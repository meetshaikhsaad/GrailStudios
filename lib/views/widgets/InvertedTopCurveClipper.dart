
import '../../helpers/ExportImports.dart';

class InvertedTopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Responsive radius: 13% of width, clamped between 36 and 100
    final double r = (size.width * 0.130).clamp(36.0, 100.0);

    final path = Path();

    // Start after top-left curve
    path.moveTo(r, r);

    // Straight top line
    path.lineTo(size.width - r, r);

    // Top-right INVERTED (concave upward)
    path.arcToPoint(
      Offset(size.width, 0),
      radius: Radius.circular(r),
      clockwise: false,
    );

    // Right side
    path.lineTo(size.width, size.height);

    // Bottom
    path.lineTo(0, size.height);

    // Left side up
    path.lineTo(0, r * 2);

    // Top-left NORMAL (convex downward)
    path.arcToPoint(
      Offset(r, r),
      radius: Radius.circular(r),
      clockwise: true,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
