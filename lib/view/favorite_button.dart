import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteButton extends StatefulWidget {
  final String userId; // This is the ID of the user being favorited
  const FavoriteButton({super.key, required this.userId});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final _supabase = Supabase.instance.client;
  bool _isFavorite = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    try {
      final response = await _supabase
          .from('favorites')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('worker_id',
              widget.userId) // Using worker_id as it exists in your schema
          .maybeSingle();

      if (mounted) {
        setState(() {
          _isFavorite = response != null;
          _loading = false;
        });
      }
    } catch (e) {
      log('Error in _checkIfFavorite: ${e.toString()}');
      if (mounted) {
        setState(() {
          _isFavorite = false;
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      if (_isFavorite) {
        await _supabase
            .from('favorites')
            .delete()
            .eq('user_id', _supabase.auth.currentUser!.id)
            .eq('worker_id',
                widget.userId); // Using worker_id to match your schema
      } else {
        await _supabase.from('favorites').insert({
          'user_id': _supabase.auth.currentUser!.id,
          'worker_id': widget.userId, // Using worker_id to match your schema
        });
      }

      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
    } catch (e) {
      log('Error in _toggleFavorite: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _toggleFavorite,
      icon: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(),
            )
          : Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
    );
  }
}
