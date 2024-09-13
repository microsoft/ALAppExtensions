namespace Microsoft.Purchases.PowerBIReports;

using System.Integration.PowerBI;

page 36962 "Purchasing Scorecard"
{
    Caption = 'Purchasing Scorecard';
    AboutTitle = 'About purchasing scorecard.';
    AboutText = 'Here, you can embed your Power BI scorecard you have created for purchasing, allow you to track your key business objectives in a single view.';
    PageType = Card;
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ContextSensitiveHelpPage = 'track-kpis-with-power-bi-metrics';
    Extensible = false;

    layout
    {
        area(Content)
        {
            part(EmbeddedReport; "Power BI Embedded Report Part")
            {
                ApplicationArea = All;
                Caption = 'Purchase Overview';
                SubPageView = where(Context = const('53023-purchasing-scorecard'));
            }
        }
    }

    var
        PowerBiNotSetupErr: Label 'Power BI is not set up. You need to set up Power BI in order to see this report.';
        ContextTxt: Label '53023-purchasing-scorecard', MaxLength = 30, Locked = true, Comment = 'IMPORTANT: keep it unique across pages. Also, make sure this value is the same used in the SubPageView above.';

    trigger OnOpenPage()
    var
        PowerBIContextSettings: Record "Power BI Context Settings";
        PowerBIEmbedSetupWizard: Page "Power BI Embed Setup Wizard";
    begin
        PowerBIContextSettings.SetRange(UserSID, UserSecurityId());
        if PowerBIContextSettings.IsEmpty() then begin
            PowerBIEmbedSetupWizard.SetContext(ContextTxt);
            if PowerBIEmbedSetupWizard.RunModal() <> Action::OK then;

            if PowerBIContextSettings.IsEmpty() then
                Error(PowerBiNotSetupErr);
        end;

        // CurrPage.EmbeddedReport.Page.SetFullPageMode(true); // FIXME: Full page mode feature not yet implemented in v24
    end;
}