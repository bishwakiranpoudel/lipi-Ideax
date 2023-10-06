import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/colors.dart';
import 'package:frontend/screens/addLanguage.dart';
import 'package:frontend/screens/language.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String uid = user!.uid.toString();
    return GestureDetector(
      onTap: () {
        // Lose focus when tapping outside the TextField
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),

            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('profiles')
                  .where('uid', isEqualTo: uid)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final documents = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final name = document['name'];
                    final image = document['image'];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hola! ${name} 👋",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Hope your having a wonderful day",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(157, 59, 74, 63)),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            backgroundColor: AppColors.primaryColor,
                            foregroundImage: NetworkImage(image),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            SizedBox(
              height: 10,
            ),
            // add search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(208, 219, 239, 222),
                          borderRadius: BorderRadius.circular(4)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Looking for",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Specific Language?",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: "Search Languages...",
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.all(
                                    16), // Adjust padding as needed
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide:
                                      BorderSide.none, // Remove border color
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide:
                                      BorderSide.none, // Remove border color
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide:
                                      BorderSide.none, // Remove border color
                                ),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.search,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        // Handle search button click here
                                        // You can use the entered search query to filter your data
                                      },
                                    ),
                                  ),
                                ),
                                // Add elevation to the TextField
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                isDense: true,
                              ),
                              onTap: () {
                                // Set isSearching to true when the TextField is tapped
                                setState(() {
                                  isSearching = true;
                                });
                              },
                              onEditingComplete: () {
                                // Set isSearching to false when editing is complete (e.g., when pressing the "Done" key on the keyboard)
                                setState(() {
                                  isSearching = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Your Languages Container
            Container(
              margin: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Languages',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Add Language Button
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddLanguageScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                        ),
                        child: Text(
                          'Add Language',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Show all user Languages
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('languages')
                        .where('maintainer', isEqualTo: uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      final documents = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final document = documents[index];
                          final name = document['name'];
                          final description = document['description'];
                          final documentId = document.id;

                          return Card(
                            margin: EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            elevation: 2.0, // Decreased shadow elevation
                            child: ListTile(
                              title: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                description,
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LanguageDocumentScreen(
                                      changer: false,
                                      documentId: documentId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Change Requests',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Add Language Button
                    ],
                  ),
                  // Show all user Languages
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('changerequests')
                        .where('changer', isEqualTo: uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      final documents = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final document = documents[index];
                          final name = document['name'];
                          final description = document['description'];
                          final documentId = document.id;

                          return Card(
                            margin: EdgeInsets.symmetric(
                              vertical: 8.0,
                            ),
                            elevation: 2.0, // Decreased shadow elevation
                            child: ListTile(
                              title: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                description,
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                              onTap: () {},
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
