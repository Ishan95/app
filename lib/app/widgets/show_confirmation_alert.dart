import 'package:flutter/material.dart';
import 'package:app/app/export.dart';
import 'package:app/l10n/app_localizations.dart';

class ConfirmationAlert {
  static Future<Widget> showConfirmationAlert({
    required BuildContext context,
    bool isCancelVisible = false,
    String? title,
    String? message,
    String? actionText,
    Color? messageColor,
    Color? actionColor,
    Color? cancelColor,
    Function()? onTap2,
    Function()? onTap,
    Function()? cancelOnTap,
    Function()? onDismiss,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            height: context.screenHeight * 0.34,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                title != ''
                    ? Text(title ?? '', style: context.regularMulish18(color: ColorManager.blackMedium))
                    : const SizedBox(),
                title != '' ? SizedBox(height: context.verticalSize(15)) : const SizedBox(),
                SizedBox(
                  width: context.screenWidth,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: ColorManager.white,
                    elevation: 4,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: onTap2,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              message ?? "",
                              style: context.semiBold18(fontSize: 16, color: messageColor ?? ColorManager.grayText),
                            ),
                          ),
                        ),
                        Divider(height: 1.0, color: ColorManager.disabledText),
                        InkWell(
                          onTap: onTap,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              actionText ?? "",
                              style: context.regularMulish18(color: actionColor ?? ColorManager.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.verticalSize(5)),
                isCancelVisible
                    ? SizedBox(
                      width: context.screenWidth,
                      child: InkWell(
                        onTap: cancelOnTap,
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: ColorManager.white,
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              l10n.cancel,
                              style: context.semiBold18(color: cancelColor ?? ColorManager.kPrimary),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox(height: 0),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      if (onDismiss != null) {
        onDismiss();
      }
      return const SizedBox();
    });
  }
}
