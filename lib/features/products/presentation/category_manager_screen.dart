import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/role.dart';
import '../application/product_providers.dart';

class CategoryManagerScreen extends ConsumerStatefulWidget {
  const CategoryManagerScreen({super.key});

  @override
  ConsumerState<CategoryManagerScreen> createState() => _CategoryManagerScreenState();
}

class _CategoryManagerScreenState extends ConsumerState<CategoryManagerScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await ref.read(categoryRepositoryProvider).create(name);
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(currentRoleProvider).value == AppRole.admin;
    if (!isAdmin) {
      return const Scaffold(body: Center(child: Text('Akses ditolak. Hanya admin yang bisa mengelola kategori.')));
    }

    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama kategori baru'),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _add, child: const Text('Tambah')),
              ],
            ),
          ),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_cafe_outlined),
                      title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref.read(categoryRepositoryProvider).delete(category.id),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Gagal memuat kategori: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
