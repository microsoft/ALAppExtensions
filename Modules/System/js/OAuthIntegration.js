/*
This addin communicates with OAuthLanding.htm using localStorage. The keys used in the localStorage must be the same in both the files.
*/
var AuthStatusKey = "NavOauthStatus";
var RegistrationStatusKey = "NavRegistrationStatus";

function StartAuthorization(url) {

    OauthLandingHelper(url, AuthStatusKey, handler);

    function handler(data) {
        if (data.code) {
            notifySuccess(data.code);
        } else if (data.error) {
            notifyError(data.error, data.desc);
        }
    }

    function notifySuccess(code) {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AuthorizationCodeRetrieved', [code]);
    }

    function notifyError(error, desc) {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AuthorizationErrorOccurred', [error, desc]);
    }
}

function Authorize(url, linkName, linkTooltip) {
    var a = createHyperlink(url, linkName, linkTooltip);

    a.onclick = function () {
        StartAuthorization(url);
    }
}

function RegisterApp(url, linkName, linkTooltip) {
    var a = createHyperlink(url, linkName, linkTooltip);

    a.onclick = function () {
        if (!isFeatureSupported()) {
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AppRegistrationErrorOccurred', ['NotSupported', '']);
            return;
        }

        OauthLandingHelper(url, RegistrationStatusKey, handler);
    }

    function isFeatureSupported() {
        var isSupported = false;
        switch (Microsoft.Dynamics.NAV.GetEnvironment().Platform) {
            case 0: // windows
            case 1: // web
                switch (Microsoft.Dynamics.NAV.GetEnvironment().DeviceCategory) {
                    case 0: // desktop
                    case 1: // tablet
                        isSupported = true;
                }
        }
        return isSupported;
    }

    function handler(data) {
        if (data.clientId && data.clientSecret) {
            top.window.localStorage.setItem(RegistrationStatusKey, 'success');
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AppRegistrationInformationRetrieved', [data.clientId, data.clientSecret]);
        }
    }
}

function OauthLandingHelper(url, key, callback) {
    var w = top.window;
    var aadWindow = w.open(url, '_blank', 'width=972,height=904,location=no');

    if (aadWindow == null || aadWindow.closed || typeof aadWindow.closed === "undefined") {
        callback({
            error: "Popup blocked",
            desc: "There was a problem opening the authentication prompt. Check if it was blocked by a popup blocker."
        });
        return;
    }

    function storageEvent(e) {
        if (e.key === key && e.newValue) {
            w.removeEventListener('storage', storageEvent, false);
            action(e.newValue);
        }
    }

    function messageEvent(e) {
        if (e.data.clientId) {
            w.removeEventListener("message", messageEvent, false);
            action(e.data);
        }
    }

    function action(data) {
        var obj = data;
        if (typeof data === 'string') {
            obj = JSON.parse(data);
        }
        callback(obj);
        closeWindow();
    }

    function closeWindow() {
        try {
            w.removeEventListener("message", messageEvent, false);
            w.removeEventListener('storage', storageEvent, false);

            try {
                if (aadWindow.onbeforeunload) {
                    aadWindow.onbeforeunload = null;
                }
            } catch (e) { }

            if (w.localStorage.getItem(key)) {
                w.localStorage.removeItem(key);
            }

            aadWindow.close();
        } catch (ex) { }
    }

    function isCordova(win) {
        if (typeof win !== 'undefined' && win) {
            try {
                // this can throw a 'Permission denied" exception in IE11
                if (win.executeScript) { // if cordova. Is there a better way to detect?
                    return true;
                }
            }
            catch (e) {
                return false;
            }
        }

        return false;
    }

    if (isCordova(aadWindow)) {
        aadWindow.addEventListener("loadstop", function () {
            function getDataFromWindow() {
                aadWindow.executeScript(
                    { code: "localStorage.getItem('" + AuthStatusKey + "');" },
                    function (data) {
                        if (data && data.length > 0 && data[0]) {
                            var value = data[0];
                            clearInterval(loop);
                            action(value);
                        }
                    }
                );
            };
            var loop = setInterval(getDataFromWindow, 1000);
        });
    } else {
        w.removeEventListener('storage', storageEvent, false);
        w.addEventListener('storage', storageEvent, false);
        w.removeEventListener('message', messageEvent, false);
        w.addEventListener("message", messageEvent, false);
    }
}

function createHyperlink(url, linkName, linkTooltip) {
    var a = document.createElement('a');
    var linkText = document.createTextNode(linkName);
    a.appendChild(linkText);
    a.title = linkTooltip;
    a.href = "#";
    a.className = getLinkClassName();

    document.getElementById('controlAddIn').appendChild(a);
    return a;
}

function getClassNameSuffix() {
    switch (Microsoft.Dynamics.NAV.GetEnvironment().Platform) {
        case 0:
        default:
            return '-windows';

        case 3:
            return '-outlook';

        case 1:
        case 2:
            switch (Microsoft.Dynamics.NAV.GetEnvironment().DeviceCategory) {
                case 0:
                default:
                    return "-desktop";
                case 1:
                    return '-tablet';
                case 2:
                    return '-phone';
            }
    }
}

function getLinkClassName() {
    return 'addInLink' + getClassNameSuffix();
}

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlAddInReady');
