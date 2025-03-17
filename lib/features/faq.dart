import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../widgets/reusable_text.dart';

class Faq extends StatelessWidget {
  const Faq({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textLight,
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
              text: "FAQs",
              fontSize: 11,
              textColor: AppColors.textLight,
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Container(
            height: 12.h,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppColors.backgroundPrimary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
              ),
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _faqItem(
                    question: "Bagaimana cara kerja NAVIENTA ?",
                    answer:
                        "NAVIENTA adalah sistem berbasis LiDAR untuk deteksi objek yang aman dan akurat.",
                  ),
                  _faqItem(
                    question: "Apa itu NAVIENTA?",
                    answer:
                        "Navienta adalah sistem asisten pengemudi cerdas yang membantu dalam manuver menyalip dengan aman menggunakan sensor dan voice assistant.",
                  ),
                  _faqItem(
                    question: "Seberapa akurat deteksi dari NAVIENTA?",
                    answer:
                        "Ya! NAVIENTA dirancang untuk meningkatkan keamanan pengemudi kendaraan listrik.",
                  ),
                  _faqItem(
                    question:
                        "Apakah Navienta bisa digunakan di malam hari atau saat hujan?",
                    answer:
                        "Ya! NAVIENTA dirancang untuk meningkatkan keamanan pengemudi kendaraan listrik.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _faqItem({
  required String question,
  required String answer,
}) =>
    Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: Color(0xFFEDF3F7),
      child: ExpansionTile(
        title: ReusableText(
          text: question,
          textColor: AppColors.textPrimary,
          fontSize: 7,
          textAlign: TextAlign.left,
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(3.w),
            child: ReusableText(
              text: answer,
              textColor: AppColors.textDark,
              fontSize: 6,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
