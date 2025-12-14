import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import 'category_posts_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();

    // 🔥 Pedir categorías solo si no existen
    final bloc = context.read<NewsBloc>();
    if (bloc.state is! CategoriesLoaded) {
      bloc.add(FetchCategories());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías'), centerTitle: true),
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          // 🔄 Loading
          if (state is NewsInitial || state is NewsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (state is NewsError) {
            return Center(child: Text(state.message));
          }

          // ✅ Categorías cargadas
          if (state is CategoriesLoaded) {
            if (state.categories.isEmpty) {
              return const Center(
                child: Text(
                  'No hay categorías',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.4,
              ),
              itemCount: state.categories.length,
              itemBuilder: (_, i) {
                final cat = state.categories[i];

                return GestureDetector(
                  onTap: () {
                    // 🔥 pedir posts de la categoría
                    context.read<NewsBloc>().add(
                      FetchPostsByCategory(cat['id'], cat['name']),
                    );

                    // 🔥 navegar
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryPostsScreen(
                          categoryId: cat['id'],
                          categoryName: cat['name'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      cat['name'].toString().toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                );
              },
            );
          }

          // 🧼 Fallback seguro
          return const Center(child: Text('No hay datos disponibles'));
        },
      ),
    );
  }
}
