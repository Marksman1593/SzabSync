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
import 'package:szabsync/model/student.model.dart';
import 'package:szabsync/model/ticket.model.dart';
import 'package:szabsync/student/buy_ticket.dart';
import 'package:szabsync/student/event_page.dart';
import 'package:szabsync/student/my_tickets.dart';
import 'package:szabsync/widgets/custom_icon.dart';
import 'package:szabsync/widgets/post_card.dart';

class EventPage extends StatefulWidget {
  String id;

  EventPage({
    required this.id,
  });

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _venueController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  EventCategory? selectedCategory;
  List<String> _dates = [];
  bool isLoading = false;
  List<EventCategory> categories = [];
  String? eventBanner;
  SzabistEvent? eventData;
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

  getIfHasTicket() {
    print(widget.id);
    print(email);
    FirebaseFirestore.instance
        .collection("tickets")
        .where("eventID", isEqualTo: widget.id)
        .where("studentID", isEqualTo: email)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.length == 0) {
        setState(() {
          alreadyHasTicket = false;
        });
      } else {
        setState(() {
          alreadyHasTicket = true;
        });
        value.docs.forEach((element) {
          setState(() {
            ticket = Ticket.fromJson(element.data());
          });
        });
      }
    });
  }

  getEvent() {
    FirebaseFirestore.instance
        .collection("events")
        .doc(widget.id)
        .get()
        .then((value) {
      setState(() {
        eventData = SzabistEvent.fromJson(value.data()!);
        _titleController.text = eventData!.title;
        _descriptionController.text = eventData!.description;
        _venueController.text = eventData!.venue;
        _categoryController.text = eventData!.categoryText;
        selectedCategory = categories
            .firstWhere((element) => element.id == eventData!.categoryCode);
        _dates = eventData!.dates;
      });
    });
  }

  getCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString("email") ?? "";
    });
    if (email != "") {
      getIfHasTicket();
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
      length: eventData == null
          ? 1
          : eventData!.status == "pending"
              ? 1
              : 2,
      child: Scaffold(
        bottomNavigationBar: eventData == null
            ? null
            : eventData!.status != "active"
                ? null
                : alreadyHasTicket == null
                    ? null
                    : alreadyHasTicket!
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QrCodeScreen(
                                      ticket!.eventName, ticket!.id),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondaryDark,
                                  ],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      "View Ticket",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BuyTicketScreen(
                                    eventInfo: eventData!,
                                    studentInfo: currentStudent!,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondaryDark,
                                  ],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      "Buy Ticket",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
        body: eventData == null
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
            : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("events")
                    .doc(widget.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    SzabistEvent event =
                        SzabistEvent.fromJson(snapshot.data!.data()!);
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
                            if (eventData!.status != "pending")
                              Tab(
                                text: "Community",
                              ),
                          ],
                        ),

                        // create widgets for each tab bar here
                        Expanded(
                          child: eventData!.status == "pending"
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: SingleChildScrollView(
                                    physics: BouncingScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              "When",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                        ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return Card(
                                              elevation: 4,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: ListTile(
                                                  title: Text(
                                                    "Day ${index + 1}",
                                                    style: TextStyle(
                                                      color: AppColors
                                                          .secondaryDark,
                                                    ),
                                                  ),
                                                  subtitle: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4.0),
                                                    child: Text(
                                                      event.dates[index],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .primaryDark,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          itemCount: event.dates.length,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            CustomIcon(
                                              icon: Icon(
                                                CupertinoIcons
                                                    .person_2_square_stack,
                                                size: 20,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              event.ticketsSold != 0
                                                  ? "${event.ticketsSold}+ people interested"
                                                  : "No registrations yet.",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            CustomIcon(
                                              icon: Icon(
                                                CupertinoIcons.location_circle,
                                                size: 20,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              event.venue,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : TabBarView(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 25.0),
                                      child: SingleChildScrollView(
                                        physics: BouncingScrollPhysics(),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                  "When",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54),
                                                ),
                                              ],
                                            ),
                                            ListView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                return Card(
                                                  elevation: 4,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: ListTile(
                                                      title: Text(
                                                        "Day ${index + 1}",
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .secondaryDark,
                                                        ),
                                                      ),
                                                      subtitle: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 4.0),
                                                        child: Text(
                                                          event.dates[index],
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: AppColors
                                                                .primaryDark,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              itemCount: event.dates.length,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                CustomIcon(
                                                  icon: Icon(
                                                    CupertinoIcons
                                                        .person_2_square_stack,
                                                    size: 20,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  event.ticketsSold != 0
                                                      ? "${event.ticketsSold}+ people interested"
                                                      : "No registrations yet.",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                CustomIcon(
                                                  icon: Icon(
                                                    CupertinoIcons
                                                        .location_circle,
                                                    size: 20,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  event.venue,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (email == "")
                                      Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (_) => LoginScreen(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Login to view community posts",
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (email != "")
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (isPosting)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    "Uploading media to server... This may take a while depending on the size of this post.",
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              ),
                                            if (eventData!.status !=
                                                    "completed" &&
                                                !isPosting &&
                                                wantToPost)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: TextFormField(
                                                      controller:
                                                          _postContentController,
                                                      onChanged: (value) {
                                                        setState(() {});
                                                      },
                                                      validator: (value) {
                                                        if (value!.length <
                                                            50) {
                                                          return "Please enter at least 50 characters.";
                                                        }
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            "What's on your mind?",
                                                        hintText:
                                                            "Share something related to ${eventData!.title}.",
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        suffixIcon:
                                                            GestureDetector(
                                                          onTap: () {
                                                            getPostMedia();
                                                          },
                                                          child: CustomIcon(
                                                            icon: Icon(
                                                              Icons.attach_file,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      maxLines: 2,
                                                      maxLength: 1000,
                                                    ),
                                                  ),
                                                  if ((postImages.length +
                                                          postVideos.length) >
                                                      0)
                                                    GestureDetector(
                                                      onTap: () {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          builder: (context) {
                                                            return ListView(
                                                              children: postImages
                                                                  .map((image) {
                                                                return ListTile(
                                                                  title: Text(image
                                                                      .split(
                                                                          "/")
                                                                      .last),
                                                                  trailing:
                                                                      IconButton(
                                                                    icon: Icon(Icons
                                                                        .delete),
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        postImages
                                                                            .remove(image);
                                                                      });
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                  ),
                                                                );
                                                              }).toList()
                                                                ..addAll(postVideos
                                                                    .map(
                                                                        (video) {
                                                                  return ListTile(
                                                                    title: Text(video
                                                                        .split(
                                                                            "/")
                                                                        .last),
                                                                    trailing:
                                                                        IconButton(
                                                                      icon: Icon(
                                                                          Icons
                                                                              .delete),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          postVideos
                                                                              .remove(video);
                                                                        });
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                    ),
                                                                  );
                                                                }).toList()),
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "${(postImages.length + postVideos.length).toString()} Attachment(s)",
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .secondary,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          CustomIcon(
                                                            icon: Icon(
                                                              Icons.edit,
                                                              size: 15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  if (((postImages.length +
                                                              postVideos
                                                                  .length) >
                                                          0) ||
                                                      _postContentController
                                                              .text !=
                                                          "")
                                                    GestureDetector(
                                                      onTap: () {
                                                        postIt(
                                                            event.postsCount);
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            10,
                                                          ),
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                        child: Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              vertical: 14.0,
                                                            ),
                                                            child: Text(
                                                              "Post",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            if (wantToPost)
                                              Divider(
                                                height: 0,
                                              ),
                                            if (!wantToPost)
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    wantToPost = true;
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      10,
                                                    ),
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        AppColors.primary,
                                                        AppColors.primaryDark,
                                                      ],
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          "+ Create Post",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            Expanded(
                                              child: StreamBuilder(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection("posts")
                                                    .where("eventID",
                                                        isEqualTo: widget.id)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    List<Post> posts =
                                                        snapshot.data!.docs
                                                            .map(
                                                              (e) =>
                                                                  Post.fromJson(
                                                                e.data(),
                                                              ),
                                                            )
                                                            .toList();
                                                    return ListView.builder(
                                                      itemCount: posts.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return PostCard(
                                                          isLiked: posts[index]
                                                              .likesCount
                                                              .contains(email),
                                                          isAdmin: false,
                                                          post: posts[index],
                                                          onLike: () async {
                                                            if (posts[index]
                                                                .likesCount
                                                                .contains(
                                                                    email)) {
                                                              List<String>
                                                                  newLikes =
                                                                  posts[index]
                                                                      .likesCount;
                                                              newLikes.remove(
                                                                  email);
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "posts")
                                                                  .doc(posts[
                                                                          index]
                                                                      .id)
                                                                  .update(
                                                                {
                                                                  "likesCount": newLikes
                                                                      .map(
                                                                          (v) =>
                                                                              v)
                                                                      .toList(),
                                                                },
                                                              ).then((value) {
                                                                Fluttertoast
                                                                    .showToast(
                                                                  msg:
                                                                      "Your Like was removed from ${posts[index].by}'s post.",
                                                                );
                                                              });
                                                            } else {
                                                              List<String>
                                                                  newLikes =
                                                                  posts[index]
                                                                      .likesCount;
                                                              newLikes
                                                                  .add(email);
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      "posts")
                                                                  .doc(posts[
                                                                          index]
                                                                      .id)
                                                                  .update(
                                                                {
                                                                  "likesCount": newLikes
                                                                      .map(
                                                                          (v) =>
                                                                              v)
                                                                      .toList(),
                                                                },
                                                              ).then((value) {
                                                                Fluttertoast
                                                                    .showToast(
                                                                  msg:
                                                                      "Your Like was added to ${posts[index].by}'s post.",
                                                                );
                                                              });
                                                            }
                                                          },
                                                        );
                                                      },
                                                    );
                                                  }
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                        ),
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
