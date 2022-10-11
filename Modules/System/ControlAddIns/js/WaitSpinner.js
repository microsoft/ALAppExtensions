var spinner = document.createElement("img");
spinner.className = "spinner-image";
spinner.src = Microsoft.Dynamics.NAV.GetImageResource("ControlAddIns/images/spinner.gif");

var container = document.createElement("div");
container.className = "spinner-container";
container.appendChild(spinner);

document.getElementById("controlAddIn").appendChild(container);

function Wait(SecondsToWait) {
    setTimeout(CallbackBC, SecondsToWait * 1000);
};

function CallbackBC() {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('Callback');
}

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('Ready');


