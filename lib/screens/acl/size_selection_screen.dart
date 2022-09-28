import 'package:admin_app/models/services/delivery.dart';
import 'package:admin_app/screens/delivery/fill_in_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_app/route/route_constants.dart';
import 'package:admin_app/screens/sceleton_screen.dart';
import 'package:admin_app/widgets/cards/cell_size_card.dart';

import '../../api/http_exceptions.dart';
import '../../api/orders.dart';
import '../../api/lockers.dart';
import '../../providers/auth.dart';
import '../../providers/orders.dart';
import '../../utilities/styles.dart';
import '../../models/lockers.dart';
import '../../models/services/acl.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/tariff_dialog.dart';
import '../../widgets/sww_dialog.dart';

class SizeSelectionScreen extends StatefulWidget {
  const SizeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<SizeSelectionScreen> createState() => _SizeSelectionScreenState();
}

class _SizeSelectionScreenState extends State<SizeSelectionScreen> {
  late Service? currentService;
  String? token;
  late Locker? locker;
  late Future _getFreeCellsFuture;
  var isInit = false;

  Future<List<CellStatus>?> _obtainGetFreeCellsFuture() async {
    token = Provider.of<Auth>(context, listen: false).token;
    currentService =
        Provider.of<ServiceNotifier>(context, listen: false).service;
    locker = Provider.of<LockerNotifier>(context, listen: false).locker;

    try {
      final freeCells = await LockerApi.getFreeCells(locker?.lockerId ?? 0,
          service: ServiceCategoryExt.typeToString(currentService!.category),
          token: token);
      if (freeCells.isEmpty) {
        showDialog(
          context: context,
          builder: (ctx) => SomethingWentWrongDialog(
            title: "acl.no_free_cells".tr(),
            bodyMessage: "acl.no_free_cells_detail".tr(),
          ),
        ).then((value) => Navigator.pushNamed(context, menuRoute));

        return null;
      }
      return freeCells;
    } catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => SomethingWentWrongDialog(
          title: "acl.no_free_cells".tr(),
          bodyMessage: "acl.technical_error".tr(),
        ),
      ).then((value) => Navigator.pushNamed(context, menuRoute));
      return null;
    }
  }

  @override
  void initState() {
    _getFreeCellsFuture = _obtainGetFreeCellsFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SkeletonScreen(
      title: 'acl.select_size'.tr(),
      body: FutureBuilder(
        future: _getFreeCellsFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "history.cant_display_orders".tr(),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else {
              final cellStatuses = dataSnapshot.data as List<CellStatus>?;
              if (cellStatuses == null || cellStatuses.isEmpty) {
                return const Center();
              } else {
                List cellTypes = currentService?.data["cell_types"] as dynamic;
                return Center(
                  child: SingleChildScrollView(
                    child: _buildCellSizes(cellTypes, cellStatuses),
                  ),
                );
              }
            }
          }
        },
      ),
    );
  }

  Widget _buildCellSizes(
    List cellTypes,
    List<CellStatus> cellStatuses,
  ) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 30),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 60,
        runSpacing: 40,
        children: cellTypes.map((cellType) {
          final index = cellStatuses.indexWhere(
              (element) => element.isThisTypeId(cellType.id.toString()));
          final cellSizeCard = CellSizeCard(
            title: cellType.title,
            symbol: cellType.symbol,
          );
          if (index < 0) {
            return Opacity(opacity: 0.5, child: cellSizeCard);
          } else {
            return GestureDetector(
              onTap: () {
                if (currentService!.category == ServiceCategory.delivery) {
                  deliveryNextStep(cellType);
                }
              },
              child: cellSizeCard,
            );
          }
        }).toList(),
      ),
    );
  }

  void deliveryNextStep(DeliveryCellType cellType) async {
    try {
      final category =
          ServiceCategoryExt.typeToString(currentService!.category);
      final res = await LockerApi.getFreeCells(locker?.lockerId ?? 0,
          service: category, typeId: cellType.id, token: token);
      if (res.isEmpty) {
        await showDialog(
            context: context,
            builder: (ctx) => SomethingWentWrongDialog(
                  title: "acl.no_free_cells".tr(),
                  bodyMessage: "acl.no_free_cells__select_another_size".tr(),
                ));
        return;
      } else {
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) =>
                      DeliveryFillInDataScreen(cellType, res.first)));
        }
        return;
      }
    } catch (e) {
      if (e is HttpException) {
        if (e.statusCode == 400) {
          await showDialog(
              context: context,
              builder: (ctx) => SomethingWentWrongDialog(
                    bodyMessage: "complex_offline".tr(),
                  ));
          return;
        }
      }
      await showDialog(
          context: context, builder: (ctx) => const SomethingWentWrongDialog());
      return;
    }
  }
}
