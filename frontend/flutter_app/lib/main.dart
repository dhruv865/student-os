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
      title: 'Student OS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xffF7F5FF),
      ),
      home: const HomeScreen(),
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<String> postAgent(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result']?.toString() ?? 'No result received from backend.';
      }
      return 'Backend error: ${response.statusCode}\n${response.body}';
    } catch (e) {
      return 'Backend not connected. Demo mode active.\n\n$e';
    }
  }

  static Future<String> uploadPdf(PlatformFile file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-pdf'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        return data['result']?.toString() ?? 'PDF uploaded successfully.';
      }
      return 'Upload failed: ${response.statusCode}\n$body';
    } catch (e) {
      return 'PDF upload failed.\n\n$e';
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
        height: 72,
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

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff4C1D95), Color(0xff7C3AED), Color(0xffA855F7)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 34),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 31,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
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
            subtitle: 'Your AI-powered multi-agent student assistant',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(18),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 33,
                          child: Icon(Icons.person, size: 36),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome Dhruv 👋',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text('B.Tech CSE Cyber Security'),
                              Text('Galgotias University'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: const [
                    StatCard(title: 'Notes Uploaded', value: '12', icon: Icons.note_alt),
                    StatCard(title: 'Deadlines', value: '5', icon: Icons.alarm),
                    StatCard(title: 'PDFs Scanned', value: '8', icon: Icons.picture_as_pdf),
                    StatCard(title: 'AI Queries', value: '24', icon: Icons.smart_toy),
                  ],
                ),
                const SizedBox(height: 18),
                SectionTitle(title: 'Active Agents'),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(label: 'Academic Active'),
                    StatusChip(label: 'Deadline Active'),
                    StatusChip(label: 'Content Active'),
                    StatusChip(label: 'PDF Tool Ready'),
                  ],
                ),
                const SizedBox(height: 18),
                const InfoCard(
                  icon: Icons.lightbulb,
                  title: 'AI Suggestion',
                  text: 'Upload your syllabus PDF and let Student OS create notes, deadlines and study plan.',
                ),
              ],
            ),
          ),
        ],
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
  String selectedTask = 'Summary';
  String result = '';
  bool loading = false;

  Future<void> generate() async {
    if (controller.text.trim().isEmpty) {
      setState(() => result = 'Please enter notes or a topic first.');
      return;
    }

    setState(() => loading = true);

    result = await ApiService.postAgent('academic', {
      'task': selectedTask,
      'input': controller.text,
    });

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const AppHeader(
            title: 'Academic Agent',
            subtitle: 'Summaries, quizzes and flashcards',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedTask,
                  decoration: const InputDecoration(
                    labelText: 'Select Academic Task',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Summary', child: Text('Generate Summary')),
                    DropdownMenuItem(value: 'Quiz', child: Text('Generate Quiz')),
                    DropdownMenuItem(value: 'Flashcards', child: Text('Generate Flashcards')),
                    DropdownMenuItem(value: 'Study Plan', child: Text('Create Study Plan')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedTask = value!);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  maxLines: 7,
                  decoration: InputDecoration(
                    hintText: 'Paste notes, syllabus or topic here...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: loading ? 'Generating...' : 'Run Academic Agent',
                  icon: Icons.auto_awesome,
                  onPressed: loading ? null : generate,
                ),
                const SizedBox(height: 20),
                ResultBox(result: result.isEmpty ? 'Academic result will appear here.' : result),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeadlineScreen extends StatefulWidget {
  const DeadlineScreen({super.key});

  @override
  State<DeadlineScreen> createState() => _DeadlineScreenState();
}

class _DeadlineScreenState extends State<DeadlineScreen> {
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  String priority = 'Medium';
  String result = '';
  bool loading = false;

  Future<void> addDeadline() async {
    if (titleController.text.trim().isEmpty || dateController.text.trim().isEmpty) {
      setState(() => result = 'Please enter deadline title and due date.');
      return;
    }

    setState(() => loading = true);

    result = await ApiService.postAgent('deadline', {
      'title': titleController.text,
      'due_date': dateController.text,
      'priority': priority,
    });

    setState(() => loading = false);
  }

  Future<void> pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (selected != null) {
      dateController.text = '${selected.day}/${selected.month}/${selected.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const AppHeader(
            title: 'Deadline Agent',
            subtitle: 'Track assignments, exams and priorities',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CustomInput(
                  controller: titleController,
                  label: 'Assignment / Exam Name',
                  icon: Icons.assignment,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  onTap: pickDate,
                  decoration: InputDecoration(
                    labelText: 'Due Date',
                    prefixIcon: const Icon(Icons.calendar_month),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                    DropdownMenuItem(value: 'Urgent', child: Text('Urgent')),
                  ],
                  onChanged: (value) {
                    setState(() => priority = value!);
                  },
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: loading ? 'Saving...' : 'Add Deadline',
                  icon: Icons.alarm_add,
                  onPressed: loading ? null : addDeadline,
                ),
                const SizedBox(height: 20),
                ResultBox(result: result.isEmpty ? 'Deadline confirmation will appear here.' : result),
              ],
            ),
          ),
        ],
      ),
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
  String contentType = 'Email';
  String result = '';
  bool loading = false;

  Future<void> generateContent() async {
    if (controller.text.trim().isEmpty) {
      setState(() => result = 'Please enter your content requirement.');
      return;
    }

    setState(() => loading = true);

    result = await ApiService.postAgent('content', {
      'type': contentType,
      'input': controller.text,
    });

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const AppHeader(
            title: 'Content Agent',
            subtitle: 'Emails, reports and applications',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: contentType,
                  decoration: InputDecoration(
                    labelText: 'Content Type',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Email', child: Text('Email')),
                    DropdownMenuItem(value: 'Report', child: Text('Report')),
                    DropdownMenuItem(value: 'Application', child: Text('Application')),
                    DropdownMenuItem(value: 'Resume Point', child: Text('Resume Point')),
                  ],
                  onChanged: (value) {
                    setState(() => contentType = value!);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  maxLines: 7,
                  decoration: InputDecoration(
                    hintText: 'Example: Write an email to mentor for meeting...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: loading ? 'Generating...' : 'Generate Content',
                  icon: Icons.edit_note,
                  onPressed: loading ? null : generateContent,
                ),
                const SizedBox(height: 20),
                ResultBox(result: result.isEmpty ? 'Generated content will appear here.' : result),
              ],
            ),
          ),
        ],
      ),
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

    final uploadResult = await ApiService.uploadPdf(pickedFile.files.single);

    setState(() {
      result = uploadResult;
      loading = false;
    });
  }

  void uploadImageForOcr() {
    setState(() {
      result = 'OCR image upload is ready. Connect this to /ocr endpoint.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const AppHeader(
            title: 'Tools',
            subtitle: 'PDF upload, OCR and academic extraction',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 36,
                          child: Icon(Icons.picture_as_pdf, size: 38),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Upload Academic PDF',
                          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Upload notes, syllabus, assignment or report PDF for AI analysis.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        if (selectedFileName != null)
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('Selected: $selectedFileName'),
                          ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: loading ? 'Uploading...' : 'Upload PDF',
                          icon: Icons.upload_file,
                          onPressed: loading ? null : uploadPdf,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.image)),
                    title: const Text('Upload Image for OCR'),
                    subtitle: const Text('Extract text from screenshots or handwritten notes'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: uploadImageForOcr,
                  ),
                ),
                const SizedBox(height: 20),
                ResultBox(result: result),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple.shade50,
              child: Icon(icon, color: Colors.deepPurple),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;

  const StatusChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.circle, size: 12, color: Colors.green),
      label: Text(label),
      backgroundColor: Colors.green.shade50,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(text),
      ),
    );
  }
}

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const CustomInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
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
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.deepPurple.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Text(
        result,
        style: const TextStyle(fontSize: 15, height: 1.4),
      ),
    );
  }
}