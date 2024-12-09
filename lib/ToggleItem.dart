import 'package:flutter/material.dart';

class ToggleItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ToggleItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  _ToggleItemState createState() => _ToggleItemState();
}

class _ToggleItemState extends State<ToggleItem> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(widget.icon, color: Colors.cyan, size: 30),
                    SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Switch(
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                    });
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                ),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}
