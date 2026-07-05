import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/l10n/app_localizations.dart';

/// Shows the redesigned About App dialog with Style 2 Elegant Serif signature.
void showAboutAppDialog(BuildContext context, String version) {
  final l10n = AppLocalizations.of(context)!;
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  
  showDialog(
    context: context,
    builder: (context) {
      final primaryColor = Theme.of(context).colorScheme.primary;
      final onSurfaceColor = Theme.of(context).colorScheme.onSurface;
      final onSurfaceVariantColor = Theme.of(context).colorScheme.onSurfaceVariant;
      
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Center Mosque Header Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mosque_rounded,
                color: primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            
            // App Title
            Text(
              l10n.aboutAppTitle,
              style: GoogleFonts.amiri(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: onSurfaceColor,
              ),
            ),
            const SizedBox(height: 4),
            
            // Version tag
            Text(
              'Version $version',
              style: GoogleFonts.outfit(
                color: onSurfaceVariantColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            
            // App Description
            Text(
              l10n.aboutAppMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 16,
                height: 1.5,
                color: onSurfaceColor,
              ),
            ),
            // Islamic Spiritual Touch
            isArabic
                ? Text(
                    '✨ لا تنسونا من صالح دعائكم ✨',
                    style: GoogleFonts.amiri(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryColor.withValues(alpha: 0.7),
                    ),
                  )
                : Text(
                    '✨ Please remember us in your prayers ✨',
                    style: GoogleFonts.dancingScript(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryColor.withValues(alpha: 0.75),
                    ),
                  ),
            const SizedBox(height: 20),
            
            // Developed By Section (Redesigned Signature)
            Text(
              isArabic ? 'تطوير' : 'DEVELOPED BY',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
                color: onSurfaceVariantColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            
            // Interactive Developer Signature
            InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                _launchUrl('https://github.com/m0hamed-elnagar');
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: isArabic
                    ? Text(
                        'محمد النجار',
                        style: GoogleFonts.amiri(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: primaryColor,
                        ),
                      )
                    : Text(
                        'MOHAMED ELNAGAR',
                        style: GoogleFonts.cinzel(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          letterSpacing: 1.5,
                          color: primaryColor,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Contact & Social Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(
                  context,
                  icon: SvgPicture.string(
                    _whatsappSvg,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                  ),
                  tooltip: l10n.whatsapp,
                  onTap: () => _launchUrl('https://wa.me/201017713257'),
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _buildSocialIcon(
                  context,
                  icon: Icon(
                    Icons.email_outlined,
                    color: primaryColor,
                    size: 20,
                  ),
                  tooltip: l10n.contactUs,
                  onTap: () => _launchUrl('mailto:mohamed.3lnagar@gmail.com?subject=Fard%20App%20Feedback'),
                  color: primaryColor,
                ),
                const SizedBox(width: 16),
                _buildSocialIcon(
                  context,
                  icon: SvgPicture.string(
                    _githubSvg,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(onSurfaceColor, BlendMode.srcIn),
                  ),
                  tooltip: 'GitHub',
                  onTap: () => _launchUrl('https://github.com/m0hamed-elnagar'),
                  color: onSurfaceColor,
                ),
              ],
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                MaterialLocalizations.of(context).closeButtonLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildSocialIcon(
  BuildContext context, {
  required Widget icon,
  required String tooltip,
  required VoidCallback onTap,
  required Color color,
}) {
  return Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
        child: icon,
      ),
    ),
  );
}

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('Could not launch $url: $e');
  }
}

const String _whatsappSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
  <path d="M13.601 2.326A7.85 7.85 0 0 0 7.994 0C3.627 0 .068 3.558.064 7.926c0 1.399.366 2.76 1.057 3.965L0 16l4.204-1.102a7.9 7.9 0 0 0 3.79.965h.004c4.368 0 7.926-3.558 7.93-7.93A7.9 7.9 0 0 0 13.6 2.326zM7.994 14.521a6.6 6.6 0 0 1-3.356-.92l-.24-.144-2.494.654.666-2.433-.156-.251a6.56 6.56 0 0 1-1.007-3.505c0-3.626 2.957-6.584 6.591-6.584a6.56 6.56 0 0 1 4.66 1.931 6.56 6.56 0 0 1 1.928 4.66c-.004 3.639-2.961 6.592-6.592 6.592m3.615-4.934c-.197-.099-1.17-.578-1.353-.646-.182-.065-.315-.099-.445.099-.133.197-.513.646-.627.775-.114.133-.232.148-.43.05-.197-.1-.836-.308-1.592-.985-.59-.525-.985-1.175-1.103-1.372-.114-.198-.011-.304.088-.403.087-.088.197-.232.296-.346.1-.114.133-.198.198-.33.065-.134.034-.248-.015-.347-.05-.099-.445-1.076-.612-1.47-.16-.389-.323-.335-.445-.34-.114-.007-.247-.007-.38-.007a.73.73 0 0 0-.529.247c-.182.198-.691.677-.691 1.654s.71 1.916.81 2.049c.098.133 1.394 2.132 3.383 2.992.47.205.84.326 1.129.418.475.152.904.129 1.246.08.38-.058 1.171-.48 1.338-.943.164-.464.164-.86.114-.943-.049-.084-.182-.133-.38-.232"/>
</svg>
''';

const String _githubSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/>
</svg>
''';
