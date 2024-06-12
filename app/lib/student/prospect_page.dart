import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f_datetimerangepicker/f_datetimerangepicker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/login.dart';
import 'package:szabsync/model/attachments.model.dart';
import 'package:szabsync/model/category.model.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/model/post.model.dart';
import 'package:szabsync/model/prospect.model.dart';
import 'package:szabsync/model/student.model.dart';
import 'package:szabsync/model/ticket.model.dart';
import 'package:szabsync/student/buy_ticket.dart';
import 'package:szabsync/student/event_page.dart';
import 'package:szabsync/student/my_tickets.dart';
import 'package:szabsync/widgets/custom_icon.dart';
import 'package:szabsync/widgets/post_card.dart';

class ProspectPage extends StatefulWidget {
  String id;

  ProspectPage({
    required this.id,
  });

  @override
  State<ProspectPage> createState() => _ProspectPageState();
}

class _ProspectPageState extends State<ProspectPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _venueController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  EventCategory? selectedCategory;
  List<String> _dates = [];
  bool isLoading = false;
  List<EventCategory> categories = [];
  String? eventBanner;
  SzabistProspect? eventData;
  TextEditingController _postContentController = TextEditingController();

  List<String> postImages = [];
  List<String> postVideos = [];

  bool isPosting = false;

  String email = "";
  Student? currentStudent;
  bool wantToPost = false;

  bool? alreadyHasTicket;
  Ticket? ticket;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  getEvent() {
    FirebaseFirestore.instance
        .collection("prospects")
        .doc(widget.id)
        .get()
        .then((value) {
      setState(() {
        eventData = SzabistProspect.fromJson(value.data()!);
      });
    });
  }

  getCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("email") ?? "";
    });
    if (email != "") {
      FirebaseFirestore.instance.collection("students").doc(email).get().then(
        (value) {
          setState(() {
            currentStudent = Student.fromJson(value.data()!);
          });
        },
      );
    }
    FirebaseFirestore.instance
        .collection("categories")
        .where("isActive", isEqualTo: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        categories.add(EventCategory.fromJson(element.data()));
      });
      getEvent();
    });
  }

  completeEvent() {
    FirebaseFirestore.instance.collection("events").doc(widget.id).update({
      "status": "completed",
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Event marked completed successfully. You will be able to find it in archives",
          ),
        ),
      );
      Navigator.pop(context);
    });
  }

  selectBannerImageType(BuildContext context, bool isFront) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          child: Wrap(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  getBannerImage(false);
                },
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.photo,
                    color: Colors.black,
                  ),
                  title: Text(
                    "Gallery",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  getBannerImage(true);
                },
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.camera,
                    color: Colors.black,
                  ),
                  title: Text(
                    "Camera",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  getBannerImage(bool isCamera) async {
    var image = await ImagePicker().pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 40);
    File imageF = File(image!.path);
    final bytes = imageF.readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;
    if (mb > 10) {
      Fluttertoast.showToast(
        msg: "Image is larger than 5 mb, please upload a smaller image",
      );
    } else {
      setState(() {
        eventBanner = image.path;
      });
    }
  }

  getPostMedia() async {
    List<XFile> mediaObjects =
        await ImagePicker().pickMultipleMedia(imageQuality: 80);
    mediaObjects.forEach((element) {
      String type = lookupMimeType(element.path)!;
      print(element.path + " : " + type);
      if (type.split("/").first == "image") {
        setState(() {
          postImages.add(element.path);
        });
      } else {
        setState(() {
          postVideos.add(element.path);
        });
      }
    });
  }

  showCategories() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "Select Category",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        setState(() {
                          _categoryController.text = categories[index].name +
                              " " +
                              categories[index].icon;
                          selectedCategory = categories[index];
                        });
                        Navigator.pop(context);
                      },
                      title: Text(
                        categories[index].name,
                      ),
                      leading: CircleAvatar(
                        child: Text(
                          categories[index].icon,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  saveEvent() async {
    if (_titleController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter a valid title.",
          ),
        ),
      );
      return;
    }
    if (_descriptionController.text.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter a valid description.",
          ),
        ),
      );
      return;
    }
    if (_venueController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter a valid venue.",
          ),
        ),
      );
      return;
    }
    if (_categoryController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select a valid category.",
          ),
        ),
      );
      return;
    }
    if (_dates.length == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select at least one date.",
          ),
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    if (eventBanner == null) {
      FirebaseFirestore.instance.collection("events").doc(widget.id).update({
        "title": _titleController.text,
        "titleArray": _titleController.text.split(""),
        "description": _descriptionController.text,
        "venue": _venueController.text,
        "categoryText": _categoryController.text,
        "categoryCode": selectedCategory!.id,
        "dates": _dates,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Event data saved successfully.",
            ),
          ),
        );
        Navigator.pop(context);
      });
    }

    Fluttertoast.showToast(
      msg: "Uploading data to server. This may take a while...",
    );
    File eventBannerFile = File(eventBanner!);
    await FirebaseStorage.instance
        .ref()
        .child("events/")
        .putFile(eventBannerFile)
        .then((p0) async {
      var _bannerURL = await p0.ref.getDownloadURL();

      FirebaseFirestore.instance.collection("events").doc(widget.id).update({
        "title": _titleController.text,
        "titleArray": _titleController.text.split(""),
        "description": _descriptionController.text,
        "venue": _venueController.text,
        "categoryText": _categoryController.text,
        "categoryCode": selectedCategory!.id,
        "dates": _dates,
        "bannerURL": _bannerURL,
      }).then((value) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Event data saved successfully.",
            ),
          ),
        );
        Navigator.pop(context);
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: $error",
            ),
          ),
        );
      });
    });
  }

  postIt(int postCount) async {
    setState(() {
      isPosting = true;
    });
    String postID = DateTime.now().millisecondsSinceEpoch.toString();
    List<String> imageURLs = [];
    List<String> videoURLs = [];
    List<Attachment> attachments = [];

    if (postImages.length > 0) {
      imageURLs = await Future.wait(
        postImages.map(
          (_image) => uploadFile(
            File(
              _image,
            ),
          ),
        ),
      );
    }
    if (postVideos.length > 0) {
      videoURLs = await Future.wait(
        postVideos.map(
          (videos) => uploadFile(
            File(
              videos,
            ),
          ),
        ),
      );
    }

    imageURLs.forEach((element) {
      attachments.add(
        Attachment(
          id: element.split("/").last + postID,
          postID: postID,
          contentURL: element,
          type: "image",
        ),
      );
    });
    videoURLs.forEach((element) {
      attachments.add(
        Attachment(
          id: element.split("/").last + postID,
          postID: postID,
          contentURL: element,
          type: "video",
        ),
      );
    });

    Post eventPost = Post(
      id: postID,
      eventID: widget.id,
      by: currentStudent!.name,
      byID: email,
      textContent: _postContentController.text,
      likesCount: [],
      attachments: attachments,
      createdAt: Timestamp.now(),
    );

    FirebaseFirestore.instance
        .collection("posts")
        .doc(postID)
        .set(
          eventPost.toJson(),
        )
        .then((value) {
      FirebaseFirestore.instance.collection("events").doc(widget.id).update(
        {
          "postCounts": postCount + 1,
        },
      ).then((value) {
        setState(() {
          isPosting = false;
          postImages = [];
          postVideos = [];
          _postContentController.text = "";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Post created successfully.",
            ),
          ),
        );
      });
    }).catchError((error) {
      setState(() {
        isPosting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't create post (Error: $error)",
          ),
        ),
      );
    });
  }

  Future<String> uploadFile(File _image) async {
    Reference storageReference =
        FirebaseStorage.instance.ref().child('posts/${_image.path}');
    UploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.whenComplete(() => null);

    return await storageReference.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        body: eventData == null
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("prospects")
                    .doc(widget.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    SzabistProspect event =
                        SzabistProspect.fromJson(snapshot.data!.data()!);
                    String acronym =
                        event.title.split(" ").map((e) => e[0]).join();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xff7c94b6),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0.2),
                                        BlendMode.dstATop),
                                    image: NetworkImage(
                                      event.bannerURL,
                                    ),
                                  ),
                                ),
                                height: 180,
                              ),
                            ),
                            Positioned(
                              top: 50,
                              left: 20,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 150,
                              right: 5,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Card(
                                  elevation: 4,
                                  color: AppColors.primary,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      eventData!.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 140,
                              left: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    100,
                                  ),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        100,
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.secondary,
                                            AppColors.secondaryDark,
                                          ],
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 25.0,
                                          vertical: 20,
                                        ),
                                        child: Text(
                                          acronym,
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 60,
                        ),
                        TabBar(
                          tabs: [
                            Tab(
                              text: "Details",
                            ),
                          ],
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  event.description,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    CustomIcon(
                                      icon: Icon(
                                        CupertinoIcons.calendar,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Expected Ticket Fee:",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black54),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Rs." + event.ticketPrice,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
      ),
    );
  }
}
