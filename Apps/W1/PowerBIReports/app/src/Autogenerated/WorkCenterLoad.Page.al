namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37042 "Work Center Load"
{
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Work Center Load';
    AboutTitle = 'About Work Center Load';
    AboutText = 'View the percentage of production order time assigned vs Available Capacity for each Work Centre Group and/or Work Centre in a specified period. Allows you to determine if a Work Centre is overloaded and requires rescheduling.';
    Extensible = false;

    layout
    {
        area(Content)
        {
            usercontrol(PowerBIAddin; PowerBIManagement)
            {
                ApplicationArea = All;

                trigger ControlAddInReady()
                begin
                    SetupHelper.InitializeEmbeddedAddin(CurrPage.PowerBIAddin, ReportId, ReportPageTok);
                end;

                trigger ErrorOccurred(Operation: Text; ErrorText: Text)
                begin
                    SetupHelper.ShowPowerBIErrorNotification(Operation, ErrorText);
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(FullScreen)
            {
                ApplicationArea = All;
                Caption = 'Fullscreen';
                ToolTip = 'Shows the Power BI element as full screen.';
                Image = View;
                Visible = false;

                trigger OnAction()
                begin
                    CurrPage.PowerBIAddin.FullScreen();
                end;
            }
        }
    }

    var
        SetupHelper: Codeunit "Setup Helper";
        ReportId: Guid;
#pragma warning disable AA0240
        ReportPageTok: Label 'ReportSection83a7395d207d5b47b1a4', Locked = true;
#pragma warning restore AA0240

    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Manufacturing Report Id"));
    end;
}

