import 'package:flutter/material.dart';
import 'package:virtual_try_on_app/models/product_model.dart';
import 'package:virtual_try_on_app/screens/product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Product list
  final List<ProductModel> products = [
    ProductModel()
      ..setName = "Test Ring"
      ..setIsARSupported = true
      ..setModelPath = "assets/3DModels/TestRing/TestRing.glb"
      ..setVirtualImagePath = "assets/images/Rings/TestRing/virtual.png",
    ProductModel()
      ..setName = "Silver Ring (Zigzag)"
      ..setIsARSupported = true
      ..setModelPath = "assets/3DModels/SilverRing_Zigzag/SilverRing_Zigzag.glb"
      ..setRealImagePath = "assets/images/Rings/SilverRing_Zigzag/real.jpg"
      ..setVirtualImagePath = "assets/images/Rings/SilverRing_Zigzag/virtual.png",
    ProductModel()
      ..setName = "Blue Ring"
      ..setIsARSupported = true
      ..setModelPath = "assets/3DModels/BlueRing/BlueRing.glb"
      ..setRealImagePath = "assets/images/Rings/BlueRing/real.jpg"
      ..setVirtualImagePath = "assets/images/Rings/BlueRing/virtual.png",
    ProductModel()
      ..setName = "Silver Ring (Wire Wrapping)"
      ..setIsARSupported = true
      ..setModelPath = "assets/3DModels/SilverRing_WireWrapping/SilverRing_WireWrapping.glb"
      ..setRealImagePath = "assets/images/Rings/SilverRing_WireWrapping/real.jpg"
      ..setVirtualImagePath = "assets/images/Rings/SilverRing_WireWrapping/virtual.png",
    ProductModel()
      ..setName = "Silver Ring"
      ..setIsARSupported = false
      ..setRealImagePath = "assets/images/Rings/SilverRing/real.jpg"
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return ListView.builder(
      cacheExtent: 1000,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(product: product);
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductScreen(product: product),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
              if (product.realImagePath.isNotEmpty || product.virtualImagePath.isNotEmpty)
                Image.asset(product.realImagePath.isNotEmpty ? product.realImagePath : product.virtualImagePath,
                  fit: BoxFit.scaleDown,
                ),
            ],
          ),
        ),
      ),
    );
  }
}