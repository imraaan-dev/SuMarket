//this our unit test: checking that the path based on category helper function works correctly for the fridge category.
import 'package:su_fridges/utils/image_helper.dart';
import 'package:test/test.dart';

void main() {
  test('image helper path based on category helper function test', () {
    
    final path = ImageHelper.getAssetPathForCategory('fridges');
    expect(path, 'assets/images/fridge_image.jpg');
  });
}