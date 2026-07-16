import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/recipe_model.dart';

class PdfHelper {
  static Future<void> generateAndPrintRecipe(RecipeModel recipe) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(recipe.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Kategori: ${recipe.category}'),
            pw.Text('Waktu Memasak: ${recipe.cookingTime} menit'),
            pw.Text('Porsi: ${recipe.portions} orang'),
            pw.Text('Tingkat Kesulitan: ${recipe.difficulty}'),
            pw.SizedBox(height: 20),
            pw.Text('Deskripsi:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text(recipe.description),
            pw.SizedBox(height: 20),
            pw.Text('Bahan-bahan:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: recipe.ingredients.map((e) => '${e.name} (${e.amount})').join('\n')),
            pw.SizedBox(height: 20),
            pw.Text('Langkah-langkah:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ...recipe.steps.map((step) => pw.Text('${step.order}. ${step.description}')),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
