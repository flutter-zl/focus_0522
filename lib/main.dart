import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
  SemanticsBinding.instance.ensureSemantics(); // Required for full a11y tree on web

  // Enable debug semantics tree printing
  // debugPrintSemanticsTree = true;

  // Add listener for semantic action events (e.g., VoiceOver interactions)
  SemanticsBinding.instance.addSemanticsActionListener((SemanticsActionEvent event) {
    print('[DEBUG] SemanticsActionEvent received - Type: ${event.type}, NodeId: ${event.nodeId}, ViewId: ${event.viewId}');
  });

  // Track route changes to see if focus restoration should be triggered
  print('[DEBUG] App starting - focus restoration should happen on route changes');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Demo with Debug',
      home: const FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final FocusNode _buttonFocus = FocusNode();
  int _testCounter = 0;

  @override
  void initState() {
    super.initState();
    _buttonFocus.addListener(() {
      print('[DEBUG] Button focus changed: ${_buttonFocus.hasFocus}');
      if (_buttonFocus.hasFocus) {
        print('[DEBUG] "Go to Page Two" button gained focus');
      } else {
        print('[DEBUG] "Go to Page Two" button lost focus');
      }
    });
  }

  @override
  void dispose() {
    _buttonFocus.dispose();
    super.dispose();
  }

  void _triggerFocusEvent() {
    setState(() {
      _testCounter++;
    });

    // Find the semantics node for our button and send a focus event
    final renderObject = context.findRenderObject();
    if (renderObject != null) {
      print('[DEBUG] Manually triggering FocusSemanticEvent on ${renderObject.runtimeType}');
      print('[DEBUG] RenderObject semantics id: ${renderObject.debugSemantics?.id}');
      renderObject.sendSemanticsEvent(FocusSemanticEvent());
      print('[DEBUG] FocusSemanticEvent sent');
    } else {
      print('[DEBUG] No renderObject found to send focus event');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page One - Debug Focus')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),

            // Random Card Widget
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Featured Item',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text('This is a random featured card widget'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Random Container with decoration
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade300, Colors.purple.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Gradient Container',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            Center(
              child: Focus(
                focusNode: _buttonFocus,
                child: Semantics(
                  label: 'Go to Page Two - Navigation Button',
                  button: true,
                                      child: ElevatedButton(
                      onPressed: () {
                        print('[DEBUG] Navigate button pressed - should save focus state');
                        print('[DEBUG] Current focus node: ${_buttonFocus.hasFocus}');
                        print('[DEBUG] Current semantics id: ${context.findRenderObject()?.debugSemantics?.id}');

                        // Check if the framework will track this focus state
                        final RenderObject? renderObj = context.findRenderObject();
                        if (renderObj?.debugSemantics != null) {
                          print('[DEBUG] Button semantics node ID: ${renderObj!.debugSemantics!.id}');
                          print('[DEBUG] Button has focus flag: ${renderObj.debugSemantics!.hasFlag(SemanticsFlag.isFocused)}');
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SecondPage(),
                            settings: const RouteSettings(name: '/second'),
                          ),
                        ).then((_) {
                          print('[DEBUG] Returned from second page - framework should restore focus now');
                          print('[DEBUG] Button focus node has focus: ${_buttonFocus.hasFocus}');
                        });
                      },
                      child: const Text('Go to Page Two'),
                    ),
                ),
              ),
            ),

            // Random Row with icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.home, color: Colors.green, size: 32),
                    Text('Home'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.favorite, color: Colors.red, size: 32),
                    Text('Favorite'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.settings, color: Colors.grey, size: 32),
                    Text('Settings'),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),

            // Random TextField
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter something random',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
            ),

            SizedBox(height: 20),

            // Random ListTile
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text('R'),
              ),
              title: Text('Random List Item'),
              subtitle: Text('This is a subtitle for the list item'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),

            SizedBox(height: 20),

            // Random Chip widgets
            Wrap(
              spacing: 8.0,
              children: [
                Chip(
                  label: Text('Flutter'),
                  backgroundColor: Colors.blue.shade100,
                ),
                Chip(
                  label: Text('Dart'),
                  backgroundColor: Colors.green.shade100,
                ),
                Chip(
                  label: Text('Mobile'),
                  backgroundColor: Colors.orange.shade100,
                ),
                Chip(
                  label: Text('Web'),
                  backgroundColor: Colors.purple.shade100,
                ),
              ],
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  void initState() {
    super.initState();
    print('[DEBUG] SecondPage initialized - first page focus should be saved');

    // Check what happens when this route becomes active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('[DEBUG] SecondPage post-frame callback - checking route state');
      print('[DEBUG] ModalRoute.of(context)?.isCurrent: ${ModalRoute.of(context)?.isCurrent}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Two')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is Page Two',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('[DEBUG] Back button pressed - should restore focus to Page One button');
                print('[DEBUG] About to navigate back to Page One');
                print('[DEBUG] Current route: ${ModalRoute.of(context)?.settings.name}');
                Navigator.pop(context);
              },
              child: const Text('Back to Page One'),
            ),
          ],
        ),
      ),
    );
  }
}