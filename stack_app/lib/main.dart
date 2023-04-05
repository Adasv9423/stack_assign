import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
void main() {
runApp(MyApp());
}

class MyApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return ChangeNotifierProvider(
create: (_) => PostProvider(),
child: MaterialApp(
title: 'Flutter Demo',
theme: ThemeData(
primarySwatch: Colors.blue,
),
home: HomeScreen(),
),
);
}
}


class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
    );
  }
}

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  Future<void> fetchPosts() async {
    _isLoading = true;
    try {
      final Uri url =
          Uri.https('jsonplaceholder.typicode.com', '/posts', {'_start': '0', '_limit': '10'});
      final response = await http.get(url);
      final responseData = json.decode(response.body) as List<dynamic>;
      final List<Post> loadedPosts = [];
      for (final post in responseData) {
        loadedPosts.add(Post.fromJson(post));
      }
      _posts = loadedPosts;
      _isLoading = false;
    } catch (error) {
      _hasError = true;
      _errorMessage = error.toString();
      _isLoading = false;
    }
    notifyListeners();
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post List'),
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.hasError) {
            return Center(
              child: Text(postProvider.errorMessage),
            );
          }
          if (postProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: postProvider.posts.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: Card(
                  shadowColor: Colors.amber,
                  child: ListTile(
                    
                    title: Text(postProvider.posts[index].title,style: TextStyle(fontSize: 20),),
                    subtitle: Text(postProvider.posts[index].body),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          post: postProvider.posts[index],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<PostProvider>(context, listen: false).fetchPosts();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Post post;

  const DetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Text(
                post.title,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              post.body,
            ),
            SizedBox(height: 10.0),
            Text(
              ' id of whom posted by- ${post.userId}',
              style: TextStyle(fontSize: 14.0),
            ),
          ],
        ),
      ),
    );
  }
}