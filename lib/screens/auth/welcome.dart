import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:admin_app/screens/auth/enter_phone.dart';

import '../../utilities/locales.dart';
import '../../utilities/styles.dart';
import '../../widgets/buttons.dart';
import '../../widgets/image_banner.dart';
import '../sceleton_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final String? prevRouteName;

  const WelcomeScreen({this.prevRouteName, Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late LocaleObject currentLocale;
  bool _isInit = false;
  bool _isCheck = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      currentLocale =
          SupportedLocales.getLocaleByCode(context.locale.languageCode);
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            child: Column(
              children: [
                const SizedBox(height: 30),
                SizedBox(
                  width: 300,
                  height: 45,
                  child: Image.asset('assets/logos/mvk.png'),
                ),
                const SizedBox(height: 20),
                const Spacer(),
                const ImageBanner(
                  'assets/images/welcome.png',
                  imageFit: BoxFit.fitHeight,
                  hConstraint: 180,
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    'auth.welcome_title'.tr(),
                    style: Theme.of(context).textTheme.headline6,
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.public,
                        color: AppColors.mainColor,
                        size: 32,
                      ),
                      const SizedBox(width: 20),
                      LanguageDropDownWidget(
                          locale: currentLocale,
                          selectedLocale: (LocaleObject? localeObject) =>
                              changeLocale(context, localeObject)),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: userAgreementWidget(),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: MainButton(
                    text: 'auth.welcome_start'.tr(),
                    icon: Icons.arrow_right_alt,
                    iconLocation: IconLocation.right,
                    onButtonPress: _isCheck
                        ? () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EnterPhoneScreen(
                                        prevRouteName: widget.prevRouteName)));
                          }
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            )),
      )
    ]));
  }

  void changeLocale(BuildContext context, LocaleObject? localeObject) async {
    if (localeObject != null) {
      setState(() {
        currentLocale = localeObject;
      });
      await context.setLocale(localeObject.locale);
    }
  }

  Row userAgreementWidget() {
    return Row(
      children: [
        Checkbox(
            activeColor: AppColors.mainColor,
            value: _isCheck,
            onChanged: (value) {
              setState(() {
                _isCheck = value ?? false;
              });
            }),
        const SizedBox(width: 10),
        Flexible(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black45),
              children: [
                TextSpan(text: 'auth.user_agreement_part1'.tr()),
                TextSpan(
                  text: 'auth.user_agreement_part2'.tr(),
                  style: const TextStyle(
                      color: AppColors.mainColor, fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      String userAgreementText;
                      try {
                        userAgreementText = await rootBundle.loadString(
                            'assets/user_agreement/${context.locale.languageCode}.md');
                      } catch (e) {
                        userAgreementText = await rootBundle
                            .loadString('assets/user_agreement/en.md');
                      }
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SkeletonScreen(
                              title: 'auth.user_agreement_title'.tr(),
                              body: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                child: Markdown(data: userAgreementText),
                              ),
                            );
                          },
                        ),
                      );
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LanguageDropDownWidget extends StatelessWidget {
  final LocaleObject locale;
  final Function selectedLocale;

  const LanguageDropDownWidget(
      {required this.locale, required this.selectedLocale, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<LocaleObject>(
      value: locale,
      icon: const Icon(Icons.keyboard_arrow_down),
      elevation: 4,
      underline: null,
      style: const TextStyle(
          color: AppColors.mainColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.8),
      focusColor: Colors.white,
      onChanged: (LocaleObject? newValue) => selectedLocale(newValue),
      items: SupportedLocales.lockaleObjects.map((LocaleObject value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value.title),
        );
      }).toList(),
    );
  }
}
