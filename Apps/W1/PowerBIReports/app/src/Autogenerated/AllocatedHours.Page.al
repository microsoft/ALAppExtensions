namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37043 "Allocated Hours"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Manufacturing;
#pragma warning disable AS0035 // Changed from Card to UserControlHost
    PageType = UserControlHost;
#pragma warning restore AS0035
    Caption = 'Allocated Hours';
    AboutTitle = 'About Allocated Hours';
    AboutText = 'View the number of hours remaining for production allocated to each Work Centre in a specified period. Allows you to determine if a Work Centre is under or overloaded and requires rescheduling.';

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

                trigger ErrorOccurred(Operation: Text; ErrorText: Text)
                begin
                    SetupHelper.ShowPowerBIErrorNotification(Operation, ErrorText);
                end;
            }
        }
    }

    var
        SetupHelper: Codeunit "Setup Helper";
        ReportId: Guid;
#pragma warning disable AA0240
        ReportPageLbl: Label 'ReportSectionf3f7e4f23b609a9d9cb2', Locked = true;
#pragma warning restore AA0240

    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Manufacturing Report Id"));
    end;
}

