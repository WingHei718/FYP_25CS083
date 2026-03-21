import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_try_on_app/models/settings_model.dart';
import 'package:virtual_try_on_app/models/product_model.dart';
import 'package:virtual_try_on_app/services/arcore_service.dart';
import 'package:virtual_try_on_app/services/permission_service.dart';
import 'package:virtual_try_on_app/widgets/custom_loading_dialog.dart';

class ARCoreScreen extends StatefulWidget {
  final ProductModel product;
  const ARCoreScreen({Key? key, required this.product}) : super(key: key);

  @override
  _ARCoreScreenState createState() => _ARCoreScreenState();
}

class _ARCoreScreenState extends State<ARCoreScreen> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  bool _platformViewCreated = false;
  String? sessionStatus;
  bool _openControlPanel = false;
  bool _planeDetected = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  StreamSubscription? _planeSubscription;

  static const cardContentPadding = 15.0;
  static const Widget spaceBetweenIconAndText = SizedBox(width: 12);
  static const Widget spaceBetweenRows = SizedBox(height: 10);
  static const Widget spaceBetweenCardHeaderAndContent = SizedBox(height: 10);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0,).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
        )
      );

    _planeSubscription = ARCoreService().onPlaneDetected.listen((_) {
      if (mounted) {
        setState(() {
          _planeDetected = true;
        });
      }
    });
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    setState(() {
      isLoading = true;
      sessionStatus = null;
    });
    final granted = await PermissionService.checkCameraPermission();
    if (!mounted) return;
    if (!granted) {
      setState(() {
        isLoading = false;
        sessionStatus = 'Camera permission is required for AR';
      });
      return;
    }
    await _startARSession();
  }

  void _toggleSettingsButton() {
    setState(() {
      _openControlPanel = !_openControlPanel;
      if (_openControlPanel) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _startARSession() async {
    setState(() {
      isLoading = true;
      sessionStatus = null;
    });
    final result = await ARCoreService().startARSession();
    if (mounted) {
      setState(() {
        isLoading = false;
        sessionStatus = result ?? 'Failed to start AR session';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR View'),
      ),
      body: isLoading 
          ? const CustomLoadingDialog()
          : sessionStatus != null && sessionStatus!.contains('AR Session Started')
              ? Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          AndroidView(
                            viewType: 'arcore_view',
                            layoutDirection: TextDirection.ltr,
                            onPlatformViewCreated: (int id) async {
                              _platformViewCreated = true;
                              final settingModel = Provider.of<SettingsModel>(context, listen: false);
                              await ARCoreService().setFinger(settingModel.targetFinger);
                              if (settingModel.handTrackingEnabled) {
                                await ARCoreService().enableHandTracking();
                              } else {
                                await ARCoreService().disableHandTracking();
                              }
                              if (settingModel.testingModeEnabled) {
                                await ARCoreService().enableTestingMode();
                              } else {
                                await ARCoreService().disableTestingMode();
                              }
                              await Future.delayed(const Duration(seconds: 3));
                              await ARCoreService().loadModel(widget.product.modelPath);
                            },
                          ),
                          AnimatedBuilder(
                            animation: _slideAnimation,
                            builder: (context, child) {
                              final panelMaxHeight = MediaQuery.of(context).size.height * 0.3;
                              return Positioned(
                                bottom: 16 - (panelMaxHeight * (1 - _slideAnimation.value)),
                                left: 16,
                                right: 16,
                                child: Transform.scale(
                                  scale: _slideAnimation.value,
                                  alignment: Alignment.bottomCenter,
                                  child: Opacity(
                                    opacity: _slideAnimation.value,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(maxHeight: panelMaxHeight),
                                      child: _buildControlPanelCard(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Settings button
                          if (!_openControlPanel)
                            _buildButton(
                              "menuButton",
                              const Icon(Icons.tune),
                              _toggleSettingsButton,
                              bottom: 16,
                              left: 16,
                            ),
                          // Reload model button
                          _buildButton(
                            "reloadButton",
                            const Icon(Icons.refresh),
                            () => ARCoreService().loadModel(widget.product.modelPath),
                            top: 16,
                            right: 16,
                          ),
                          if (!_planeDetected)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black45,
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.phone_android, color: Colors.white, size: 60),
                                      SizedBox(height: 16),
                                      Text(
                                        "Please move around for plane detection",
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                )
              : _buildErrorScreen(),
    );
  }

  @override
  void dispose() {
    _planeSubscription?.cancel();
    _animationController.dispose();
    // Clean ARCore resources
    ARCoreService().closeARSession();
    super.dispose();
  }

  void _handleHandTrackingChange(SettingsModel settingModel, bool value) {
    settingModel.setHandTrackingEnabled(value);
    if (value) {
      ARCoreService().enableHandTracking();
    } else {
      ARCoreService().disableHandTracking();
    }
  }

  void _handleTestingModeChange(SettingsModel settingModel, bool value) {
    settingModel.setTestingModeEnabled(value);
    if (value) {
      ARCoreService().enableTestingMode();
    } else {
      ARCoreService().disableTestingMode();
    }
  }

  Widget _buildButton(String heroTagName, Icon icon, function, {double? top, double? bottom, double? left, double? right,}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: FloatingActionButton.small(
        heroTag: heroTagName,
        onPressed: function,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: icon,
      ),
    );
  }

  Widget _buildControlPanelCard() {
    return Card(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(cardContentPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.control_camera,
                  color: Theme.of(context).colorScheme.primary,
                ),
                spaceBetweenIconAndText,
                Expanded(
                  child: Text(
                    'Control Panel',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _toggleSettingsButton,
                  icon: const Icon(
                    Icons.close,
                  ),
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            spaceBetweenCardHeaderAndContent,
            // Card content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<SettingsModel>(
                  builder: (context, settingModel, child) {
                    return Column(
                      children: [

                        Row(
                          children: [
                            Icon(
                              Icons.pan_tool_outlined,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            spaceBetweenIconAndText,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hand Tracking",
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    "Enable hand tracking for 3D model movement",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: settingModel.handTrackingEnabled,
                              onChanged: (bool value) {
                                _handleHandTrackingChange(settingModel, value);
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            spaceBetweenIconAndText,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Testing Mode",
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    "Enable testing mode",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: settingModel.testingModeEnabled,
                              onChanged: (bool value) {
                                _handleTestingModeChange(settingModel, value);
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.fingerprint,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            spaceBetweenIconAndText,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Target Finger",
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    "Select a finger to place the ring on",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DropdownButton<String>(
                              value: settingModel.targetFinger,
                              onChanged: (String? value) {
                                settingModel.setTargetFinger(value!);
                                ARCoreService().setFinger(value);
                              },
                              items: ['thumb', 'index', 'middle', 'ring', 'pinky'].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value[0].toUpperCase() + value.substring(1)),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Error: $sessionStatus',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _checkPermission,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: PermissionService.openSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Open Settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}