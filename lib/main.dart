import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppInitializer());
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return MaterialApp(
              home: Scaffold(
                  body: Center(
                      child: Text('Firebase Error:\n${snapshot.error}',
                          style: const TextStyle(color: Colors.red)))));
        if (snapshot.connectionState == ConnectionState.done)
          return const CaterFlowEmployerApp();
        return const MaterialApp(
            home: Scaffold(
                backgroundColor: Color(0xFF0A2540),
                body: Center(
                    child: CircularProgressIndicator(color: Colors.white))));
      },
    );
  }
}

class CaterFlowEmployerApp extends StatelessWidget {
  const CaterFlowEmployerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CaterFlow Employer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0A2540),
        scaffoldBackgroundColor: const Color(0xFFF4F5F7),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0A2540),
            foregroundColor: Colors.white,
            elevation: 0),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0A2540), width: 2)),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) return const MainNavigation();
        return const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController =
      TextEditingController(text: 'employer@caterflow.com');
  final _passwordController = TextEditingController(text: 'Employer@123');
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Login failed: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.business_center,
                    size: 80, color: Color(0xFF0A2540)),
                const SizedBox(height: 20),
                const Text('Employer Portal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2540))),
                const Text('Manage your catering & event staff',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 40),
                TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 20),
                TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline))),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A2540),
                      disabledBackgroundColor:
                          const Color(0xFF0A2540).withOpacity(0.7),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3))
                      : const Text('LOGIN',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MainNavigation())),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: const Text('TEST LOGIN (BYPASS FIREBASE)',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const ActiveOrdersScreen(),
    const HistoryScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF0A2540),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Active Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class ActiveOrdersScreen extends StatelessWidget {
  const ActiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Active Orders',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0A2540)));
          var activeJobs = snapshot.data!.docs
              .where((doc) =>
                  (doc.data() as Map<String, dynamic>)['status'] == 'Active')
              .toList();

          if (activeJobs.isEmpty)
            return const Center(
                child: Text('No active orders.\nClick + to publish one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16)));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: activeJobs.length,
            itemBuilder: (context, index) {
              var job = activeJobs[index].data() as Map<String, dynamic>;
              String jobId = activeJobs[index].id;

              int? startMs = job['startTimestamp'];
              bool canCancel = true;
              if (startMs != null) {
                DateTime startTime =
                    DateTime.fromMillisecondsSinceEpoch(startMs);
                if (startTime.difference(DateTime.now()).inHours < 6) {
                  canCancel = false;
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                  backgroundColor:
                                      const Color(0xFF0A2540).withOpacity(0.1),
                                  child: Icon(
                                      job['title'] == 'Catering'
                                          ? Icons.restaurant
                                          : Icons.event,
                                      color: const Color(0xFF0A2540))),
                              const SizedBox(width: 10),
                              Text('${job['title']} (${job['duration']})',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ],
                          ),
                          Text(job['price'],
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                      const Divider(height: 20),
                      Text('📅 Date: ${job['date']} | ⏰ Time: ${job['time']}'),
                      Text('📍 Location: ${job['location']}'),
                      Text('👥 Staff Needed: ${job['peopleNeeded']}'),
                      Text('💰 Pay Per Person: ₹${job['perPersonPay']}'),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) =>
                                    DynamicQRDialog(jobId: jobId));
                          },
                          icon: const Icon(Icons.qr_code, color: Colors.white),
                          label: const Text('Show Check-In QR',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A2540),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ManageAttendanceScreen(jobId: jobId)));
                          },
                          icon: const Icon(Icons.checklist,
                              color: Color(0xFF0A2540)),
                          label: const Text('Manual Attendance',
                              style: TextStyle(
                                  color: Color(0xFF0A2540),
                                  fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF0A2540)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (!canCancel) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Cannot cancel! The event starts in less than 6 hours.'),
                                      backgroundColor: Colors.red));
                              return;
                            }
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Cancel Order?'),
                                content: const Text(
                                    'Are you sure you want to cancel this order? Workers will no longer be able to apply or check in.'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('No, Keep It')),
                                  TextButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('jobs')
                                          .doc(jobId)
                                          .update({'status': 'Cancelled'});
                                      if (context.mounted)
                                        Navigator.pop(context);
                                    },
                                    child: const Text('Yes, Cancel',
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(Icons.cancel,
                              color: canCancel ? Colors.red : Colors.grey),
                          label: Text(
                              canCancel
                                  ? 'Cancel Order'
                                  : 'Too late to cancel (Under 6 hrs)',
                              style: TextStyle(
                                  color: canCancel ? Colors.red : Colors.grey,
                                  fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: canCancel ? Colors.red : Colors.grey),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0A2540),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddJobScreen())),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Publish Order',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class ManageAttendanceScreen extends StatelessWidget {
  final String jobId;
  const ManageAttendanceScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Attendance')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .doc(jobId)
            .collection('attendance')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0A2540)));

          var workers = snapshot.data!.docs;
          if (workers.isEmpty)
            return const Center(
                child: Text('No workers have applied for this job yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 16)));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: workers.length,
            itemBuilder: (context, index) {
              var worker = workers[index].data() as Map<String, dynamic>;
              String workerId = workers[index].id;
              bool isPresent = worker['status'] == 'Present';

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: isPresent
                          ? Colors.green.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      child: Icon(Icons.person,
                          color: isPresent ? Colors.green : Colors.grey)),
                  title: Text(worker['workerName'] ?? 'Unknown Worker',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text(isPresent ? 'Checked In' : 'Applied (Waiting)'),
                  trailing: isPresent
                      ? const Icon(Icons.check_circle,
                          color: Colors.green, size: 30)
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A2540)),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('jobs')
                                .doc(jobId)
                                .collection('attendance')
                                .doc(workerId)
                                .update({
                              'status': 'Present',
                              'checkInTime': FieldValue.serverTimestamp()
                            });
                          },
                          child: const Text('Mark Present',
                              style: TextStyle(color: Colors.white)),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DynamicQRDialog extends StatefulWidget {
  final String jobId;
  const DynamicQRDialog({super.key, required this.jobId});
  @override
  State<DynamicQRDialog> createState() => _DynamicQRDialogState();
}

