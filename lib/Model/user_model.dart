// ignore_for_file: prefer_typing_uninitialized_variables

class UserModel {
  var username;
  var id;
  var email;
  var image;
  var follower;
  var following;
  var date;

  UserModel({
    this.id,
    this.username,
    this.date,
    this.follower,this.following,
    this.email,
    this.image,
  });

  UserModel.fromMap(Map<String, dynamic> map) {
    id = map['id'] ?? '';
    date = map['date'].toDate();
    follower = map['follower'] ?? 0;
    following = map['following'] ?? 0;
    username = map['username'] ?? '';
    email = map['email'] ?? '';
    image = map['image'] ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'date': date,
      'follower': follower,
      'following': following,
      
      'image': image,
    };
  }
}
