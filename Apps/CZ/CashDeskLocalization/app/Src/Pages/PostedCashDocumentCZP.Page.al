// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.Currency;
using Microsoft.Foundation.Attachment;

page 31165 "Posted Cash Document CZP"
{
    Caption = 'Posted Cash Document';
    Editable = false;
    PageType = Document;
    SourceTable = "Posted Cash Document Hdr. CZP";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
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
                field("Payment Purpose"; Rec."Payment Purpose")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a payment purpose.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which the cash document was posted.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which you created the document.';
                }
                field("Amounts Including VAT"; Rec."Amounts Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the unit price on the line should be displayed including or excluding VAT.';
                }
                field("Received From"; Rec."Received From")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies who recieved amount.';
                }
                field("Paid To"; Rec."Paid To")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whom is paid.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Lookup = false;
                    ToolTip = 'Specifies the currency of amounts on the document.';

                    trigger OnAssistEdit()
                    var
                        ChangeExchangeRate: Page "Change Exchange Rate";
                    begin
                        ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", Rec."Posting Date");
                        ChangeExchangeRate.Editable(false);
                        if ChangeExchangeRate.RunModal() = Action::OK then begin
                            Rec."Currency Factor" := ChangeExchangeRate.GetParameter();
                            Rec.Modify();
                        end;
                        Clear(ChangeExchangeRate);
                    end;
                }
                field("VAT Base Amount"; Rec."VAT Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies the total VAT base amount for lines. The program calculates this amount from the sum of line VAT base amount fields.';
                    Visible = false;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies whether the unit price on the line should be displayed including or excluding VAT.';
                    Visible = false;
                }
                field("VAT Base Amount (LCY)"; Rec."VAT Base Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies the VAT base amount for cash desk document line.';
                    Visible = false;
                }
                field("Amount Including VAT (LCY)"; Rec."Amount Including VAT (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies whether the unit price on the line should be displayed including or excluding VAT.';
                    Visible = false;
                }
            }
            part(PostedCashDocLines; "Posted Cash Document Subf. CZP")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Cash Desk No." = field("Cash Desk No."), "Cash Document No." = field("No.");
                SubPageView = sorting("Cash Desk No.", "Cash Document No.", "Line No.");
            }
            group(Posting)
            {
                Caption = 'Posting';
                field("Partner Type"; Rec."Partner Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the partner is Customer or Vendor or Contact or Salesperson/Purchaser or Employee.';
                }
                field("Partner No."; Rec."Partner No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the partner number.';
                }
                field("Received By"; Rec."Received By")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies who recieved amount.';
                }
                field("Paid By"; Rec."Paid By")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whom is paid.';
                }
                field("Identification Card No."; Rec."Identification Card No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for a card.';
                }
                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the registration number of customer or vendor.';
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT registration number. The field will be used when you do business with partners from EU countries/regions.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the Shortcut Dimension 1, which is defined in the Shortcut Dimension 1 Code field in the General Ledger Setup window.';
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the Shortcut Dimension 2, which is defined in the Shortcut Dimension 2 Code field in the General Ledger Setup window.';
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies which salesperson/purchaser is assigned to the cash desk document.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the responsibility center which works with this cash desk.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number that the vendor uses on the invoice they sent to you or number of receipt.';
                }
                field("EET Entry No."; Rec."EET Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the EET entry number.';
                }
                field("Created ID"; Rec."Created ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies employee ID of creating cash desk document.';
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies date of creating cash desk document.';
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
#if not CLEAN22
#pragma warning disable AS0072
            group(Category_Report)
            {
                Caption = 'Report';
                ObsoleteTag = '22.0';
                ObsoleteState = Pending;
                ObsoleteReason = 'This group has been removed.';
                Visible = false;

                actionref(PrinttoAttachmentPromoted; PrintToAttachment)
                {
                    ObsoleteTag = '22.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This group has been removed.';
                }
                actionref(PrintPromoted; "&Print")
                {
                    ObsoleteTag = '22.0';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'This group has been removed.';
                }
            }
#pragma warning restore AS0072
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
}
