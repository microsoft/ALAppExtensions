#if not CLEAN26
namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37040 "Current Utilization"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Manufacturing;
    PageType = UserControlHost;
    Caption = 'Current Utilization';
    AboutTitle = 'About Current Utilization';
    AboutText = 'View the current Weeks Utilization % by comparing Capacity Used to Available Capacity in Hours. View all or some Work Centers to measure throughput and efficiency.';
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
        ReportPageLbl: Label 'ReportSection1cb4eb25650060b6dbd0', Locked = true;
#pragma warning restore AA0240

    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Manufacturing Report Id"));
    end;
}
#endif

