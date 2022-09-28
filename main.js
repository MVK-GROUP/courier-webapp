function openLiqpay(data, signature, isBlank) {
    var mapForm = document.createElement("form");
    if (isBlank) {
        mapForm.target = "_blank"
    }
    mapForm.method = "POST";
    mapForm.action = "https://www.liqpay.ua/api/3/checkout";

    var dataInput = document.createElement("input");
    dataInput.type = "text";
    dataInput.name = "data";
    dataInput.value = data;
    mapForm.appendChild(dataInput);

    var signatureInput = document.createElement("input");
    signatureInput.type = "text";
    signatureInput.name = "signature";
    signatureInput.value = signature;
    mapForm.appendChild(signatureInput);

    document.body.appendChild(mapForm);
    mapForm.submit();
}