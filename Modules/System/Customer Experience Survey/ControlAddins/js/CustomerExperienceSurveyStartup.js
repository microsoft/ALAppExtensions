const controlAddinRoot = document.getElementById("controlAddIn");
const surveyDiv = document.createElement("div");
surveyDiv.id = "surveyDiv";
surveyDiv.className = "container";
surveyDiv.style = 'height:100%; width:100%'
controlAddinRoot.appendChild(surveyDiv);

Microsoft.Dynamics.NAV.InvokeExtensibilityMethod("ControlReady");