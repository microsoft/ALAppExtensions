tableextension 4884 "EU3 Purchase Header" extends "Purchase Header"
{
    fields
    {
        field(4881; "EU 3 Party Trade"; Boolean)
        {
            Caption = 'EU 3-Party Trade';
            trigger OnValidate()
            var
                FeatureTelemetry: Codeunit "Feature Telemetry";
                EU3PartyTok: Label 'W1 EU-3 Party Trade Purchase', Locked = true;
            begin
                if "EU 3 Party Trade" then begin
                    FeatureTelemetry.LogUptake('0000KM0', EU3PartyTok, Enum::"Feature Uptake Status"::"Used");
                    FeatureTelemetry.LogUsage('0000KM1', EU3PartyTok, 'EU-3 Party Trade Purchase used.');
                end;
            end;
        }
    }
}
