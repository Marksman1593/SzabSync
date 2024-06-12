import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:szabsync/admin/add_category.dart';
import 'package:szabsync/admin/edit_category.dart';
import 'package:szabsync/constants/app_colors.dart';
import 'package:szabsync/model/category.model.dart';
import 'package:szabsync/widgets/page_header.dart';

class ViewCategories extends StatefulWidget {
  const ViewCategories({super.key});

  @override
  State<ViewCategories> createState() => _ViewCategoriesState();
}

class _ViewCategoriesState extends State<ViewCategories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => AddCategory(),
            ),
          );
        },
        label: Text(
          "Add Category",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: AppColors.primary,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: "View Categories",
              subtitle: "View all event categories here.",
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                ),
                child: Column(
                  children: [
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("categories")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<EventCategory> categories = [];
                          snapshot.data!.docs.forEach((element) {
                            categories.add(
                              EventCategory.fromJson(
                                element.data(),
                              ),
                            );
                          });
                          return Expanded(
                            child: ListView.builder(
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditCategory(
                                          id: categories[index].id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
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
                                          categories[index].name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          categories[index].isActive
                                              ? "Enabled"
                                              : "Disabled",
                                          style: TextStyle(
                                            color: categories[index].isActive
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                        leading: Text(
                                          categories[index].icon,
                                          style: TextStyle(fontSize: 30),
                                        ),
                                        trailing: Icon(
                                          Icons.edit,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
