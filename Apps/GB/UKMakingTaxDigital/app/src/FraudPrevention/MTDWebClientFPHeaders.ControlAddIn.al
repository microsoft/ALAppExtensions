controladdin "MTD Web Client FP Headers"
{
    Scripts = 'https://cdnjs.cloudflare.com/ajax/libs/knockout/3.4.2/knockout-debug.js',
                'src/FraudPrevention/MTDFPHeaders.js';
    StartupScript = 'src/FraudPrevention/MTDFPHeaders.js';

    procedure Run(PublicAPIurl: Text);

    event Ready();
    event Callback(headersJson: JsonObject);
}
