import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app/app/export.dart';

class PhotoPreview extends StatelessWidget {
  final String imagePath;
  final bool isOnboard;

  const PhotoPreview({super.key, required this.imagePath, this.isOnboard = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBar(
        backgroundColor: ColorManager.white,
        elevation: 0.5,
        title: Text('Take a photo', style: context.semiBold20(color: ColorManager.blackMedium)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: ColorManager.blackMedium),
        ),
      ),
      body: Column(
        children: [
          /// **Image Preview with Rounded Corners**
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                // Center(
                //   child:
                ClipRRect(
                  borderRadius: BorderRadius.circular(22), // Rounded Edges
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                ),
                // ),

                /// **Redo Button Inside Image (Top-Left)**
                Positioned(
                  top: 0, // Adjusted to reduce space
                  left: 0,
                  child: SizedBox(
                    // width: 88, // Set width
                    height: 40, // Set height
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context), // Redo button action
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                      label: const Text(
                        "Redo",
                        style: TextStyle(color: Colors.white, fontSize: 16), // Adjust text size
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: ColorManager.white, width: 4),
                        ),
                      ),
                    ),
                  ),
                ),

                /// **Instruction Text**
                isOnboard
                    ? const SizedBox()
                    : Positioned(
                      bottom: 90, // Adjusted for better placement
                      left: 15,
                      right: 15,
                      child: Text(
                        "Before submitting your request, please make \nsure that the photo shows the charging station in its entirety",
                        textAlign: TextAlign.center,
                        style: context.medium16(color: ColorManager.blackMedium),
                      ),
                    ),
              ],
            ),
          ),
          SizedBox(height: context.verticalSize(30)),
        ],
      ),
    );
  }
}
