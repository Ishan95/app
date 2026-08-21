import 'package:app/app/themes/text_themes.dart';
import 'package:app/app/utils/color_manager.dart';
import 'package:flutter/material.dart';

class InfoButtonWithTooltip extends StatelessWidget {
  final String tooltipText;
  final double? width;
  final double? height;
  final double paddin;
  final bool isSignUp;
  final Widget? child;

  const InfoButtonWithTooltip({
    super.key,
    required this.tooltipText,
    this.width = 200,
    this.height = 85,
    this.paddin = 20,
    this.isSignUp = false,
    this.child
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final overlay = Overlay.of(context).context.findRenderObject();
        final renderBox = context.findRenderObject() as RenderBox;
        final offset = renderBox.localToGlobal(Offset.zero, ancestor: overlay);

        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: '',
          barrierColor: Colors.transparent,
          pageBuilder: (context, animation, secondaryAnimation) {
            return Stack(
              children: [
                Positioned(
                  left: offset.dx - 150,
                  top: isSignUp
                      ? offset.dy - height! - 20
                      : offset.dy + renderBox.size.height + 10,
                  child: Material(
                    color: Colors.transparent,
                    child: CustomPaint(
                      painter: TooltipArrowPainter(),
                      child: Container(
                        width: width,
                        height: height,
                        padding: EdgeInsets.all(paddin),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFFF1EF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          tooltipText,
                          style: context.regular12(color: ColorManager.red)
                        )
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: child ?? Container(
        width: 16,
        height: 16,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(),
        child:
            const Icon(Icons.info_outline, size: 16, color: Color(0xFF71727A)),
      ),
    );
  }
}

class TooltipArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFF1EF);

    final path = Path()
      ..moveTo(size.width - 70, 0)   // start near top-right
      ..lineTo(size.width - 50, -10) // tip of arrow
      ..lineTo(size.width - 60, 0)        // back to edge
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


// class TooltipArrowPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..color = const Color(0xFFFFF1EF);
//     final path = Path()
//       ..moveTo(10, 10)
//       ..lineTo(17, -8)
//       ..lineTo(20, 0)
//       ..close();
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return false;
//   }
// }
