import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../api/lockers.dart';
import '../utilities/styles.dart';
import 'services/acl.dart';
import 'services/delivery.dart';

enum ServiceCategory {
  powerbank,
  phoneCharging,
  acl,
  delivery,
  unknown,
}

extension ServiceCategoryExt on ServiceCategory {
  static ServiceCategory fromString(String? value) {
    if (value == "acl") {
      return ServiceCategory.acl;
    } else if (value == "powerbank") {
      return ServiceCategory.powerbank;
    } else if (value == "delivery") {
      return ServiceCategory.delivery;
    }
    return ServiceCategory.unknown;
  }

  static String typeToString(ServiceCategory value) {
    if (value == ServiceCategory.acl) {
      return "acl";
    } else if (value == ServiceCategory.powerbank) {
      return "powerbank";
    } else if (value == ServiceCategory.phoneCharging) {
      return "phone_charge";
    } else if (value == ServiceCategory.delivery) {
      return "delivery";
    }
    return "unknown";
  }
}

enum TariffSelectionType {
  tariffSelection,
  setTime,
  quick,
  unknown,
}

extension TariffSelectionTypeExt on TariffSelectionType {
  static TariffSelectionType fromString(String? value) {
    if (value == "tariff_selection") {
      return TariffSelectionType.tariffSelection;
    } else if (value == "set_time") {
      return TariffSelectionType.setTime;
    } else if (value == "quick") {
      return TariffSelectionType.quick;
    }
    return TariffSelectionType.unknown;
  }
}

enum AlgorithmType {
  qrReading,
  enterPinOnComplex,
  selfService,
  selfPlusQr,
  selfPlusPin,
  unknown,
}

extension AlgorithmTypeExt on AlgorithmType {
  static AlgorithmType fromString(String? value) {
    if (value == "qr_reading") {
      return AlgorithmType.qrReading;
    } else if (value == "enter_pin") {
      return AlgorithmType.enterPinOnComplex;
    } else if (value == "self_service") {
      return AlgorithmType.selfService;
    } else if (value == "self_plus_qr") {
      return AlgorithmType.selfPlusQr;
    } else if (value == "self_plus_enter_pin") {
      return AlgorithmType.selfPlusPin;
    }
    return AlgorithmType.unknown;
  }

  static String toStr(AlgorithmType algorithm) {
    if (algorithm == AlgorithmType.qrReading) {
      return "qr_reading";
    } else if (algorithm == AlgorithmType.enterPinOnComplex) {
      return "enter_pin";
    } else if (algorithm == AlgorithmType.selfService) {
      return "self_service";
    } else if (algorithm == AlgorithmType.selfPlusQr) {
      return "self_plus_qr";
    } else if (algorithm == AlgorithmType.selfPlusPin) {
      return "self_plus_enter_pin";
    }
    return "unknown";
  }
}

class Service {
  final String serviceId;
  final ServiceCategory category;
  final String title;
  final String? imageUrl;
  final Color color;
  final String action;
  final Map<String, Object> data;

  Service(
      {required this.serviceId,
      required this.title,
      this.imageUrl,
      this.color = AppColors.mainColor,
      this.action = "Unknown",
      this.category = ServiceCategory.unknown,
      this.data = const {}});

  factory Service.fromJson(Map<String, dynamic> json, {required String lang}) {
    var serviceCategory = ServiceCategoryExt.fromString(json["service"]);
    Map<String, Object> data = {};

    String title;
    String action;
    switch (serviceCategory) {
      case ServiceCategory.acl:
        title = "acl.service_acl_title".tr();
        action = "acl.service_acl_action".tr();

        data["algorithm"] = AlgorithmTypeExt.fromString(json["algorithm"]);
        data["tariff_selection_type"] =
            TariffSelectionTypeExt.fromString(json["tariff_selection_type"]);
        List<ACLCellType> cellTypes = [];

        if (json.containsKey("cell_types")) {
          for (var element in (json["cell_types"] as List<dynamic>)) {
            cellTypes.add(ACLCellType.fromJson(element, lang: lang));
          }
        }
        data["cell_types"] = cellTypes;
        break;
      case ServiceCategory.phoneCharging:
        title = "acl.service_phonecharge".tr();
        action = "acl.service_phonecharge_action".tr();
        break;
      case ServiceCategory.powerbank:
        title = "acl.service_powerbank".tr();
        action = "acl.service_powerbank_action".tr();
        break;
      case ServiceCategory.delivery:
        title = "delivery.service_title".tr();
        action = "delivery.service_action".tr();
        List<DeliveryCellType> cellTypes = [];
        if (json.containsKey("cell_types")) {
          for (var element in (json["cell_types"] as List<dynamic>)) {
            cellTypes.add(DeliveryCellType.fromJson(element, lang: lang));
          }
        }
        data["cell_types"] = cellTypes;
        break;
      default:
        title = "unknown".tr();
        action = title;
    }
    var color = AppColors.secondaryColor;
    if (json.containsKey("color")) {
      var colorValue = int.tryParse('0xFF${json['color']}');
      if (colorValue != null) {
        color = Color(colorValue);
      }
    }

    return Service(
      serviceId: json["service_id"],
      category: serviceCategory,
      title: title,
      action: action,
      color: color,
      data: data,
    );
  }
}

