import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:intl/intl.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';

import 'package:fard/core/extensions/number_extension.dart';
import 'package:fard/core/theme/app_colors.dart';

class BookmarkList extends StatefulWidget {
  final String searchQuery;

  const BookmarkList({super.key, required this.searchQuery});

  @override
  State<BookmarkList> createState() => _BookmarkListState();
}

class _BookmarkListState extends State<BookmarkList>
    with AutomaticKeepAliveClientMixin {
  final Set<AyahNumber> _selectedBookmarks = {};
  bool _isSelectionMode = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<QuranBloc>().add(const QuranEvent.loadBookmarks());
  }

  void _toggleSelection(AyahNumber ayahNumber) {
    setState(() {
      if (_selectedBookmarks.contains(ayahNumber)) {
        _selectedBookmarks.remove(ayahNumber);
        if (_selectedBookmarks.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedBookmarks.add(ayahNumber);
        _isSelectionMode = true;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedBookmarks.clear();
      _isSelectionMode = false;
    });
  }

  Future<bool> _confirmDelete(
    BuildContext context, {
    required int count,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'تأكيد الحذف',
              style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            content: Text(
              count > 1
                  ? 'هل أنت متأكد من حذف ${count.toArabicIndic()} إشارات مرجعية؟'
                  : 'هل أنت متأكد من حذف هذه الإشارة المرجعية؟',
              style: GoogleFonts.amiri(),
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.amiri(color: context.onSurfaceVariantColor),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('حذف', style: GoogleFonts.amiri(color: context.errorColor)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocConsumer<QuranBloc, QuranState>(
      listenWhen: (previous, current) =>
          previous.bookmarks != current.bookmarks,
      listener: (context, state) {
        final currentAyahNumbers = state.bookmarks
            .map((b) => b.ayahNumber)
            .toSet();
        final toRemove = _selectedBookmarks
            .where((selected) => !currentAyahNumbers.contains(selected))
            .toList();
        if (toRemove.isNotEmpty) {
          setState(() {
            for (final item in toRemove) {
              _selectedBookmarks.remove(item);
            }
            if (_selectedBookmarks.isEmpty) {
              _isSelectionMode = false;
            }
          });
        }
      },
      builder: (context, state) {
        final bookmarks = state.bookmarks;

        final filteredBookmarks = bookmarks.where((bookmark) {
          if (widget.searchQuery.isEmpty) return true;
          final surahName = quran.getSurahNameArabic(
            bookmark.ayahNumber.surahNumber,
          );
          return surahName.contains(widget.searchQuery) ||
              bookmark.ayahNumber.ayahNumberInSurah.toString().contains(
                widget.searchQuery,
              );
        }).toList();

        if (filteredBookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border_rounded,
                  size: 64,
                  color: context.onSurfaceVariantColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد إشارات مرجعية',
                  style: GoogleFonts.amiri(fontSize: 20),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (_isSelectionMode)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: context.errorColor),
                      onPressed: () async {
                        if (await _confirmDelete(
                          context,
                          count: _selectedBookmarks.length,
                        )) {
                          if (context.mounted) {
                            context.read<QuranBloc>().add(
                              QuranEvent.removeMultipleBookmarks(
                                _selectedBookmarks.toList(),
                              ),
                            );
                            _clearSelection();
                          }
                        }
                      },
                    ),
                    const Spacer(),
                    Text(
                      'تم تحديد ${_selectedBookmarks.length.toArabicIndic()}',
                      style: GoogleFonts.amiri(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _clearSelection,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredBookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = filteredBookmarks[index];
                  final surahName = quran.getSurahNameArabic(
                    bookmark.ayahNumber.surahNumber,
                  );
                  final page = quran.getPageNumber(
                    bookmark.ayahNumber.surahNumber,
                    bookmark.ayahNumber.ayahNumberInSurah,
                  );
                  final isSelected = _selectedBookmarks.contains(
                    bookmark.ayahNumber,
                  );

                  return Card(
                    elevation: isSelected ? 4 : 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : context.outlineColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: _isSelectionMode
                          ? Checkbox(
                              value: isSelected,
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (_) =>
                                  _toggleSelection(bookmark.ayahNumber),
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: context.errorColor,
                                size: 20,
                              ),
                              onPressed: () async {
                                if (await _confirmDelete(context, count: 1)) {
                                  if (context.mounted) {
                                    context.read<QuranBloc>().add(
                                      QuranEvent.removeBookmark(
                                        bookmark.ayahNumber,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                      title: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'سورة $surahName',
                          style: GoogleFonts.amiri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                            wordSpacing: 2,
                          ),
                        ),
                      ),
                      subtitle: Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'الآية ${bookmark.ayahNumber.ayahNumberInSurah.toArabicIndic()} | صفحة ${page.toArabicIndic()}',
                              style: GoogleFonts.amiri(
                                fontSize: 14,
                                color: context.onSurfaceVariantColor,
                                height: 1.4,
                                wordSpacing: 2,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'yyyy/MM/dd HH:mm',
                              ).format(bookmark.createdAt),
                              style: TextStyle(
                                fontSize: 10,
                                color: context.onSurfaceVariantColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onLongPress: () => _toggleSelection(bookmark.ayahNumber),
                      onTap: () {
                        if (_isSelectionMode) {
                          _toggleSelection(bookmark.ayahNumber);
                        } else {
                          Navigator.push(
                            context,
                            QuranReaderPage.route(
                              surahNumber: bookmark.ayahNumber.surahNumber,
                              ayahNumber: bookmark.ayahNumber.ayahNumberInSurah,
                            ),
                          );
                        }
                      },
                      trailing: !_isSelectionMode
                          ? Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.secondaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.bookmark_rounded,
                                color: context.secondaryColor,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
