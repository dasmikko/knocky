import 'package:bbob_dart/bbob_dart.dart' as bbob;

class BBCodeParser implements bbob.NodeVisitor {
  List<bbob.Node> parse(String text) {
    // Remove bad empty properties
    String cleanedText = text.replaceAll('href=""', '');
    
    var ast = bbob.parse(cleanedText);
    return ast;
  }

  void visitText(bbob.Text text) {
  }

  bool visitElementBefore(bbob.Element element) {
    return true;
  }

  void visitElementAfter(bbob.Element element) {
  }    
}