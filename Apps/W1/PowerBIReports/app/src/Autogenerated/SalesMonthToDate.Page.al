namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37003 "Sales Month-To-Date"
{
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Sales Month-To-Date';
    AboutTitle = 'About Sales Month-To-Date';
    AboutText = 'The Sales Month-to-Date report tracks the accumulation of sales amounts throughout the current month, providing insights into progress and performance up to the present date.';
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
        ReportPageTok: Label 'ReportSection7d903e33b708c20e3be1', Locked = true;
#pragma warning restore AA0240

    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Sales Report Id"));
    end;
}

