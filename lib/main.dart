import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data_provider.dart';
import 'util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataProvider()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
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
  Future? _dataFuture;
  StreamSubscription? _dataSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const DataPresentation(),
            FutureBuilder(
              future: _dataFuture,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const SizedBox(
                      width: 48.0,
                      height: 48.0,
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.done:
                    return Text(
                      snapshot.data,
                      style: Theme.of(context).textTheme.headline5,
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _getData(),
        child: const Icon(Icons.adb),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _getData() {
    _dataSubscription?.cancel();
    setState(() {
      _dataFuture = Util.getText();
      _dataSubscription = _dataFuture?.asStream().listen((data) {
        if (!mounted) return;
        context.read<DataProvider>().updateData(newData: data);
      });
    });
  }
}

class DataPresentation extends StatefulWidget {
  const DataPresentation({Key? key}) : super(key: key);

  @override
  State<DataPresentation> createState() => _DataPresentationState();
}

class _DataPresentationState extends State<DataPresentation> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, value, child) => Text(
        value.data,
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }
}
