namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37058 "Inventory Valuation by Loc."
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
#pragma warning disable AS0035 // Changed from Card to UserControlHost
    PageType = UserControlHost;
#pragma warning restore AS0035
    Caption = 'Inventory Valuation by Location';
    AboutTitle = 'About Inventory Valuation by Location';
    AboutText = 'The Inventory Valuation by Location report features a Treemap that visualizes ending balance quantities by location. It also includes a table matrix providing a detailed view of ending balances and showing fluctuations in inventory over the specified period.';

    layout
    {
        area(Content)
        {
            usercontrol(PowerBIAddin; PowerBIManagement)
            {
                ApplicationArea = All;

                trigger ControlAddInReady()
                begin
                    SetupHelper.InitializeEmbeddedAddin(CurrPage.PowerBIAddin, ReportId, ReportPageLbl);
                end;
                
                trigger ReportLoaded(ReportFilters: Text; ActivePageName: Text; ActivePageFilters: Text; CorrelationId: Text)
                begin
                    SetupHelper.LogReportLoaded(CorrelationId);
                end;

                trigger ErrorOccurred(Operation: Text; ErrorText: Text)
                begin
                    SetupHelper.LogError(Operation, ErrorText);
                    SetupHelper.ShowPowerBIErrorNotification(Operation, ErrorText);
                end;
            }
        }
    }

    var
        SetupHelper: Codeunit "Setup Helper";
        ReportId: Guid;
#pragma warning disable AA0240
        ReportPageLbl: Label '6a6852c0d882690a617b', Locked = true;
#pragma warning restore AA0240

    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Inventory Val. Report Id"));
    end;
}

