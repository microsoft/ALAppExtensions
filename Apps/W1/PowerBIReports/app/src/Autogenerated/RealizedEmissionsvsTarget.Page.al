#if not CLEAN27
namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37085 "Realized Emissions vs Target"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    PageType = UserControlHost;
    Caption = 'Realized Emissions vs. Target';
    AboutTitle = 'About Realized Emissions vs. Target';
    AboutText = 'The Realized Emissions by Target report breaks down your carbon emissions and allows for comparison against the target. This allows you to effectively monitor planned progress and drive continuous improvement to sustainability goals.';
    ObsoleteReason = 'Please use and extend page "Emissions vs Target Power BI" on the Sustainability app.';
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
        ReportPageLbl: Label 'b5e269104115da14c7e4', Locked = true;

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