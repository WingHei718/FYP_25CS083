import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:virtual_try_on_app/models/settings_model.dart';

// For loading necessary data if backend exists
// Showing Starting Screen for this project only

class AppInit extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppInitState();
}

class _AppInitState extends State<AppInit> {
  @override
  void initState() {
    super.initState();
    // Initialize Settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SettingsModel>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(
                child: Image(
                  image: AssetImage('assets/images/startSC_bg.jpg'),
                  fit : BoxFit.cover,
                ),
              ),
              Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CS4514 Project',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mobile Application of AR Dressing Room for Trying Accessories',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Welcome to use the virtual try-on application. In this application, you can try on 3 different realistic rings in the virtual AR world. Let\'s enjoy it by pressing the start button below >.< !',
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context, '/main', (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text('Start'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}
