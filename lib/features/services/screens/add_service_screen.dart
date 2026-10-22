import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/providers/service_provider.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});
  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _imageUrlController = TextEditingController();
  String _selectedCategory = 'Hair';
  File? _selectedImage;
  bool _isLoading = false;
  final _picker = ImagePicker();
  // Keep API category values stable; only localize their presentation.
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
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choisir dans la galerie'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery)),
              ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Prendre une photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera)),
            ])));
    if (source == null) return;
    try {
      final image = await _picker.pickImage(
          source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
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

  void _message(String text, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(text),
          backgroundColor: error ? AppColors.error : AppColors.success));

  Future<void> _saveService() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final provider = context.read<ServiceProvider>();
    bool success = false;
    try {
      success = await provider.createService(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          durationMinutes: int.parse(_durationController.text.trim()),
          category: _selectedCategory,
          imageUrl: _selectedImage == null &&
                  _imageUrlController.text.trim().isNotEmpty
              ? _imageUrlController.text.trim()
              : null,
          imageFile: _selectedImage);
    } catch (_) {
      if (mounted) _message('Impossible de créer le service.', error: true);
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      _message('Service ajouté avec succès');
      context.pop();
    } else {
      _message('Impossible de créer le service. Réessayez.', error: true);
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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: const Text('Nouveau service'),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop())),
        bottomNavigationBar: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                    text: 'Enregistrer',
                    isLoading: _isLoading,
                    onPressed: _saveService))),
        body: Form(
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
                        if (_selectedImage != null)
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(_selectedImage!,
                                  width: 60, height: 60, fit: BoxFit.cover))
                        else
                          const Icon(Icons.add_a_photo_outlined,
                              color: AppColors.accent),
                        const SizedBox(width: 16),
                        const Expanded(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Ajouter une photo',
                                  style: TextStyle(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w700)),
                              Text('Appareil photo ou galerie · JPG, PNG',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textLight)),
                            ])),
                        const Icon(Icons.add, color: AppColors.primary),
                      ]))),
              const SizedBox(height: 20),
              CustomTextField(
                  controller: _nameController,
                  label: 'Nom du service',
                  hintText: 'Ex. Soin du visage hydratant',
                  validator: _required),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items: _categories.entries
                      .map((e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)))
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
                        hintText: 'Ex. 8000',
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
                  hintText:
                      'Décrivez la prestation, ce qui est inclus et les préparatifs.',
                  maxLines: 4,
                  validator: _required),
              const SizedBox(height: 16),
              if (_selectedImage == null)
                ExpansionTile(
                    title: const Text('Lien de photo (facultatif)',
                        style: TextStyle(fontSize: 13)),
                    children: [
                      CustomTextField(
                          controller: _imageUrlController,
                          label: 'URL de la photo',
                          keyboardType: TextInputType.url),
                    ]),
              const SizedBox(height: 16),
              const Text(
                  'Votre service sera visible dans votre catalogue après enregistrement.',
                  style: TextStyle(color: AppColors.textLight, fontSize: 12)),
            ])),
      );
}
