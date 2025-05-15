import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IdentityStatusActions extends StatelessWidget {
  final bool isFormValid;
  final bool isSaving;
  final bool showSuccess;
  final String? errorText;
  final VoidCallback onSave;
  final VoidCallback onBack;
  const IdentityStatusActions({
    super.key,
    required this.isFormValid,
    required this.isSaving,
    required this.showSuccess,
    required this.errorText,
    required this.onSave,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(errorText!, style: GoogleFonts.inter(color: Colors.red, fontSize: 14)),
          ),
        AnimatedScale(
          scale: isSaving ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isFormValid && !isSaving ? onSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFormValid ? Theme.of(context).primaryColor : Colors.grey,
                foregroundColor: isFormValid ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18),
                elevation: 0,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                    )
                  : showSuccess
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                      : const Text('Kaydet ve İlerle'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Tüm sorulara yanıt vererek en iyi sonucu alın.', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey, size: 24),
            onPressed: onBack,
            tooltip: 'Geri',
          ),
        ),
      ],
    );
  }
} 