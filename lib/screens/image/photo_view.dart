import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app/app/export.dart';
import 'package:app/l10n/app_localizations.dart';

class PhotoPreview extends StatelessWidget {
  final String imagePath;
  final bool isOnboard;

  const PhotoPreview({super.key, required this.imagePath, this.isOnboard = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBar(
        backgroundColor: ColorManager.white,
        elevation: 0.5,
        title: Text(l10n.takePhotoTitle, style: context.semiBold20(color: ColorManager.blackMedium)),
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
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                      label: Text(l10n.redo, style: const TextStyle(color: Colors.white, fontSize: 16)),
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
                isOnboard
                    ? const SizedBox()
                    : Positioned(
                      bottom: 90,
                      left: 15,
                      right: 15,
                      child: Text(
                        l10n.photoPreviewInstruction,
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
