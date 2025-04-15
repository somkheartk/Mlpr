// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:mlpr/consts/constant.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  _CaptureScreenState createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (!mounted) return;
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final compressedImage = await compressImage(imageFile);
        setState(() {
          _image = compressedImage;
        });
      } else {
        _showSnackBar('ไม่ได้เลือกภาพ');
      }
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<String> encodeImage(File image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  static Future<File> compressImage(File image) async {
    final originalImage = img.decodeImage(await image.readAsBytes());
    if (originalImage == null) {
      throw Exception('ไม่สามารถแปลงภาพได้');
    }

    final compressedImage = img.encodeJpg(originalImage, quality: 50);
    final tempDir = Directory.systemTemp;
    final compressedFile = File('${tempDir.path}/compressed_image.jpg');
    await compressedFile.writeAsBytes(compressedImage);
    return compressedFile;
  }

  Future<void> _uploadImage() async {
    if (_isUploading) {
      _showSnackBar('กำลังอัปโหลดอยู่แล้ว');
      return;
    }

    if (_image == null) {
      _showSnackBar('กรุณาเลือกภาพก่อน');
      return;
    }

    final base64Image = await compute(encodeImage, _image!);
    final apiUrl = '${AppConfig.LPR_BACKEND_URL}/api/Lpr/uploadBase64';
    print('API URL: $apiUrl');
    print('Base64 Image Length: ${base64Image.length}');
    final payload = jsonEncode({"base64Image": base64Image});

    setState(() => _isUploading = true);
    await _performUpload(apiUrl, payload);

    if (mounted) {
      setState(() {
        _isUploading = false;
        _image = null; // Clear the image after upload
      });
    }
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('ตกลง'),
              ),
            ],
          ),
    );
  }

  Future<void> _performUpload(String apiUrl, String payload) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json', 'accept': '*/*'},
        body: payload,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Safely access the licensePlate object
        final licensePlate = responseData['licensePlate'];
        final message = licensePlate?['message'] ?? 'No message';
        final lpNumber = licensePlate?['lpNumber'] ?? 'N/A';
        final confidence = licensePlate?['conf']?.toStringAsFixed(2) ?? 'N/A';
        final province = licensePlate?['province'] ?? 'N/A';
        final vehicleBrand = licensePlate?['vehicleBrand'] ?? 'N/A';
        final vehicleModel = licensePlate?['vehicleModel'] ?? 'N/A';
        final vehicleColor = licensePlate?['vehicleColor'] ?? 'N/A';
        final vehicleYear = licensePlate?['vehicleYear'] ?? 'N/A';
        final vehicleBodyType = licensePlate?['vehicleBodyType'] ?? 'N/A';
        final vehicleOrientation = licensePlate?['vehicleOrientation'] ?? 'N/A';

        _showResultDialog(
          'สำเร็จ',
          'อัปโหลดภาพสำเร็จ\n\n'
              'Message: $message\n'
              'License Plate: $lpNumber\n'
              'Confidence: $confidence\n'
              'Province: $province\n'
              'Vehicle Brand: $vehicleBrand\n'
              'Vehicle Model: $vehicleModel\n'
              'Vehicle Color: $vehicleColor\n'
              'Vehicle Year: $vehicleYear\n'
              'Vehicle Body Type: $vehicleBodyType\n'
              'Vehicle Orientation: $vehicleOrientation',
        );
      } else if (response.statusCode == 404) {
        _showResultDialog('ข้อผิดพลาด', 'ไม่พบปลายทาง (404)');
      } else {
        _showResultDialog(
          'ข้อผิดพลาด',
          'เกิดข้อผิดพลาดในการอัปโหลด: ${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('เกิดข้อผิดพลาด: $e');
    }
  }

  void _showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueAccent,
              ),
            ),
            content: SingleChildScrollView(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'ตกลง',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ถ่ายภาพ'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display image or placeholder
                if (_image == null)
                  const Center(
                    child: Text(
                      'ยังไม่มีภาพที่เลือก',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  )
                else
                  Column(
                    children: [
                      Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FittedBox(
                            fit:
                                BoxFit
                                    .contain, // Maintain aspect ratio and avoid squeezing
                            child: Image.file(_image!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<int>(
                        future: _image!.length(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text('กำลังคำนวณขนาดภาพ...');
                          } else if (snapshot.hasError) {
                            return const Text('ไม่สามารถคำนวณขนาดภาพได้');
                          } else {
                            final sizeMB = (snapshot.data! / (1024 * 1024))
                                .toStringAsFixed(2);
                            return Text('ขนาดภาพ: $sizeMB MB');
                          }
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 24),

                // Capture button
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('ถ่ายภาพ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 16),

                // Reset button (if image exists)
                if (_image != null)
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _image = null),
                    icon: const Icon(Icons.refresh),
                    label: const Text('ถ่ายใหม่'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                const SizedBox(height: 16),

                // Upload button
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _uploadImage,
                  icon: const Icon(Icons.upload),
                  label: Text(_isUploading ? 'กำลังอัปโหลด...' : 'อัปโหลดภาพ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),

          // Overlay loading indicator
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
