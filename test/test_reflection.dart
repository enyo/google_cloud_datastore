library reflection.test;

import 'dart:typed_data';

import 'package:unittest/unittest.dart';

import '../lib/datastore.dart';
import 'mock_connection.dart';
import 'test_mirrorfree.dart' as mirrorfree;


@Kind()
class User extends Entity {
  User(Datastore datastore, Key key): super(datastore, key);

  @Property(indexed: true)
  String get name => getProperty("name");

  @Property()
  Uint8List get password => getProperty("password");

  @Property(name: "user_details")
  Key get details => getProperty("user_details");

  @Property(name: "date_joined")
  DateTime get dateJoined => getProperty("date_joined");

}

@Kind()
class UserDetails extends Entity {
  UserDetails(Datastore datastore, Key key):super(datastore, key);

  @Property()
  int get age => getProperty("age");
  @Property()
  bool get isAdmin => getProperty("isAdmin");
  @Property()
  List<Key> get friends => getProperty("friends");
}

void defineTests(MockConnection connection) {
  var datastore = new Datastore(connection);
  test("reflected user kind should be identical to mirrorfree kind", () {
    var userKind = datastore.kindByName("User");
    expect(userKind, mirrorfree.userKind);
    expect(userKind.properties, mirrorfree.userKind.properties);
  });
  test("reflected user details kind should be identical to mirrorfree kind", () {
    var userDetailsKind = datastore.kindByName("UserDetails");
    expect(userDetailsKind, mirrorfree.userDetailsKind);
    expect(userDetailsKind.properties, mirrorfree.userDetailsKind.properties);
  });

}