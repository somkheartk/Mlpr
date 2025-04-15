import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'capture_screen.dart';
import 'settings_screen.dart';
import 'car_detail_screen.dart'; // Import หน้าจอใหม่
import '../services/car_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CarService _carService = CarService();
  int _selectedIndex = 0;
  List<dynamic> carData = [];
  List<dynamic> filteredCarData = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String searchQuery = '';
  int _currentPage = 1;
  int _itemsPerPage = 10;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    fetchCarData();
  }

  Future<void> fetchCarData({bool loadMore = false}) async {
    if (loadMore && !isLoadingMore) {
      setState(() => isLoadingMore = true);
    } else if (!loadMore) {
      setState(() => isLoading = true);
    }

    try {
      final data = await _carService.fetchCarData(_currentPage, _itemsPerPage);
      if (data.containsKey('data')) {
        final List<dynamic> fetchedData = data['data'];
        final filteredData =
            fetchedData.where((car) => car['lpNumber'] != null).toList();

        setState(() {
          if (loadMore) {
            carData.addAll(filteredData);
          } else {
            carData = filteredData;
          }

          filteredCarData = carData;

          final totalPages = data['totalPages'] ?? 1;
          _hasMoreData = _currentPage < totalPages;

          isLoading = false;
          isLoadingMore = false;

          if (data.containsKey('pageSize')) {
            _itemsPerPage = data['pageSize'];
          }
        });
      } else {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _filterCarData(String query) {
    setState(() {
      searchQuery = query;
      filteredCarData =
          carData
              .where(
                (car) => (car['lpNumber'] ?? '').toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  void _loadPreviousData() {
    if (_currentPage > 1 && !isLoadingMore) {
      _currentPage--;
      fetchCarData(loadMore: true);
    }
  }

  void _loadMoreData() {
    final totalPages =
        (carData.isNotEmpty && carData.length % _itemsPerPage == 0)
            ? (carData.length ~/ _itemsPerPage)
            : (_currentPage + 1);

    if (_hasMoreData && _currentPage < totalPages && !isLoadingMore) {
      _currentPage++;
      fetchCarData(loadMore: true);
    }
  }

  final List<Widget> _pages = [
    const Placeholder(),
    const CaptureScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ทะเบียนรถ',
          style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _currentPage = 1;
                _hasMoreData = true;
                isLoading = true;
              });
              fetchCarData();
            },
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.blueAccent,
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.camera_alt, color: Colors.white),
          Icon(Icons.settings, color: Colors.white),
        ],
      ),
      body:
          _selectedIndex == 0
              ? isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent &&
                          !isLoadingMore) {
                        _loadMoreData();
                      } else if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.minScrollExtent &&
                          !isLoadingMore) {
                        _loadPreviousData();
                      }
                      return false;
                    },
                    child: Column(
                      children: [
                        _buildBanner(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: _filterCarData,
                            decoration: InputDecoration(
                              hintText: 'ค้นหาทะเบียนรถ',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: _buildCarList()),
                        if (isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  )
              : _pages[_selectedIndex],
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 53, 155, 238),
            const Color.fromARGB(255, 44, 144, 231),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'ยินดีต้อนรับ!\nดูทะเบียนรถทั้งหมดได้ที่นี่',
          style: GoogleFonts.kanit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCarList() {
    if (filteredCarData.isEmpty) {
      return const Center(
        child: Text('ไม่มีข้อมูลทะเบียนรถ หรือเกิดข้อผิดพลาดในการโหลดข้อมูล'),
      );
    }

    return ListView.builder(
      itemCount: filteredCarData.length,
      itemBuilder: (context, index) {
        final car = filteredCarData[index];
        final imageUrl = car['lprImageUrl'];
        final lpNumber = car['lpNumber'];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: Colors.black26,
          child: ListTile(
            onTap: () {
              // เมื่อคลิกให้ไปหน้ารายละเอียด
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CarDetailScreen(car: car)),
              );
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  (imageUrl != null &&
                          imageUrl is String &&
                          imageUrl.isNotEmpty)
                      ? Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          );
                        },
                      )
                      : const Icon(
                        Icons.directions_car,
                        size: 40,
                        color: Colors.grey,
                      ),
            ),
            title: Text(
              (lpNumber != null &&
                      lpNumber is String &&
                      !lpNumber.startsWith('http'))
                  ? lpNumber
                  : 'ไม่พบป้ายทะเบียน',
              style: GoogleFonts.kanit(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              '${car['vehicleBrand']} ${car['vehicleModel']}\nจังหวัด: ${car['province']}\nเวลา: ${car['formattedTimestamp']}',
              style: GoogleFonts.kanit(fontSize: 14),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
