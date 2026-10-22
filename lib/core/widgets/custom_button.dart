import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// BeautyConnect button variants per the Figma component library:
/// - Primary (default): orange pill (#E8620A), white bold text, orange shadow
/// - `isOutlined`: navy-outlined pill, navy text
/// - `isDestructive`: red-outlined pill, red text
/// - `isGhost`: orange label, no background
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isGradient;
  final bool isOutlined;
  final bool isDestructive;
  final bool isGhost;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Widget? trailing;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isGradient = false,
    this.isOutlined = false,
    this.isDestructive = false,
    this.isGhost = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 30,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isDestructive
        ? AppColors.error
        : isOutlined
            ? AppColors.primary
            : isGhost
                ? AppColors.accent
                : (textColor ?? Colors.white);

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: fg,
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: isGhost ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          );

    if (isGhost) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: textColor ?? AppColors.accent,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: Size(width ?? 0, height ?? 40),
        ),
        child: child,
      );
    }

    if (isOutlined || isDestructive) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height ?? 56,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? fg,
            side: BorderSide(
                color: isDestructive ? AppColors.error : AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          ),
          child: child,
        ),
      );
    }

    return Container(
      width: width ?? double.infinity,
      height: height ?? 56,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.accent,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: onPressed == null ? null : AppColors.buttonShadow,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: textColor ?? Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
        ),
        child: child,
      ),
    );
  }
}
