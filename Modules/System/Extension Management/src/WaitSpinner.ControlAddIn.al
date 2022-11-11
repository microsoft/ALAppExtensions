controladdin WaitSpinner
{
    RequestedHeight = 350;
    RequestedWidth = 350;
    HorizontalStretch = true;
    VerticalStretch = true;
    Scripts = 'https://cdnjs.cloudflare.com/ajax/libs/knockout/3.4.2/knockout-debug.js', 'ControlAddIns/js/WaitSpinner.js';
    StartupScript = 'ControlAddIns/js/WaitSpinner.js';
    StyleSheets = 'ControlAddIns/stylesheets/spinner.css';
    Images = 'ControlAddIns/images/spinner.gif';

    procedure Wait(SecondsToWait: Integer);
    event Ready();
    event Callback();
}