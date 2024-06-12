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
import 'package:szabsync/model/month.model.dart';
import 'package:szabsync/model/prospect.model.dart';
import 'package:szabsync/model/notifications.model.dart';
import 'package:szabsync/widgets/page_header.dart';

class AddProspect extends StatefulWidget {
  const AddProspect({super.key});

  @override
  State<AddProspect> createState() => _AddProspectState();
}

class _AddProspectState extends State<AddProspect> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _ticketPriceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _monthController = TextEditingController();
  MonthModel? eventMonth;
  List<MonthModel> months = [
    MonthModel(
      number: "1",
      name: "January",
      events: [],
    ),
    MonthModel(
      number: "2",
      name: "February",
      events: [],
    ),
    MonthModel(
      number: "3",
      name: "March",
      events: [],
    ),
    MonthModel(
      number: "4",
      name: "April",
      events: [],
    ),
    MonthModel(
      number: "5",
      name: "May",
      events: [],
    ),
    MonthModel(
      number: "6",
      name: "June",
      events: [],
    ),
    MonthModel(
      number: "7",
      name: "July",
      events: [],
    ),
    MonthModel(
      number: "8",
      name: "August",
      events: [],
    ),
    MonthModel(
      number: "9",
      name: "September",
      events: [],
    ),
    MonthModel(
      number: "10",
      name: "October",
      events: [],
    ),
    MonthModel(
      number: "11",
      name: "November",
      events: [],
    ),
    MonthModel(
      number: "12",
      name: "December",
      events: [],
    ),
  ];
  EventCategory? _selectedCategory;
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

  showMonths() {
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
                "Select Month",
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
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        setState(() {
                          _monthController.text = months[index].name;
                          eventMonth = months[index];
                        });
                        Navigator.pop(context);
                      },
                      title: Text(
                        months[index].name,
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

  addProspect() async {
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

    if (_ticketPriceController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select a price for prospect ticket.",
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

    if (eventMonth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select a month for the prospect to occur in.",
          ),
        ),
      );
      return;
    }
    if (eventBanner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please select a banner for the prospect",
          ),
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    Fluttertoast.showToast(
      msg: "Prospect creation initiated. This may take a while...",
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
      SzabistProspect _prospectiveEvent = SzabistProspect(
        title: _titleController.text,
        description: _descriptionController.text,
        categoryText: _categoryController.text,
        categoryCode: _selectedCategory!.id,
        bannerURL: _bannerURL,
        status: "active",
        id: eventID,
        titleArray: titleArray,
        eventMonth: eventMonth!.number,
        ticketPrice: _ticketPriceController.text,
      );
      FirebaseFirestore.instance
          .collection("prospects")
          .doc(eventID)
          .set(_prospectiveEvent.toJson())
          .then((value) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Prospect added successfully.",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: "Add Prospect",
              subtitle: "Launch a new prospect here.",
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
                          labelText: "Prospect Title",
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
                          labelText: "Prospect Description",
                          hintText:
                              "Enter a description for the prospect, include all relevant information to attract more students. Use emojis for beautification where needed.",
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
                          labelText: "Prospect Expected Ticket Price",
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
                          labelText: "Prospect Category",
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
                          showMonths();
                        },
                        readOnly: true,
                        controller: _monthController,
                        decoration: InputDecoration(
                          labelText: "Prospect Month",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Prospect Banner",
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
                            addProspect();
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
                                  "Create Prospect",
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
