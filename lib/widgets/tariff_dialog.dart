import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../models/services/acl.dart';
import '../utilities/styles.dart';

class TariffDialog extends StatelessWidget {
  final ACLCellType cellType;

  const TariffDialog(this.cellType, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(
              maxWidth: 400, minHeight: 300, maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: IconButton(
                        iconSize: 32,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close))),
              ),
              Text(
                "create_order.select_tariff".tr(),
                style: AppStyles.titleSecondaryTextStyle
                    .copyWith(color: AppColors.secondaryColor),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  cellType.title,
                  style: AppStyles.subtitleTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: cellType.tariff
                      .map((e) => Container(
                            height: 70,
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, e);
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    primary: AppColors.secondaryColor),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Spacer(),
                                    if (width > 380)
                                      const Icon(Icons.lock_clock, size: 24),
                                    const SizedBox(width: 5),
                                    Text(
                                      e.humanHours,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (width > 340)
                                      const Icon(Icons.attach_money, size: 24),
                                    Text(
                                      e.priceWithCurrency(cellType.currency),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const Spacer(),
                                  ],
                                )),
                          ))
                      .toList(),
                ),
              )),
            ],
          ),
        ));
  }
}
