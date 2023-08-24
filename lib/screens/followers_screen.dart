import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialize/utils/colors.dart';

class FollowersScreen extends StatefulWidget {
  final String userId;
  const FollowersScreen({Key? key, required this.userId}) : super(key: key);
  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text('Followers'),
        centerTitle: false,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(
              child: Text('No followers found.'),
            );
          }

          final followerIds =
              List<String>.from(snapshot.data!.data()!['followers']);

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: getUsersDetails(followerIds),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final followersData = snapshot.data!;

              if (followersData.isEmpty) {
                return Center(
                  child: Text('No followers found.'),
                );
              }

              return ListView.builder(
                itemCount: followersData.length,
                itemBuilder: (context, index) {
                  final follower = followersData[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(follower['photoUrl']),
                    ),
                    title: Text(follower['username']),
                    subtitle: Text(follower['bio']),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getUsersDetails(
      List<String> followersIds) async {
    List<Map<String, dynamic>> followersData = [];
    try {
      for (final followerId in followersIds) {
        var followerSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(followerId)
            .get();
        var followerData = followerSnap.data()!;
        followersData.add(followerData);
      }
    } catch (e) {
      print('Error fetching followers details: $e');
    }
    return followersData;
  }
}