class ServiceNotifier with ChangeNotifier {
  Service? _currentService;

  void setService(Service service) {
    _currentService = service;
    notifyListeners();
  }

  Service? get service {
    return _currentService;
  }

  bool get isContainService {
    return _currentService != null;
  }
}

enum LockerType {
  free,
  paid,
  hub,
}

extension LockerTypeExt on LockerType {
  static LockerType getByString(String value) {
    if (value == "paid") {
      return LockerType.paid;
    } else if (value == "hub") {
      return LockerType.hub;
    }
    return LockerType.free;
  }

  static String typeToString(LockerType value) {
    if (value == LockerType.paid) {
      return "paid";
    } else if (value == LockerType.hub) {
      return "hub";
    }
    return "free";
  }
}

enum LockerStatus {
  ok,
  cannotConnect,
  unknown,
}

extension LockerStatusExt on LockerStatus {
  static LockerStatus getByString(String value) {
    if (value == "ok") {
      return LockerStatus.ok;
    } else if (value == "cannot_connect") {
      return LockerStatus.cannotConnect;
    }
    return LockerStatus.unknown;
  }
}

class Locker {
  final int lockerId;
  final String name;
  final String? address;
  final double? latitude;
  final double? longtitude;
  final String? description;
  final LockerStatus status;
  final LockerType type;
  final String? imageUrl;
  final List<Service> services = [];

  Locker({
    required this.lockerId,
    required this.name,
    required this.type,
    this.status = LockerStatus.unknown,
    this.imageUrl,
    this.address,
    this.latitude,
    this.longtitude,
    this.description,
  });

  void addService(Service service) {
    services.add(service);
  }

  String get fullLockerName {
    if (name.isNotEmpty && address != null) {
      return "$name, $address";
    }
    return address ?? name;
  }

  factory Locker.fromJson(Map<String, dynamic> json, {required String lang}) {
    var locker = Locker(
      lockerId: json["lockerID"],
      name: json["name"],
      description: json["description"],
      address: json["address"],
      latitude: json["latitude"],
      longtitude: json["longitude"],
      type: LockerTypeExt.getByString(
        json["type"],
      ),
      status: LockerStatusExt.getByString(
        json["status"],
      ),
      imageUrl: json["image"],
    );

    if (json.containsKey("services")) {
      var services = json["services"] as List<dynamic>;
      for (Map<String, dynamic> service in services) {
        locker.addService(Service.fromJson(service, lang: lang));
      }
    }

    return locker;
  }
}

class LockerNotifier with ChangeNotifier {
  Locker? _currenctLocker;
  String? authToken;
  String lang;

  LockerNotifier(this._currenctLocker, this.authToken, {this.lang = "en"});

  Locker? get locker {
    return _currenctLocker;
  }

  Future<Locker?> setLocker(String? id) async {
    if (id == null) {
      _currenctLocker = null;
      notifyListeners();
      return null;
    } else {
      try {
        _currenctLocker =
            await LockerApi.fetchLockerById(id, authToken, lang: lang);
        notifyListeners();
        return _currenctLocker;
      } catch (e) {
        _currenctLocker = null;
        rethrow;
      }
    }
  }

  Future<Locker?> setLockerByOrderId(int orderId) async {
    try {
      _currenctLocker =
          await LockerApi.fetchLockerByOrderId(orderId, authToken, lang: lang);
      notifyListeners();
      return _currenctLocker;
    } catch (e) {
      _currenctLocker = null;
      notifyListeners();
      rethrow;
    }
  }

  void resetLocker() {
    _currenctLocker = null;
    notifyListeners();
  }

  void setExistingLocker(Locker? locker) {
    _currenctLocker = locker;
    notifyListeners();
  }
}

class CellStatus {
  final String cellId;
  final String status;
  final String typeId;
  final String cellNumber;

  const CellStatus(this.cellId, this.status, this.typeId, this.cellNumber);

  factory CellStatus.fromJson(Map<String, dynamic> json) {
    String cellNumber =
        json.containsKey('number') ? json['number'] : json["id"];
    return CellStatus(json["id"], json["status"], json["type"], cellNumber);
  }

  bool isThisTypeId(String otherTypeId) {
    return otherTypeId == typeId;
  }
}
