import 'package:flutter/material.dart';
import 'package:hospedaje_f1/core/colors.dart';
import 'package:hospedaje_f1/src/navigation/routes.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  Header({super.key})
      : preferredSize = Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        'Hotel Formula 1',
        style: TextStyle(
          color: AppColors.secondary100,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),
      backgroundColor: AppColors.primary500,
      actions: [
        IconButton(
          icon: Icon(
            Icons.dashboard,
            color: Colors.white,
          ),
          iconSize: 30,
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.home);
          },
        ),
      ],
    );
  }
}
