import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Biodata Mahasiswa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
        useMaterial3: true,
      ),
      home: const BiodataFormPage(),
    );
  }
}

class BiodataFormPage extends StatefulWidget {
  const BiodataFormPage({super.key});

  @override
  State<BiodataFormPage> createState() => _BiodataFormPageState();
}

class _BiodataFormPageState extends State<BiodataFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _npmController = TextEditingController();
  final _jurusanController = TextEditingController();

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (picked != null) setState(() => _imageFile = picked);
    } catch (e) {
      _snack('Gagal: $e');
    }
  }

  void _showSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        _snack('Upload foto dulu ya');
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            nama: _namaController.text,
            npm: _npmController.text,
            jurusan: _jurusanController.text,
            foto: _imageFile!,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _npmController.dispose();
    _jurusanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Biodata'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showSourceDialog,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(
                        color: const Color(0xFF3F51B5),
                        width: 3,
                      ),
                    ),
                    child: _imageFile == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo,
                                  size: 40, color: Color(0xFF3F51B5)),
                              SizedBox(height: 8),
                              Text('Upload Foto',
                                  style: TextStyle(color: Color(0xFF3F51B5))),
                            ],
                          )
                        : ClipOval(
                            child: FutureBuilder<Uint8List>(
                              future: _imageFile!.readAsBytes(),
                              builder: (context, snap) {
                                if (snap.hasData) {
                                  return Image.memory(
                                    snap.data!,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return const CircularProgressIndicator();
                              },
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _npmController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'NPM',
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'NPM wajib diisi';
                  if (v.length < 8) return 'NPM minimal 8 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _jurusanController,
                decoration: InputDecoration(
                  labelText: 'Jurusan',
                  prefixIcon: const Icon(Icons.school),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Jurusan wajib diisi' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text(
                  'SAVE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final String nama;
  final String npm;
  final String jurusan;
  final XFile foto;

  const ResultPage({
    super.key,
    required this.nama,
    required this.npm,
    required this.jurusan,
    required this.foto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Tersimpan'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<Uint8List>(
                    future: foto.readAsBytes(),
                    builder: (context, snap) {
                      if (snap.hasData) {
                        return ClipOval(
                          child: Image.memory(
                            snap.data!,
                            width: 130,
                            height: 130,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'BIODATA MAHASISWA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F51B5),
                    ),
                  ),
                  const Divider(height: 30),
                  _row('Nama', nama),
                  _row('NPM', npm),
                  _row('Jurusan', jurusan),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          const Text(': '),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}