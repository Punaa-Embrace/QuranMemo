import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'detail_setoran_page_ustad.dart';
import 'beri_tugas_sheet.dart';
import '../../components/app_layout.dart';
import '../../services/ustad_service.dart';
import '../../services/quran_database.dart';

class SetoranPageUstad extends StatefulWidget {
  const SetoranPageUstad({super.key});

  @override
  State<SetoranPageUstad> createState() => _SetoranPageUstadState();
}

class _SetoranPageUstadState extends State<SetoranPageUstad> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> dataSetoran = [];
  List<Map<String, dynamic>> daftarSantri = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch daftar santri untuk form tugas
      final santriRes = await UstadService.getSantriBinaan();
      if (santriRes['success'] == true) {
        final List raw = santriRes['data'] ?? [];
        daftarSantri = raw.map((s) => {
          'id': s['id'],
          'nama': s['nama'] ?? 'Santri',
        }).toList().cast<Map<String, dynamic>>();
      }

      final res = await UstadService.getSetoran();
      if (res['success'] == true) {
        final List data = res['data'] ?? [];
        List<Map<String, dynamic>> tempSetoran = [];
        
        for (var item in data) {
          Map<String, dynamic> mapped = Map<String, dynamic>.from(item as Map);
          mapped["nama"] = item["santri_ustad"] != null ? (item["santri_ustad"]["santri"]?["nama"] ?? "Unknown") : "Unknown";
          
          // Ambil nama surah
          final suratNo = int.tryParse(item['surat']?.toString() ?? '1') ?? 1;
          final surahInfo = await QuranDatabase.getSurahById(suratNo);
          final namaSurat = surahInfo != null ? surahInfo.namaLatin : suratNo.toString();
          
          mapped["surah"] = "Surah $namaSurat - Ayat ${item["ayat"] ?? ''}";
          mapped["nama_surat"] = namaSurat;
          
          mapped["status_label"] = item["status"] != null 
              ? (item["status"] == 'selesai' ? 'Dah Benar' : (item["status"] == 'revisi' ? 'Revisi' : 'Pending'))
              : 'Pending';
          mapped["tanggal"] = "Hari ini";
          tempSetoran.add(mapped);
        }

        setState(() {
          dataSetoran = tempSetoran;
        });
      }
    } catch (e) {
      print('Error fetch setoran: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String searchText = "";
  String selectedFilter = "Semua";
  String selectedSort = "Terbaru";
  String? selectedSantriFilter; // null = Semua Santri

  List<Map<String, dynamic>> get filteredData {
    List<Map<String, dynamic>> result = List.from(dataSetoran);

    /// SEARCH
    if (searchText.isNotEmpty) {
      result = result.where((item) {
        return item["nama"]
            .toLowerCase()
            .contains(searchText.toLowerCase());
      }).toList();
    }

    /// FILTER STATUS
    if (selectedFilter != "Semua") {
      result = result.where((item) {
        return item["status_label"] == selectedFilter;
      }).toList();
    }

    /// FILTER SANTRI
    if (selectedSantriFilter != null) {
      result = result.where((item) {
        return item["nama"] == selectedSantriFilter;
      }).toList();
    }

    /// SORT
    if (selectedSort == "Nama A-Z") {
      result.sort((a, b) => a["nama"].compareTo(b["nama"]));
    } else if (selectedSort == "Nama Z-A") {
      result.sort((a, b) => b["nama"].compareTo(a["nama"]));
    }

    return result;
  }

  Color _getColor(String status) {
    switch (status) {
      case "Dah Benar":
        return Colors.green;
      case "Revisi":
        return Colors.orange;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getIcon(String status) {
    switch (status) {
      case "Dah Benar":
        return Icons.check_circle;
      case "Revisi":
        return Icons.refresh;
      default:
        return Icons.hourglass_bottom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = filteredData;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => BeriTugasSheet(
              daftarSantri: daftarSantri,
              onSuccess: _fetchData,
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Beri Tugas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: AppLayout(
        title: "Setoran Hafalan",
        imagePath: 'assets/images/self.jpg',
        scrollable: false,
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
          children: [

            _buildSearch(),
            const SizedBox(height: 10),

            _buildFilter(),
            const SizedBox(height: 5),

            _buildSantriFilter(),
            const SizedBox(height: 5),

            _buildSort(),
            const SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  Text(
                    "Menampilkan ${data.length} setoran",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () async {
                      final shouldRefresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailSetoranPageUstad(data: item),
                        ),
                      );
                      if (shouldRefresh == true) _fetchData();
                    },
                    child: _buildCard(item),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  /// ============================
  /// SEARCH BAR
  /// ============================
  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Cari nama santri...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchText = "";
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// ============================
  /// FILTER CHIP
  /// ============================
  Widget _buildFilter() {
    final filters = [
      "Semua",
      "Pending",
      "Dah Benar",
      "Revisi",
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final item = filters[index];

          return ChoiceChip(
            label: Text(item),
            selected: selectedFilter == item,
            onSelected: (_) {
              setState(() {
                selectedFilter = item;
              });
            },
            selectedColor: AppTheme.primaryColor,
            labelStyle: TextStyle(
              color: selectedFilter == item
                  ? Colors.white
                  : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: filters.length,
      ),
    );
  }

  /// ============================
  /// SANTRI FILTER CHIPS
  /// ============================
  Widget _buildSantriFilter() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: daftarSantri.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          if (index == 0) {
            // "Semua Santri" chip
            final isSelected = selectedSantriFilter == null;
            return ChoiceChip(
              label: const Text('Semua Santri'),
              selected: isSelected,
              onSelected: (_) {
                setState(() => selectedSantriFilter = null);
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.15),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                ),
              ),
            );
          }
          final santri = daftarSantri[index - 1];
          final santriNama = santri['nama'] as String? ?? '';
          final isSelected = selectedSantriFilter == santriNama;
          return ChoiceChip(
            label: Text(santriNama),
            selected: isSelected,
            onSelected: (_) {
              setState(() => selectedSantriFilter = isSelected ? null : santriNama);
            },
            selectedColor: AppTheme.primaryColor.withOpacity(0.15),
            labelStyle: TextStyle(
              color: isSelected ? AppTheme.primaryColor : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
              ),
            ),
          );
        },
      ),
    );
  }

  /// ============================
  /// SORT
  /// ============================
  Widget _buildSort() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.sort, size: 20),

          const SizedBox(width: 8),

          const Text(
            "Urutkan :",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),

          const Spacer(),

          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedSort,
              items: const [
                DropdownMenuItem(
                  value: "Terbaru",
                  child: Text("Terbaru"),
                ),
                DropdownMenuItem(
                  value: "Nama A-Z",
                  child: Text("Nama A-Z"),
                ),
                DropdownMenuItem(
                  value: "Nama Z-A",
                  child: Text("Nama Z-A"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedSort = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ============================
  /// CARD
  /// ============================
  Widget _buildCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [

          /// Avatar
          CircleAvatar(
            radius: 25,
            backgroundColor: AppTheme.primaryColor.withOpacity(.15),
            child: Icon(
              Icons.person,
              color: AppTheme.primaryColor,
            ),
          ),

          const SizedBox(width: 14),

          /// Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  item["nama"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  item["surah"],
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [

                    Icon(
                      Icons.schedule,
                      size: 15,
                      color: Colors.grey.shade500,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      item["tanggal"],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              _buildStatus(item["status_label"]),

              const SizedBox(height: 18),

              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ============================
  /// STATUS BADGE
  /// ============================
  Widget _buildStatus(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _getColor(status).withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            _getIcon(status),
            color: _getColor(status),
            size: 15,
          ),

          const SizedBox(width: 5),

          Text(
            status,
            style: TextStyle(
              color: _getColor(status),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// ============================
  /// EMPTY
  /// ============================
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(
            Icons.search_off,
            size: 70,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 16),

          const Text(
            "Setoran tidak ditemukan",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Coba gunakan kata kunci lain",
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
