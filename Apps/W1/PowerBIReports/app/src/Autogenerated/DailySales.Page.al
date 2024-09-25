namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 36999 "Daily Sales"
{
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Daily Sales';
    AboutTitle = 'About Daily Sales';
    AboutText = 'The Daily Sales report offers a detailed analysis of sales amounts by weekday. The tabular report highlights trends by using conditional formatting to display figures in a gradient from low to high.';
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
        ReportPageTok: Label 'ReportSectionb3680fa80c9685297c06', Locked = true;
#pragma warning restore AA0240

    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Sales Report Id"));
    end;
}

