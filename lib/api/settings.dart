import "package:flutter/foundation.dart" show kDebugMode;

const debugServer = kDebugMode && true;
const domain =
    debugServer ? "http://localhost:8000" : "https://lockershub.online";