class _DynamicQRDialogState extends State<DynamicQRDialog> {
  late Timer _timer;
  String _qrData = '';

  @override
  void initState() {
    super.initState();
    _generateQR();
    _timer =
        Timer.periodic(const Duration(seconds: 5), (timer) => _generateQR());
  }

  void _generateQR() => setState(() =>
      _qrData = '${widget.jobId}|${DateTime.now().millisecondsSinceEpoch}');

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Worker Check-In',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              'This QR code refreshes every 5 seconds to prevent fake WhatsApp check-ins.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                  data: _qrData, version: QrVersions.auto, size: 200.0)),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Close'))
      ],
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Order History',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('jobs')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0A2540)));
          var historyJobs = snapshot.data!.docs.where((doc) {
            var status = (doc.data() as Map<String, dynamic>)['status'];
            return status == 'Completed' || status == 'Cancelled';
          }).toList();

          if (historyJobs.isEmpty)
            return const Center(
                child: Text('No history yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 16)));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: historyJobs.length,
            itemBuilder: (context, index) {
              var job = historyJobs[index].data() as Map<String, dynamic>;
              bool isCancelled = job['status'] == 'Cancelled';

              return Card(
                color: Colors.grey[200],
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: Icon(isCancelled ? Icons.cancel : Icons.check_circle,
                      color: isCancelled ? Colors.red : Colors.grey),
                  title: Text('${job['title']} - ${job['date']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  subtitle: Text(
                      'Total Paid: ${job['price']} | Staff: ${job['peopleNeeded']}'),
                  trailing: Text(job['status'],
                      style: TextStyle(
                          color: isCancelled ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Profile',
              style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            color: Colors.white,
            child: Column(
              children: [
                const CircleAvatar(
                    radius: 50,
                    backgroundColor: Color(0xFF0A2540),
                    child: Icon(Icons.business, size: 50, color: Colors.white)),
                const SizedBox(height: 15),
                Text(user?.email ?? 'Employer Account',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const Text('Event Manager',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log Out',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted)
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});
  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _mapLinkCtrl = TextEditingController(); // Google Maps Link
  final _perPersonPayCtrl = TextEditingController(text: '500');
  final _peopleCtrl = TextEditingController(text: '1');
  final _descCtrl = TextEditingController();

  String _selectedCategory = 'Catering';
  String _selectedDuration = 'Half Time';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isLoading = false;

  double get _calculatedTotal {
    double perPerson = double.tryParse(_perPersonPayCtrl.text) ?? 0;
    int staff = int.tryParse(_peopleCtrl.text) ?? 0;
    return perPerson * staff;
  }

  void _updatePriceBasedOnDuration(String duration) {
    setState(() {
      _selectedDuration = duration;
      if (duration == 'Half Time') _perPersonPayCtrl.text = '500';
      if (duration == 'Full Time') _perPersonPayCtrl.text = '1000';
    });
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null)
      setState(() {
        if (isStart)
          _startTime = picked;
        else
          _endTime = picked;
      });
  }

  void _uploadJob() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select Start and End time'),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    String autoImageUrl = _selectedCategory == 'Catering'
        ? 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=800&q=80'
        : 'https://images.unsplash.com/photo-1511556532299-8f662fc26c06?auto=format&fit=crop&w=800&q=80';
    String timeString =
        '${_startTime!.format(context)} - ${_endTime!.format(context)}';

    DateTime startDateTime = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _startTime!.hour, _startTime!.minute);

    try {
      // ADDED A 10 SECOND TIMEOUT SO IT NEVER HANGS FOREVER
      await FirebaseFirestore.instance.collection('jobs').add({
        'title': _selectedCategory,
        'duration': _selectedDuration,
        'location': _locationCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'shift': 'All',
        'time': timeString,
        'startTimestamp': startDateTime.millisecondsSinceEpoch,
        'perPersonPay': double.parse(_perPersonPayCtrl.text.trim()),
        'price': '₹${_calculatedTotal.toStringAsFixed(0)}',
        'priceValue': _calculatedTotal,
        'peopleNeeded': int.parse(_peopleCtrl.text.trim()),
        'description': _descCtrl.text.trim(),
        'image': autoImageUrl,
        'distance': '3.5 km',
        'distanceValue': 3.5,
        'mapLink': _mapLinkCtrl.text.trim(), // SAVES THE GOOGLE MAPS LINK
        'status': 'Active',
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Order Published Successfully!'),
            backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Network Timeout: Please check your internet connection.'),
            backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publish New Order')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration:
                              const InputDecoration(labelText: 'Job Type'),
                          items: ['Catering', 'Event']
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v!))),
                  const SizedBox(width: 15),
                  Expanded(
                      child: DropdownButtonFormField<String>(
                          value: _selectedDuration,
                          decoration:
                              const InputDecoration(labelText: 'Timing'),
                          items: ['Half Time', 'Full Time']
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => _updatePriceBasedOnDuration(v!))),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                          controller: _perPersonPayCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Pay Per Person (₹)',
                              prefixIcon: Icon(Icons.currency_rupee, size: 18)),
                          onChanged: (v) => setState(() {}),
                          validator: (v) => v!.isEmpty ? 'Required' : null)),
                  const SizedBox(width: 15),
                  Expanded(
                      child: TextFormField(
                          controller: _peopleCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Staff Needed',
                              prefixIcon: Icon(Icons.people_outline)),
                          onChanged: (v) => setState(() {}),
                          validator: (v) => v!.isEmpty ? 'Required' : null)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: const Color(0xFF0A2540).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Estimated Payout:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('₹${_calculatedTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 20))
                    ]),
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030));
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date'),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                          const Icon(Icons.calendar_today,
                              size: 18, color: Colors.grey)
                        ])),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                      child: InkWell(
                          onTap: () => _selectTime(context, true),
                          child: InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: 'Start Time'),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_startTime?.format(context) ??
                                        'Select Time'),
                                    const Icon(Icons.access_time,
                                        size: 18, color: Colors.grey)
                                  ])))),
                  const SizedBox(width: 15),
                  Expanded(
                      child: InkWell(
                          onTap: () => _selectTime(context, false),
                          child: InputDecorator(
                              decoration:
                                  const InputDecoration(labelText: 'End Time'),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_endTime?.format(context) ??
                                        'Select Time'),
                                    const Icon(Icons.access_time,
                                        size: 18, color: Colors.grey)
                                  ])))),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Area / City (e.g. Bandra)',
                      prefixIcon: Icon(Icons.location_city)),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 15),
              TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Full Venue Address',
                      prefixIcon: Icon(Icons.location_on_outlined)),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 15),

              // GOOGLE MAPS LINK TEXT FIELD
              TextFormField(
                  controller: _mapLinkCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Google Maps Link (Paste URL)',
                      hintText: 'https://maps.app.goo.gl/...',
                      prefixIcon: Icon(Icons.map)),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 15),

              TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Job Description / Instructions',
                      alignLabelWithHint: true),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 30),

              // FIXED LOADING BUTTON
              SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A2540),
                          disabledBackgroundColor: const Color(0xFF0A2540)
                              .withOpacity(0.7), // Keeps it dark when disabled
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: _isLoading ? null : _uploadJob,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3))
                          : const Text('PUBLISH ORDER',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)))),
            ],
          ),
        ),
      ),
    );
  }
}
