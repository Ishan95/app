// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:app/app/export.dart';

// class CustomSearchBar extends StatefulWidget {
//   final String hintText;
//   final VoidCallback? onPress;
//   final VoidCallback? onTap;
//   final ValueChanged<String>? onSearchTap;
//   final VoidCallback? onVoiceIconTap;
//   final VoidCallback? onClearIconTap;
//   final bool isClearIconTap;
//   final TextEditingController? textController;
//   final ValueChanged<String>? onSubmit;
//   final Duration debounceDurationChange;
//   final Duration debounceDurationSubmit;
//   final Widget? suffixIcon;
//   final bool isSuffix;

//   const CustomSearchBar({
//     super.key,
//     this.hintText = 'Search',
//     this.onPress,
//     this.onTap,
//     this.onSearchTap,
//     this.onVoiceIconTap,
//     this.onClearIconTap,
//     this.isClearIconTap = false,
//     this.textController,
//     this.onSubmit,
//     this.debounceDurationChange = const Duration(seconds: 5),
//     this.debounceDurationSubmit = const Duration(seconds: 5),
//     this.suffixIcon,
//     this.isSuffix = false,
//   });

//   @override
//   State<CustomSearchBar> createState() => _CustomSearchBarState();
// }

// class _CustomSearchBarState extends State<CustomSearchBar> {
//   late TextEditingController _controller;
//   Timer? _debounceForChange;
//   Timer? _debounceForSubmit;

//   @override
//   void initState() {
//     super.initState();
//     _controller = widget.textController ?? TextEditingController();
//   }

//   @override
//   void dispose() {
//     _debounceForChange?.cancel();
//     _debounceForSubmit?.cancel();

//     if (widget.textController == null) {
//       _controller.dispose();
//     }
//     super.dispose();
//   }

//   void _onTextChanged(String text) {
//     if (_debounceForChange?.isActive ?? false)
//       _debounceForChange!.cancel(); // Cancel previous timer

//     widget.onSearchTap?.call(text);

//     _debounceForChange = Timer(widget.debounceDurationChange, () {
//       if (text.isNotEmpty) {
//         widget.onSearchTap?.call(text); // Call API or function after debounce
//       }
//     });
//   }

//   void _onTextSubmit(String text) {
//     if (_debounceForSubmit?.isActive ?? false)
//       _debounceForSubmit!.cancel(); // Cancel previous timer

//     _debounceForSubmit = Timer(widget.debounceDurationSubmit, () {
//       if (text.isNotEmpty) {
//         widget.onSubmit?.call(text); // Call API or function after debounce
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: context.padding(horizontal: 8.0, vertical: 7),
//       margin: context.margin(all: 2.0),
//       decoration: BoxDecoration(
//         color: ColorManager.white10.withOpacity(0.24),
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 10,
//           ),
//           GestureDetector(
//                   onTap: widget.isSuffix ? widget.onClearIconTap : (){},
//                   behavior: HitTestBehavior.translucent,
//                   child: widget.suffixIcon ?? Icon(Icons.search, color: ColorManager.white)
//            ),
//           SizedBox(
//             width: context.horizontalSize(10),
//           ),
//           Expanded(
//             child: TextField(
//             autocorrect: false,
//               controller: _controller,
//               onTap: widget.onTap,
//               onChanged: _onTextChanged, // Connect the onChanged callback here
//               onSubmitted: _onTextSubmit,
//               cursorColor: const Color(0xFFF5F5F5),
//               style: TextStyle(
//                 color: ColorManager.white, // Typing text color
//               ),

//               decoration: InputDecoration(
//                 hintText: widget.hintText,
//                 hintStyle: TextStyle(
//                   fontFamily: 'SfPro',
//                   color: Color(0xffBEC5B8),
//                   fontWeight: FontWeight.w400,
//                   fontSize: 17.0,
//                 ),
//                 border: InputBorder.none,
//                 isDense: true,
//                 contentPadding: const EdgeInsets.symmetric(vertical: 7),
//               ),
//             ),
//           ),
//           widget.isClearIconTap
//               ? GestureDetector(
//                   onTap: widget.onClearIconTap,
//                   behavior: HitTestBehavior.translucent,
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     child: Icon(Icons.close_rounded, color: ColorManager.white),
//                   ),
//                 )
//               : SizedBox(
//                   width: 10,
//                 ),
//         ],
//       ),
//     );
//   }
// }
