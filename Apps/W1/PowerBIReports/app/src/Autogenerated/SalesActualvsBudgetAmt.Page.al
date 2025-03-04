#if not CLEAN26
namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37008 "Sales Actual vs. Budget Amt."
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
#pragma warning disable AS0035 // Changed from Card to UserControlHost
    PageType = UserControlHost;
#pragma warning restore AS0035
    Caption = 'Sales Actual vs. Budget Amount';
    AboutTitle = 'About Sales Actual vs. Budget Amount';
    AboutText = 'The Sales Actual vs. Budget Amount report provides a comparative analysis of sales amounts to budget amount. Featuring variance and variance percentage metrics that provide a clear view of actual performance compared to budgeted targets.';
    ObsoleteState = Pending;
    ObsoleteReason = 'The Power BI report has been changed/removed and this is no longer required.';
    ObsoleteTag = '26.0';
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

                trigger ErrorOccurred(Operation: Text; ErrorText: Text)
                begin
                    SetupHelper.ShowPowerBIErrorNotification(Operation, ErrorText);
                end;
            }
        }
    }

    var
        SetupHelper: Codeunit "Setup Helper";
        ReportId: Guid;
#pragma warning disable AA0240
        ReportPageLbl: Label 'ReportSectionce3be3bc80c816f2646b', Locked = true;
#pragma warning restore AA0240

    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Sales Report Id"));
    end;
}
#endif

