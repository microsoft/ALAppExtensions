#pragma warning disable AA0247
controladdin "MTD Web Client FP Headers"
{
    RequestedHeight = 350;
    RequestedWidth = 350;
    HorizontalStretch = true;
    VerticalStretch = true;
    Scripts = 'src/FraudPrevention/MTDFPHeaders.js';
    StartupScript = 'src/FraudPrevention/MTDFPHeaders.js';
    StyleSheets = 'stylesheets/spinner.css';
    Images = 'images/spinner.gif';

    procedure Run(PublicIPServiceURL: Text);
    procedure TestExternalPublicIPService(PublicIPServiceURL: Text)

    event Ready();
    event Callback(headersJson: JsonObject);
}
