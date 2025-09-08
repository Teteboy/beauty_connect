import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_provider.dart';
import '../../../core/models/service.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  String _selectedFilter = 'All';
  String _sortBy = 'Name';

  @override
  void initState() {
    super.initState();
    _loadMyServices();
  }

  void _loadMyServices() {
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser != null && currentUser.role == 'technician') {
      context.read<ServiceProvider>().loadMyServices();
    }
  }

  List<Service> _getFilteredAndSortedServices(List<Service> services) {
    List<Service> filtered = services;
    
    // Apply filter
    if (_selectedFilter != 'All') {
      if (_selectedFilter == 'Active') {
        filtered = services.where((s) => s.isAvailable).toList();
      } else if (_selectedFilter == 'Paused') {
        filtered = services.where((s) => !s.isAvailable).toList();
      } else {
        filtered = services.where((s) => s.category == _selectedFilter).toList();
      }
    }
    
    // Apply sorting
    switch (_sortBy) {
      case 'Name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Price':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Category':
        filtered.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'Duration':
        filtered.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
        break;
    }
    
    return filtered;
  }

  void _toggleServiceAvailability(Service service) async {
    final serviceProvider = context.read<ServiceProvider>();
    final success = await serviceProvider.updateService(
      serviceId: service.id.toString(),
      isAvailable: !service.isAvailable,
    );

    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(serviceProvider.error ?? 'Failed to update service'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteService(Service service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final serviceProvider = context.read<ServiceProvider>();
      final success = await serviceProvider.deleteService(service.id.toString());
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(serviceProvider.error ?? 'Failed to delete service'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthProvider>().user;
    
    if (currentUser?.role != 'technician') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Services'),
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: const Center(
          child: Text('Only technicians can manage services'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Services'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'Price', child: Text('Sort by Price')),
              const PopupMenuItem(value: 'Category', child: Text('Sort by Category')),
              const PopupMenuItem(value: 'Duration', child: Text('Sort by Duration')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort),
                  const SizedBox(width: 4),
                  Text(_sortBy, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ServiceProvider>(
        builder: (context, serviceProvider, _) {
          if (serviceProvider.isLoading && serviceProvider.myServices.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (serviceProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(serviceProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadMyServices,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredServices = _getFilteredAndSortedServices(serviceProvider.myServices);

          if (serviceProvider.myServices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.spa, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No services yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first service to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/add-service'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Service'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter Chips
              Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All (${serviceProvider.myServices.length})',
                        isSelected: _selectedFilter == 'All',
                        onSelected: () => setState(() => _selectedFilter = 'All'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Active (${serviceProvider.myServices.where((s) => s.isAvailable).length})',
                        isSelected: _selectedFilter == 'Active',
                        onSelected: () => setState(() => _selectedFilter = 'Active'),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Paused (${serviceProvider.myServices.where((s) => !s.isAvailable).length})',
                        isSelected: _selectedFilter == 'Paused',
                        onSelected: () => setState(() => _selectedFilter = 'Paused'),
                      ),
                      const SizedBox(width: 8),
                      // Category filters
                      ...serviceProvider.myServices
                          .map((s) => s.category)
                          .toSet()
                          .map((category) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _FilterChip(
                                  label: category,
                                  isSelected: _selectedFilter == category,
                                  onSelected: () => setState(() => _selectedFilter = category),
                                ),
                              )),
                    ],
                  ),
                ),
              ),
              
              // Services List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadMyServices(),
                  child: filteredServices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.filter_list, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No services match "$_selectedFilter"',
                                style: const TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => setState(() => _selectedFilter = 'All'),
                                child: const Text('Clear Filter'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = filteredServices[index];
                            return _ServiceCard(
                              service: service,
                              onToggleAvailability: () => _toggleServiceAvailability(service),
                              onDelete: () => _deleteService(service),
                              onTap: () => context.go('/service/${service.id}'),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-service'),
        child: const Icon(Icons.add),
        tooltip: 'Add Service',
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onToggleAvailability;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.onToggleAvailability,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            if (service.imageUrl != null && service.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  child: Image.network(
                    service.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.spa,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Icon(
                  Icons.spa,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
            
            // Service Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and menu
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                service.category,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Availability Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: service.isAvailable 
                              ? Colors.green.withOpacity(0.1) 
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: service.isAvailable ? Colors.green : Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              service.isAvailable ? Icons.check_circle : Icons.pause_circle,
                              size: 16,
                              color: service.isAvailable ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.isAvailable ? 'Active' : 'Paused',
                              style: TextStyle(
                                fontSize: 12,
                                color: service.isAvailable ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              context.go('/edit-service/${service.id}');
                              break;
                            case 'toggle':
                              onToggleAvailability();
                              break;
                            case 'delete':
                              onDelete();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit Service'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  service.isAvailable 
                                      ? Icons.visibility_off 
                                      : Icons.visibility,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  service.isAvailable 
                                      ? 'Make Unavailable' 
                                      : 'Make Available',
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    service.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  
                  // Price and Duration Row
                  Row(
                    children: [
                      // Price
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            Text(
                              '${service.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Duration
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${service.durationMinutes} min',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      
                      // Quick Actions
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.go('/edit-service/${service.id}'),
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit Service',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              foregroundColor: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => context.go('/service/${service.id}'),
                            icon: const Icon(Icons.visibility),
                            tooltip: 'View Details',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.green.withOpacity(0.1),
                              foregroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}



