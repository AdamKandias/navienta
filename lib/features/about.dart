import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:navienta/constants/assets.dart';
import '../constants/app_colors.dart';
import '../widgets/reusable_text.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 3.w,
          children: [
            ReusableText(
              textAlign: TextAlign.center,
              text: "Tentang",
              fontSize: 11,
              textColor: AppColors.textPrimary,
            ),
            Row(
              children: [
                ReusableText(
                  textAlign: TextAlign.center,
                  text: "NAVI",
                  fontSize: 10.5,
                  textColor: AppColors.textNavi,
                  fontFamily: Assets.fontCoolvetica,
                  fontWeight: FontWeight.w500,
                ),
                ReusableText(
                  textAlign: TextAlign.center,
                  text: "ENTA",
                  fontSize: 10.5,
                  textColor: AppColors.textPrimary,
                  fontFamily: Assets.fontCoolvetica,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ],
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
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.all(
              Radius.circular(12.r),
            ),
          ),
          child: Row(
            spacing: 17.w,
            children: [
              Expanded(
                child: Column(
                  spacing: 9.h,
                  children: [
                    Expanded(
                      child: ReusableText(
                        text:
                            'NAVIENTA adalah solusi inovatif yang mengoptimalkan teknologi LiDAR untuk deteksi objek yang akurat hingga jarak 100 meter, bahkan dalam kondisi kurang ideal.  Sistem ini menyajikan data real-time tentang kecepatan, jarak kendaraan lain, dan potensi bahaya saat menyalip.  Dilengkapi asisten suara, NAVIENTA memungkinkan pengemudi berinteraksi tanpa mengalihkan fokus dari jalan, meningkatkan keselamatan berkendara. Inovasi ini dirancang untuk meningkatkan keamanan, kenyamanan, dan efisiensi pengemudi kendaraan listrik.',
                        fontSize: 6.3,
                        textColor: AppColors.textLight,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundPrimary,
                          borderRadius: BorderRadius.all(
                            Radius.circular(12.r),
                          ),
                        ),
                        child: Row(
                          spacing: 3.w,
                          children: [
                            Image.asset(
                              "assets/images/instagram.png",
                              fit: BoxFit.fill,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 2.w,
                              children: [
                                ReusableText(
                                  textAlign: TextAlign.center,
                                  text: "Kunjungi Instagram",
                                  fontSize: 6,
                                  textColor: AppColors.textDark,
                                ),
                                Row(
                                  children: [
                                    ReusableText(
                                      textAlign: TextAlign.center,
                                      text: "NAVI",
                                      fontSize: 6.5,
                                      textColor: AppColors.textNavi,
                                      fontFamily: Assets.fontCoolvetica,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    ReusableText(
                                      textAlign: TextAlign.center,
                                      text: "ENTA",
                                      fontSize: 6.5,
                                      textColor: AppColors.textPrimary,
                                      fontFamily: Assets.fontCoolvetica,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundPrimary,
                          borderRadius: BorderRadius.all(
                            Radius.circular(12.r),
                          ),
                        ),
                        child: Row(
                          spacing: 3.w,
                          children: [
                            Image.asset(
                              "assets/images/whatsapp.png",
                              fit: BoxFit.fill,
                            ),
                            ReusableText(
                              textAlign: TextAlign.center,
                              text: "Hubungi Customer Service (WA)",
                              fontSize: 6,
                              textColor: AppColors.textDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundPrimary,
                          borderRadius: BorderRadius.all(
                            Radius.circular(12.r),
                          ),
                        ),
                        child: Row(
                          spacing: 3.w,
                          children: [
                            Image.asset(
                              "assets/images/message.png",
                              fit: BoxFit.fill,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 2.w,
                              children: [
                                ReusableText(
                                  textAlign: TextAlign.center,
                                  text: "Saran dan masukan",
                                  fontSize: 6,
                                  textColor: AppColors.textDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Image.asset(
                  "assets/images/about.png",
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
