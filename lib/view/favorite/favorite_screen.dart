import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:worker_bee/view/favorite_button.dart';
import 'package:worker_bee/view/workerDetails/worker_details.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    try {
      final favorites = await _supabase
          .from('favorites')
          .select('worker_id')
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('created_at');

      final List<Future<Map<String, dynamic>>> workerFutures =
          favorites.map((favorite) async {
        return await _supabase
            .from('users')
            .select()
            .eq('id', favorite['worker_id'])
            .single();
      }).toList();

      final workers = await Future.wait(workerFutures);

      setState(() {
        _favorites = workers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching favorites: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(child: Text('No favorites yet'))
              : ListView.builder(
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final worker = _favorites[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(worker['image_url'] ?? ""),
                        ),
                        title: Text(worker['user_name'] ?? 'Unknown'),
                        subtitle: Text(worker['profession'] ?? 'No profession'),
                        trailing:
                            FavoriteButton(userId: worker['id'].toString()),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WorkerDetails(workerId: worker['id']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
