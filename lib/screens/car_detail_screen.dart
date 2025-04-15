import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CarDetailScreen extends StatelessWidget {
  final Map<String, dynamic> car;

  const CarDetailScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final imageUrl = car['lprImageUrl'];
    final lpNumber = car['lpNumber'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'รายละเอียดทะเบียนรถ',
          style: GoogleFonts.kanit(),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white24, // เปลี่ยนสี AppBar เป็นสีขาว
      ),
      backgroundColor: Colors.white, // เปลี่ยนสีพื้นหลังของ Scaffold เป็นสีขาว
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        size: 120,
                        color: Colors.redAccent,
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Card(
              color: Colors.white, // เปลี่ยนสีพื้นหลังของ Card เป็นสีขาว
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Colors.teal.shade300,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ทะเบียน: $lpNumber',
                      style: GoogleFonts.kanit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.teal),
                    const SizedBox(height: 12),
                    Text(
                      'ยี่ห้อ: ${car['vehicleBrand'] ?? "-"}',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'รุ่น: ${car['vehicleModel'] ?? "-"}',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'จังหวัด: ${car['province'] ?? "-"}',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เวลา: ${car['formattedTimestamp'] ?? "-"}',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
