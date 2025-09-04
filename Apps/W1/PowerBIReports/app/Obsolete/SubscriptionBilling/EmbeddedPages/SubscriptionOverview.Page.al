//#if not CLEAN28
namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37068 "Subscription Overview"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    PageType = UserControlHost;
    Caption = 'Subscription Overview';
    AboutTitle = 'About Subscription Overview';
    AboutText = 'The Subscription Overview provides a comprehensive view of subscription performance, offering insights into metrics such as Monthly Recurring Revenue, Total Contract Value, Churn and top-performing customers or vendors.';
    //ObsoleteReason = 'Please use and extend page "Subscription Overview Power BI" on the Subscription Billing app.';
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
#pragma warning disable AA0240 // Bug 595848
        ReportPageLbl: Label '04fa320747962435bf38', Locked = true;
#pragma warning restore AA0240

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