import 'package:flutter/material.dart';

import 'gallery.dart';
import 'samples.dart';

/// Root of the showcase: holds which sample palette and brightness the
/// gallery is wearing.
class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({
    super.key,
    this.initialSample = 0,
    this.initialMode = ThemeMode.light,
  });

  final int initialSample;
  final ThemeMode initialMode;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  late int _sample = widget.initialSample;
  late ThemeMode _mode = widget.initialMode;

  @override
  Widget build(BuildContext context) {
    final sample = samples[_sample];
    return MaterialApp(
      title: 'forge_ui showcase',
      debugShowCheckedModeBanner: false,
      theme: sample.theme(Brightness.light),
      darkTheme: sample.theme(Brightness.dark),
      themeMode: _mode,
      home: GalleryScreen(
        sample: sample,
        sampleIndex: _sample,
        onSampleChanged: (i) => setState(() => _sample = i),
        dark: _mode == ThemeMode.dark,
        onToggleBrightness: () => setState(
          () => _mode = _mode == ThemeMode.dark
              ? ThemeMode.light
              : ThemeMode.dark,
        ),
      ),
    );
  }
}
