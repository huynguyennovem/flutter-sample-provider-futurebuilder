## Project description

This project demonstrates a solution for the combination between Provider and FutureBuilder

#### Context
- You start a Future task by an action (clicking a button for eg), not from initialization when starting a widget (inside initState() or didChangeDependencies())
- You want to update Provider's data when the Future's connection state is done (the Future work is finished)
- You want to follow the best practice: `The FutureBuilder's builder should only build widgets`
- You are having an error `setState() or markNeedsBuild() called during build.` as below very common case:

```dart
class DataProvider extends ChangeNotifier {

  String _data = '';
  String get data => _data;

  void updateData({required String newData}) {
    _data = newData;
    notifyListeners();
  }
}
```

```dart
FutureBuilder(
    future: _dataFuture,
    builder: (context, snapshot) {
        switch (snapshot.connectionState) {
            case ConnectionState.done:
              context.read<DataProvider>().updateData(newData: snapshot.data);
              return Text(
                snapshot.data,
                style: Theme.of(context).textTheme.headline5,
              );
        },
    },
),
```

#### Solution

-> Other logics should be separated to widget building to prevent side effects. 
-> Use `StreamSubscription` for subscribing the current `Future`

```dart
Future? _dataFuture;
StreamSubscription? _dataSubscription;

...

FutureBuilder(
    future: _dataFuture,
    builder: (context, snapshot) {
        switch (snapshot.connectionState) {
            // removed data updating logic from here
            // context.read<DataProvider>().updateData(newData: snapshot.data);
            case ConnectionState.done:
                return Text(
                    snapshot.data,
                    style: Theme.of(context).textTheme.headline5,
                );
        },
    },
),

...

floatingActionButton: FloatingActionButton(
    onPressed: () => _getData(),
    child: const Icon(Icons.adb),
),

...

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
```