namespace Microsoft.Finance.VAT.Reporting;

page 13606 "Elec. VAT Decl. Comm. Logs"
{
    Caption = 'Electronic VAT Declaration Communication Logs';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Elec. VAT Decl. Communication";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the communication with Skat.dk.';
                }
                field("Transaction ID"; Rec."Transaction ID")
                {
                    ToolTip = 'Specifies the unique ID for the transaction.';
                }
                field("Request Type"; Rec."Request Type")
                {
                    ToolTip = 'Specifies the type of the request.';
                }
                field("Related VAT Return No."; Rec."Related VAT Return No.")
                {
                    ToolTip = 'Specifies the number of the VAT Return that is related to the communication with Skat.dk.';
                }
                field(TimeSent; Rec.TimeSent)
                {
                    ToolTip = 'Specifies the time when the request was sent.';
                }
                field("Response Transaction ID"; Rec."Response Transaction ID")
                {
                    ToolTip = 'Specifies the unique ID of the response transaction.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DownloadRequestBLOB)
            {
                Caption = 'Download Request';
                Image = Download;
                ToolTip = 'Download the XML Request which was sent to SKAT.DK';

                trigger OnAction()
                begin
                    Rec.SaveRequestToFile();
                end;
            }
            action(DownloadResponseBLOB)
            {
                Caption = 'Download Response';
                Image = Download;
                ToolTip = 'Download the XML Response which was received from SKAT.DK';

                trigger OnAction()
                begin
                    Rec.SaveResponseToFile();
                end;
            }
        }
        area(Promoted)
        {
            actionref(DownloadRequestBLOB_promoted; DownloadRequestBLOB)
            {

            }
            actionref(DownloadResponseBLOB_promoted; DownloadResponseBLOB)
            {

            }
        }
    }
}