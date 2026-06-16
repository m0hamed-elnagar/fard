import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _contactEmail() async {
    final uri = Uri.parse('mailto:mohamed.3lnagar@gmail.com?subject=Fard%20App%20Feedback');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isArabic = locale == 'ar';

    final title = isArabic ? 'سياسة الخصوصية' : 'Privacy Policy';
    final lastUpdated = isArabic ? 'آخر تحديث: 14 يونيو 2026' : 'Last Updated: June 14, 2026';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: context.onSurfaceColor,
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 40.0),
        children: [
          // Last Updated Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lastUpdated,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Intro paragraph
          Text(
            isArabic
                ? 'يدير محمد النجار تطبيق فرض (تتبع القضاء). نحن ملتزمون بحماية خصوصيتك وضمان التعامل مع بياناتك الشخصية والروحية بطريقة آمنة وشفافة ومسؤولة.'
                : 'Mohamed Elnagar operates the Fard (Qada Tracker) mobile application. We are committed to protecting your privacy and ensuring your spiritual and personal data is handled in a safe, transparent, and responsible manner.',
            style: GoogleFonts.amiri(
              fontSize: 16,
              height: 1.6,
              color: context.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 24),

          // Section 1: Offline First & Data Storage
          _buildSectionCard(
            context,
            isArabic ? '1. التخزين المحلي والبيانات' : '1. Local Storage & Offline-First',
            isArabic
                ? 'تطبيق فرض يعمل بالكامل بدون اتصال بالإنترنت (Offline-First):\n'
                    '• جميع بيانات الصلوات الفائتة (القضاء)، وتتبع قراءة القرآن (الورد)، وال bookmarks، وأذكارك المخصصة، وتعداد التسبيح تُخزن محلياً فقط على جهازك.\n'
                    '• لا نطلب أي إنشاء حساب أو تسجيل دخول، ولا نقوم برفع أو الوصول إلى أي من هذه البيانات الروحية أو الشخصية.'
                : 'Fard is designed as an offline-first application:\n'
                    '• All records of your missed prayers (Qada), Quran progress (Werd), bookmarks, custom Azkar, and Tasbih counts are stored strictly on your device.\n'
                    '• No registration or account creation is required, and we do not collect, view, or upload any of your tracking data.',
            Icons.phonelink_setup_rounded,
          ),

          // Section 2: Permissions
          _buildSectionCard(
            context,
            isArabic ? '2. صلاحيات الجهاز' : '2. Device Permissions',
            isArabic
                ? 'يتطلب التطبيق بعض الصلاحيات الأساسية لتقديم وظائفه:\n'
                    '• بيانات الموقع: تُستخدم لحساب مواقيت الصلاة واتجاه القبلة. الحساب يتم بالكامل محلياً على الجهاز ولا يتم مشاركته أو رفعه أبداً.\n'
                    '• التنبيهات: لإرسال تذكيرات بمواقيت الصلاة والأذكار اليومية.\n'
                    '• الصوت والتشغيل في الخلفية: لتشغيل تلاوات القرآن حتى عندما تكون الشاشة مغلقة.\n'
                    '• الاهتزاز (Haptics): لمحاكاة السبحة الإلكترونية بشكل تفاعلي.'
                : 'To provide its features, the App requests access to certain device capabilities:\n'
                    '• Location Data: Used only to calculate accurate local prayer times and Qibla direction. Location coordinates are processed strictly on-device and never uploaded.\n'
                    '• Notifications: Used to send reminders for prayer times and daily Azkar.\n'
                    '• Audio & Background: Used to play Quran recitations while the screen is off or in the background.\n'
                    '• Vibration: Used to simulate physical beads for the Tasbih counter.',
            Icons.vpn_key_rounded,
          ),

          // Section 3: Ad-Free Policy
          _buildSectionCard(
            context,
            isArabic ? '3. سياسة خالية من الإعلانات' : '3. Ad-Free Policy',
            isArabic
                ? 'التطبيق خالٍ تماماً من الإعلانات. نحن لا نقوم بدمج أي أدوات برمجية للإعلانات أو مشاركة بياناتك مع شبكات التسويق والإعلانات.'
                : 'Fard is completely ad-free. We do not integrate advertising SDKs and do not share any user information with marketing or advertising networks.',
            Icons.block_rounded,
          ),

          // Section 4: Anonymous Telemetry & Analytics
          _buildSectionCard(
            context,
            isArabic ? '4. تحليلات وخدمات الطرف الثالث المجهولة' : '4. Telemetry & Performance Monitoring',
            isArabic
                ? 'لمراقبة استقرار وأداء التطبيق وحل المشكلات، نستخدم خدمات Firebase المجهولة من Google:\n'
                    '• Firebase Analytics: لمعرفة إحصائيات الاستخدام بشكل مجهول ومجمع.\n'
                    '• Firebase Crashlytics: لتلقي تقارير الأخطاء والأعطال البرمجية مجهولة الهوية لتصحيحها في التحديثات.\n'
                    '• Firebase Performance: لقياس سرعة استجابة التطبيق وتحسين استهلاك الموارد.'
                : 'To help us monitor app performance and solve crashes, we use anonymous services from Google Firebase:\n'
                    '• Firebase Analytics: Collects anonymous usage metrics (such as screen views and button taps).\n'
                    '• Firebase Crashlytics: Gathers anonymous crash logs to help us debug unexpected crashes.\n'
                    '• Firebase Performance: Measures app latency and resource utilization anonymously.',
            Icons.analytics_rounded,
          ),

          // Section 5: Children's Privacy
          _buildSectionCard(
            context,
            isArabic ? '5. خصوصية الأطفال' : '5. Children\'s Privacy',
            isArabic
                ? 'نحن لا نجمع أي بيانات تعريف شخصية. ولا نقوم بجمع أي معلومات من الأطفال دون سن 13 عاماً.'
                : 'The App does not collect any personally identifiable information. We do not knowingly collect personal information from children under 13.',
            Icons.child_care_rounded,
          ),

          // Contact us section card
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.surfaceContainerColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: context.outlineColor.withValues(alpha: 0.15),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.mail_outline_rounded,
                  color: context.primaryColor,
                  size: 36,
                ),
                const SizedBox(height: 12),
                Text(
                  isArabic ? 'هل لديك أي استفسار؟' : 'Have any questions?',
                  style: GoogleFonts.amiri(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: context.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isArabic
                      ? 'يمكنك التواصل مباشرة مع المطور للملاحظات أو المساعدة.'
                      : 'You can contact the developer directly for feedback or support.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.onSurfaceVariantColor,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse('https://wa.me/201017713257'),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: SvgPicture.string(
                        _whatsappSvg,
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      label: Text(isArabic ? 'واتساب' : 'WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _contactEmail,
                      icon: const Icon(Icons.email_outlined, size: 18),
                      label: Text(isArabic ? 'البريد الإلكتروني' : 'Email'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const String _whatsappSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
  <path d="M13.601 2.326A7.85 7.85 0 0 0 7.994 0C3.627 0 .068 3.558.064 7.926c0 1.399.366 2.76 1.057 3.965L0 16l4.204-1.102a7.9 7.9 0 0 0 3.79.965h.004c4.368 0 7.926-3.558 7.93-7.93A7.9 7.9 0 0 0 13.6 2.326zM7.994 14.521a6.6 6.6 0 0 1-3.356-.92l-.24-.144-2.494.654.666-2.433-.156-.251a6.56 6.56 0 0 1-1.007-3.505c0-3.626 2.957-6.584 6.591-6.584a6.56 6.56 0 0 1 4.66 1.931 6.56 6.56 0 0 1 1.928 4.66c-.004 3.639-2.961 6.592-6.592 6.592m3.615-4.934c-.197-.099-1.17-.578-1.353-.646-.182-.065-.315-.099-.445.099-.133.197-.513.646-.627.775-.114.133-.232.148-.43.05-.197-.1-.836-.308-1.592-.985-.59-.525-.985-1.175-1.103-1.372-.114-.198-.011-.304.088-.403.087-.088.197-.232.296-.346.1-.114.133-.198.198-.33.065-.134.034-.248-.015-.347-.05-.099-.445-1.076-.612-1.47-.16-.389-.323-.335-.445-.34-.114-.007-.247-.007-.38-.007a.73.73 0 0 0-.529.247c-.182.198-.691.677-.691 1.654s.71 1.916.81 2.049c.098.133 1.394 2.132 3.383 2.992.47.205.84.326 1.129.418.475.152.904.129 1.246.08.38-.058 1.171-.48 1.338-.943.164-.464.164-.86.114-.943-.049-.084-.182-.133-.38-.232"/>
</svg>
''';

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.surfaceContainerColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.outlineColor.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: context.primaryColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.onSurfaceColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: context.onSurfaceVariantColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
