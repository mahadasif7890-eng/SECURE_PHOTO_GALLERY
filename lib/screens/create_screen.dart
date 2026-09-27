import 'package:flutter/material.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Text(
                'Create',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildCreateTile(
                  context,
                  title: 'Collage',
                  subtitle: 'Combine 2 to 9 photos into artistic layouts',
                  icon: Icons.grid_view_rounded,
                  color: Colors.pinkAccent,
                ),
                _buildCreateTile(
                  context,
                  title: 'Highlight Video',
                  subtitle: 'Create a video with music from your best moments',
                  icon: Icons.movie_creation_outlined,
                  color: Colors.indigoAccent,
                ),
                _buildCreateTile(
                  context,
                  title: 'Cinematic Photo',
                  subtitle: 'Add 3D depth and motion to your 2D portraits',
                  icon: Icons.auto_awesome,
                  color: Colors.amber.shade700,
                ),
                _buildCreateTile(
                  context,
                  title: 'Animation / GIF',
                  subtitle: 'Create moving photo loops from burst shots',
                  icon: Icons.animation_rounded,
                  color: Colors.teal,
                ),
                _buildCreateTile(
                  context,
                  title: 'Photo Book',
                  subtitle: 'Design printed albums from your vacation trip',
                  icon: Icons.book_outlined,
                  color: Colors.deepOrange,
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(fontSize: 13)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Starting "$title" creation workflow'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }
}
