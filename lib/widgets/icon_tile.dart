import 'package:flutter/material.dart';
import '../utilities/styles.dart';

class IconTile extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String text;

  const IconTile({
    required this.text,
    required this.icon,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [AppShadows.getShadow100()]),
        child: Row(children: [
          Icon(icon, size: 50),
          const SizedBox(width: 10),
          Expanded(
              child: Text(
            text,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          )),
        ]),
      ),
    );
  }
}
