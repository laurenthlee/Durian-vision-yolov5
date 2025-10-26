import 'package:flutter/material.dart';
import 'detection.dart';
import 'details_page.dart';
import 'loading_page.dart';
import 'data.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ตรวจโรคทุเรียน',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Roboto'),
          bodyMedium: TextStyle(fontFamily: 'Roboto'),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const LoadingPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late String greeting;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _setGreeting();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 3 && hour < 7) {
      greeting = "สวัสดีตอนเช้า";
    } else if (hour >= 7 && hour < 11) {
      greeting = "สวัสดีตอนสาย";
    } else if (hour >= 11 && hour < 13) {
      greeting = "สวัสดีตอนเที่ยง";
    } else if (hour >= 13 && hour < 16) {
      greeting = "สวัสดีตอนบ่าย";
    } else if (hour >= 16 && hour < 18) {
      greeting = "สวัสดีตอนเย็น";
    } else {
      greeting = "สวัสดีตอนกลางคืน";
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomePage() {
    return ListView(
      children: [
        // Horizontal Scrollable Sections with PageView
        SizedBox(
          height: 250,
          child: PageView(
            controller: _pageController,
            children: [
              // Greeting Section
              _buildGreetingSection(),
              // ขั้นตอนการใช้งาน Section
              _buildUsageStepsSection(),
            ],
          ),
        ),
        // Smooth Page Indicator
        Center(
          child: SmoothPageIndicator(
            controller: _pageController,
            count: 2,
            effect: const WormEffect(
              dotColor: Colors.grey,
              activeDotColor: Colors.green,
              dotHeight: 8,
              dotWidth: 8,
              spacing: 16,
            ),
          ),
        ),
        // Disease Information Section
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 17.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'โรคทุเรียนที่เกิดขึ้นบ่อย',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 60, 239, 69),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        // Disease Grid
        _buildDiseaseGrid(),
      ],
    );
  }

  Widget _buildGreetingSection() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      height: 200, // Set a fixed height to make both sections the same size
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            greeting == "สวัสดีตอนกลางคืน" ? Icons.nights_stay : Icons.wb_sunny,
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              greeting,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black54,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStepsSection() {
    return Container(
      margin: const EdgeInsets.only(
          left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
      padding: const EdgeInsets.all(16.0),
      height: 200, // Set the same fixed height
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.lightGreen, Colors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ขั้นตอนการใช้งาน',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildStepGuide(),
        ],
      ),
    );
  }

  Widget _buildStepGuide() {
    final steps = [
      {'icon': Icons.camera_alt, 'label': 'ถ่ายรูป'},
      {'icon': Icons.search, 'label': 'วิเคราะห์'},
      {'icon': Icons.info, 'label': 'รับคำแนะนำ'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: steps.map((step) {
        return Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(
                step['icon'] as IconData,
                size: 30,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              step['label'] as String,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black45,
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDiseaseGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        itemCount: items.length,
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(), // Prevent grid from scrolling separately
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              // Navigate to detailed page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsPage(
                    images: item['images'],
                    title: item['title'],
                    description: item['description'],
                    link: item['link'],
                    cause: item['cause'],
                    importance: item['importance'],
                    symptoms: item['symptoms'],
                    spread: item['spread'],
                    prevention: item['prevention'],
                  ),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(
                        item['images'][0],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    child: Text(
                      item['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18, // Increased font size
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetectionPage() {
    return const DetectionPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF64B5F6), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          toolbarHeight: 70.0,
          centerTitle: true,
          elevation: 5,
          shadowColor: Colors.black54,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white),
              onPressed: () {
                // Help action
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/image/durian_background.png'), // Your background image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color.fromARGB(
                  115, 66, 66, 66), // Dark overlay to ensure content stands out
              BlendMode.darken,
            ),
          ),
        ),
        child: _selectedIndex == 0 ? _buildHomePage() : _buildDetectionPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'ตรวจสอบโรค',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
