import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:admin_app/api/orders.dart';
import 'package:admin_app/models/order.dart';
import 'package:admin_app/providers/auth.dart';
import 'package:admin_app/providers/orders.dart';
import 'package:admin_app/screens/sceleton_screen.dart';
import 'package:admin_app/utilities/styles.dart';
import 'package:admin_app/widgets/button.dart';

import '../route/screen_export.dart';

class FeedbackScreen extends StatelessWidget {
  final OrderData? order;
  const FeedbackScreen({this.order, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return SkeletonScreen(
        title: "feedback.title".tr(),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: screenSize.width > 800 && screenSize.height > 600
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color.fromARGB(255, 226, 223, 217),
                    )
                  : null,
              child: FeedbackForm(order: order),
            ),
          ),
        ));
  }
}

class DropdownOrderItem {
  final int id;
  final String title;
  const DropdownOrderItem(this.id, this.title);

  @override
  bool operator ==(Object other) =>
      other is DropdownOrderItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class FeedbackForm extends StatefulWidget {
  final OrderData? order;
  const FeedbackForm({Key? key, this.order}) : super(key: key);

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  String _communicateMethod = 'email';
  late DropdownOrderItem _currentOrder;

  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _messageController;

  final _formKey = GlobalKey<FormState>();

  late FocusNode _emailFocus;
  late FocusNode _problemOrderFocus;
  late FocusNode _phoneFocus;
  late FocusNode _messageFocus;

  bool _emailIsNotValid = false;
  bool _phoneIsNotValid = false;
  bool _isSending = false;

  List<DropdownOrderItem> get dropdownOrderItems {
    List<DropdownOrderItem> items = [];
    items.add(DropdownOrderItem(0, "feedback.no_order".tr()));
    var allOrders =
        Provider.of<OrdersNotifier>(context, listen: false).allOrders;
    items.addAll(
      allOrders.map(
        (order) => DropdownOrderItem(
          order.id,
          getDropdownItemTitle(order),
        ),
      ),
    );
    return items;
  }

  String getDropdownItemTitle(OrderData orderData) {
    final orderId = orderData.id.toString();
    final created = orderData.humanDate;
    return '${'history.order_number'.tr(namedArgs: {
          "id": orderId
        })} [$created]';
  }

  @override
  void initState() {
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _messageController = TextEditingController();
    _emailFocus = FocusNode();
    _problemOrderFocus = FocusNode();
    _phoneFocus = FocusNode();
    _messageFocus = FocusNode();

    _currentOrder = widget.order != null
        ? DropdownOrderItem(
            widget.order!.id,
            getDropdownItemTitle(widget.order!),
          )
        : DropdownOrderItem(0, "feedback.no_order".tr());
    Future.delayed(Duration.zero, () {
      _phoneController.text =
          Provider.of<Auth>(context, listen: false).phone ?? '';
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    _emailFocus.dispose();
    _problemOrderFocus.dispose();
    _phoneFocus.dispose();
    _messageFocus.dispose();
    super.dispose();
  }

  void _fieldFocusChange(FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void _fieldFocusSet(FocusNode nextFocus) {
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 20.0, bottom: 10, left: 10, right: 10),
          child: ElevatedButton.icon(
            icon: const Icon(
              Icons.send,
              size: 16,
            ),
            onPressed: () {
              final url = Uri.https('t.me', 'technicalsupportmvk');
              launchUrl(url);
            },
            style: ElevatedButton.styleFrom(
              primary: AppColors.secondaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            label: Text(
              'feedback.contact_in_tg'.tr(),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        Text('feedback.or_fill_in_form'.tr()),
        Form(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "feedback.how_to_contact".tr(),
                    style: ThemeData().textTheme.headline3,
                  ),
                ),
              ),
              Opacity(
                opacity: _communicateMethod == 'email' ? 1.0 : 0.5,
                child: RadioOption(
                  text: 'feedback.email'.tr(),
                  value: 'email',
                  textField: TextFormField(
                    focusNode: _emailFocus,
                    onFieldSubmitted: (_) =>
                        _fieldFocusChange(_emailFocus, _problemOrderFocus),
                    onChanged: (value) {
                      if (_emailIsNotValid) {
                        setState(() {
                          _emailIsNotValid = !_emailIsNotValid;
                        });
                      }
                    },
                    readOnly: _communicateMethod != 'email',
                    controller: _emailController,
                    decoration: textFieldInputDecoration(
                        isError: _emailIsNotValid,
                        hintText: 'feedback.email_placeholder'.tr()),
                    autofillHints: const [AutofillHints.email],
                  ),
                  onChange: onChange,
                  groupValue: _communicateMethod,
                ),
              ),
              Opacity(
                opacity: _communicateMethod == 'call' ? 1.0 : 0.5,
                child: RadioOption(
                  text: 'feedback.phone'.tr(),
                  value: 'call',
                  textField: TextFormField(
                    focusNode: _phoneFocus,
                    onFieldSubmitted: (_) =>
                        _fieldFocusChange(_phoneFocus, _problemOrderFocus),
                    readOnly: _communicateMethod != 'call',
                    controller: _phoneController,
                    onChanged: (value) {
                      if (_phoneIsNotValid) {
                        setState(() {
                          _phoneIsNotValid = !_phoneIsNotValid;
                        });
                      }
                    },
                    decoration: textFieldInputDecoration(
                        isError: _phoneIsNotValid,
                        hintText: "feedback.phone_placeholder".tr()),
                  ),
                  onChange: onChange,
                  groupValue: _communicateMethod,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "feedback.select_problem_order".tr(),
                    style: ThemeData().textTheme.headline3,
                  ),
                ),
              ),
              ProblemOrderSelect(
                initItem: _currentOrder,
                focusNode: _problemOrderFocus,
                values: dropdownOrderItems,
                onChange: (DropdownOrderItem? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _currentOrder = newValue;
                    });
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "feedback.message".tr(),
                    style: ThemeData().textTheme.headline3,
                  ),
                ),
              ),
              TextFormField(
                maxLines: 3,
                focusNode: _messageFocus,
                controller: _messageController,
                decoration: textFieldInputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    hintText: "feedback.message_placeholder".tr()),
              ),
              const SizedBox(height: 20),
              ElevatedDefaultButton(
                onPressed: _isSending ? () {} : sendFeedback,
                child: _isSending
                    ? Container(
                        padding: const EdgeInsets.all(5),
                        width: 26,
                        height: 26,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ))
                    : Text(
                        'feedback.send'.tr(),
                        style: const TextStyle(fontSize: 20),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  void sendFeedback() async {
    String? isNotValidMessage;
    String? communicateMethodValue;
    switch (_communicateMethod) {
      case 'email':
        bool emailValid = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(_emailController.text);
        if (_emailController.text.isEmpty || !emailValid) {
          setState(() => _emailIsNotValid = true);
          isNotValidMessage = 'feedback.email_is_not_valid'.tr();
        }
        communicateMethodValue = _emailController.text;
        break;
      case 'call':
        if (_phoneController.text.length < 5) {
          setState(() => _phoneIsNotValid = true);
          isNotValidMessage = 'feedback.phone_is_not_valid'.tr();
        }
        communicateMethodValue = _phoneController.text;
        break;
      default:
        return;
    }

    if (isNotValidMessage != null) {
      showSnackbarMessage(isNotValidMessage);
      return;
    }

    Map<String, Object> data = {
      'type': _communicateMethod,
      'value': communicateMethodValue,
      'message': _messageController.text,
    };
    if (_currentOrder.id != 0) {
      data['order_id'] = _currentOrder.id;
    }
    setState(() => _isSending = true);
    final token = Provider.of<Auth>(context, listen: false).token;
    try {
      await OrderApi.sendProblemReport(data, token);
      showSnackbarMessage("feedback.message_sent".tr());
    } catch (e) {
      showSnackbarMessage("feedback.message_not_sent".tr());
    }

    setState(() => _isSending = false);

    if (mounted) {
      widget.order != null
          ? Navigator.pushNamed(context, menuRoute)
          : Navigator.pop(context);
    }
  }

  void showSnackbarMessage(String text, {IconData? icon}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(buildSnackBar(text, icon: icon));
  }

  SnackBar buildSnackBar(String text, {IconData? icon}) {
    return SnackBar(
      backgroundColor: AppColors.secondaryColor,
      content: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void onChange(String? value) {
    setState(() {
      _communicateMethod = value!;
    });
  }

  InputDecoration textFieldInputDecoration({
    String hintText = "",
    contentPadding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    isError = false,
  }) {
    return InputDecoration(
        contentPadding: contentPadding,
        fillColor: Colors.white,
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              width: 2.0, color: Theme.of(context).colorScheme.background),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              width: 0.0, color: isError ? Colors.red : Colors.transparent),
        ),
        hoverColor: Colors.white);
  }
}

