//#if not CLEAN28
namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37079 "Vendor Deferrals"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    PageType = UserControlHost;
    Caption = 'Vendor Deferrals';
    AboutTitle = 'About Vendor Deferrals';
    AboutText = 'The Vendor Deferrals report provides an overview of deferred vs. released subscription cost amount.';
    //ObsoleteReason = 'Please use and extend page "Vendor Deferrals Power BI" on the Subscription Billing app.';
    //ObsoleteState = Pending;
    //ObsoleteTag = '28.0';

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
        SetupHelper: Codeunit "Power BI Report Setup";
        ReportId: Guid;
        ReportPageLbl: Label 'daf7261ae50cb900681b', Locked = true;

#if not CLEAN28  // Temporary while uptake of the move of the table extension gets to BCApps
    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
        //#if not CLEAN28
#pragma warning disable AL0801
        //#endif
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Subscription Billing Report Id"));
        //#if not CLEAN28
#pragma warning restore AL0801
        //#endif
    end;
#endif  // Temporary while uptake of the move of the table extension gets to BCApps
}
//#endif