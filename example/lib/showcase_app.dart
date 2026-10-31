import 'package:flutter/material.dart';
import 'package:forge_ui/forge_ui.dart';

import 'gallery.dart';
import 'samples.dart';

/// Root of the showcase: holds which sample palette, brightness and density
/// the gallery is wearing.
class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({
    super.key,
    this.initialSample = 0,
    this.initialMode = ThemeMode.light,
    this.initialDensity = ForgeDensity.touch,
  });

  final int initialSample;
  final ThemeMode initialMode;
  final ForgeDensity initialDensity;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  late int _sample = widget.initialSample;
  late ThemeMode _mode = widget.initialMode;
  late ForgeDensity _density = widget.initialDensity;

  @override
  Widget build(BuildContext context) {
    final sample = samples[_sample];
    return MaterialApp(
      title: 'forge_ui showcase',
      debugShowCheckedModeBanner: false,
      theme: sample.theme(Brightness.light, density: _density),
      darkTheme: sample.theme(Brightness.dark, density: _density),
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
        density: _density,
        onToggleDensity: () => setState(
          () => _density = _density == ForgeDensity.desktop
              ? ForgeDensity.touch
              : ForgeDensity.desktop,
        ),
      ),
    );
  }
}
