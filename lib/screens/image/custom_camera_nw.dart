import 'dart:io';

import 'package:app/screens/image/photo_view.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:app/app/export.dart';

class CustomCameraNw extends StatefulWidget {
  const CustomCameraNw({super.key, this.isOnboard = false, this.onPress, required this.onImageSelected});

  final bool isOnboard;
  final VoidCallback? onPress;
  final ValueChanged<File> onImageSelected;

  @override
  State<CustomCameraNw> createState() => _CustomCameraNwState();
}

class _CustomCameraNwState extends State<CustomCameraNw> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isFlashOn = false;
  bool _isRearCamera = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _controller = CameraController(
        _isRearCamera ? cameras![0] : cameras![1],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;
    final image = await _controller!.takePicture();
    debugPrint('Image saved at: ${image.path}');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhotoPreview(imagePath: image.path, isOnboard: widget.isOnboard)),
    ).then((isSuccess) async {
      if (isSuccess) {
        // widget.selectedImage = image;
        widget.onImageSelected(File(image.path));
        Navigator.pop(context);
      }
    });
  }

  void _toggleFlash() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    _isFlashOn = !_isFlashOn;
    _controller!.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    setState(() {});
  }

  void _switchCamera() async {
    if (cameras == null || cameras!.length < 2) return;
    _isRearCamera = !_isRearCamera;
    _controller = CameraController(
      _isRearCamera ? cameras![0] : cameras![1],
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int rotation = 0;
    if (_controller != null && _controller!.value.isInitialized) {
      rotation = (_controller!.description.sensorOrientation ~/ 90) % 4;
    }
    // if (_controller == null || !_controller!.value.isInitialized) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    // int rotation = (_controller!.description.sensorOrientation ~/ 90) % 4;

    return Scaffold(
      body: Stack(
        children: [
          /// **Full-Screen Camera Preview**
          // Positioned.fill(
          //   child: CameraPreview(_controller!),
          // ),
          Positioned.fill(
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: RotatedBox(quarterTurns: rotation, child: CameraPreview(_controller!)),
              ),
            ),
          ),

          /// **Dark Black Overlay at the Top**
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150, // Adjust height as needed
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          /// **Dark Black Overlay at the Bottom**
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200, // Adjust height as needed
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          /// **Top Bar with Back Button and Title**
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context)..pop(false),
                  // Navigator.pop(context),
                ),
                Text('Take a photo', style: context.semiBold20(color: ColorManager.white)),
                const SizedBox(width: 48), // Spacer
              ],
            ),
          ),

          /// **Bottom Camera Controls**
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                /// **Camera Control Buttons**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: _switchCamera,
                      child: Icon(Icons.cameraswitch, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 40),
                    GestureDetector(
                      onTap: _takePicture,
                      child: Icon(Icons.camera, color: Colors.white, size: 80),
                      // Image.asset(
                      //   Assets.clickbutton,
                      //   height: 60,
                      //   width: 60,
                      // ),
                    ),
                    const SizedBox(width: 40),
                    IconButton(
                      icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: ColorManager.kPrimary, size: 32),
                      onPressed: _toggleFlash,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// **Instructional Text**
                widget.isOnboard
                    ? const SizedBox()
                    : const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "Step back and capture a clear, well-framed photo that provides the best details possible.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
