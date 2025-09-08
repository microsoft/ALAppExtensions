#if not CLEAN27
namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37086 "Realized Emissions vs Baseline"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    PageType = UserControlHost;
    Caption = 'Realized Emissions vs. Baseline';
    AboutTitle = 'About Realized Emissions vs. Baseline';
    AboutText = 'The Realized Emissions by Bassline report breaks down your carbon emissions and allows for comparison against a defined baseline period. This allows you to track your progress against the baseline and monitor trends against a previous period.';
    ObsoleteReason = 'Please use and extend page "Emissions vs Baseline Power BI" on the Sustainability app.';
    ObsoleteState = Pending;
    ObsoleteTag = '27.0';

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
        ReportPageLbl: Label '56c99409880d5002ad2e', Locked = true;

    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
#pragma warning disable AL0801
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Sustainability Report ID"));
#pragma warning restore AL0801
    end;
}
#endif