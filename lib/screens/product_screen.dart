import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:virtual_try_on_app/models/product_model.dart';
import 'package:virtual_try_on_app/screens/arcore_screen.dart';

class ProductScreen extends StatelessWidget {
  final ProductModel product;
  const ProductScreen({Key? key, required this.product}) : super(key: key);

  static const Widget spaceBetweenRows = SizedBox(height: 16);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: Text(product.name)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${product.name}', style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Text('AR Supported: ${product.isARSupported ? "Yes" : "No"}'),
              spaceBetweenRows,
              (product.isARSupported && product.modelPath.isNotEmpty) ? SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ARCoreScreen(product: product)),
                    );
                  },
                  child: const Text('Virtual Try On'),
                ),
              ) : const SizedBox.shrink(),
              spaceBetweenRows,
              TabBar(
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: const [
                  Tab(text: 'Image'),
                  Tab(text: '3D Model'),
                ],
              ),
              spaceBetweenRows,
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildImageTab(),
                    _build3DModelTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageTab() {
    String imagePath = product.realImagePath.isNotEmpty
        ? product.realImagePath
        : product.virtualImagePath;

    if (imagePath.isEmpty) {
      return const Center(child: Text("No image available"));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }

  Widget _build3DModelTab() {
    if (!product.isARSupported || product.modelPath.isEmpty) {
      return const Center(child: Text("3D Model is not available"));
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Flutter3DViewer(
          src: product.modelPath,
        ),
      ),
    );
  }
}
