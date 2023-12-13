// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Foundation.Attachment;

page 31167 "Posted Cash Document List CZP"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Posted Cash Documents';
    CardPageID = "Posted Cash Document CZP";
    DataCaptionFields = "Cash Desk No.";
    Editable = false;
    PageType = List;
    SourceTable = "Posted Cash Document Hdr. CZP";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Cash Desk No."; Rec."Cash Desk No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of cash desk.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the cash desk document represents a cash receipt (Receipt) or a withdrawal (Wirthdrawal)';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the cash document.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which the cash document was posted.';
                }
                field("VAT Base Amount"; Rec."VAT Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total VAT base amount for lines. The program calculates this amount from the sum of line VAT base amount fields.';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the unit price on the line should be displayed including or excluding VAT.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                }
                field("Payment Purpose"; Rec."Payment Purpose")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a payment purpose.';
                }
                field("Received From"; Rec."Received From")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies who recieved amount.';
                    Visible = false;
                }
                field("Paid To"; Rec."Paid To")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whom is paid.';
                    Visible = false;
                }
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(11737), "No." = field("No.");
            }
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }
    actions
    {
        area(navigation)
        {
            action(Dimensions)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Dimensions';
                Image = Dimensions;
                ToolTip = 'View the dimension sets that are set up for the cash document.';

                trigger OnAction()
                begin
                    Rec.ShowDimensions();
                end;
            }
            action(DocAttach)
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                Image = Attach;
                ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                trigger OnAction()
                var
                    DocumentAttachmentDetails: Page "Document Attachment Details";
                    RecRef: RecordRef;
                begin
                    RecRef.GetTable(Rec);
                    DocumentAttachmentDetails.OpenForRecRef(RecRef);
                    DocumentAttachmentDetails.RunModal();
                end;
            }
        }
        area(reporting)
        {
            action("&Print")
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
                begin
                    PostedCashDocumentHdrCZP := Rec;
                    PostedCashDocumentHdrCZP.SetRecFilter();
                    PostedCashDocumentHdrCZP.PrintRecords(true);
                end;
            }
            action(PrintToAttachment)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attach as PDF';
                Image = PrintAttachment;
                ToolTip = 'Create a PDF file and attach it to the document.';

                trigger OnAction()
                begin
                    Rec.PrintToDocumentAttachment();
                end;
            }
        }
        area(processing)
        {
            action("&Navigate")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Find Entries';
                Ellipsis = true;
                Image = Navigate;
                ShortCutKey = 'Ctrl+Alt+Q';
                ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.';

                trigger OnAction()
                begin
                    Rec.Navigate();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(NavigatePromoted; "&Navigate")
                {
                }
            }
#if not CLEANT22
            group(Category_Report)
            {
                Caption = 'Report';
                ObsoleteTag = '22.0';
                ObsoleteState = Pending;
                ObsoleteReason = 'This group has been removed.';
                Visible = false;

                actionref(PrinttoAttachmentPromoted; PrintToAttachment)
                {
                }
                actionref(PrintPromoted; "&Print")
                {
                }
            }
#endif
            group(Category_Category8)
            {
                Caption = 'Print';

                actionref(Print_Promoted; "&Print")
                {
                }
                actionref(PrinttoAttachment_Promoted; PrintToAttachment)
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Cash Document';

                actionref(DimensionsPromoted; Dimensions)
                {
                }
                actionref(DocAttachPromoted; DocAttach)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        CashDeskFilter: Text;
    begin
        CashDeskManagementCZP.CheckCashDesks();
        CashDeskFilter := CashDeskManagementCZP.GetCashDesksFilter();

        Rec.FilterGroup(2);
        if CashDeskFilter <> '' then
            Rec.SetFilter("Cash Desk No.", CashDeskFilter);
        Rec.FilterGroup(0);
    end;

    var
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
}
