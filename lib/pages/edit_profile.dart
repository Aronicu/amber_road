import 'package:amber_road/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.fromRoute});
  final String fromRoute;

  @override
  State<StatefulWidget> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.go(widget.fromRoute);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit Profile", style: TextStyle(color: colPrimary)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go(widget.fromRoute);
            },
          ),
          shape: Border(
            bottom: BorderSide(
              color: colSpecial,
              width: 2,
            )
          ),
        ),
        body: Center(child: Text("Edit Here")),
      ),
    );
  }

}