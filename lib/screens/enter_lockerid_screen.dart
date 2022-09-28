import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../route/route_constants.dart';
import '/api/http_exceptions.dart';
import '/models/lockers.dart';
import '/providers/orders.dart';
import '/utilities/styles.dart';
import '/widgets/dialog.dart';
import '../api/lockers.dart';

class EnterLockerIdScreen extends StatefulWidget {
  const EnterLockerIdScreen({Key? key}) : super(key: key);

  @override
  State<EnterLockerIdScreen> createState() => _EnterLockerIdScreenState();
}

class _EnterLockerIdScreenState extends State<EnterLockerIdScreen> {
  var isFetchingData = false;

  String lockerId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        iconTheme: const IconThemeData(color: AppColors.textColor),
        elevation: 0.0,
        actions: [
          IconButton(
            iconSize: 36,
            onPressed: () {
              Navigator.pushNamed(context, menuRoute);
            },
            icon: const Icon(Icons.home),
          ),
          const SizedBox(width: 10)
        ],
      ),
      body: isFetchingData
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              child: Center(
                child: SingleChildScrollView(
                  reverse: true,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(children: [
                      _buildTitle('set_locker.enter_locker_id'.tr()),
                      const SizedBox(height: 6),
                      _buildLockerIdInputWidget(),
                      _buildDivider(),
                      _buildTitle('set_locker.scan_qr'.tr()),
                      const SizedBox(height: 16),
                      _buildQr(),
                    ]),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headline4,
    );
  }

  Widget _buildQr() {
    return GestureDetector(
      onTap: () async {
        if (kIsWeb) {
          final res = await Navigator.of(context).pushNamed(scannerRoute);
          if (res != null) {
            if (res is String) {
              lockerId = res;
              enteredLockerId();
            }
          }
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("information".tr()),
              content: Text("functionality_is_not_available".tr()),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [AppShadows.getShadow200()],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          SizedBox(
            height: 92,
            width: 92,
            child: Image.asset(
              "assets/images/scan_qr.png",
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "set_locker.scan_qr_action".tr(),
            style: const TextStyle(
                fontSize: 16,
                color: AppColors.textColor,
                fontWeight: FontWeight.w600),
          ),
        ]),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Divider(
              thickness: 2,
              indent: 25,
              endIndent: 25,
              color: AppColors.textColor.withOpacity(0.5),
            ),
          ),
          Text(
            "set_locker.or".tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
          Expanded(
            child: Divider(
              thickness: 2,
              indent: 25,
              endIndent: 25,
              color: AppColors.textColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockerIdInputWidget() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 410),
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        autofocus: false,
        maxLength: 4,
        style: const TextStyle(
            fontSize: 28, letterSpacing: 16, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          counterText: "",
          hintText: '0000',
          hintStyle: const TextStyle(color: AppColors.grayColor),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
                width: 3.0, color: Theme.of(context).colorScheme.background),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
                width: 3.0, color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        autofillHints: const [AutofillHints.oneTimeCode],
        onChanged: (value) async {
          setState(() {
            lockerId = value;
          });
          if (value.length == 4) {
            await enteredLockerId();
          }
        },
        autocorrect: false,
      ),
    );
  }

  bool isValidLockerId(String lockerId) {
    return lockerId.length >= 4 && int.tryParse(lockerId) != null;
  }

  Future<void> enteredLockerId() async {
    if (!isValidLockerId(lockerId)) {
      return;
    }
    setState(() {
      isFetchingData = true;
    });

    final homeMenuButon = TextButton.icon(
      icon: const Icon(Icons.home),
      label: Text('main_menu'.tr()),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    );
    try {
      final isActive = await LockerApi.isActive(lockerId);
      if (!isActive) {
        final action = await showDialog(
            context: context,
            builder: (ctx) {
              return DefaultAlertDialog(
                title: "attention_title".tr(),
                body: "complex_offline".tr(),
                actions: [homeMenuButon],
              );
            });
        if (!mounted) {
          return;
        }
        Provider.of<LockerNotifier>(context, listen: false).resetLocker();
        Provider.of<OrdersNotifier>(context, listen: false).resetOrders();
        setState(() {
          isFetchingData = false;
        });
        if (action != null) {
          Navigator.pushReplacementNamed(context, menuRoute);
        }
        return;
      }
      if (!mounted) return;

      await Provider.of<LockerNotifier>(context, listen: false)
          .setLocker(lockerId);
      if (!mounted) return;
      Provider.of<OrdersNotifier>(context, listen: false).resetOrders();
      setState(() {
        isFetchingData = false;
      });
      Navigator.pushNamed(context, menuRoute);
    } catch (onError) {
      String titleMessage = "something_went_wrong_with_dots".tr();
      String bodyMessage = "we_have_technical_problems".tr();

      if (onError is HttpException) {
        if (onError.statusCode == 404) {
          titleMessage = "set_locker.complex_not_found".tr();
          bodyMessage = "set_locker.try_scan_qr_or_enter_id".tr();
        }
      }
      setState(() {
        isFetchingData = false;
      });
      final action = await showDialog(
          context: context,
          builder: (ctx) {
            return DefaultAlertDialog(
              title: titleMessage,
              body: bodyMessage,
              actions: [
                homeMenuButon,
                const SizedBox(width: 5),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16)),
                  icon: const Icon(Icons.qr_code),
                  label: Text(
                    'set_locker.scan_again'.tr(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });

      if (action == null) {
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, menuRoute);
      }
    }
  }
}
