import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:admin_app/screens/auth/enter_otp.dart';
import 'package:admin_app/utilities/styles.dart';

import '../../api/settings.dart';
import '../../widgets/buttons.dart';
import '../../widgets/snackbar.dart';
import '/api/auth.dart';

class EnterPhoneScreen extends StatefulWidget {
  static const routeName = '/enter-phone';

  final String? prevRouteName;

  const EnterPhoneScreen({this.prevRouteName, Key? key}) : super(key: key);

  @override
  State<EnterPhoneScreen> createState() => _EnterPhoneScreenState();
}

class _EnterPhoneScreenState extends State<EnterPhoneScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController controller = TextEditingController();
  String? phoneNumber;
  String initialCountry = 'UA';
  PhoneNumber number = PhoneNumber(isoCode: 'UA');
  bool _isSendingPhone = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 24),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Text(
                  'auth.phone_verification'.tr(),
                  style: Theme.of(context).textTheme.headline4,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Text(
                    'auth.phone_help_text'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.black45),
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 410),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: InternationalPhoneNumberInput(
                    autoFocus: true,
                    errorMessage: '',
                    inputDecoration: InputDecoration(
                        hintText: 'auth.phone_number'.tr(),
                        hintStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.black38),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 3)),
                        errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                                color: AppColors.dangerousColor, width: 3)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.background,
                                width: 3)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.background,
                                width: 3))),
                    onInputChanged: (PhoneNumber currentNumber) {
                      number = currentNumber;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        showSnackbarMessage("auth.phone_invalid_number".tr());
                        return '';
                      }
                      return null;
                    },
                    textStyle:
                        const TextStyle(fontSize: 24, letterSpacing: 1.5),
                    selectorTextStyle: const TextStyle(fontSize: 20),
                    selectorConfig: const SelectorConfig(
                      setSelectorButtonAsPrefixIcon: true,
                      leadingPadding: 20,
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    initialValue: number,
                    formatInput: false,
                    textFieldController: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                  ),
                ),
                _isSendingPhone
                    ? const MainButton(
                        isWaitingButton: true, mHorizontalInset: 30)
                    : MainButton(
                        text: 'auth.phone_get_code'.tr(),
                        onButtonPress: () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          formKey.currentState!.save();

                          setState(() {
                            _isSendingPhone = true;
                          });
                          if (number.phoneNumber != null) {
                            try {
                              var wasSent = true;
                              if (!debugServer) {
                                wasSent = await AuthApi.createOtp(
                                    number.phoneNumber ?? "");
                              }
                              phoneNumber = number.phoneNumber;
                              if (!mounted) return;
                              if (wasSent) {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EnterOtpScreen(
                                            phoneNumber: phoneNumber ?? '',
                                            prevRouteName:
                                                widget.prevRouteName)));
                                setState(() {
                                  phoneNumber = null;
                                  controller.text = '';
                                });
                              } else {
                                showSnackbarMessage("auth.phone_not_sent".tr());
                              }
                            } catch (e) {
                              showSnackbarMessage("auth.phone_not_sent".tr());
                            }
                          }
                          setState(() {
                            _isSendingPhone = false;
                          });
                        },
                        mHorizontalInset: 30,
                      ),
                const SizedBox(height: 40)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSnackbarMessage(String text, {IconData? icon}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(buildSnackBar(text, icon: icon));
  }
}
