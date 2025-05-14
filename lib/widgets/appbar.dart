import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';
import '../constants/assets.dart';
import '../constants/global.dart';

PreferredSizeWidget navientaAppBar(bool isTablet) => !isTablet
    ? AppBar(
        toolbarHeight: 60.h,
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: AppColors.primary,
              size: 11.w,
            ),
            onPressed: () => Global.globalKey.currentState?.openEndDrawer(),
          ),
          SizedBox(
            width: 13.w,
          ),
        ],
        centerTitle: true,
        backgroundColor: AppColors.backgroundPrimary,
        title: Row(
          children: [
            Image.asset(
              Assets.logo,
              height: 60.h,
            ),
          ],
        ),
      )
    : AppBar(
        toolbarHeight: 70.h,
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: AppColors.primary,
              size: 15.w,
            ),
            onPressed: () => Global.globalKey.currentState?.openEndDrawer(),
          ),
          SizedBox(
            width: 13.w,
          ),
        ],
        centerTitle: true,
        backgroundColor: AppColors.backgroundPrimary,
        title: Row(
          children: [
            Image.asset(
              Assets.logo,
              height: 75.h,
            ),
          ],
        ),
      );
