import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/profileController.dart';
import 'package:knocky/models/userProfile.dart';
import 'package:knocky/models/userProfileDetails.dart';
import 'package:knocky/models/userProfileRatings.dart';
import 'package:knocky/widgets/KnockoutLoadingIndicator.dart';
import 'package:knocky/widgets/profile/body.dart';
import 'package:knocky/widgets/profile/header.dart';

class ProfileScreen extends StatefulWidget {
  final int id;

  ProfileScreen({@required this.id});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.put(ProfileController());
  UserProfile get profile => profileController.profile.value;
  List<UserProfileRating> get ratings => profileController.ratings.value;
  UserProfileDetails get details => profileController.details.value;

  @override
  void initState() {
    super.initState();
    profileController.initState(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: profileController.fetch,
            ),
          ],
        ),
        body: Container(
            child: KnockoutLoadingIndicator(
                show: profileController.isFetching.value,
                child: !profileController.isFetching.value
                    ? Column(children: [
                        ProfileHeader(
                            profile: profile,
                            ratings: ratings,
                            details: details),
                        ProfileBody(profile: profile)
                      ])
                    : Container()))));
  }
}
