namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37041 "Historical Utilization"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    PageType = Card;
    Caption = 'Historical Utilization';
    AboutTitle = 'About Historical Utilization';
    AboutText = 'View the historical Utilisation % by comparing Capacity Used vs Available Capacity in Hours viewed over a timeline you can define to see trends. View all or some Work Centres.';
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
        ReportPageTok: Label 'ReportSectionf9d212728e1d71a00044', Locked = true;
#pragma warning restore AA0240

    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Manufacturing Report Id"));
    end;
}

