import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class DetailsPage extends StatefulWidget {
  final List<String> images;
  final String title;
  final String description;
  final String link;
  final String? cause;
  final String? importance;
  final Map<String, String>? symptoms;
  final String? spread;
  final Map<String, String>? prevention;

  const DetailsPage({
    Key? key,
    required this.images,
    required this.title,
    required this.description,
    required this.link,
    this.cause,
    this.importance,
    this.symptoms,
    this.spread,
    this.prevention,
  }) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  final ScrollController _scrollController = ScrollController();

  static const TextStyle textStyle = TextStyle(
    fontSize: 18,
    color: Colors.black,
    height: 1.6,
  );

  static const TextStyle headerStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  );

  static const TextStyle subHeaderStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black54,
  );

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < widget.images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * 0.95;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF41A96D),
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel
                SizedBox(
                  width: double.infinity,
                  height: 400,
                  child: widget.images.isNotEmpty
                      ? Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: widget.images.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    widget.images[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: SmoothPageIndicator(
                                  controller: _pageController,
                                  count: widget.images.length,
                                  effect: const ExpandingDotsEffect(
                                    dotColor: Colors.grey,
                                    activeDotColor: Color(0xFF41A96D),
                                    dotHeight: 10,
                                    dotWidth: 10,
                                    spacing: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Center(child: Text('No images available')),
                ),

                // Title and Description
                const SizedBox(height: 20),
                _buildSection(widget.title, headerStyle, width),
                const SizedBox(height: 12),
                _buildSection(widget.description, textStyle, width),
                const Divider(height: 32),

                // Additional Sections
                if (widget.cause != null)
                  _buildCollapsibleSection('สาเหตุ', widget.cause!),
                if (widget.importance != null)
                  _buildCollapsibleSection('ความสำคัญ', widget.importance!),
                if (widget.symptoms != null)
                  _buildSymptomSection('อาการ', widget.symptoms!, width),
                if (widget.spread != null)
                  _buildCollapsibleSection('การแพร่กระจาย', widget.spread!),
                if (widget.prevention != null)
                  _buildSymptomSection('การป้องกัน', widget.prevention!, width),

                // Source Button
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: width,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchURL(context, widget.link),
                      icon: const Icon(Icons.link),
                      label: const Text('แหล่งอ้างอิงข้อมูล',
                          style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                // Extra spacing
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }

  Widget _buildSection(String text, TextStyle style, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Text(text, style: style),
      ),
    );
  }

  Widget _buildCollapsibleSection(String header, String content) {
    return ExpansionTile(
      title: Text(header, style: subHeaderStyle),
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(content, style: textStyle),
        ),
      ],
    );
  }

  Widget _buildSymptomSection(
      String header, Map<String, String> items, double width) {
    final keysOrder = [
      'root',
      'stem',
      'leaf',
      'environment',
      'biological',
      'chemical',
      'organic'
    ];

    return ExpansionTile(
      title: Text(header, style: subHeaderStyle),
      children: keysOrder.where((key) => items.containsKey(key)).map((key) {
        return ListTile(
          title: Text(_capitalizeFirstLetter(key),
              style: textStyle.copyWith(fontWeight: FontWeight.bold)),
          subtitle: Text(items[key]!, style: textStyle),
        );
      }).toList(),
    );
  }

  String _capitalizeFirstLetter(String text) {
    switch (text) {
      case 'root':
        return 'ราก';
      case 'stem':
        return 'ลำต้น';
      case 'leaf':
        return 'ใบ';
      case 'environment':
        return 'สิ่งแวดล้อม';
      case 'biological':
        return 'การใช้ชีววิธี';
      case 'chemical':
        return 'การแก้ไขแบบสารเคมี';
      case 'organic':
        return 'การแก้ไขแบบเกษตรอินทรีย์';
      default:
        return text;
    }
  }
}
