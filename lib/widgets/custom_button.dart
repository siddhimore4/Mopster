import 'package:flutter/material.dart';
import '../config/colors.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLimeAccent;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.isLimeAccent = false,
    this.icon,
    this.isLoading = false,
    this.height = 54.0,
    this.borderRadius = 18.0,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;
    List<BoxShadow>? shadows;

    if (widget.isOutlined) {
      backgroundColor = Colors.transparent;
      foregroundColor = AppColors.forestGreen;
      borderSide = const BorderSide(color: AppColors.forestGreen, width: 1.8);
      shadows = null;
    } else if (widget.isLimeAccent) {
      backgroundColor = isEnabled ? AppColors.electricLime : AppColors.electricLime.withOpacity(0.5);
      foregroundColor = AppColors.deepCharcoal;
      borderSide = null;
      shadows = isEnabled
          ? [
              BoxShadow(
                color: AppColors.electricLime.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ]
          : null;
    } else {
      backgroundColor = isEnabled ? AppColors.forestGreen : AppColors.forestGreen.withOpacity(0.5);
      foregroundColor = Colors.white;
      borderSide = null;
      shadows = isEnabled
          ? [
              BoxShadow(
                color: AppColors.forestGreen.withOpacity(0.24),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ]
          : null;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: borderSide != null ? Border.fromBorderSide(borderSide) : null,
              boxShadow: shadows,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: InkWell(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                onTap: widget.isLoading ? null : widget.onPressed,
                child: Center(
                  child: _buildChild(foregroundColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(Color textColor) {
    if (widget.isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 20, color: textColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: 0.2,
      ),
    );
  }
}
