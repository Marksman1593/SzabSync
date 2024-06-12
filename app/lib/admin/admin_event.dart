import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f_datetimerangepicker/f_datetimerangepicker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/attachments.model.dart';
import 'package:szabsync/model/category.model.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/model/notifications.model.dart';
import 'package:szabsync/model/post.model.dart';
import 'package:szabsync/student/event_page.dart';
import 'package:szabsync/widgets/custom_icon.dart';
import 'package:szabsync/widgets/post_card.dart';

class EventAdministration extends StatefulWidget {
  String id;

  EventAdministration({
    required this.id,
  });

  @override
  State<EventAdministration> createState() => _EventAdministrationState();
}

class _EventAdministrationState extends State<EventAdministration> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _ticketPriceController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    getCategories();
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
        _ticketPriceController.text = eventData!.ticketPrice.toString();
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
      email = prefs.getString("email")!;
    });
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

  approveEvent() {
    FirebaseFirestore.instance.collection("events").doc(widget.id).update({
      "status": "active",
    }).then((value) {
      http
          .post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAzOzbw6I:APA91bHTP4qsKjjRYQm_-LK7Y1kpPX6MT_v9nFFTpwQAq1GUQkYmRT9O2O6cBYbp1d-OLuYV3x1HFNLJuzvZkiPJEUtqlBqMm1_CVLe7yeDNGZ5Z5FOIzkuj5oRjy-OD0rlYNszV7rsY',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': {
              'body':
                  "${_titleController.text} has been posted in ${_categoryController.text} category.}",
              'title': "A New Event is here!",
            },
            'priority': 'high',
            'to': "/topics/new",
          },
        ),
      )
          .then((value) {
        String notifID = DateTime.now().millisecondsSinceEpoch.toString();
        Notif newNotif = Notif(
          id: notifID,
          title: "A New Event is here!",
          subtitle:
              "${_titleController.text} has been posted in ${_categoryController.text} category.",
          createdAt: Timestamp.now(),
          studentID: "",
          isRead: false,
          isGlobal: true,
        );
        FirebaseFirestore.instance
            .collection("notifications")
            .doc(notifID)
            .set(newNotif.toJson())
            .then((value) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Event approved successfully.",
              ),
            ),
          );
          Navigator.pop(context);
        });
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
    List<String> titleArray = [];
    for (int i = 1; i < _titleController.text.length + 1; i++) {
      titleArray.add(_titleController.text.toLowerCase().substring(0, i));
    }
    if (eventBanner == null) {
      FirebaseFirestore.instance.collection("events").doc(widget.id).update({
        "title": _titleController.text,
        "titleArray": titleArray,
        "description": _descriptionController.text,
        "venue": _venueController.text,
        "ticketPrice": int.parse(_ticketPriceController.text),
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
        "titleArray": titleArray,
        "description": _descriptionController.text,
        "venue": _venueController.text,
        "ticketPrice": int.parse(_ticketPriceController.text),
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
      by: "Admin",
      byID: "admin.szabsync@szabist.pk",
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
          "postsCount": postCount + 1,
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
      length: 2,
      child: Scaffold(
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
                              text: "Edit Details",
                            ),
                            Tab(
                              text: "View Posts",
                            ),
                          ],
                        ),

                        // create widgets for each tab bar here
                        Expanded(
                          child: TabBarView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25.0,
                                ),
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      TextFormField(
                                        controller: _titleController,
                                        validator: (value) {
                                          if (value!.length < 3) {
                                            return "Please enter a valid title.";
                                          }
                                        },
                                        maxLength: 25,
                                        decoration: InputDecoration(
                                          labelText: "Event Title",
                                          hintText:
                                              "This will be used for searching.",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      TextFormField(
                                        controller: _descriptionController,
                                        validator: (value) {
                                          if (value!.length < 50) {
                                            return "Please enter at least 50 characters.";
                                          }
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Event Description",
                                          hintText:
                                              "Enter a description for the event, include all relevant information to attract more students. Use emojis for beautification where needed.",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        maxLines: 4,
                                        maxLength: 1000,
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      TextFormField(
                                        controller: _venueController,
                                        validator: (value) {
                                          if (value!.length < 3) {
                                            return "Please enter a valid venue.";
                                          }
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Event Venue",
                                          hintText:
                                              "eg, SZABIST Islamabad, Room 101",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      TextFormField(
                                        controller: _ticketPriceController,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "Please enter a valid ticket price.";
                                          }
                                        },
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]')),
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        decoration: InputDecoration(
                                          labelText: "Event Ticket Price",
                                          hintText: "1500",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      // make category picker
                                      SizedBox(
                                        height: 15,
                                      ),
                                      TextFormField(
                                        onTap: () {
                                          showCategories();
                                        },
                                        readOnly: true,
                                        controller: _categoryController,
                                        decoration: InputDecoration(
                                          labelText: "Event Category",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "Event Banner",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        height: 150,
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15, right: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                eventBanner == null
                                                    ? Image.network(
                                                        eventData!.bannerURL,
                                                        height: 50,
                                                        width: 50,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Image.file(
                                                          File(
                                                            eventBanner!,
                                                          ),
                                                          height: 50,
                                                          width: 50,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                ElevatedButton(
                                                  child: Text('SELECT'),
                                                  onPressed: () {
                                                    selectBannerImageType(
                                                        context, true);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                                    textStyle: TextStyle(
                                                      fontSize: 20,
                                                      // fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          elevation: 5,
                                          margin: EdgeInsets.all(10),
                                          shape: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                          "* For optimal results, use a banner in landscape mode."),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Event Dates",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          Spacer(),
                                          GestureDetector(
                                            onTap: () {
                                              DateTimeRangePicker(
                                                startText: "From",
                                                endText: "To",
                                                doneText: "Yes",
                                                cancelText: "Cancel",
                                                interval: 5,
                                                initialStartTime:
                                                    DateTime.now().add(
                                                  Duration(
                                                    hours: 24,
                                                  ),
                                                ),
                                                mode: DateTimeRangePickerMode
                                                    .dateAndTime,
                                                minimumTime: DateTime.now(),
                                                maximumTime: DateTime.now()
                                                    .add(Duration(days: 25)),
                                                use24hFormat: false,
                                                onConfirm: (start, end) {
                                                  String formattedStart =
                                                      DateFormat.jm()
                                                              .format(start) +
                                                          ", " +
                                                          DateFormat.yMMMEd()
                                                              .format(start);
                                                  String formattedEnd =
                                                      DateFormat.jm()
                                                              .format(end) +
                                                          ", " +
                                                          DateFormat.yMMMEd()
                                                              .format(end);

                                                  setState(() {
                                                    _dates.add(
                                                      formattedStart +
                                                          "\nTo\n" +
                                                          formattedEnd,
                                                    );
                                                  });
                                                },
                                              ).showPicker(context);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryDark,
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      if (_dates.length == 0)
                                        Center(
                                          child: Text(
                                            "No dates added yet",
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      if (_dates.length > 0)
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
                                                      _dates[index],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: AppColors
                                                            .primaryDark,
                                                      ),
                                                    ),
                                                  ),
                                                  trailing: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _dates.removeAt(index);
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          itemCount: _dates.length,
                                        ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      if (isLoading)
                                        Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      if (!isLoading)
                                        GestureDetector(
                                          onTap: () {
                                            saveEvent();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10,
                                              ),
                                              color: AppColors.primary,
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: Text(
                                                  "Update Event",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      if (!isLoading &&
                                          event.status == "pending")
                                        GestureDetector(
                                          onTap: () {
                                            approveEvent();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10,
                                              ),
                                              border: Border.all(
                                                color: Colors.green,
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: Text(
                                                  "Approve Event",
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      if (!isLoading &&
                                          event.status != "completed")
                                        GestureDetector(
                                          onTap: () {
                                            completeEvent();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10,
                                              ),
                                              border: Border.all(
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: Text(
                                                  "Mark Event Completed",
                                                  style: TextStyle(
                                                    color: AppColors.primary,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            child: CircularProgressIndicator(
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
                                    if (eventData!.status != "completed" &&
                                        !isPosting)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              controller:
                                                  _postContentController,
                                              onChanged: (value) {
                                                setState(() {});
                                              },
                                              validator: (value) {
                                                if (value!.length < 50) {
                                                  return "Please enter at least 50 characters.";
                                                }
                                              },
                                              decoration: InputDecoration(
                                                labelText:
                                                    "What's on your mind?",
                                                hintText:
                                                    "Share something related to ${eventData!.title}.",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                suffixIcon: GestureDetector(
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
                                                              .split("/")
                                                              .last),
                                                          trailing: IconButton(
                                                            icon: Icon(
                                                                Icons.delete),
                                                            onPressed: () {
                                                              setState(() {
                                                                postImages
                                                                    .remove(
                                                                        image);
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                        );
                                                      }).toList()
                                                        ..addAll(postVideos
                                                            .map((video) {
                                                          return ListTile(
                                                            title: Text(video
                                                                .split("/")
                                                                .last),
                                                            trailing:
                                                                IconButton(
                                                              icon: Icon(
                                                                  Icons.delete),
                                                              onPressed: () {
                                                                setState(() {
                                                                  postVideos
                                                                      .remove(
                                                                          video);
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
                                                      color:
                                                          AppColors.secondary,
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
                                                      postVideos.length) >
                                                  0) ||
                                              _postContentController.text != "")
                                            GestureDetector(
                                              onTap: () {
                                                postIt(event.postsCount);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                  color: AppColors.primary,
                                                ),
                                                child: Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 14.0,
                                                    ),
                                                    child: Text(
                                                      "Post",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                    Divider(
                                      height: 0,
                                    ),
                                    Expanded(
                                      child: StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection("posts")
                                            .where("eventID",
                                                isEqualTo: widget.id)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            List<Post> posts =
                                                snapshot.data!.docs
                                                    .map(
                                                      (e) => Post.fromJson(
                                                        e.data(),
                                                      ),
                                                    )
                                                    .toList();
                                            return ListView.builder(
                                              itemCount: posts.length,
                                              itemBuilder: (context, index) {
                                                return PostCard(
                                                  isLiked: posts[index]
                                                      .likesCount
                                                      .contains(email),
                                                  isAdmin: true,
                                                  post: posts[index],
                                                  onLike: () async {
                                                    if (posts[index]
                                                        .likesCount
                                                        .contains(email)) {
                                                      List<String> newLikes =
                                                          posts[index]
                                                              .likesCount;
                                                      newLikes.remove(email);
                                                      FirebaseFirestore.instance
                                                          .collection("posts")
                                                          .doc(posts[index].id)
                                                          .update(
                                                        {
                                                          "likesCount": newLikes
                                                              .map((v) => v)
                                                              .toList(),
                                                        },
                                                      ).then((value) {
                                                        Fluttertoast.showToast(
                                                          msg:
                                                              "Your Like was removed from ${posts[index].by}'s post.",
                                                        );
                                                      });
                                                    } else {
                                                      List<String> newLikes =
                                                          posts[index]
                                                              .likesCount;
                                                      newLikes.add(email);
                                                      FirebaseFirestore.instance
                                                          .collection("posts")
                                                          .doc(posts[index].id)
                                                          .update(
                                                        {
                                                          "likesCount": newLikes
                                                              .map((v) => v)
                                                              .toList(),
                                                        },
                                                      ).then((value) {
                                                        Fluttertoast.showToast(
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
                                            child: CircularProgressIndicator(),
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
