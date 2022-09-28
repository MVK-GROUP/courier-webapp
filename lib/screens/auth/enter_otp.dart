import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:admin_app/route/route_constants.dart';
import 'package:admin_app/widgets/snackbar.dart';
import '../../api/settings.dart';
import '../../utilities/styles.dart';
import '/providers/auth.dart';
import 'package:provider/provider.dart';
import '../../api/auth.dart';

class EnterOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String? prevRouteName;

  const EnterOtpScreen(
      {required this.phoneNumber, this.prevRouteName, Key? key})
      : super(key: key);

  @override
  State<EnterOtpScreen> createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  bool _isInit = false;
  bool _isLoading = false;
  bool _isCanResend = false;
  bool _isResendLoading = false;
  Timer? _timer;
  int _start = 20;
  late double screenWidth;
  late TextEditingController otpController;

  @override
  void initState() {
    otpController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      startTimer();
      screenWidth = MediaQuery.of(context).size.width;
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _timer!.cancel();
    otpController.dispose();
    super.dispose();
  }

  Widget buildOtpInputWidget() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 410),
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: TextField(
        autofocus: true,
        controller: otpController,
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
        autofillHints: const [AutofillHints.oneTimeCode],
        onChanged: confirmOtp,
        autocorrect: false,
      ),
    );
  }

  void confirmOtp(String otpCode) async {
    if (otpCode.length == 4) {
      setState(() {
        _isLoading = true;
      });
      try {
        if (debugServer) {
          await Provider.of<Auth>(context, listen: false)
              .testConfirmOtp(widget.phoneNumber, otpCode);
        } else {
          await Provider.of<Auth>(context, listen: false)
              .confirmOtp(widget.phoneNumber, otpCode);
        }
        if (!mounted) return;
        Navigator.pushReplacementNamed(
            context, widget.prevRouteName ?? menuRoute);
      } catch (e) {
        otpController.text = '';
        showSnackbarMessage("auth.otp_invalid_code".tr(), icon: Icons.cancel);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
            width: screenWidth,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        'auth.phone_verification'.tr(),
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black45),
                              children: [
                                TextSpan(text: 'auth.otp_enter_code'.tr()),
                                TextSpan(
                                  text: widget.phoneNumber,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                    text: ' ${'auth.otp_change_number'.tr()}',
                                    style: const TextStyle(
                                        color: AppColors.secondaryColor),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pop(context);
                                      }),
                              ]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 10),
                        child: buildOtpInputWidget(),
                      ),
                      const Spacer(),
                      if (!_isCanResend && !_isResendLoading)
                        Text(
                          'auth.otp_repeat'
                              .tr(namedArgs: {'time': _start.toString()}),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black45),
                        ),
                      if (_isResendLoading)
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      if (_isCanResend && !_isResendLoading)
                        TextButton(
                          onPressed: () async {
                            setState(() {
                              _isResendLoading = true;
                              _isCanResend = false;
                            });
                            try {
                              final wasSent =
                                  await AuthApi.createOtp(widget.phoneNumber);
                              if (!wasSent) {
                                showSnackbarMessage(
                                    "auth.otp_sending_error".tr());
                              }
                            } catch (e) {
                              showSnackbarMessage(
                                  "auth.otp_sending_error".tr());
                            }

                            setState(() {
                              _isResendLoading = false;
                              _isCanResend = false;
                              _start = 20;
                              startTimer();
                            });
                          },
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16)),
                          child: Text(
                            'auth.otp_send_new_code'.tr(),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      const SizedBox(height: 40)
                    ],
                  ),
                ),
                if (_isLoading == true)
                  Container(
                      color: Colors.black.withOpacity(0.1),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      )),
              ],
            )),
      ),
    );
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _isCanResend = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void showSnackbarMessage(String text, {IconData? icon}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(buildSnackBar(text, icon: icon));
  }
}
