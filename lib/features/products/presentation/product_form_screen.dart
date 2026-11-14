import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/role.dart';
import '../../../core/format/rupiah_input.dart';
import '../application/product_providers.dart';
import '../domain/product.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.existing});

  final Product? existing;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  String? _categoryId;
  XFile? _pickedPhoto;
  Uint8List? _pickedPhotoBytes;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _skuController = TextEditingController(text: existing?.sku ?? '');
    _priceController = TextEditingController(
      text: existing == null ? '' : formatRupiah(existing.price),
    );
    _stockController = TextEditingController(text: existing?.stockQty.toString() ?? '0');
    _categoryId = existing?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _pickedPhoto = file;
      _pickedPhotoBytes = bytes;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(productRepositoryProvider);
      String? photoUrl = widget.existing?.photoUrl;
      if (_pickedPhoto != null) {
        photoUrl = await repository.uploadPhoto(_pickedPhoto!);
      }

      final product = Product(
        id: widget.existing?.id ?? '',
        name: _nameController.text.trim(),
        sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
        price: parseRupiah(_priceController.text),
        stockQty: int.parse(_stockController.text),
        isActive: true,
        categoryId: _categoryId,
        photoUrl: photoUrl,
      );

      if (_isEditing) {
        await repository.update(widget.existing!.id, product);
      } else {
        await repository.create(product);
      }

      if (mounted) context.pop();
    } catch (e) {
      setState(() => _errorMessage = 'Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(currentRoleProvider).value == AppRole.admin;
    if (!isAdmin) {
      return const Scaffold(body: Center(child: Text('Akses ditolak. Hanya admin yang bisa mengelola produk.')));
    }

    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Ubah Produk' : 'Tambah Produk')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _pickedPhotoBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(_pickedPhotoBytes!, fit: BoxFit.cover),
                        )
                      : (widget.existing?.photoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(widget.existing!.photoUrl!, fit: BoxFit.cover),
                            )
                          : const Center(child: Icon(Icons.add_a_photo_outlined, size: 32))),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(labelText: 'SKU (opsional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: const [RupiahInputFormatter()],
                decoration: const InputDecoration(labelText: 'Harga', prefixText: 'Rp '),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Harga wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stok'),
                validator: (v) => (int.tryParse(v ?? '') == null) ? 'Stok tidak valid' : null,
              ),
              const SizedBox(height: 12),
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Kategori (opsional)'),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Gagal memuat kategori: $err'),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null) ...[
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              FilledButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
