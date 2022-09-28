import 'package:admin_app/models/lockers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

import '../../models/services/delivery.dart';
import '../../providers/orders.dart';
import '../../route/route_constants.dart';
import '../../utilities/styles.dart';
import '../../widgets/buttons.dart';
import '../../widgets/snackbar.dart';
import '../sceleton_screen.dart';

class DeliveryFillInDataScreen extends StatefulWidget {
  final DeliveryCellType cellType;
  final CellStatus cellData;
  const DeliveryFillInDataScreen(this.cellType, this.cellData, {super.key});

  @override
  State<DeliveryFillInDataScreen> createState() =>
      _DeliveryFillInDataScreenState();
}

class _DeliveryFillInDataScreenState extends State<DeliveryFillInDataScreen> {
  bool _isPOD = false;
  PhoneNumber number = PhoneNumber(isoCode: 'UA');
  bool _isOrderCreated = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late Locker? locker;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      locker = Provider.of<LockerNotifier>(context, listen: false).locker;
      print("locker: $locker");
      _isInit = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SkeletonScreen(
      title: 'delivery.fill_in'.tr(),
      body: Center(
        child: Column(
          children: [
            titleWidget(widget.cellData.cellNumber),
            isPODWidget(),
            phoneWidget(),
            const SizedBox(height: 30),
            _isOrderCreated
                ? const MainButton(isWaitingButton: true, mHorizontalInset: 30)
                : MainButton(
                    text: 'delivery.create_order'.tr(),
                    onButtonPress: createDeliveryOrder,
                    mHorizontalInset: 30,
                  ),
          ],
        ),
      ),
    );
  }

  void createDeliveryOrder() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();

    setState(() {
      _isOrderCreated = true;
    });

    Map<String, Object> extraData = {};
    String service = ServiceCategoryExt.typeToString(ServiceCategory.delivery);
    extraData["is_pod"] = _isPOD;
    extraData["time"] = widget.cellType.tariff!.seconds;
    extraData["paid"] = widget.cellType.tariff!.priceInCoins;
    extraData["service"] = service;
    extraData["cell_id"] = widget.cellData.cellId;
    extraData["cell_number"] = widget.cellData.cellNumber;
    if (widget.cellType.overduePayment != null) {
      extraData["overdue_payment"] = {
        "time": widget.cellType.overduePayment!.seconds,
        "price": widget.cellType.overduePayment!.priceInCoins,
      };
    }

    var helperText = "create_order.order_created_with_cell_N"
        .tr(namedArgs: {"cell": widget.cellData.cellNumber.padLeft(2, '0')});
    helperText += ' ${"create_order.contain_all_needed_info".tr()}';

    try {
      final orderData =
          await Provider.of<OrdersNotifier>(context, listen: false).addOrder(
              locker!.lockerId, "delivery.service_title".tr(),
              data: extraData,
              lang: context.locale.languageCode,
              service: service,
              customerPhone: number.phoneNumber ?? "");
      if (mounted) {
        Navigator.pushNamed(context, successOrderRoute,
            arguments: {"order": orderData, "title": helperText});
      }
    } catch (e) {
      await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              content: Text("ERROR: $e"),
            );
          });
    }
    setState(() {
      _isOrderCreated = false;
    });
  }

  Widget titleWidget(String cell) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
      child: Text(
        'delivery.info'.tr(
          namedArgs: {'cell': cell},
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
        ),
      ),
    );
  }

  Widget phoneWidget() {
    return Form(
      key: formKey,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 410),
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: InternationalPhoneNumberInput(
          autoFocus: true,
          errorMessage: '',
          inputDecoration: InputDecoration(
              hintText: 'delivery.phone_number'.tr(),
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
          textStyle: const TextStyle(fontSize: 24, letterSpacing: 1.5),
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
          keyboardType: const TextInputType.numberWithOptions(
              signed: true, decimal: true),
        ),
      ),
    );
  }

  Widget pointWidget(String text) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        constraints: const BoxConstraints(maxWidth: 410),
        child: Text(text));
  }

  Widget isPODWidget() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 410),
      child: CheckboxListTile(
        title: Text('delivery.pay_on_delivery'.tr()),
        value: _isPOD,
        onChanged: (newValue) {
          setState(() {
            if (newValue != null) {
              _isPOD = newValue;
            }
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  void showSnackbarMessage(String text, {IconData? icon}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(buildSnackBar(text, icon: icon));
  }
}
