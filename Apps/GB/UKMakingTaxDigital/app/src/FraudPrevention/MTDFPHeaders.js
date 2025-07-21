var spinner = document.createElement("img");
spinner.className = "spinner-image";
spinner.src = Microsoft.Dynamics.NAV.GetImageResource("images/spinner.gif");

var container = document.createElement("div");
container.className = "spinner-container";
container.appendChild(spinner);

document.getElementById("controlAddIn").appendChild(container);

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('Ready', []);

function Run(publicIPServiceURL) {

    headersJson = {
        screenWidth: window.screen.width,
        screenHeight: window.screen.height,
        screenColorDepth: window.screen.colorDepth,
        windowWidth: window.outerWidth,
        windowHeight: window.outerHeight,
        timestamp: (new Date()).toISOString(),
        timezone: getTimezone(),
        browserUserAgent: navigator.userAgent,
        browserDoNotTrack: getDoNotTrack(),
        deviceID: getDeviceID(),
        publicIP: ''
    };

    Promise.delay = function (t, val) {
        return new Promise(resolve => {
            setTimeout(resolve.bind(null, val), t);
        });
    }

    Promise.raceAll = function (promises, timeoutTime, timeoutVal) {
        return Promise.all(promises.map(p => {
            return Promise.race([p, Promise.delay(timeoutTime, timeoutVal)])
        }));
    }

    Promise.raceAll(
        [getPublicIPAsync(publicIPServiceURL)], 10000, { ip: '', source: '' }) // 10 sec timeout
        .then(
            function ([publicIPResult]) {
                headersJson.publicIP = publicIPResult.ip || '';
                headersJson.publicIPSource = publicIPResult.source || '';
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('CallBack', [headersJson]);
            },
            function (reject) {
                Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('CallBack', [headersJson]);
            }
        );
}

function TestExternalPublicIPService(url) {
    getPublicIPFromExtService(url)
        .then(publicIP => {
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('CallBack', [{
                publicIP: publicIP || "",
                publicIPSource: "external"
            }]);
        })
        .catch(error => {
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('CallBack', [{
                publicIP: "",
                publicIPSource: ""
            }]);
        });
}

function getPublicIPAsync(url) {
    return getPublicIPFromFCE()
        .then(clientIp => {
            if (clientIp)
                return { ip: clientIp, source: "FCE" };

            if (url)
                return getPublicIPFromExtService(url)
                    .then(extIp => ({ ip: extIp, source: "external" }));

            return { ip: "", source: "" };
        });
}

function getPublicIPFromFCE() {
    try {
        const baseUrl = new URL(window.location.href);
        let internalUrl = baseUrl.origin + baseUrl.pathname + "/" + "clientIp/clientIp";

        const sessionIdQueryParam = "tid";
        try {
            const sessionId = new URLSearchParams(location.href).get(sessionIdQueryParam);
            if (sessionId && sessionId !== "undefined") {
                const urlObject = new URL(internalUrl);
                urlObject.searchParams.append(sessionIdQueryParam, sessionId);
                internalUrl = urlObject.toString();
            }
        } catch {
            // Ignore errors if we can't add the session ID
        }

        return fetch(internalUrl, { credentials: "include" })
            .then(response => response.text())
            .then(content => parseContentForIP(content) || "")
            .catch(() => "");
    } catch {
        // If internal URL construction fails, return an empty string
        return Promise.resolve("");
    }
}

function getPublicIPFromExtService(url) {
    if (!url) {
        return Promise.resolve("");
    }

    return fetch(url)
        .then(response => response.text())
        .then(content => parseContentForIP(content) || "")
        .catch(() => "");
}

function parseContentForIP(content) {
    var resp_regex = /([0-9]{1,3}(\.[0-9]{1,3}){3})|(([0-9A-Fa-f]{0,4}:){2,7}([0-9A-Fa-f]{1,4}))/;
    var respFmt = resp_regex.exec(content);
    if (respFmt) {
        return respFmt[0];
    }
}

function getTimezone() {
    // UTC+01:00
    var timezone = new Date().toString().match(/([A-Z]+[\+-][0-9]+)/)[1].replace('GMT', 'UTC');
    return timezone.slice(0, 6) + ':' + timezone.slice(6, 8);
}

function getDoNotTrack() {
    // true or false
    return window.doNotTrack === '1' || navigator.doNotTrack === 'yes' ||
        navigator.doNotTrack === '1' || navigator.msDoNotTrack === '1' ||
        'msTrackingProtectionEnabled' in window.external && window.external.msTrackingProtectionEnabled();
}

function getDeviceID() {
    CookieName = 'BC-HMRC-Gov-Client-Device-ID';
    result = getCookie(CookieName);
    if (!result) {
        result = uuidv4();
        setCookie(CookieName, result);
    }
    return result;
}

function setCookie(name, value, days = 365, path = '/') {
    const expires = new Date(Date.now() + days * 864e5).toUTCString()
    document.cookie = name + '=' + encodeURIComponent(value) + '; expires=' + expires + '; path=' + path
}

function getCookie(name) {
    return document.cookie.split('; ').reduce((r, v) => {
        const parts = v.split('=')
        return parts[0] === name ? decodeURIComponent(parts[1]) : r
    }, '')
}

function uuidv4() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
}
