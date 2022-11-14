import 'dart:async';
import 'dart:ui';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/page4.dart';
import 'package:flutter_app/mediaquerycontextsize.dart';
import 'package:flutter_vpn/flutter_vpn.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/speedtest.dart';
import 'package:internet_speed_test/internet_speed_test.dart';
import 'package:internet_speed_test/callbacks_enum.dart';
class page3 extends StatelessWidget {
  int serverid = 1;
  page3(){}
  page3.idget(this.serverid);

  @override
  Widget build(BuildContext context) {
    screensize scsize = screensize(context);
    ScreenUtil.init(
        BoxConstraints(
            maxWidth:scsize.wsize,
            maxHeight: scsize.hsize,
            //maxWidth:428,
            // maxHeight:926,
            ),
        designSize: Size(428, 926),
        minTextAdapt: true,
        orientation: Orientation.portrait);
    return ScreenUtilInit(
      designSize: Size(428, 926),
      minTextAdapt: true,
      builder: () => MaterialApp(
        builder: DevicePreview.appBuilder,
        debugShowCheckedModeBanner: false,
        home: page3stf(serverid),
      ),
    );
  }
}

class page3stf extends StatefulWidget {

  int serverid = 1;
  page3stf(this.serverid);
  @override
  _page3stfState createState() => _page3stfState(serverid);
}

class _page3stfState extends State<page3stf> with SingleTickerProviderStateMixin {
int serverid = 1;
  _page3stfState(this.serverid);
  late AnimationController centeranim;
  var state = FlutterVpnState.disconnected;
  String vpnstate = "disconnected";
  bool timermode = false;
  var servername = "";
  late Timer timer;
  int sec = 0;
  String user = "";
  String pass = "";
  //start speed internet test  Variable
  final internetSpeedTest = InternetSpeedTest();
  double downloadRate = 0;
  double uploadRate = 0;
  String downloadProgress = '0';
  String uploadProgress = '0';
  String downloadunitText = 'Mb/s';
  String uploadunitText = 'Kb/s';
//end speed internet test  Variable

  // check user login?
  CheckLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("loginuser") == true) {
      user = prefs.getString("user").toString();
      pass = prefs.getString("pass").toString();
    } else {
      Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => new myapp(),
          ),
      );
    };
  }// end  check user login?

  //start json get server address
 List jsongetmap=[] ;
  serverget() async {
     jsongetmap = await getserver();
    setState(() {
    });
  }
  // end json get server address


  @override
  void initState() {
    // TODO: implement initState

    serverget();
    CheckLogin();
    FlutterVpn.prepare();

    FlutterVpn.onStateChanged.listen((s) => setState(() {
          state = s;
          if (state == FlutterVpnState.connecting) {
            timermode = false;
            vpnstate = "connecting...";
          } else if (state == FlutterVpnState.connected) {
            vpnstate = "connected";
            timermode = true;
            //start speed download test

            downloadspeedtest();


            //end download speed  test
          } else if (state == FlutterVpnState.disconnecting) {
            vpnstate = "disconnecting";
          } else if (state == FlutterVpnState.disconnected) {
            vpnstate = "disconnected";
            timermode = false;
            sec = 0;
          }
        }
        ),//setstate
    );//flutter vpn

    centeranim = AnimationController(vsync: this, duration: Duration(seconds: 6));
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timermode) {
        setState(() {
          sec = sec + 1;
        });
      }
    });
    super.initState();
  } //initstate

//start speed download test
  downloadspeedtest(){

    return internetSpeedTest.startDownloadTesting(
      onDone: (double transferRate, SpeedUnit unit) {
        print('the transfer rate $transferRate');
        setState(() {
          downloadRate = transferRate;
          downloadunitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
          downloadProgress = '100';
          uploadspeedtest();
        });
      },
      onProgress:
          (double percent, double transferRate, SpeedUnit unit) {
        print(
            'the transfer rate $transferRate, the percent $percent');
        setState(() {
          downloadRate = transferRate;
          downloadunitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
          downloadProgress = percent.toStringAsFixed(2);
        });
      },
      onError: (String errorMessage, String speedTestError) {
        print(
            'the errorMessage $errorMessage, the speedTestError $speedTestError');
      },
      fileSize: 20000000,

    );

  }
  //end download speed  test

