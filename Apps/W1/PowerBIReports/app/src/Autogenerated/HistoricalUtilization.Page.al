#if not CLEAN26
namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37041 "Historical Utilization"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Manufacturing;
    PageType = UserControlHost;
    Caption = 'Historical Utilization';
    AboutTitle = 'About Historical Utilization';
    AboutText = 'View the historical Utilization % by comparing Capacity Used vs. Available Capacity in Hours viewed over a timeline you can define to see trends. View all or some Work Centers.';
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
        ReportPageLbl: Label 'ReportSectionf9d212728e1d71a00044', Locked = true;
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

