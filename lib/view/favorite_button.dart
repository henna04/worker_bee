import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteButton extends StatefulWidget {
  final String workerId;

  const FavoriteButton({super.key, required this.workerId});

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
          .eq('worker_id', widget.workerId)
          .eq('user_id', _supabase.auth.currentUser!.id)
          .single();

      if (mounted) {
        setState(() {
          _isFavorite = true;
          _loading = false;
        });
      }
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        // No rows found means not a favorite
        if (mounted) {
          setState(() {
            _isFavorite = false;
            _loading = false;
          });
        }
      } else {
        // Handle other potential errors
        print('Error checking favorite: $e');
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
            .eq('worker_id', widget.workerId)
            .eq('user_id', _supabase.auth.currentUser!.id);
      } else {
        await _supabase.from('favorites').insert({
          'worker_id': widget.workerId,
          'user_id': _supabase.auth.currentUser!.id,
        });
      }
      setState(() => _isFavorite = !_isFavorite);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _loading = false);
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
