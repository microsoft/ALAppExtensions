namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 6316 "Sustainability Report Power BI"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    PageType = UserControlHost;
    Caption = 'Sustainability Report';
    AboutTitle = 'About Sustainability Report';
    AboutText = 'The Sustainability Report offers a view of all Sustainability report pages embedded into a single page for easy access. ';

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
        ReportPageLbl: Label '', Locked = true;

    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
#if not CLEAN27
#pragma warning disable AL0801
#endif
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Sustainability Report ID"));
#if not CLEAN27
#pragma warning restore AL0801
#endif
    end;
}

