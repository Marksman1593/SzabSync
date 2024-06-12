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
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/category.model.dart';
import 'package:szabsync/model/event.model.dart';
import 'package:szabsync/model/notifications.model.dart';
import 'package:szabsync/widgets/page_header.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _ticketPriceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _venueController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  EventCategory? _selectedCategory;
  List<String> _dates = [];
  bool isLoading = false;
  List<EventCategory> categories = [];
  String? eventBanner;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  getCategories() {
    FirebaseFirestore.instance
        .collection("categories")
        .where("isActive", isEqualTo: true)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        categories.add(EventCategory.fromJson(element.data()));
      });
    });
  }

  selectImageType(BuildContext context, bool isFront) {
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
                  getImage(false);
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
                  getImage(true);
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

  getImage(bool isCamera) async {
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

  showCategories() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Column(
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
                          _selectedCategory = categories[index];
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

  addEvent() async {
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
    if (_ticketPriceController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select a price for event ticket.",
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
    if (eventBanner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select a banner for the event",
          ),
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    Fluttertoast.showToast(
      msg: "Event creation initiated. This may take a while...",
    );
    File eventBannerFile = File(eventBanner!);
    await FirebaseStorage.instance
        .ref()
        .child("events/")
        .putFile(eventBannerFile)
        .then((p0) async {
      var _bannerURL = await p0.ref.getDownloadURL();
      String eventID = DateTime.now().millisecondsSinceEpoch.toString();
      List<String> titleArray = [];
      for (int i = 1; i < _titleController.text.length + 1; i++) {
        titleArray.add(_titleController.text.toLowerCase().substring(0, i));
      }
      SzabistEvent _prospectiveEvent = SzabistEvent(
        title: _titleController.text,
        description: _descriptionController.text,
        venue: _venueController.text,
        categoryText: _categoryController.text,
        categoryCode: _selectedCategory!.id,
        dates: _dates,
        bannerURL: _bannerURL,
        status: "active",
        ticketPrice: int.parse(_ticketPriceController.text),
        ticketsSold: 0,
        id: eventID,
        postsCount: 0,
        titleArray: titleArray,
        createdAt: Timestamp.now(),
      );
      FirebaseFirestore.instance
          .collection("events")
          .doc(eventID)
          .set(_prospectiveEvent.toJson())
          .then((value) {
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
                  "Event added successfully.",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: "Add Event",
              subtitle: "Launch a new event here.",
            ),
            SizedBox(
              height: 25,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          hintText: "This will be used for searching.",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
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
                            borderRadius: BorderRadius.circular(10),
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
                          hintText: "eg, SZABIST Islamabad, Room 101",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
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
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          labelText: "Event Ticket Price",
                          hintText: "1500",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
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
                            borderRadius: BorderRadius.circular(10),
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
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                eventBanner == null
                                    ? Icon(
                                        Icons.image,
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
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
                                    selectImageType(context, true);
                                  },
                                  style: ElevatedButton.styleFrom(
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
                            borderRadius: BorderRadius.circular(10),
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
                                initialStartTime: DateTime.now().add(
                                  Duration(
                                    hours: 24,
                                  ),
                                ),
                                mode: DateTimeRangePickerMode.dateAndTime,
                                minimumTime: DateTime.now(),
                                maximumTime:
                                    DateTime.now().add(Duration(days: 25)),
                                use24hFormat: false,
                                onConfirm: (start, end) {
                                  String formattedStart =
                                      DateFormat.jm().format(start) +
                                          ", " +
                                          DateFormat.yMMMEd().format(start);
                                  String formattedEnd =
                                      DateFormat.jm().format(end) +
                                          ", " +
                                          DateFormat.yMMMEd().format(end);

                                  setState(() {
                                    _dates.add(
                                      formattedStart + "\nTo\n" + formattedEnd,
                                    );
                                  });
                                },
                              ).showPicker(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryDark,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
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
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text(
                                    "Day ${index + 1}",
                                    style: TextStyle(
                                      color: AppColors.secondaryDark,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      _dates[index],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
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
                            addEvent();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                              color: AppColors.primary,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  "Create Event",
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
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
