import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:admin_app/route/route_constants.dart';
import '../providers/auth.dart';
import '../utilities/styles.dart';
import 'package:provider/provider.dart';

import '../api/http_exceptions.dart';
import '../api/lockers.dart';
import '../api/orders.dart';
import '../models/lockers.dart';
import '../widgets/button.dart';
import '../widgets/dialog.dart';

class ConfirmLockerScreen extends StatefulWidget {
  final String lockerId;
  const ConfirmLockerScreen(this.lockerId, {Key? key}) : super(key: key);

  @override
  State<ConfirmLockerScreen> createState() => _ConfirmLockerScreenState();
}

class _ConfirmLockerScreenState extends State<ConfirmLockerScreen> {
  late Future _getLockerFuture;
  bool isActiveChecking = false;
  Locker? locker;
  String? token;

  Future _obtainGetLockerFuture() async {
    token = Provider.of<Auth>(context, listen: false).token;
    //final isExist = await OrderApi.isExistActiveOrders(token);
    //if (isExist) {
    //  try {
    //    await Provider.of<LockerNotifier>(context, listen: false)
    //        .setLocker(widget.lockerId);
    //    Navigator.of(context).pushReplacementNamed(menuRoute);
    //    return;
    //  } catch (e) {
    //    if (e is HttpException) {
    //      if (e.statusCode == 404) {
    //        Navigator.of(context).pushReplacementNamed(enterLockerIdRoute);
    //        return;
    //      }
    //    }
    //    Navigator.of(context).pushReplacementNamed(menuRoute);
    //    return;
    //  }
    //}
    try {
      locker = await Provider.of<LockerNotifier>(context, listen: false)
          .setLocker(widget.lockerId);
    } catch (e) {
      Navigator.of(context).pushReplacementNamed(enterLockerIdRoute);
      return;
    }
  }

  @override
  void initState() {
    _getLockerFuture = _obtainGetLockerFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: _getLockerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center();
                } else {
                  if (snapshot.error != null) {
                    print("Error: ${snapshot.error.toString()}");
                    return Center(
                      child: Text("Error: ${snapshot.error.toString()}"),
                    );
                  } else {
                    if (locker != null) {
                      return Center(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Column(
                          children: [
                            Text(
                              "set_locker.complex_looks_like".tr(),
                              textAlign: TextAlign.center,
                              style: AppStyles.titleSecondaryTextStyle,
                            ),
                            const SizedBox(height: 10),
                            if (locker!.imageUrl == null)
                              Image.asset(
                                "assets/images/no-image-2.png",
                                width: 250,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                            if (locker!.imageUrl != null)
                              Image.network(
                                locker!.imageUrl ??
                                    "http://placehold.jp/3d4070/ffffff/250x250.png?text=NO%20IMAGE&css=%7B%22border-radius%22%3A%2230px%22%7D",
                                width: 250,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                            const SizedBox(height: 8),
                            Text(
                              locker!.fullLockerName,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textColor),
                            ),
                            const SizedBox(height: 20),
                            ElevatedDefaultButton(
                                buttonColor: AppColors.successColor,
                                onPressed:
                                    isActiveChecking ? null : confirmLocker,
                                child: isActiveChecking
                                    ? const SizedBox(
                                        height: 28,
                                        width: 28,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        "set_locker.yes".tr(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 4),
                                      )),
                            const SizedBox(height: 30),
                            ElevatedIconButton(
                              icon: const Icon(Icons.qr_code_scanner_outlined),
                              textStyle: GoogleFonts.openSans(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                              text: "set_locker.not_this_complex".tr(),
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, enterLockerIdRoute);
                              },
                            ),
                            const SizedBox(height: 15),
                            ElevatedIconButton(
                              icon: const Icon(Icons.home),
                              text: "to_main_menu".tr(),
                              textStyle: GoogleFonts.openSans(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, menuRoute);
                              },
                            ),
                          ],
                        ),
                      ));
                    } else {
                      return const Center();
                    }
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void confirmLocker() async {
    setState(() {
      isActiveChecking = true;
    });
    try {
      final isActive = await LockerApi.isActive(widget.lockerId);
      if (!isActive) {
        throw Exception();
      }
    } catch (e) {
      await showDialog(
          context: context,
          builder: (ctx) {
            return DefaultAlertDialog(
              title: "information".tr(),
              body: "complex_offline".tr(),
            );
          });
      Provider.of<LockerNotifier>(context, listen: false).resetLocker();
      setState(() {
        isActiveChecking = false;
      });
      return;
    }
    Navigator.pushReplacementNamed(context, menuRoute);
  }
}
