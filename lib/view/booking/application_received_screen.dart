import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:valuemate/res/colors/colors.dart';

class ValuationUpdatedScreen extends StatelessWidget {
  const ValuationUpdatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? scaffoldColorDark : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_work_outlined, 
                size: 100, 
                color: isDark ? Colors.white : primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Your property valuation application\nhas been Received',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'re currently reviewing the information.\nYou will be notified once the valuation is complete.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Navigate to dashboard or home
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: Text(
                  'Go to Dashboard',
                  style: GoogleFonts.inter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}