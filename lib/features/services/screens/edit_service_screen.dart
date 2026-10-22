import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/service_provider.dart';
import '../../../core/models/service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_dropdown.dart';

class EditServiceScreen extends StatefulWidget {
  final String serviceId;
  const EditServiceScreen({super.key, required this.serviceId});
  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _selectedCategory = 'Hair';
  bool _isAvailable = true;
  File? _selectedImage;
  Service? _service;
  bool _isLoading = true;
  String? _currentImageUrl;
  final _picker = ImagePicker();
  static const _categories = {
    'Hair': 'Coiffure',
    'Nails': 'Ongles',
    'Skincare': 'Soins',
    'Makeup': 'Maquillage',
    'Massage': 'Massage',
    'Eyebrows': 'Sourcils',
    'Eyelashes': 'Cils',
    'Other': 'Autre'
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadService());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/my-services');
    }
  }

  void _message(String text, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(text),
          backgroundColor: error ? AppColors.error : AppColors.success));

  Future<void> _loadService() async {
    final service = await context
        .read<ServiceProvider>()
        .fetchServiceById(int.parse(widget.serviceId));
    if (!mounted) return;
    if (service == null) {
      _message('Service introuvable', error: true);
      _back();
      return;
    }
    setState(() {
      _service = service;
      _nameController.text = service.name;
      _descriptionController.text = service.description;
      _priceController.text = service.price.toString();
      _durationController.text = service.durationMinutes.toString();
      _imageUrlController.text = service.imageUrl ?? '';
      _currentImageUrl = service.imageUrl;
      _selectedCategory = service.category;
      _isAvailable = service.isAvailable;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SafeArea(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                  leading: const Icon(LucideIcons.image),
                  title: const Text('Choisir dans la galerie'),
                  onTap: () => Navigator.pop(context, 'gallery')),
              ListTile(
                  leading: const Icon(LucideIcons.camera),
                  title: const Text('Prendre une photo'),
                  onTap: () => Navigator.pop(context, 'camera')),
              if (_selectedImage != null || _currentImageUrl != null)
                ListTile(
                    leading: const Icon(LucideIcons.trash,
                        color: AppColors.error),
                    title: const Text('Supprimer la photo'),
                    onTap: () => Navigator.pop(context, 'remove')),
            ])));
    if (source == null || !mounted) return;
    if (source == 'remove') {
      setState(() {
        _selectedImage = null;
        _currentImageUrl = null;
        _imageUrlController.clear();
      });
      return;
    }
    try {
      final image = await _picker.pickImage(
          source:
              source == 'camera' ? ImageSource.camera : ImageSource.gallery);
      if (image != null && mounted)
        setState(() {
          _selectedImage = File(image.path);
          _imageUrlController.clear();
        });
    } catch (_) {
      if (mounted)
        _message('Impossible de sélectionner la photo.', error: true);
    }
  }

  Future<void> _updateService() async {
    final provider = context.read<ServiceProvider>();
    if (provider.isLoading || !_formKey.currentState!.validate()) return;
    final success = await provider.updateService(
        serviceId: widget.serviceId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        durationMinutes: int.parse(_durationController.text.trim()),
        category: _selectedCategory,
        imageUrl: _selectedImage == null &&
                _imageUrlController.text.trim().isNotEmpty
            ? _imageUrlController.text.trim()
            : (_selectedImage == null && _imageUrlController.text.trim().isEmpty
                ? ''
                : null),
        imageFile: _selectedImage,
        isAvailable: _isAvailable);
    if (!mounted) return;
    if (success) {
      _message('Service modifié avec succès');
      _back();
    } else {
      _message('Impossible de modifier le service. Réessayez.', error: true);
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Ce champ est obligatoire' : null;
  String? _price(String? value) =>
      (double.tryParse(value?.trim() ?? '') ?? 0) <= 0
          ? 'Saisissez un prix valide'
          : null;
  String? _duration(String? value) =>
      (int.tryParse(value?.trim() ?? '') ?? 0) <= 0
          ? 'Saisissez une durée valide'
          : null;

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<ServiceProvider>().isLoading;
    final categories = {
      ..._categories,
      if (!_categories.containsKey(_selectedCategory))
        _selectedCategory: _selectedCategory
    };
    return Scaffold(
      appBar: AppBar(
          title: const Text('Modifier le service'),
          leading:
              IconButton(icon: const Icon(LucideIcons.arrowLeft), onPressed: _back)),
      bottomNavigationBar: _isLoading
          ? null
          : SafeArea(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                      text: 'Enregistrer les modifications',
                      isLoading: busy,
                      onPressed: _updateService))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                const Text('CATALOGUE · PRESTATAIRE',
                    style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                        height: 90,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: AppColors.navyBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider)),
                        child: Row(children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: _selectedImage != null
                                      ? Image.file(_selectedImage!,
                                          fit: BoxFit.cover)
                                      : _currentImageUrl != null &&
                                              _currentImageUrl!.isNotEmpty
                                          ? Image.network(_currentImageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  const Icon(
                                                      Icons
                                                          .add_a_photo_outlined,
                                                      color: AppColors.accent))
                                          : const Icon(
                                              LucideIcons.imagePlus,
                                              color: AppColors.accent))),
                          const SizedBox(width: 12),
                          const Expanded(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Modifier la photo',
                                    style: TextStyle(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w700)),
                                Text('Appareil photo ou galerie · JPG, PNG',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textLight)),
                              ])),
                          const Icon(LucideIcons.plus, color: AppColors.primary),
                        ]))),
                const SizedBox(height: 20),
                CustomTextField(
                    controller: _nameController,
                    label: 'Nom du service',
                    validator: _required),
                const SizedBox(height: 16),
                CustomDropdown<String>(
                    label: 'Catégorie',
                    hintText: 'Choisissez une catégorie',
                    value: _selectedCategory,
                    items: categories.entries
                        .map((e) => DropdownMenuItem(
                            value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null)
                        setState(() => _selectedCategory = value);
                    }),
                const SizedBox(height: 16),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: CustomTextField(
                          controller: _priceController,
                          label: 'Prix · CFA',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: _price)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: CustomTextField(
                          controller: _durationController,
                          label: 'Durée · minutes',
                          keyboardType: TextInputType.number,
                          validator: _duration)),
                ]),
                const SizedBox(height: 12),
                Wrap(
                    spacing: 8,
                    children: [15, 30, 45, 60, 90]
                        .map((minutes) => ChoiceChip(
                            label: Text('$minutes min'),
                            selected: _durationController.text == '$minutes',
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                                color: _durationController.text == '$minutes'
                                    ? Colors.white
                                    : AppColors.primary,
                                fontSize: 11),
                            onSelected: (_) => setState(
                                () => _durationController.text = '$minutes')))
                        .toList()),
                const SizedBox(height: 16),
                CustomTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    maxLines: 4,
                    validator: _required),
                const SizedBox(height: 16),
                SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Service actif'),
                    subtitle: Text(_isAvailable
                        ? 'Visible et disponible à la réservation'
                        : 'Masqué dans le catalogue'),
                    value: _isAvailable,
                    activeTrackColor: AppColors.primary,
                    onChanged: (value) => setState(() => _isAvailable = value)),
                if (_service != null) const SizedBox(height: 16),
              ])),
    );
  }
}
