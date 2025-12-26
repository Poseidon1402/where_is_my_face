import 'dart:typed_data';

import 'package:flutter/material.dart';

class ExtractedFacesDialog extends StatefulWidget {
  final List<Uint8List> faces;

  const ExtractedFacesDialog({super.key, required this.faces});

  @override
  State<ExtractedFacesDialog> createState() => _ExtractedFacesDialogState();
}

class _ExtractedFacesDialogState extends State<ExtractedFacesDialog> {
  final Set<int> _selectedFaces = {};

  @override
  void initState() {
    super.initState();
    // If only one face, select it by default
    if (widget.faces.length == 1) {
      _selectedFaces.add(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSingleFace = widget.faces.length == 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2C38),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Badge
            _buildStatusBadge(isSingleFace),

            const SizedBox(height: 24),

            // Title
            Text(
              isSingleFace ? 'Face Extracted' : 'Select Faces',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            // Face(s) Display
            if (isSingleFace) _buildSingleFace() else _buildMultipleFaces(),

            const SizedBox(height: 24),

            // Description Text
            Text(
              isSingleFace
                  ? 'The facial features have been successfully isolated. What would you like to do with this capture?'
                  : 'Tap a thumbnail to view details. Choose to save the selected face or save all detected faces.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            if (isSingleFace)
              _buildSingleFaceButtons()
            else
              _buildMultipleFacesButtons(),

            const SizedBox(height: 16),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white38, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isSingleFace) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.5), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSingleFace ? Icons.check_circle : Icons.tag_faces,
            color: Colors.cyan,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isSingleFace ? 'SUCCESS' : '${widget.faces.length} FACES DETECTED',
            style: const TextStyle(
              color: Colors.cyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleFace() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3), width: 3),
      ),
      child: ClipOval(child: Image.memory(widget.faces[0], fit: BoxFit.cover)),
    );
  }

  Widget _buildMultipleFaces() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: widget.faces.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFaces.contains(index);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedFaces.remove(index);
                } else {
                  _selectedFaces.add(index);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.cyan : Colors.white24,
                        width: isSelected ? 4 : 2,
                      ),
                    ),
                    child: ClipOval(
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          isSelected
                              ? Colors.transparent
                              : Colors.black.withValues(alpha: 0.6),
                          BlendMode.darken,
                        ),
                        child: Image.memory(
                          widget.faces[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.cyan,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSingleFaceButtons() {
    return Column(
      children: [
        // Save to Storage Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Save to storage action
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Face saved to storage')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download, size: 24),
                SizedBox(width: 12),
                Text(
                  'Save to Storage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Take Picture Again Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 24),
                SizedBox(width: 12),
                Text(
                  'Take Picture Again',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleFacesButtons() {
    return Column(
      children: [
        // Save Selected Face Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _selectedFaces.isEmpty
                ? null
                : () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${_selectedFaces.length} face(s) saved to storage',
                        ),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedFaces.isEmpty
                  ? Colors.grey
                  : Colors.cyan,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, size: 24),
                SizedBox(width: 12),
                Text(
                  'Save Selected Face',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Save All Faces Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${widget.faces.length} faces saved to storage',
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, size: 24),
                SizedBox(width: 12),
                Text(
                  'Save All Faces',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Take Picture Again Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 24),
                SizedBox(width: 12),
                Text(
                  'Take Picture Again',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
