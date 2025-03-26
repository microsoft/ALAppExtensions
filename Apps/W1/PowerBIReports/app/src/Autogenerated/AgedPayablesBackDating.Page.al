namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 36994 "Aged Payables (Back Dating)"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
#pragma warning disable AS0035 // Changed from Card to UserControlHost
    PageType = UserControlHost;
#pragma warning restore AS0035
    Caption = 'Aged Payables (Back Dating)';
    AboutTitle = 'About Aged Payables (Back Dating)';
    AboutText = 'The Aged Payables Back Dating report categorizes vendor balances into aging buckets. It offers flexibility with filters for different payment terms, aging dates, and custom aging bucket sizes.';

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
        ReportPageLbl: Label 'ReportSection904474b579cc92816425', Locked = true;
#pragma warning restore AA0240

    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Finance Report Id"));
    end;
}

