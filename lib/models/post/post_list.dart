/**
 * locnx
 * This is just an example how to create an ModelList that get a list of data from a json map list returned by API (DocClient or RestClient)
 * Note: must create the respected Model class first i.e Abc
 */

import 'package:flutterapp/models/post/post.dart';

class PostList {
  final List<Post>? posts;

  PostList({
    this.posts,
  });

  factory PostList.fromJson(List<dynamic> json) {
    List<Post> posts = <Post>[];
    posts = json.map((post) => Post.fromMap(post)).toList();

    return PostList(
      posts: posts,
    );
  }
}
