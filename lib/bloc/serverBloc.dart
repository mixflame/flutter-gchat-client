import 'dart:async';
import '../event/event.dart';

class ServerBloc {
  var _serverController = StreamController<Event>();

  Function(Event) get sink => _serverController.sink.add;

  Stream<Event> get stream => _serverController.stream;

  ServerBloc() {
    //The Stream is listening to the Function.
    stream.listen((Event event) {
      if event i
      print("got event $event");
    });
  }

  dispose() {
    //Dispose Stream to avoid memory leak.
    _serverController?.close();
  }
}

//Global Variable for this Stream.
ServerBloc serverBloc = ServerBloc();
