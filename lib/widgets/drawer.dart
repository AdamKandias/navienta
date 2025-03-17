import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../features/about.dart';

import '../constants/assets.dart';
import '../constants/global.dart';
import '../constants/app_colors.dart';
import '../features/education.dart';
import '../features/faq.dart';
import 'reusable_text.dart';

class NavientaDrawer extends StatelessWidget {
  const NavientaDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.4,
      backgroundColor: AppColors.primary,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          5.w,
          30.h,
          5.w,
          10.h,
        ),
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 17.w,
              onPressed: () => Global.globalKey.currentState?.closeEndDrawer(),
              icon: Icon(
                color: AppColors.backgroundPrimary,
                Icons.close,
              ),
            ),
          ),
          Column(
            spacing: 30.h,
            children: [
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => About()),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 5.h,
                        ),
                        Icon(
                          Icons.remove,
                          size: 12.w,
                          color: AppColors.backgroundPrimary,
                        ),
                      ],
                    ),
                    ReusableText(
                      textAlign: TextAlign.left,
                      text: 'Tentang',
                      fontSize: 8,
                      textColor: AppColors.textLight,
                    ),
                    Flexible(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 4.5.h,
                          ),
                          ReusableText(
                            textAlign: TextAlign.left,
                            text: ' NAVIENTA',
                            fontFamily: Assets.fontCoolvetica,
                            fontWeight: FontWeight.w400,
                            fontSize: 8,
                            textColor: AppColors.textLight,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Education()),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 5.h,
                        ),
                        Icon(
                          Icons.remove,
                          size: 12.w,
                          color: AppColors.backgroundPrimary,
                        ),
                      ],
                    ),
                    Flexible(
                      child: ReusableText(
                        textAlign: TextAlign.left,
                        text: 'Edukasi Mengemudi',
                        fontSize: 8,
                        textColor: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Faq()),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 5.h,
                        ),
                        Icon(
                          Icons.remove,
                          size: 12.w,
                          color: AppColors.backgroundPrimary,
                        ),
                      ],
                    ),
                    Flexible(
                      child: ReusableText(
                        textAlign: TextAlign.left,
                        text: 'FAQs',
                        fontSize: 8,
                        textColor: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
