import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../widgets/reusable_text.dart';

class Education extends StatefulWidget {
  const Education({super.key, this.defaultTab = 1});
  final int defaultTab;

  @override
  State<Education> createState() => _EducationState();
}

class _EducationState extends State<Education> {
  final ScrollController _contentScrollController = ScrollController();

  @override
  void initState() {
    _contentScrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    _pageTab = widget.defaultTab;
    super.initState();
  }

  @override
  void dispose() {
    _contentScrollController.dispose();
    super.dispose();
  }

  int _pageTab = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70.h,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        title: ReusableText(
          textAlign: TextAlign.center,
          text: "Edukasi Dalam Berkendara",
          fontSize: 11,
          textColor: AppColors.textPrimary,
        ),
        backgroundColor: AppColors.backgroundPrimary,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: 12.w,
          left: 12.w,
          right: 12.w,
          top: 4.5.w,
        ),
        child: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.22,
              decoration: const BoxDecoration(
                color: AppColors.backgroundPrimary,
              ),
              child: Column(
                children: [
                  _tabButton(
                    isActive: _pageTab == 1,
                    text: 'Aturan batas kecepatan',
                    pageTabIndex: 1,
                  ),
                  _tabButton(
                    isActive: _pageTab == 2,
                    text: 'Aturan mendahului kendaraan lain',
                    pageTabIndex: 2,
                  ),
                  _tabButton(
                    isActive: _pageTab == 3,
                    text: 'Aturan jarak minimal kendaraan',
                    pageTabIndex: 3,
                  ),
                  _tabButton(
                    isActive: _pageTab == 4,
                    text: 'Aturan keamanan mengemudi',
                    pageTabIndex: 4,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8.w),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  controller: _contentScrollController,
                  child: ReusableText(
                    text: _pageDetailText(index: _pageTab),
                    textColor: AppColors.textLight,
                    textAlign: TextAlign.left,
                    fontSize: 6.7,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required bool isActive,
    required String text,
    required int pageTabIndex,
  }) =>
      isActive
          ? Expanded(
              child: Container(
                padding: EdgeInsets.only(right: 4.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    bottomLeft: Radius.circular(12.r),
                  ),
                  color: AppColors.primary,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4.w,
                      margin: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                          color: AppColors.backgroundPrimary,
                          borderRadius: BorderRadius.all(
                            Radius.circular(12.r),
                          )),
                    ),
                    Flexible(
                      child: ReusableText(
                        text: text,
                        textColor: AppColors.textLight,
                        fontSize: 6.5,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _pageTab = pageTabIndex;
                    _contentScrollController.jumpTo(0);
                  });
                },
                child: Container(
                  padding: EdgeInsets.only(right: 4.w),
                  color: AppColors.backgroundPrimary,
                  child: Row(
                    children: [
                      Container(
                        width: 4.w,
                        margin: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                            color: AppColors.backgroundPrimary,
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.r),
                            )),
                      ),
                      Flexible(
                        child: ReusableText(
                          text: text,
                          textColor: AppColors.textPrimary,
                          fontSize: 6.5,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
}

String _pageDetailText({required int index}) => switch (index) {
      1 =>
        "Undang-Undang Nomor 22 Tahun 20 Batas kecepatan berkendara di Indonesia diatur dalam Undang-Undang Nomor 22 Tahun 2009 tentang Lalu Lintas Angkutan Jalan. Batas kecepatan berkendara dibedakan berdasarkan jenis jalan, yaitu:\n\n\t\t\t●\t Jalan bebas hambatan: Kecepatan minimum 60 km/jam dan maksimum 100 km/jam. Namun, tidak semua jalan bebas hambatan dapat dimasuki kendaraan roda dua.\n\t\t\t●\tJalan antarkota: Kecepatan maksimum 80 km/jam.\n\t\t\t●\tKawasan perkotaan: Kecepatan maksimum 50 km/jam.\n\t\t\t●\tKawasan pemukiman: Kecepatan maksimum 30 km/jam.\n\nSelain menjaga kecepatan, pengendara juga harus menjaga jarak aman dengan batas kecepatan berkendara yang sesuai aturan, dan memantau kondisi lalu lintas sekitar.09 tentang Lalu Lintas dan Angkutan Jalan",
      2 =>
        "Menyalip diatur dalam Undang-Undang Lalu Lintas dan Angkutan Jalan No 22 Tahun 2009 Pasal 109:\n\n\t\t\t●\t Ayat 1 Pengemudi kendaraan bermotor yang akan melewati kendaraan lain harus menggunakan lajur atau jalur jalan sebelah kanan dari kendaraan yang akan dilewati, mempunyai jarak pandang yang bebas dan tersedia ruang yang cukup.\n\n\t\t\t●\t Ayat 2 Dalam keadaan tertentu pengemudi sebagaimana dimaksud pada ayat 1 dapat menggunakan lajur jalan sebelah kiri dengan tetap memperhatikan keamanan dan keselamatan berlalu lintas dan angkutan jalan.\n\n\t\t\t●\t Ayat 3 Jika kendaraan yang akan dilewati telah memberi isyarat akan menggunakan lajur atau jalur jalan sebelah kanan pengemudi sebagaimana dimaksud pada ayat 1 dilarang melewati kendaraan tersebut.",
      3 =>
        "Undang-Undang jarak minimal dan jarak aman antar kendaraan diatur dalam Undang-Undang dalam Pasal 62 PP No. 43 tahun 1993 tentang Tata Cara Berlalu Lintas:\n\n● Kecepatan 30 km/jam - Jarak minimal 15 meter - Jarak aman 30 meter\n● Kecepatan 40 km/jam - Jarak minimal 20 meter - Jarak aman 40 meter\n● Kecepatan 50 km/jam - Jarak minimal 25 meter - Jarak aman 50 meter\n● Kecepatan 60 km/jam - Jarak minimal 40 meter - Jarak aman 60 meter\n● Kecepatan 70 km/jam - Jarak minimal 50 meter - Jarak aman 70 meter\n● Kecepatan 80 km/jam - Jarak minimal 60 meter - Jarak aman 80 meter\n● Kecepatan 90 km/jam - Jarak minimal 70 meter - Jarak aman 90 meter\n● Kecepatan 100 km/jam - Jarak minimal 80 meter - Jarak aman 100 meter ",
      4 =>
        "Undang-Undang Keamanan Pengemudi diatur dalam Undang-Undang Nomor 22 Tahun 2009 tentang Lalu Lintas dan Angkutan Jalan:\n\n●\t Tidak boleh mengantuk saat berkendara (Pasal 106 Ayat 1)\n\n●\t Dilarang mengemudi dalam keadaan mabuk atau terpengaruh alkohol, narkotika, atau obat-obatan yang mengganggu konsentrasi (Pasal 311 dan Pasal 283)\n\n●\t Harus memiliki Surat Izin Mengemudi (SIM) yang sesuai dengan jenis kendaraan yang dikemudikan (Pasal 77 Ayat 1)\n\n●\t Wajib mematuhi rambu lalu lintas, marka jalan, dan perintah petugas (Pasal 106 Ayat 4)\n\n●\t Wajib menggunakan sabuk pengaman (untuk mobil) dan helm SNI (untuk motor) (Pasal 106 Ayat 6 & Pasal 291)",
      _ => '',
    };
