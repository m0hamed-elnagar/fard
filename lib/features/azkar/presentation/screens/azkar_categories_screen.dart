import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/azkar_bloc.dart';
import 'azkar_list_screen.dart';

class AzkarCategoriesScreen extends StatelessWidget {
  const AzkarCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الأذكار',
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AzkarBloc, AzkarState>(
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const Center(child: CircularProgressIndicator()),
            categoriesLoaded: (categories) => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _CategoryCard(category: categories[index]);
              },
            ),
            error: (message) => Center(child: Text(message)),
            orElse: () {
              context.read<AzkarBloc>().add(const AzkarEvent.loadCategories());
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          category,
          style: GoogleFonts.amiri(fontSize: 18, fontWeight: FontWeight.w600),
          textAlign: TextAlign.right,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: context.read<AzkarBloc>(),
                child: AzkarListScreen(category: category),
              ),
            ),
          );
        },
      ),
    );
  }
}
