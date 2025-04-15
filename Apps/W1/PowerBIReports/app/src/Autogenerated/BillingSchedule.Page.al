namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37081 "Billing Schedule"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
#pragma warning disable AS0035 // Changed from Card to UserControlHost
    PageType = UserControlHost;
#pragma warning restore AS0035
    Caption = 'Billing Schedule';
    AboutTitle = 'About Billing Schedule';
    AboutText = 'The Billing Schedule report provides a forecast of vendor and customer invoiced amounts according to the contractual billing rhythm. It helps to identify future development of incoming and outgoing cash from billed subscriptions.';

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
        ReportPageLbl: Label 'c27df17dadb4b21679dc', Locked = true;
#pragma warning restore AA0240

    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Subscription Billing Report Id"));
    end;
}

