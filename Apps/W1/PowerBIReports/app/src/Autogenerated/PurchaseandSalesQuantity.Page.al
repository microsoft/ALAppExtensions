namespace Microsoft.PowerBIReports;

using System.Integration.PowerBI;

page 37025 "Purchase and Sales Quantity"
{
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Purchase and Sales Quantity';
    AboutTitle = 'About Purchase and Sales Quantity';
    AboutText = 'The Purchase and Sales Quantity report offers insight into inventory movements by visualizing Net Quantity Purchased and Net Quantity Sold across time. The table matrix breaks down purchases and sales by item and item category code, targeting insights into supply from purchases and demand from sales. ';
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
        ReportPageTok: Label 'ReportSection956cd619a014201c65e3', Locked = true;
#pragma warning restore AA0240

    trigger OnOpenPage()
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        SetupHelper.EnsureUserAcceptedPowerBITerms();
        ReportId := SetupHelper.GetReportIdAndEnsureSetup(CurrPage.Caption(), PowerBIReportsSetup.FieldNo("Inventory Report Id"));
    end;
}

