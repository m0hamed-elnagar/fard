import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'quran_reader_page.dart';
// import 'surah_detail_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Use the bloc from DI if available, or create it here.
    // In MainNavigationScreen we will provide it if needed, but here it's fine.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BlocProvider(
      create: (context) => getIt<QuranBloc>()..add(const QuranEvent.loadSurahs()),
      child: Scaffold(
        appBar: AppBar(
          leading: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.searchSurah,
                    border: InputBorder.none,
                    hintStyle: const TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                )
              : Text(
                  l10n.quran,
                  style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 24),
                ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _searchController.clear();
                    _searchQuery = '';
                    _isSearching = false;
                  } else {
                    _isSearching = true;
                  }
                });
              },
            ),
          ],
        ),
        body: BlocBuilder<QuranBloc, QuranState>(
          builder: (context, state) {
            if (state.isLoading && state.surahs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.loadingQuran, style: GoogleFonts.amiri()),
                  ],
                ),
              );
            }

            if (state.error != null && state.surahs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        l10n.errorLoadingQuran,
                        style: GoogleFonts.amiri(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context
                            .read<QuranBloc>()
                            .add(const QuranEvent.loadSurahs()),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              );
            }

            final filteredSurahs = state.surahs.where((surah) {
              return surah.name.contains(_searchQuery) ||
                  surah.number.value.toString().contains(_searchQuery);
            }).toList();

            if (filteredSurahs.isEmpty && !state.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu_book, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noSearchResults,
                      style: GoogleFonts.amiri(fontSize: 20),
                    ),
                  ],
                ),
              );
            }

            final lastRead = state.lastReadPosition;
            final hasLastRead = lastRead != null && state.surahs.isNotEmpty;
            Surah? lastReadSurah;
            if (hasLastRead) {
              try {
                lastReadSurah = state.surahs.firstWhere(
                  (s) => s.number.value == lastRead.ayahNumber.surahNumber
                );
              } catch (_) {}
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredSurahs.length + (hasLastRead && _searchQuery.isEmpty ? 1 : 0),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (hasLastRead && _searchQuery.isEmpty && index == 0) {
                  return _ContinueReadingCard(
                    surah: lastReadSurah!,
                    ayahNumber: lastRead.ayahNumber.ayahNumberInSurah,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuranReaderPage(
                            surahNumber: lastReadSurah!.number.value,
                            initialAyahNumber: lastRead.ayahNumber.ayahNumberInSurah,
                          ),
                        ),
                      );
                    },
                  );
                }

                final surahIndex = hasLastRead && _searchQuery.isEmpty ? index - 1 : index;
                final surah = filteredSurahs[surahIndex];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      surah.number.value.toString(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      surah.name,
                      style: GoogleFonts.amiri(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  subtitle: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${surah.numberOfAyahs} ${l10n.ayah}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuranReaderPage(surahNumber: surah.number.value),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  final Surah surah;
  final int ayahNumber;
  final VoidCallback onTap;

  const _ContinueReadingCard({
    required this.surah,
    required this.ayahNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu_book, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'متابعة القراءة',
                        style: GoogleFonts.amiri(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    surah.name,
                    style: GoogleFonts.amiri(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'الآية رقم: $ayahNumber',
                    style: GoogleFonts.amiri(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
