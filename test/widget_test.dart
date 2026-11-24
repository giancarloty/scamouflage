import 'package:flutter_test/flutter_test.dart';
import 'package:scamouflage/services/generator.dart';

void main(){
  test('procedural case builder yields nonempty fictional content',(){
    final result=CaseGenerator(142).generate(1,seed:142);
    expect(result.cases,isNotEmpty);
    for(final c in result.cases){
      expect(c.author,isNotEmpty);
      expect(c.body,isNotEmpty);
      expect(c.clues.length,3);
    }
  });
}
