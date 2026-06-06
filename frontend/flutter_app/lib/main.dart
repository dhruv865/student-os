import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
void main() {
  runApp(const StudentOSApp());
}

class StudentOSApp extends StatelessWidget {
  const StudentOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student OS',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<String> postAgent(String endpoint, String input) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'input': input}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result']?.toString() ?? 'No result received';
      } else {
        return 'Backend error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Could not connect to backend. Showing demo response.\n\n$e';
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final screens = const [
    DashboardScreen(),
    AcademicScreen(),
    DeadlineScreen(),
    ContentScreen(),
    ToolsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Academic'),
          NavigationDestination(icon: Icon(Icons.alarm), label: 'Deadline'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Content'),
          NavigationDestination(icon: Icon(Icons.build), label: 'Tools'),
        ],
      ),
    );
  }
}

class AppHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AppHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 45, 20, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff6D28D9), Color(0xff9333EA)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(fontSize: 15, color: Colors.white70)),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const AppHeader(
            title: 'Student OS',
            subtitle: 'Multi-agent AI assistant for student life',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                InfoCard(
                  icon: Icons.school,
                  title: 'Academic Agent',
                  text: 'Summarize notes, create quiz, generate flashcards.',
                ),
                InfoCard(
                  icon: Icons.alarm,
                  title: 'Deadline Agent',
                  text: 'Track assignments, exams, reminders and priority.',
                ),
                InfoCard(
                  icon: Icons.edit_note,
                  title: 'Content Agent',
                  text: 'Generate emails, reports and applications.',
                ),
                InfoCard(
                  icon: Icons.picture_as_pdf,
                  title: 'PDF/OCR Tools',
                  text: 'Upload PDFs/images and extract useful student data.',
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const InfoCard(
      {super.key, required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(text),
      ),
    );
  }
}

class AcademicScreen extends StatefulWidget {
  const AcademicScreen({super.key});

  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends State<AcademicScreen> {
  final controller = TextEditingController();
  String result = '';
  bool loading = false;

  Future<void> generate() async {
    setState(() => loading = true);
    result = await ApiService.postAgent('academic', controller.text);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AgentPage(
      title: 'Academic Agent',
      subtitle: 'Summaries, quiz and flashcards',
      hint: 'Paste notes or topic here...',
      controller: controller,
      buttonText: 'Generate Summary',
      result: result,
      loading: loading,
      onPressed: generate,
    );
  }
}

class DeadlineScreen extends StatefulWidget {
  const DeadlineScreen({super.key});

  @override
  State<DeadlineScreen> createState() => _DeadlineScreenState();
}

class _DeadlineScreenState extends State<DeadlineScreen> {
  final controller = TextEditingController();
  String result = '';
  bool loading = false;

  Future<void> generate() async {
    setState(() => loading = true);
    result = await ApiService.postAgent('deadline', controller.text);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AgentPage(
      title: 'Deadline Agent',
      subtitle: 'Assignment and exam reminders',
      hint: 'Example: Web Tech assignment due tomorrow...',
      controller: controller,
      buttonText: 'Add Deadline',
      result: result,
      loading: loading,
      onPressed: generate,
    );
  }
}

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final controller = TextEditingController();
  String result = '';
  bool loading = false;

  Future<void> generate() async {
    setState(() => loading = true);
    result = await ApiService.postAgent('content', controller.text);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AgentPage(
      title: 'Content Agent',
      subtitle: 'Emails, reports and applications',
      hint: 'Write what you want to generate...',
      controller: controller,
      buttonText: 'Generate Content',
      result: result,
      loading: loading,
      onPressed: generate,
    );
  }
}

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  String result = 'Upload a PDF to extract and analyze student data.';
  bool loading = false;
  String? selectedFileName;

  Future<void> uploadPdf() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (pickedFile == null) return;

    setState(() {
      loading = true;
      selectedFileName = pickedFile.files.single.name;
      result = 'Uploading PDF...';
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/upload-pdf'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          pickedFile.files.single.bytes!,
          filename: pickedFile.files.single.name,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        setState(() {
          result = data['result']?.toString() ?? 'PDF uploaded successfully.';
        });
      } else {
        setState(() {
          result = 'Upload failed. Status code: ${response.statusCode}\n$responseBody';
        });
      }
    } catch (e) {
      setState(() {
        result = 'Could not upload PDF.\n\n$e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> uploadImageForOcr() async {
    setState(() {
      result = 'OCR image upload will connect to /ocr endpoint.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const AppHeader(
            title: 'Tools',
            subtitle: 'PDF, OCR and email tools',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            size: 48, color: Colors.deepPurple),
                        const SizedBox(height: 10),
                        const Text(
                          'Upload Academic PDF',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Upload notes, syllabus, assignment or report PDF.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        if (selectedFileName != null)
                          Text(
                            'Selected: $selectedFileName',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: loading ? null : uploadPdf,
                            icon: const Icon(Icons.upload_file),
                            label: loading
                                ? const Text('Uploading...')
                                : const Text('Upload PDF'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.image),
                    ),
                    title: const Text('Upload Image for OCR'),
                    subtitle: const Text('Connects to OCR tool endpoint'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: uploadImageForOcr,
                  ),
                ),
                const SizedBox(height: 20),
                ResultBox(result: result),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class AgentPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String hint;
  final TextEditingController controller;
  final String buttonText;
  final String result;
  final bool loading;
  final VoidCallback onPressed;

  const AgentPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.controller,
    required this.buttonText,
    required this.result,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppHeader(title: title, subtitle: subtitle),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  maxLines: 7,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loading ? null : onPressed,
                    child: loading
                        ? const CircularProgressIndicator()
                        : Text(buttonText),
                  ),
                ),
                const SizedBox(height: 20),
                ResultBox(
                  result: result.isEmpty
                      ? 'AI response will appear here.'
                      : result,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResultBox extends StatelessWidget {
  final String result;

  const ResultBox({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Text(result, style: const TextStyle(fontSize: 15)),
    );
  }
}