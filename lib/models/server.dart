import 'package:equatable/equatable.dart';

class Server extends Equatable {
  final String name;
  final String host;
  final int port;

  const Server({this.name, this.host, this.port});

  @override
  List<Object> get props => [name, host, port];

  @override
  String toString() => 'Server { name: $name }';
}
