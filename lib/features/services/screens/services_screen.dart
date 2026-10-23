import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/service_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../widgets/service_card.dart';

class ServicesScreen extends StatefulWidget {
  final bool showMyServices;
  const ServicesScreen({super.key, this.showMyServices = false});
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _availableOnly = false;
  bool _priceAscending = false;
  bool _topRated = false;
  bool _nearbyFirst = false;

  /// Quelques puces correspondent à une spécialité de prestataire
  /// (ex. Tatouage, Barbier) plutôt qu'à une catégorie de service.
  static const _specialtyLabels = {
    'Tattoo': 'Tatouage',
    'Barber': 'Barbier',
    'Wellness': 'Bien-être',
    'Fitness': 'Fitness',
    'Massage': 'Massage',
    'Hair': 'Coiffure',
    'Nails': 'Ongles',
    'Makeup': 'Maquillage',
    'Skincare': 'Esthétique',
    'Eyebrows': 'Sourcils',
    'Eyelashes': 'Cils',
    'Other': 'Autre',
  };
  static const _categories = [
    'All',
    'Hair',
    'Nails',
    'Skincare',
    'Makeup',
    'Massage',
    'Eyebrows',
    'Eyelashes',
    'Other',
    'Tattoo',
    'Barber',
    'Wellness',
    'Fitness'
  ];
  String _label(String value) =>
      value == 'All' ? 'Toutes' : ServiceCard.category(value);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadServices());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final params = GoRouterState.of(context).uri.queryParameters;
    final search = params['search'];
    final category = params['category'];
    if (search != null && search != _searchQuery) {
      _searchController.text = search;
      _searchQuery = search;
    }
    if (category != null &&
        _categories.contains(category) &&
        category != _selectedCategory) _selectedCategory = category;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadServices() {
    final provider = context.read<ServiceProvider>();
    if (widget.showMyServices) {
      provider.loadMyServices();
    } else {
      provider.fetchServices();
    }
  }

  List<Service> _filteredServices(List<Service> services) {
    final query = _searchQuery.trim().toLowerCase();
    final myCity = _cityOf(context.read<AuthProvider>().user?.location);
    final result = services.where((service) {
      final technician = service.technician;
      final specialty = technician?.specialty?.toLowerCase() ?? '';
      final chipLabel = _specialtyLabels[_selectedCategory]?.toLowerCase();
      final matchesCategory = _selectedCategory == 'All' ||
          service.category.toLowerCase() == _selectedCategory.toLowerCase() ||
          (chipLabel != null && specialty == chipLabel) ||
          specialty == _selectedCategory.toLowerCase();
      final matchesSearch = query.isEmpty ||
          service.name.toLowerCase().contains(query) ||
          service.description.toLowerCase().contains(query) ||
          service.category.toLowerCase().contains(query) ||
          _label(service.category).toLowerCase().contains(query) ||
          (technician?.fullName.toLowerCase().contains(query) ?? false) ||
          (technician?.specialty?.toLowerCase().contains(query) ?? false);
      return matchesCategory &&
          matchesSearch &&
          (!_availableOnly || service.isAvailable);
    }).toList();
    if (_topRated) {
      result.sort((a, b) => (b.technician?.ratingAvg ?? 0)
          .compareTo(a.technician?.ratingAvg ?? 0));
    } else if (_priceAscending) {
      result.sort((a, b) => a.price.compareTo(b.price));
    }
    if (_nearbyFirst && myCity != null) {
      result.sort((a, b) {
        final aNear = _cityOf(a.technician?.location) == myCity ? 0 : 1;
        final bNear = _cityOf(b.technician?.location) == myCity ? 0 : 1;
        return aNear.compareTo(bNear);
      });
    }
    return result;
  }

  static String? _cityOf(String? location) {
    if (location == null || location.isEmpty) return null;
    // Formats attendus : « Douala, Bonapriso » ou « Bonapriso, Douala »
    for (final part in location.split(',')) {
      final city = part.trim();
      if (city.toLowerCase().startsWith('douala')) return 'douala';
      if (city.toLowerCase().startsWith('yaound')) return 'yaounde';
    }
    return location.split(',').first.trim().toLowerCase();
  }

  void _showCategoryFilters() {
    showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Choisir une catégorie',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 18),
                      Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories
                              .map((category) => ChoiceChip(
                                  label: Text(_label(category)),
                                  selected: category == _selectedCategory,
                                  showCheckmark: false,
                                  onSelected: (_) {
                                    setState(
                                        () => _selectedCategory = category);
                                    Navigator.of(sheetContext).pop();
                                  }))
                              .toList()),
                    ]))));
  }

  void _reset() => setState(() {
        _searchController.clear();
        _searchQuery = '';
        _selectedCategory = 'All';
        _availableOnly = false;
        _priceAscending = false;
        _topRated = false;
        _nearbyFirst = false;
      });
  @override
  Widget build(BuildContext context) => Scaffold(
          body: SafeArea(
              child: Column(children: [
        AppHeader(
            title: widget.showMyServices ? 'Mes services' : 'Recherche',
            showNotification: !widget.showMyServices,
            showBack: widget.showMyServices,
            trailing: widget.showMyServices
                ? IconButton(
                    onPressed: () => context.go('/add-service'),
                    icon: const Icon(LucideIcons.plus))
                : null),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchField(
                controller: _searchController,
                hintText: 'Rechercher un service ou prestataire',
                onChanged: (value) => setState(() => _searchQuery = value),
                onFilterTap: _showCategoryFilters)),
        SizedBox(
            height: 68,
            child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                scrollDirection: Axis.horizontal,
                children: [
                  _chip(
                      _selectedCategory == 'All'
                          ? 'Catégorie'
                          : _label(_selectedCategory),
                      _showCategoryFilters,
                      _selectedCategory != 'All',
                      dropdown: true),
                  _chip(
                      'Prix',
                      () => setState(() => _priceAscending = !_priceAscending),
                      _priceAscending),
                  _chip('Note',
                      () => setState(() => _topRated = !_topRated), _topRated),
                  _chip(
                      'Disponible',
                      () => setState(() => _availableOnly = !_availableOnly),
                      _availableOnly),
                  _chip('Distance',
                      () => setState(() => _nearbyFirst = !_nearbyFirst),
                      _nearbyFirst),
                ])),
        Expanded(
            child: Consumer<ServiceProvider>(builder: (context, provider, _) {
          final source =
              widget.showMyServices ? provider.myServices : provider.services;
          final services = _filteredServices(source);
          if (provider.isLoading && source.isEmpty)
            return const Center(child: CircularProgressIndicator());
          if (provider.error != null && source.isEmpty)
            return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(LucideIcons.circleAlert, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              const Text('Impossible de charger les services.'),
              TextButton(
                  onPressed: _loadServices, child: const Text('Réessayer'))
            ]));
          return RefreshIndicator(
              onRefresh: () async => _loadServices(),
              child: services.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(32),
                      children: [
                          const SizedBox(height: 80),
                          const Icon(LucideIcons.searchX,
                              size: 64, color: AppColors.primary),
                          const SizedBox(height: 24),
                          Text('Aucun résultat',
                              textAlign: TextAlign.center,
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 12),
                          const Text(
                              'Rien ici pour l’instant. Essayez une autre recherche ou modifiez vos filtres.',
                              textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          CustomButton(
                              text: 'Découvrir les services',
                              isOutlined: true,
                              onPressed: _reset)
                        ])
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return ServiceCard(
                            service: service,
                            actionLabel: 'Voir profil',
                            onAction: () => context.go(
                                '/service-catalogue/${service.technicianId}'));
                      }));
        })),
      ])));
  Widget _chip(String label, VoidCallback onTap, bool selected,
          {bool dropdown = false}) =>
      Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
          label: Text(label),
          avatar: Icon(
              dropdown ? LucideIcons.chevronDown : LucideIcons.slidersHorizontal,
              size: 14, color: selected ? Colors.white : AppColors.primary),
          backgroundColor:
              selected ? AppColors.primary : AppColors.navyBackground,
          side: BorderSide.none,
          labelStyle:
              TextStyle(color: selected ? Colors.white : AppColors.primary),
          onPressed: onTap));
}
