import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/category.model.dart';
import 'package:szabsync/widgets/page_header.dart';

import 'package:flutter/foundation.dart' as foundation;

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  TextEditingController categoryController = TextEditingController();
  TextEditingController iconController = TextEditingController();

  bool isLoading = false;

  addCategory() {
    if (categoryController.text != "") {
      if (iconController.text != "") {
        setState(() {
          isLoading = true;
        });
        String catID =
            categoryController.text.toLowerCase().replaceAll(" ", "-");
        EventCategory category = EventCategory(
          id: catID,
          name: categoryController.text,
          icon: iconController.text,
          isActive: true,
        );
        FirebaseFirestore.instance
            .collection("categories")
            .doc(catID)
            .set(
              category.toJson(),
            )
            .then((value) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
            msg:
                "${categoryController.text} was added to categories successfully.",
          );
          Navigator.pop(context);
        }).catchError((error) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(
            msg: error.toString(),
          );
        });
      } else {
        Fluttertoast.showToast(
          msg: "Please select an icon for the category.",
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please select a title for the category.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: "Add Category",
              subtitle: "Add a new category for events.",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 25,
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: "Category Name",
                      hintText: "Enter category name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Select Category Icon",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                            children: [
                              Expanded(
                                child: EmojiPicker(
                                  onBackspacePressed: () {
                                    setState(() {
                                      iconController.text = "";
                                    });
                                    Navigator.pop(context);
                                  },
                                  onEmojiSelected: (category, emoji) {
                                    setState(() {
                                      iconController.text = emoji.emoji;
                                    });
                                    Navigator.pop(context);
                                  },
                                  config: Config(
                                    columns: 7,
                                    emojiSizeMax: 32 *
                                        (foundation.defaultTargetPlatform ==
                                                TargetPlatform.iOS
                                            ? 1.30
                                            : 1.0),
                                    verticalSpacing: 0,
                                    horizontalSpacing: 0,
                                    gridPadding: EdgeInsets.zero,
                                    initCategory: Category.RECENT,
                                    bgColor: Color(0xFFF2F2F2),
                                    indicatorColor: Colors.blue,
                                    iconColor: Colors.grey,
                                    iconColorSelected: Colors.blue,
                                    backspaceColor: Colors.blue,
                                    skinToneDialogBgColor: Colors.white,
                                    skinToneIndicatorColor: Colors.grey,
                                    enableSkinTones: true,
                                    recentTabBehavior: RecentTabBehavior.NONE,
                                    recentsLimit: 28,
                                    noRecents: const Text(
                                      'No Recents',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black26,
                                      ),
                                      textAlign: TextAlign.center,
                                    ), // Needs to be const Widget
                                    loadingIndicator: SizedBox.shrink(),
                                    tabIndicatorAnimDuration:
                                        kTabScrollDuration,
                                    categoryIcons: CategoryIcons(),
                                    buttonMode: ButtonMode.MATERIAL,
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: iconController.text != ""
                          ? Center(
                              child: Text(
                                iconController.text,
                                style: TextStyle(
                                  fontSize: 60,
                                ),
                              ),
                            )
                          : Icon(
                              CupertinoIcons.add,
                              size: 60,
                            ),
                    ),
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
                        addCategory();
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
                              "Add Category",
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
