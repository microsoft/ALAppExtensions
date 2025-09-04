//#if not CLEAN28
namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37075 "Revenue by Salesperson"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    PageType = UserControlHost;
    Caption = 'Revenue by Salesperson';
    AboutTitle = 'About Revenue by Salesperson';
    AboutText = 'The Revenue by Salesperson report breaks down subscription performance by Salesperson, highlighting metrics such as Monthly Recurring Revenue, Monthly Recurring Cost, Monthly Net Profit Amount and Churn.';
    //ObsoleteReason = 'Please use and extend page "Rev. by Salesperson Power BI" on the Subscription Billing app.';
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
        ReportPageLbl: Label '926fa2c13070086cb999', Locked = true;

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