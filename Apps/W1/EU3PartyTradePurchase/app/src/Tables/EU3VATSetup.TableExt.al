tableextension 4886 "EU3 VAT Setup" extends "VAT Setup"
{
    fields
    {
        field(4881; "Enable EU 3-Party Purchase"; Boolean)
        {
            Caption = 'Enable EU 3-Party Purchase';
            InitValue = false;
            trigger OnValidate()
            var
                FeatureTelemetry: Codeunit "Feature Telemetry";
            begin
                if "Enable EU 3-Party Purchase" then
                    FeatureTelemetry.LogUptake('0000KM2', EU3PartyTok, Enum::"Feature Uptake Status"::"Set up");
            end;
        }
    }

    var
        EU3PartyTok: Label 'W1 EU-3 Party Trade Purchase', Locked = true;
}