class RadioOption extends StatelessWidget {
  final String text;
  final String groupValue;
  final String value;
  final Function(String?)? onChange;
  final Widget? textField;
  const RadioOption(
      {required this.text,
      this.textField,
      required this.value,
      this.onChange,
      required this.groupValue,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      horizontalTitleGap: 5,
      title: Row(
        children: [
          Text(text),
          const SizedBox(width: 15),
          Expanded(
            child: Material(
              elevation: 10,
              shadowColor: const Color(0x10A7B0C0),
              borderRadius: BorderRadius.circular(16),
              child: textField,
            ),
          ),
        ],
      ),
      leading: Radio(
        value: value,
        groupValue: groupValue,
        activeColor: const Color(0xFF6200EE),
        onChanged: onChange,
      ),
    );
  }
}

class ProblemOrderSelect extends StatelessWidget {
  final DropdownOrderItem initItem;
  final List<DropdownOrderItem> values;
  final Function(DropdownOrderItem?) onChange;
  final FocusNode? focusNode;
  const ProblemOrderSelect({
    required this.initItem,
    required this.values,
    required this.onChange,
    this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DropdownOrderItem>(
      focusColor: Colors.transparent,
      focusNode: focusNode,
      decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          fillColor: Colors.white,
          filled: true,
          hintStyle: const TextStyle(color: Colors.grey),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
                width: 2.0, color: Theme.of(context).colorScheme.background),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(width: 0.0, color: Colors.transparent),
          ),
          hoverColor: Colors.white),
      value: initItem,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      elevation: 16,
      isExpanded: true,
      onChanged: (DropdownOrderItem? newValue) => onChange(newValue),
      items: values
          .map<DropdownMenuItem<DropdownOrderItem>>((DropdownOrderItem value) {
        return DropdownMenuItem<DropdownOrderItem>(
          value: value,
          child: Text(value.title),
        );
      }).toList(),
    );
  }
}
