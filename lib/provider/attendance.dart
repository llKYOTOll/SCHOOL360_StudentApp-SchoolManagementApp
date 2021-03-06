import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_360_app/functions/globar_variables.dart';
import 'package:school_360_app/model/attendance/data_model_for_attendance.dart';
import 'package:school_360_app/model/attendance/data_model_for_log_in_log_out_timings.dart';
import 'package:school_360_app/model/dropdown_list/data_model_for_course_dropdown_list.dart';
import 'package:school_360_app/model/dropdown_list/data_model_for_year_dropdown_list.dart';
import 'package:school_360_app/provider/qrcode_data.dart';
import 'package:http/http.dart' as http;
import 'package:school_360_app/view/school_hub/tabs/attendance/AttendanceReport_Table.dart';
import 'package:school_360_app/view/school_hub/tabs/attendance/FM_Table.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AttendanceProvider extends ChangeNotifier {
  AttendanceProvider();

  String alertBoxText = '';
  String alertBoxTitle = '';
  String alertBoxButtonTitle = '';
  String alertBoxButtonAction = '';

  bool _showLoading = true;
  bool get showLoading => _showLoading;
  set showLoading(bool value) {
    _showLoading = value;
    notifyListeners();
  }

  bool _showAlertBox = false;
  bool get showAlertBox => _showAlertBox;
  set showAlertBox(bool value) {
    _showAlertBox = value;
    notifyListeners();
  }

  late String _selectedCourseID;

  String get selectedCourseID => _selectedCourseID;

  set selectedCourseID(String value) {
    _selectedCourseID = value;
  }

  late String _selectedYear = 'Select year';

  String get selectedYear => _selectedYear;

  set selectedYear(String value) {
    _selectedYear = value;
  }

  late String _selectedMonth = 'Select month';

  String get selectedMonth => _selectedMonth;

  set selectedMonth(String value) {
    _selectedMonth = value;
  }

  late String _selectedCourse = 'Select course';

  String get selectedCourse => _selectedCourse;

  set selectedCourse(String value) {
    _selectedCourse = value;
  }

  final months = [
    'Select month',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  var years = <String>[
    'Select year',
  ];

  void ExtractYearFromYearDropDownApi() {
    years = <String>[
      'Select year',
    ];
    int len = yearDropdownList.yearData!.length;
    for (int i = 0; i < len; i++) {
      years.add(yearDropdownList.yearData![i].value.toString());
    }
  }

  DataModelForYearDropDown yearDropdownList = DataModelForYearDropDown();

  Future<void> callApiForYearDropdownList(BuildContext context) async {
    try {
      QRCodeDataProvider qrCodeData =
          Provider.of<QRCodeDataProvider>(context, listen: false);
      String url =
          'https://school360.app/${qrCodeData.schoolId}/service_bridge/yearListData';

      http.Response response = await http.post(Uri.parse(url), body: {
        "security_pin": '311556',
      });
      String data = response.body;
      if (data.isEmpty) {
        showLoading = false;
        alertBoxText =
            'An Error occurred while trying to fetch the data! Please try again!';
        alertBoxTitle = 'Alert';
        alertBoxButtonTitle = "Close";
        alertBoxButtonAction = "Close-year";
        _showAlertBox = true;
        return;
      } else {
        var decodedData = jsonDecode(data);
        yearDropdownList = DataModelForYearDropDown.fromJson(decodedData);
        if (yearDropdownList.status == 'success') {
          ExtractYearFromYearDropDownApi();
        } else {
          showLoading = false;
          alertBoxText = 'An Error occurred while trying to fetch the data!';
          alertBoxTitle = 'Alert';
          alertBoxButtonTitle = "Close";
          alertBoxButtonAction = "Close-year";
          _showAlertBox = true;
          return;
        }
      }
    } on SocketException {
      showLoading = false;
      alertBoxText =
          'Sorry. No working internet connection detected. Please try again later. :)';
      alertBoxTitle = 'Error: 404';
      alertBoxButtonTitle = "Retry";
      alertBoxButtonAction = "Close-year";
      _showAlertBox = true;
      return;
    } catch (e) {}
  }

  var courses = <String>[
    'Select course',
  ];

  void getData(BuildContext context) async {
    await callApiForYearDropdownList(context);
    await callApiForCourseDropdownList(context);
    showLoading = false;
    showAlertBox = false;
  }

  void ExtractCourseFromCourseDropDownApi() {
    courses = <String>[
      'Select course',
    ];
    int len = courseDropdownAPI.periodData!.length.toInt();
    for (int i = 0; i < len; i++) {
      courses.add(courseDropdownAPI.periodData![i].name.toString());
    }
  }

  DataModelForCourseDropDown courseDropdownAPI = DataModelForCourseDropDown();
  Future<void> callApiForCourseDropdownList(BuildContext context) async {
    try {
      QRCodeDataProvider qrCodeData =
          Provider.of<QRCodeDataProvider>(context, listen: false);
      String url =
          'https://school360.app/${qrCodeData.schoolId}/service_bridge/classPeriodListData';

      http.Response response = await http.post(Uri.parse(url), body: {
        "security_pin": '311556',
      });
      String data = response.body;
      if (data.isEmpty) {
        showLoading = false;
        alertBoxText = 'An Error occurred while trying to fetch the data!';
        alertBoxTitle = 'Alert';
        alertBoxButtonTitle = "Close";
        alertBoxButtonAction = "Close-Attendance";
        _showAlertBox = true;
        return;
      } else {
        var decodedData = jsonDecode(data);
        courseDropdownAPI = DataModelForCourseDropDown.fromJson(decodedData);
        if (courseDropdownAPI.status == 'success') {
          ExtractCourseFromCourseDropDownApi();
        } else {
          showLoading = false;
          alertBoxText =
              'No data found. Please contact your local administration for more information.';
          alertBoxTitle = 'Alert';
          alertBoxButtonTitle = "Close";
          alertBoxButtonAction = "Close";
          _showAlertBox = true;
          return;
        }
      }
    } on SocketException {
      showLoading = false;
      alertBoxText =
          'Sorry. No working internet connection detected. Please try again later. :)';
      alertBoxTitle = 'Error: 404';
      alertBoxButtonTitle = "Retry";
      alertBoxButtonAction = "Close-NoInternetConnectionResult";
      _showAlertBox = true;
      return;
    } catch (e) {
      showLoading = false;
      alertBoxText = 'An error occurred.';
      alertBoxTitle = 'ERROR';
      alertBoxButtonTitle = "Close";
      alertBoxButtonAction = "Close";
      _showAlertBox = true;
      return;
    }
  }

  int StringMonthToIntMonth(String _selectedMonth) {
    int month = 1;
    if (_selectedMonth == "January") {
      month = 1;
    }
    if (_selectedMonth == "February") {
      month = 2;
    }
    if (_selectedMonth == "March") {
      month = 3;
    }
    if (_selectedMonth == "April") {
      month = 4;
    }
    if (_selectedMonth == "May") {
      month = 5;
    }
    if (_selectedMonth == "June") {
      month = 6;
    }
    if (_selectedMonth == "July") {
      month = 6;
    }
    if (_selectedMonth == "August") {
      month = 8;
    }
    if (_selectedMonth == "September") {
      month = 9;
    }
    if (_selectedMonth == "October") {
      month = 10;
    }
    if (_selectedMonth == "November") {
      month = 11;
    }
    if (_selectedMonth == "December") {
      month = 12;
    }
    return month;
  }

  late DataModelForLogInLogOutTimings dataModelForLogInLogOutTimings;

  Future<void> callApiForFMData(BuildContext context) async {
    try {
      QRCodeDataProvider qrCodeData =
          Provider.of<QRCodeDataProvider>(context, listen: false);
      // print(qrCodeData.studentId);
      String url =
          'https://school360.app/${qrCodeData.schoolId}/service_bridge/getStudentAttendanceByMonthYear';
      http.Response response = await http.post(Uri.parse(url), body: {
        "security_pin": '311556',
        "student_code": qrCodeData.studentId,
        "month": StringMonthToIntMonth(_selectedMonth).toString(),
        "year": _selectedYear.toString(),
        "class_period": _selectedCourseID,
      });
      String data = response.body;
      if (data.isEmpty) {
        showLoading = false;
        alertBoxText =
            'An Error occurred while trying to fetch the data! Please try again!';
        alertBoxTitle = 'Alert';
        alertBoxButtonTitle = "Close";
        alertBoxButtonAction = "Close";
        _showAlertBox = true;
        return;
      } else {
        var decodedData = jsonDecode(data);
        dataModelForLogInLogOutTimings =
            DataModelForLogInLogOutTimings.fromJson(decodedData);
        if (dataModelForLogInLogOutTimings.status == 'success') {
          await getCalenderDataForFMTable();
          Navigator.of(context).pushNamed(FMTable_Page.routeName);
        } else {
          showLoading = false;
          alertBoxText = 'An Error occurred while trying to fetch the data!';
          alertBoxTitle = 'Alert';
          alertBoxButtonTitle = "Close";
          alertBoxButtonAction = "Close";
          _showAlertBox = true;
          return;
        }
      }
    } on SocketException {
      showLoading = false;
      alertBoxText =
          'Sorry. No working internet connection detected. Please try again later. :)';
      alertBoxTitle = 'Error: 404';
      alertBoxButtonTitle = "Retry";
      alertBoxButtonAction = "Close-NoInternetFMData";
      _showAlertBox = true;
      return;
    } catch (e) {
      print(e);
      showLoading = false;
      alertBoxText = 'An error occurred.';
      alertBoxTitle = 'ERROR';
      alertBoxButtonTitle = "Close";
      alertBoxButtonAction = "Close";
      _showAlertBox = true;
      notifyListeners();
      return;
    }
  }

  Future<void> getCalenderDataForFMTable() async {
    int loopCount = dataModelForLogInLogOutTimings.data!.attendanceInfo!.length;
    List<Appointment> calenderDataListTemp = [];
    for (int i = 0; i < loopCount; i++) {
      print(dataModelForLogInLogOutTimings.data!.attendanceInfo![i].status
          .toString());
      calenderDataListTemp.add(
        Appointment(
          startTime: DateTime(int.parse(selectedYear),
              StringMonthToIntMonth(_selectedMonth), i + 1, 0, 0, 0),
          endTime: DateTime(int.parse(selectedYear),
              StringMonthToIntMonth(_selectedMonth), i + 1, 12, 0, 0),
          subject: 'Attendance Report',
          color:

              // Colors.blue

              dataModelForLogInLogOutTimings.data!.attendanceInfo![i].status
                          .toString() ==
                      'Present'
                  ? Colors.blue
                  : dataModelForLogInLogOutTimings
                              .data!.attendanceInfo![i].status
                              .toString() ==
                          'Absent'
                      ? Colors.red
                      : dataModelForLogInLogOutTimings
                                  .data!.attendanceInfo![i].status
                                  .toString() ==
                              'Leave'
                          ? Colors.green
                          : Colors.transparent,
        ),
      );
    }

    calenderDataListForFMTable = calenderDataListTemp;
  }

  late DataModelForAttendance dataModelForAttendance;
  Future<void> callApiForAttendanceData(BuildContext context) async {
    try {
      QRCodeDataProvider qrCodeData =
          Provider.of<QRCodeDataProvider>(context, listen: false);
      String url =
          'https://school360.app/${qrCodeData.schoolId}/service_bridge/getStudentAttendanceByMonthYear';
      http.Response response = await http.post(Uri.parse(url), body: {
        "security_pin": '311556',
        "student_code": qrCodeData.studentId,
        "month": StringMonthToIntMonth(_selectedMonth).toString(),
        "year": _selectedYear.toString(),
        "class_period": _selectedCourseID,
      });
      String data = response.body;
      if (data.isEmpty) {
        showLoading = false;
        alertBoxText =
            'An Error occurred while trying to fetch the data! Please again!';
        alertBoxTitle = 'Alert';
        alertBoxButtonTitle = "Close";
        alertBoxButtonAction = "Close";
        _showAlertBox = true;
        return;
      } else {
        var decodedData = jsonDecode(data);
        dataModelForAttendance = DataModelForAttendance.fromJson(decodedData);
        if (dataModelForAttendance.status == 'success') {
          await getCalenderDataForAttendanceTable();

          Navigator.of(context).pushNamed(AttendanceReportTable_Page.routeName);
        } else {
          showLoading = false;
          alertBoxText =
              'An Error occurred while trying to fetch the data! Please try again!';
          alertBoxTitle = 'Alert';
          alertBoxButtonTitle = "Close";
          alertBoxButtonAction = "Close";
          _showAlertBox = true;
          return;
        }
      }
    } on SocketException {
      showLoading = false;
      alertBoxText =
          'Sorry. No working internet connection detected. Please try again later. :)';
      alertBoxTitle = 'Error: 404';
      alertBoxButtonTitle = "Retry";
      alertBoxButtonAction = "Close-AttendanceTable";
      _showAlertBox = true;
      return;
    } catch (e) {
      showLoading = false;
      alertBoxText =
          'An Error occurred while trying to fetch the data! Please try again!';
      alertBoxTitle = 'Alert';
      alertBoxButtonTitle = "Close";
      alertBoxButtonAction = "Close";
      _showAlertBox = true;
      return;
    }
  }

  List<Appointment> calenderDataListForAttendanceTable = [];
  List<Appointment> calenderDataListForFMTable = [];

  Future<void> getCalenderDataForAttendanceTable() async {
    int loopCount = dataModelForAttendance.data!.attendanceInfo!.length;
    List<Appointment> calenderDataListTemp = [];
    for (int i = 0; i < loopCount; i++) {
      calenderDataListTemp.add(
        Appointment(
          startTime: DateTime(int.parse(selectedYear),
              StringMonthToIntMonth(_selectedMonth), i + 1, 0, 0, 0),
          endTime: DateTime(int.parse(selectedYear),
              StringMonthToIntMonth(_selectedMonth), i + 1, 12, 0, 0),
          subject: 'Attendance Report',
          color:

              // Colors.blue

              dataModelForAttendance.data!.attendanceInfo![i].status
                          .toString() ==
                      'Present'
                  ? Colors.blue
                  : dataModelForAttendance.data!.attendanceInfo![i].status
                              .toString() ==
                          'Absent'
                      ? Colors.red
                      : dataModelForAttendance.data!.attendanceInfo![i].status
                                  .toString() ==
                              'Leave'
                          ? Colors.green
                          : Colors.transparent,
        ),
      );
    }

    calenderDataListForAttendanceTable = calenderDataListTemp;
  }

  Widget getCalenderForFMTable() {
    return Container(
      // height: 420,
      child: Card(
        elevation: 4,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SfCalendar(
                view: CalendarView.month,
                // onTap: (x){
                //   print(x.date?.day.toString());
                // },
                // initialDisplayDate: DateTime(2021, 12),
                dataSource: CalenderDataSource(calenderDataListForFMTable),
                initialDisplayDate: DateTime(int.parse(selectedYear),
                    StringMonthToIntMonth(_selectedMonth)),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Present'),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Absent'),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Leave'),
                    ],
                  ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  // Row(
                  //   children: [
                  //     Container(
                  //       height: 10,
                  //       width: 10,
                  //       decoration: BoxDecoration(
                  //           color: Colors.green,
                  //           borderRadius:
                  //               BorderRadius.all(Radius.circular(10))),
                  //     ),
                  //     SizedBox(
                  //       width: 5,
                  //     ),
                  //     Text('Working Days'),
                  //   ],
                  // )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '*A detailed breakdown of the login/logout timings can be viewed below.',
                style: defaultTS.copyWith(
                  fontSize: 12,
                  color: Colors.black.withOpacity(.5),
                ),
              ),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     Text(
              //       '*Click on a specific date, to get login & logout timings for that day.',
              //       style: defaultTS.copyWith(
              //         fontSize: 12,
              //         color: Colors.black.withOpacity(.5),
              //       ),
              //     ),
              //     Text(
              //       '*A detailed breakdown of the timings can be viewed below.',
              //       style: defaultTS.copyWith(
              //         fontSize: 12,
              //         color: Colors.black.withOpacity(.5),
              //       ),
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }

  Widget getCalenderForAttendanceTable() {
    return Container(
      // height: 420,
      child: Card(
        elevation: 4,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              SfCalendar(
                view: CalendarView.month,
                // onTap: (x){
                //   print(x.date?.day.toString());
                // },
                // initialDisplayDate: DateTime(2021, 12),
                dataSource:
                    CalenderDataSource(calenderDataListForAttendanceTable),
                initialDisplayDate: DateTime(int.parse(selectedYear),
                    StringMonthToIntMonth(_selectedMonth)),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Present'),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Absent'),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Leave'),
                    ],
                  ),
                  // SizedBox(
                  //   height: 5,
                  // ),
                  // Row(
                  //   children: [
                  //     Container(
                  //       height: 10,
                  //       width: 10,
                  //       decoration: BoxDecoration(
                  //           color: Colors.green,
                  //           borderRadius:
                  //               BorderRadius.all(Radius.circular(10))),
                  //     ),
                  //     SizedBox(
                  //       width: 5,
                  //     ),
                  //     Text('Working Days'),
                  //   ],
                  // )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CalenderDataSource extends CalendarDataSource {
  CalenderDataSource(List<Appointment> source) {
    appointments = source;
  }
}
