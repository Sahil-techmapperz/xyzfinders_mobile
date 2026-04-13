
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    print('Testing Categories API...');
    final catRes = await dio.get('http://localhost:3000/api/categories');
    final data = catRes.data['data'] as List;
    print('Categories Count: ${data.length}');
    
    int? reId, carId, elecId, mobId;
    for (var cat in data) {
      final name = cat['name'].toString().toLowerCase();
      print('ID: ${cat['id']}, Name: ${cat['name']}');
      if (name.contains('real estate') || name.contains('property')) reId = cat['id'];
      if (name.contains('automobile') || name.contains('car')) carId = cat['id'];
      if (name.contains('electronic')) elecId = cat['id'];
      if (name.contains('mobile')) mobId = cat['id'];
    }

    print('\nChecking Target IDs: RE:$reId, CAR:$carId, ELEC:$elecId, MOB:$mobId');

    Future<void> checkProducts(String label, int? id) async {
      if (id == null) {
        print('$label: Category ID not found');
        return;
      }
      try {
        final res = await dio.get('http://localhost:3000/api/products?category_id=$id');
        final prods = res.data['data'] as List;
        print('$label (ID:$id): Found ${prods.length} products');
      } catch (e) {
        print('$label (ID:$id): Error: $e');
      }
    }

    await checkProducts('Real Estate', reId);
    await checkProducts('Automobiles', carId);
    await checkProducts('Electronics', elecId);
    await checkProducts('Mobiles', mobId);

  } catch (e) {
    print('Error: $e');
  }
}
