import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_360_app/view/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../functions/globar_variables.dart';
import '../../provider/qrcode_data.dart';
import '../scanner/scanner_screen.dart';
import '../school_hub/school_hub_screen.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash-view';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void triggerSplashScreen(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 800));
    checkIfLoggedIn();
  }

  void checkIfLoggedIn() async {
    print('before shared pref init');

    final prefs = await SharedPreferences.getInstance();
    print('after shared pref init');
    String? schoolId = await prefs.getString('schoolId');
    String? studentId = await prefs.getString('studentId');
    String? studentName = await prefs.getString('studentName');
    if (studentId == null || studentName == null || schoolId == null) {
      print('pushing to homepage');
      Navigator.pushReplacementNamed(
        context,
        Homepage.routeName,
      );
    } else {
      QRCodeDataProvider qrCodeData =
          Provider.of<QRCodeDataProvider>(context, listen: false);
      qrCodeData.studentId = studentId;
      qrCodeData.studentName = studentName;
      qrCodeData.schoolId = schoolId;
      print('User found');
      print(studentId);
      print(studentName);
      print(schoolId);
      Navigator.pushNamedAndRemoveUntil(
        context,
        SchoolHub.routeName,
        (route) => false,
      );
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    triggerSplashScreen(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Color(0xffF4F6F9),
        ),
      ),
      backgroundColor: white,
      body: Stack(
        children: [
          // Container(
          //   height: double.infinity,
          //   width: double.infinity,
          //   child: GridPaper(
          //     color: Colors.black.withOpacity(0.08),
          //     divisions: 4,
          //     interval: 500,
          //     subdivisions: 8,
          //   ),
          // ),
          Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                // Flexible(
                //   flex: 1,
                //   child: Container(
                //     height: double.infinity,
                //     // color: Colors.red,
                //   ),
                // ),
                Flexible(
                  flex: 1,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    // color: Colors.green,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          // color: Colors.black,
                          width: 20,
                        ),
                        Center(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * .4,
                            width: MediaQuery.of(context).size.width * .4,
                            child: Image.asset('lib/assets/logo.png'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Flexible(
                //   flex: 1,
                //   child: Container(
                //     height: double.infinity,
                //     // color: Colors.blue,
                //     width: double.infinity,
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       children: [
                //         Stack(
                //           children: [
                //             Positioned(
                //               bottom: 0,
                //               child: Container(
                //                 // color: Colors.pink,
                //                 alignment: Alignment.center,
                //                 height: MediaQuery.of(context).size.width * .1,
                //                 width: MediaQuery.of(context).size.width * .3,
                //                 child: Text(
                //                   'SPATEi',
                //                   style: GoogleFonts.getFont(
                //                     'Ubuntu',
                //                     textStyle: TextStyle(
                //                         color:
                //                             // Theme.of(context).colorScheme.background.withOpacity(0.9),
                //                             Colors.black.withOpacity(0.6),
                //                         fontSize: 16,
                //                         height: .9,
                //                         wordSpacing: 1,
                //                         fontWeight: FontWeight.w700),
                //                   ),
                //                 ),
                //                 // child: Image.asset('lib/assets/spatei.png'),
                //               ),
                //             ),
                //             Container(
                //               height: MediaQuery.of(context).size.width * .19,
                //               width: MediaQuery.of(context).size.width * .3,
                //               alignment: Alignment.center,
                //               child: Text(
                //                 'from',
                //                 style: GoogleFonts.getFont(
                //                   'Ubuntu',
                //                   textStyle: TextStyle(
                //                       color:
                //                           // Theme.of(context).colorScheme.background.withOpacity(0.9),
                //                           Colors.black.withOpacity(0.6),
                //                       fontSize: 10,
                //                       height: .9,
                //                       wordSpacing: 1,
                //                       fontWeight: FontWeight.w700),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
