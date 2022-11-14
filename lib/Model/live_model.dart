// ignore_for_file: prefer_typing_uninitialized_variables


class LiveModel {
  var title;
  var image;
  var uid;
  var username;
  var viewer;
  var channelId;
  var start;

  LiveModel(
      {this.title,
      this.image,
      this.uid,
      this.username,
      this.viewer,
      this.channelId,
      this.start});

  LiveModel.fromJson(Map<String, dynamic> json) {
    title = json['title'] ?? '';
    image = json['image'] ?? '';
    uid = json['uid'] ?? '';
    username = json['username'] ?? '';
    viewer = json['viewer'] ?? 0;
    channelId = json['channelId'] ?? '';
    start = json['start'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['image'] = image;
    data['uid'] = uid;
    data['username'] = username;
    data['viewer'] = viewer;
    data['channelId'] = channelId;
    data['start'] = start;
    return data;
  }
}