//start uoload speed test
  uploadspeedtest(){

    return internetSpeedTest.startUploadTesting(
      onDone: (double transferRate, SpeedUnit unit) {
        print('the transfer rate $transferRate');
        setState(() {
          uploadRate = transferRate;
          uploadunitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
          uploadProgress = '100';
        });
      },
      onProgress:
          (double percent, double transferRate, SpeedUnit unit) {
        print(
            'the transfer rate $transferRate, the percent $percent');
        setState(() {
          uploadRate = transferRate;
          uploadunitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
          uploadProgress = percent.toStringAsFixed(2);
        });
      },
      onError: (String errorMessage, String speedTestError) {
        print(
            'the errorMessage $errorMessage, the speedTestError $speedTestError');
      },
      fileSize: 20000000,
    );

  }
  //end upload speed  test
  @override
  Widget build(BuildContext context) {
    screensize scsize = screensize(context);
    int min = sec ~/ 60;

    double contextheight = scsize.hsize;
    double contextwidth = scsize.wsize;

    double h1 = 174.h;
    double w1 = 174.w;
    double h2 = 251.h;
    double w2 = 251.w;

    if (contextheight <= 700) {
      h1 = 170.h;
      w1 = 380.w;
      h2 = 255.h;
      w2 = 200.w;
    } else if (contextheight <= 800) {
      h1 = 220.h;
      w1 = 400.w;
      h2 = 273.h;
      w2 = 251.w;
    } else if (contextheight <= 926) {
      h1 = 335.h;
      w1 = 427.w;
      h2 = 251.h;
      w2 = 251.w;
    } else if (contextheight > 926) {
      w1 = 427.w;
      h1 = 220.h;
      h2 = 300.h;
      w2 = 180.w;
    }

    return Scaffold(
      backgroundColor: Color(0xff07074E),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: contextheight - 60.h,
            child: Stack(
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 120, end: 40),
                  duration: Duration(milliseconds: 1000),
                  builder: (BuildContext context, double size, Widget? child) {
                    return Container(
                      width: contextwidth,
                      margin:
                          EdgeInsets.only(top: size.h, left: 40.w, right: 40.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                                border: Border.all(color: Color(0xff605A9D)),
                                color: Color(0xff07074E),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(18.0))),
                            child: IconButton(
                              icon: SvgPicture.asset(
                                'image/category.svg',
                                height: 24,
                                width: 24,
                              ),
                              onPressed: () {},
                            ),
                          ), //leftbottom appbar

                          Row(
                            children: [
                              SvgPicture.asset(
                                'image/flash-circle.svg',
                                height: 24,
                                width: 24,
                              ),
                              Text(
                                'AriaVPN',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36.0.sp,
                                    inherit: false,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ), //center appbar

                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                                border: Border.all(color: Color(0xff605A9D)),
                                color: Color(0xff07074E),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(18.0))),
                            child: IconButton(
                              icon: SvgPicture.asset(
                                'image/setting-5.svg',
                                height: 24,
                                width: 24,
                              ),
                              onPressed: () {
                                 Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (context) => new speed(),
                                    ));
                              },
                            ),
                          ), //rightbottom appbar
                        ],
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.h),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: RotationTransition(
                          turns: centeranim,
                          alignment: Alignment.center,
                          child: Image(
                            width: contextwidth,
                            image: AssetImage('image/looper.png'),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                      Image(
                        width: h2,
                        height: w2,
                        image: AssetImage('image/center circle.png'),
                        fit: BoxFit.fill,
                      ),
                      Container(
                        width: 118.w,
                        height: 127.h,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: SvgPicture.asset(
                                'image/power.svg',
                                height: 45.h,
                                width: 45.w,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (state == FlutterVpnState.disconnected) {
                                    FlutterVpn.simpleConnect(

                                   jsongetmap.isEmpty ?"ik.ikevserver.info":jsongetmap[serverid]['server'],

                                      user,
                                      pass,
                                    );
                                  } else {
                                    FlutterVpn.disconnect();
                                  }

                                  if (centeranim.isAnimating) {
                                    print('yes');
                                  } else if (centeranim.isCompleted) {
                                    print('complate');
                                    centeranim.reset();
                                    centeranim.forward();
                                  } else {
                                    centeranim.forward();
                                  }
                                });
                              },
                            ),
                            Text(
                              ' $vpnstate',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19.0.sp,
                                  inherit: false,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${sec ~/ (60 * 60)}'.padLeft(2, "0") +
                                  ':' +
                                  '${min % 60}'.padLeft(2, "0") +
                                  ':' +
                                  '${sec % 60}'.padLeft(2, "0"),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 0.6),
                                  fontSize: 19.0.sp,
                                  inherit: false,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ], //children
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 154.h),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 220, end: 348),
                      duration: Duration(seconds: 1),
                      builder:
                          (BuildContext context, double size, Widget? child) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (context) => new selectserver(),
                                ));
                          },
                          child: Container(
                            height: 78.h,
                            width: size.w,
                            decoration: BoxDecoration(
                                color: Color(0xff17185A),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(31.0))),
                            child: Padding(
                              padding:
                                  EdgeInsets.only(left: 43.64.w, top: 10.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.asset(
                                        'image/unt.png',
                                        width: 27.27.w,
                                        height: 17.h,
                                        fit: BoxFit.cover,
                                      ),
                                      SvgPicture.asset(
                                        'image/down.svg',
                                        height: 18.h,
                                        width: 19.64.w,
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 13.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          jsongetmap.isEmpty ?"uk1":jsongetmap[serverid]['name'],


                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              fontSize: 18.0.sp,
                                              inherit: false,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Connceted',
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.6),
                                              fontSize: 15.0.sp,
                                              inherit: false,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 110, end: 156),
                            duration: Duration(seconds: 1),
                            builder: (BuildContext context, double size,
                                Widget? child) {
                              return GestureDetector(
                              onTap: () {
                                downloadspeedtest();

                              },
                                child: Container(
                                  height: 102.h,
                                  width: size.w,
                                  decoration: BoxDecoration(
                                      color: Color(0xff17185A),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(31.0))),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'image/arrow-down.svg',
                                        height: 20.h,
                                        width: 20.w,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.w),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Download',
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 0.6),
                                                  fontSize: 18.0.sp,
                                                  inherit: false,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '$downloadRate' ,
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          255, 255, 255, 1),
                                                      fontSize: 16.0.sp,
                                                      inherit: false,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 5.w),
                                                  child: Text(
                                                    downloadunitText,
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            255, 255, 255, 0.6),
                                                        fontSize: 16.0.sp,
                                                        inherit: false,
                                                        fontWeight:
                                                            FontWeight.w200),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 95, end: 156),
                            duration: Duration(seconds: 1),
                            builder: (BuildContext context, double size,
                                Widget? child) {
                              return GestureDetector(
                                onTap: () {
                                  uploadspeedtest();

                                },
                                child: Container(
                                  height: 102.h,
                                  width: size.w,
                                  decoration: BoxDecoration(
                                      color: Color(0xff17185A),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(31.0))),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'image/arrow-up.svg',
                                        height: 20.h,
                                        width: 20.w,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.w),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Upload',
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 0.6),
                                                  fontSize: 18.0.sp,
                                                  inherit: false,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '$uploadRate',
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          255, 255, 255, 1),
                                                      fontSize: 16.0.sp,
                                                      inherit: false,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 5.w),
                                                  child: Text(
                                                    uploadunitText,
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            255, 255, 255, 0.6),
                                                        fontSize: 16.0.sp,
                                                        inherit: false,
                                                        fontWeight:
                                                            FontWeight.w200),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 28.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 62.h,
                            width: 254.w,
                            decoration: BoxDecoration(
                                border: Border.all(color: Color(0xff605A9D)),
                                color: Color(0xff07074E),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(70.0.r))),
                            child: MaterialButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(70.0.r),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (context) => new page3(),
                                    ));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage('image/vip 1.png'),
                                    fit: BoxFit.fill,
                                    width: 30.w,
                                    height: 30.h,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 12.w),
                                    child: Text(
                                      'Super Fast Server',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0.sp,
                                          inherit: false,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 62.h,
                            width: 68.w,
                            decoration: BoxDecoration(
                                border: Border.all(color: Color(0xff605A9D)),
                                color: Color(0xff07074E),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(28.0.r))),
                            child: IconButton(
                              icon: SvgPicture.asset(
                                'image/arrow-circle-right.svg',
                                height: 24,
                                width: 24,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (context) => new myapp(),
                                    ));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<List> getserver() async {
  var url = Uri.parse("http://192.168.1.103/db.json");
  Response res = await get(url);
  return json.decode(res.body);
}


