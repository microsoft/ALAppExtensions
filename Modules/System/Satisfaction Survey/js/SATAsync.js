function SendRequest(Url, Timeout) {
    var request = new XMLHttpRequest();
    try {
        validateParams(Url, Timeout);
        request.timeout = Timeout;
        request.onreadystatechange = responseHandler;
        request.open("GET", Url, true);
        request.send(null);
    }
    catch (ex) {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ResponseReceived', [0, 'Send request failure: ' + ex]);
    }

    function responseHandler() {
        if (request.readyState == 4) {
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ResponseReceived', [request.status, request.responseText.substring(0, 250)]);
        }
    }

    function validateParams(Url, Timeout) {
        if (!Url || !Url.startsWith('https://') || Timeout <= 0 || Timeout > 60000) {
            throw 'Unexpected parameter';
        }
    }
}

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlAddInInReady');
