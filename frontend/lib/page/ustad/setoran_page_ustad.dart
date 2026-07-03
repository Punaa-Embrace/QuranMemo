import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'detail_setoran_page_ustad.dart';
import '../../components/app_layout.dart';

class SetoranPageUstad extends StatefulWidget {
  const SetoranPageUstad({super.key});

  @override
  State<SetoranPageUstad> createState() => _SetoranPageUstadState();
}

class _SetoranPageUstadState extends State<SetoranPageUstad> {
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> dataSetoran = [
    {
      "nama": "Muhammad Aku",
      "surah": "Al-Baqarah 1-5",
      "status": "Pending",
      "tanggal": "Hari ini • 08:15",
    },
    {
      "nama": "Hakim Prasetya",
      "surah": "Al-Fatihah",
      "status": "Diterima",
      "tanggal": "Kemarin • 20:10",
    },
    {
      "nama": "Reynold",
      "surah": "An-Nas",
      "status": "Ditolak",
      "tanggal": "1 Juli 2026",
    },
    {
      "nama": "Budi Syah Putra",
      "surah": "Yasin 1-15",
      "status": "Pending",
      "tanggal": "Hari ini • 10:42",
    },
    {
      "nama": "Admin",
      "surah": "Al-Mulk",
      "status": "Pending",
      "tanggal": "Hari ini • 07:30",
    },
  ];

  String searchText = "";
  String selectedFilter = "Semua";
  String selectedSort = "Terbaru";

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

    /// FILTER
    if (selectedFilter != "Semua") {
      result = result.where((item) {
        return item["status"] == selectedFilter;
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
      case "Diterima":
        return Colors.green;
      case "Ditolak":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getIcon(String status) {
    switch (status) {
      case "Diterima":
        return Icons.check_circle;
      case "Ditolak":
        return Icons.cancel;
      default:
        return Icons.hourglass_bottom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = filteredData;

    return AppLayout(
      title: "Setoran Hafalan",
      imagePath: 'assets/images/self.jpg',
      scrollable: false,
      child: Column(
        children: [

          _buildSearch(),
          const SizedBox(height: 10),

          _buildFilter(),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailSetoranPageUstad(data: item),
                      ),
                    );
                  },
                  child: _buildCard(item),
                );
              },
            ),
          )
        ],
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
      "Diterima",
      "Ditolak",
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

              _buildStatus(item["status"]),

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
