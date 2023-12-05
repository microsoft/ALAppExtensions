namespace Microsoft.Finance.VAT.Reporting;

using System.Telemetry;

page 13605 "Elec. VAT Decl. Setup"
{
    Caption = 'Electronic VAT Declaration Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Elec. VAT Decl. Setup";

    layout
    {
        area(Content)
        {
            field("Get Periods Enpdoint"; Rec."Get Periods Enpdoint")
            {
                ToolTip = 'Specifies the url of endpoint for "Get VAT Periods" service.';
            }
            field("Submit VAT Return Endpoint"; Rec."Submit VAT Return Endpoint")
            {
                ToolTip = 'Specifies the url of endpoint for "Send VAT Return" service.';
            }
            field("Check Status Endpoint"; Rec."Check Status Endpoint")
            {
                ToolTip = 'Specifies the url of endpoint for "Check VAT Return status" service.';
            }
            field("Client Certificate Code"; Rec."Client Certificate Code")
            {
                ToolTip = 'Specifies the code of client-side certificate which is used to sign the requests to service.';
            }
            field("Server Certificate Code"; Rec."Server Certificate Code")
            {
                ToolTip = 'Specifies the code of server-side certificate which is used to validate the responses from service.';
            }
            field("ERP See Number"; Rec."ERP See Number")
            {
                ToolTip = 'Specifies the SEE number used to report the VAT Return to service.';
            }
        }
    }

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FeatureNameTxt: Label 'Electronic VAT Declaration DK', Locked = true;

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();

        FeatureTelemetry.LogUptake('0000LRC', FeatureNameTxt, "Feature Uptake Status"::Discovered);
    end;
}