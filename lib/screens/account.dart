import 'package:flutter/material.dart';
import 'package:iit_app/model/appConstants.dart';
import 'package:iit_app/pages/clubs.dart';
import 'package:iit_app/model/built_post.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  var profileDetails;
  void initState() {
    fetchProfileDetails();
    super.initState();
  }

  Future<String> _asyncInputDialog(
    BuildContext context, {
    String queryName,
  }) async {
    String returnData = '';
    return showDialog<String>(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter $queryName'),
          content: new Row(
            children: <Widget>[
              Expanded(
                  child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                    labelText: queryName,
                    hintText: queryName == 'Phone No.'
                        ? '+91987654321'
                        : 'Sheldon Cooper'),
                onChanged: (value) {
                  returnData = value;
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(returnData);
              },
            ),
          ],
        );
      },
    );
  }

  Future showUnSuccessfulDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("UnSuccessful :("),
          content: new Text("Please try again"),
          actions: <Widget>[
            FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void fetchProfileDetails() async {
    await AppConstants.service
        .getProfile("token ${AppConstants.djangoToken}")
        .catchError((onError) {
      print("Error in fetching profile: ${onError.toString()}");
    }).then((value) {
      profileDetails = value.body;
      setState(() {});
    });
  }

  void updateProfileDetails({String name, String phoneNumber}) async {
    final updatedProfile = BuiltProfilePost((b) => b
      ..name = name
      ..phone_number = phoneNumber);
    await AppConstants.service
        .updateProfileByPatch(
            "token ${AppConstants.djangoToken}", updatedProfile)
        .then((value) {
      profileDetails = value.body;
      setState(() {});
    }).catchError((onError) {
      print("Error in updating profile: ${onError.toString()}");
      showUnSuccessfulDialog();
    });
  }

  Future<bool> onPop() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          brightness: Brightness.light,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        body: SingleChildScrollView(
          child: profileDetails == null
              ? Container(
                  height: MediaQuery.of(context).size.height / 4,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                              child: CircleAvatar(
                            backgroundImage: profileDetails.photo_url == null
                                ? AssetImage('assets/AMC.png')
                                : NetworkImage(profileDetails.photo_url),
                            radius: 30.0,
                            backgroundColor: Colors.transparent,
                          )),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width - 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width -
                                          200,
                                      child: Text(
                                        profileDetails.name,
                                        style: TextStyle(fontSize: 25),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () async {
                                        final name = await _asyncInputDialog(
                                            context,
                                            queryName: 'Name');
                                        print(name);
                                        updateProfileDetails(
                                            name: name,
                                            phoneNumber:
                                                profileDetails.phone_number);
                                      },
                                    )
                                  ],
                                ),
                                Text(
                                  profileDetails.department,
                                  style: TextStyle(
                                      fontSize: 19, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          IconTile(
                            backColor: Color(0xffFFECDD),
                            imgAssetPath: "assets/email.png",
                          ),
                          Text(
                            profileDetails.email,
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: <Widget>[
                          IconTile(
                            backColor: Color(0xffFFECDD),
                            imgAssetPath: "assets/call.png",
                          ),
                          Text(
                            profileDetails.phone_number == null
                                ? 'not provided'
                                : profileDetails.phone_number,
                            style: TextStyle(fontSize: 15),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () async {
                              final phoneNumber = await _asyncInputDialog(
                                  context,
                                  queryName: 'Phone No.');
                              print(phoneNumber);
                              updateProfileDetails(
                                  name: profileDetails.name,
                                  phoneNumber: phoneNumber);
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      profileDetails.subscriptions.length == 0
                          ? SizedBox(height: 5)
                          : Text(
                              "Subscriptions",
                              style: TextStyle(
                                  color: Color(0xff242424),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600),
                            ),
                      profileDetails == null
                          ? Container(
                              height: MediaQuery.of(context).size.height / 4,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Container(
                              color: Colors.white,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: profileDetails.subscriptions.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => ClubPage(
                                            clubId: profileDetails
                                                .subscriptions[index].id,
                                          ),
                                        ),
                                      );
                                    },
                                    leading: Container(
                                      height: 50.0,
                                      width: 50.0,
                                      decoration: BoxDecoration(
                                          //color: Colors.black,
                                          image: DecorationImage(
                                            image: profileDetails
                                                        .subscriptions[index]
                                                        .small_image_url ==
                                                    null
                                                ? AssetImage('assets/AMC.png')
                                                : NetworkImage(profileDetails
                                                    .subscriptions[index]
                                                    .small_image_url),
                                            fit: BoxFit.fill,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30.0)),
                                          border: Border.all(
                                              color: Colors.blue, width: 2.0)),
                                    ),
                                    title: Container(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.blue, width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        color: Colors.black,
                                        child: Container(
                                          height: 50.0,
                                          child: Center(
                                            child: Text(
                                                profileDetails
                                                    .subscriptions[index].name,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 25.0)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                      SizedBox(
                        height: 22,
                      ),
                      profileDetails.club_privileges.length == 0
                          ? SizedBox(height: 5)
                          : Text(
                              "Club Privileges",
                              style: TextStyle(
                                  color: Color(0xff242424),
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600),
                            ),
                      Container(
                        color: Colors.white,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: profileDetails.club_privileges.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ClubPage(
                                        clubId: profileDetails
                                            .club_privileges[index].id,
                                        editMode: true),
                                  ),
                                );
                              },
                              leading: Container(
                                height: 50.0,
                                width: 50.0,
                                decoration: BoxDecoration(
                                    //color: Colors.black,
                                    image: DecorationImage(
                                      image: profileDetails
                                                  .club_privileges[index]
                                                  .small_image_url ==
                                              null
                                          ? AssetImage('assets/AMC.png')
                                          : NetworkImage(profileDetails
                                              .club_privileges[index]
                                              .small_image_url),
                                      fit: BoxFit.fill,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30.0)),
                                    border: Border.all(
                                        color: Colors.blue, width: 2.0)),
                              ),
                              title: Container(
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Colors.blue, width: 2.0),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  color: Colors.black,
                                  child: Container(
                                    height: 50.0,
                                    child: Center(
                                      child: Text(
                                          profileDetails
                                              .club_privileges[index].name,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 25.0)),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class IconTile extends StatelessWidget {
  final String imgAssetPath;
  final Color backColor;

  IconTile({this.imgAssetPath, this.backColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 16),
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
            color: backColor, borderRadius: BorderRadius.circular(15)),
        child: Image.asset(
          imgAssetPath,
          width: 20,
        ),
      ),
    );
  }
}
