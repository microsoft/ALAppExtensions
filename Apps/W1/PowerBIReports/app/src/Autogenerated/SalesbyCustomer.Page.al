namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37005 "Sales by Customer"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
#pragma warning disable AS0035 // Changed from Card to UserControlHost
    PageType = UserControlHost;
#pragma warning restore AS0035
    Caption = 'Sales by Customer';
    AboutTitle = 'About Sales by Customer';
    AboutText = 'The Sales by Customer report breaks down sales performance highlighting key metrics such as Sales Amount, Cost Amount, Gross Profit and Gross Profit Margin by customer. This report provides detailed insights into which customer and items driving revenue and profitability.';

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
        ReportPageLbl: Label 'ReportSection48bbd51044e094b7a9a2', Locked = true;
#pragma warning restore AA0240

    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Sales Report Id"));
    end;
}

