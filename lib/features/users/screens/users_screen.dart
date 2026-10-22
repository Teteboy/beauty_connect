import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/search_field.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final currentUser = context.read<AuthProvider>().user;
      if (currentUser == null) throw Exception('Utilisateur non connecté');
      final targetRole =
          currentUser.role == 'technician' ? 'customer' : 'technician';
      final response = await ApiService.get('/auth/users?role=$targetRole');
      if (mounted) {
        setState(() {
          _users = response['users'] ?? [];
          _isLoading = false;
        });
        _filterUsers(_searchController.text);
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _error = 'Impossible de charger les utilisateurs.';
          _isLoading = false;
        });
    }
  }

  void _filterUsers(String query) => setState(() {
        final search = query.toLowerCase();
        _filteredUsers = _users
            .where((user) =>
                '${user['firstName']} ${user['lastName']}'
                    .toLowerCase()
                    .contains(search) ||
                (user['location'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(search) ||
                (user['specialty'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains(search))
            .toList();
      });
  void _startChat(dynamic user) {
    Navigator.pop(context);
    context.go('/chat/${user['id']}');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AuthProvider>().user?.role == 'technician';
    return Scaffold(
        backgroundColor: AppColors.navyBackground,
        appBar: AppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            title: Text(
                provider ? 'Trouver des clients' : 'Trouver des prestataires'),
            leading: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back))),
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: SearchField(
                  controller: _searchController,
                  hintText: 'Nom, lieu ou spécialité…',
                  onChanged: _filterUsers,
                  showFilterButton: false)),
          Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 48),
                          const SizedBox(height: 16),
                          Text(_error!),
                          TextButton(
                              onPressed: _loadUsers,
                              child: const Text('Réessayer'))
                        ]))
                      : _filteredUsers.isEmpty
                          ? Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.people_outline,
                                            color: AppColors.primary, size: 64),
                                        const SizedBox(height: 16),
                                        Text(
                                            _searchController.text.isEmpty
                                                ? 'Aucun utilisateur disponible'
                                                : 'Aucun résultat',
                                            style: const TextStyle(
                                                color: AppColors.primaryDark,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 8),
                                        const Text(
                                            'Essayez de modifier votre recherche.',
                                            textAlign: TextAlign.center),
                                      ])))
                          : RefreshIndicator(
                              onRefresh: _loadUsers,
                              child: ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _filteredUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = _filteredUsers[index];
                                    final first =
                                        (user['firstName'] ?? '').toString();
                                    final last =
                                        (user['lastName'] ?? '').toString();
                                    final image =
                                        user['profileImage'] as String?;
                                    return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: AppColors.cardShadow),
                                        child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.all(16),
                                            onTap: () => _startChat(user),
                                            leading: CircleAvatar(
                                                radius: 28,
                                                backgroundColor:
                                                    AppColors.navyBackground,
                                                backgroundImage: image != null &&
                                                        image.isNotEmpty
                                                    ? CachedNetworkImageProvider(
                                                        image)
                                                    : null,
                                                child: image == null ||
                                                        image.isEmpty
                                                    ? Text(
                                                        '${first.isEmpty ? '' : first[0]}${last.isEmpty ? '' : last[0]}'
                                                            .toUpperCase(),
                                                        style: const TextStyle(
                                                            color: AppColors.primary,
                                                            fontWeight: FontWeight.w700))
                                                    : null),
                                            title: Text('$first $last', style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
                                            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                              if ((user['specialty'] ?? '')
                                                  .toString()
                                                  .isNotEmpty)
                                                Text(user['specialty'],
                                                    style: const TextStyle(
                                                        color:
                                                            AppColors.primary)),
                                              if ((user['location'] ?? '')
                                                  .toString()
                                                  .isNotEmpty)
                                                Text(user['location']),
                                              if ((user['bio'] ?? '')
                                                  .toString()
                                                  .isNotEmpty)
                                                Text(user['bio'],
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                            ]),
                                            trailing: const CircleAvatar(backgroundColor: AppColors.orangePale, child: Icon(Icons.chat_bubble_outline, color: AppColors.accent, size: 20))));
                                  }))),
        ]));
  }
}
