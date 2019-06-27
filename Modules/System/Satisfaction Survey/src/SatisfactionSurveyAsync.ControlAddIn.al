controladdin SatisfactionSurveyAsync
{
    Scripts = 'js\SATAsync.js';
    RequestedWidth = 0;
    RequestedHeight = 0;
    HorizontalStretch = false;
    VerticalStretch = false;

    procedure SendRequest(Url: Text; Timeout: Integer);
    event ResponseReceived(Status: Integer; Response: Text);
}