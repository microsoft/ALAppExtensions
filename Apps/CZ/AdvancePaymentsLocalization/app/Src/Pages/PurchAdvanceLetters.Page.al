#pragma warning disable AL0204, AL0604
page 31180 "Purch. Advance Letters CZZ"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Purchase Advance Letters';
    PageType = List;
    SourceTable = "Purch. Adv. Letter Header CZZ";
    UsageCategory = Lists;
    CardPageId = "Purch. Advance Letter CZZ";
    PromotedActionCategories = 'New,Process,Report,Release,History,Print/Send,Navigate';
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies advance letter document no.';
                }
                field("Advance Letter Code"; Rec."Advance Letter Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies code of advance letter template.';
                }
                field("Pay-to Vendor No."; Rec."Pay-to Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies pay-to vendor no.';
                }
                field("Pay-to Name"; Rec."Pay-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies pay-to name.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies posting date.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies document date.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies currency code.';
                    Visible = false;
                }
                field("Vendor Order No."; Rec."Vendor Adv. Letter No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies vendor advance letter no.';
                    Visible = false;
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies order no.';
                    Visible = false;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT bus. posting group.';
                    Visible = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies status.';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount including VAT.';
                    Visible = false;
                }
                field("Amount Including VAT (LCY)"; Rec."Amount Including VAT (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount including VAT (LCY).';
                    Visible = false;
                }
                field("To Pay"; Rec."To Pay")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies to pay amount.';
                    Visible = false;
                }
                field("To Use"; Rec."To Use")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies to use amount.';
                    Visible = false;
                }
                field("To Use (LCY)"; Rec."To Use (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies to use (LCY) amount.';
                    Visible = false;
                }
                field("Variable Symbol"; Rec."Variable Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies variable symbol.';
                    Visible = false;
                }
                field("Constant Symbol"; Rec."Constant Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies constant symbol.';
                    Visible = false;
                }
                field("Specific Symbol"; Rec."Specific Symbol")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies specific symbol.';
                    Visible = false;
                }
                field("Advance Due Date"; Rec."Advance Due Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies due date.';
                    Visible = false;
                }
                field("Automatic Post VAT Usage"; Rec."Automatic Post VAT Usage")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether VAT document will be posted automatically.';
                    Visible = false;
                }
                field("Amount on Iss. Payment Order"; "Amount on Iss. Payment Order")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount on issued payment order.';
                    Visible = false;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how to make payment, such as with bank transfer, cash, or check.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
            }
        }
        area(FactBoxes)
        {
            part(PurchAdvLettrFactBox; "Purch. Adv. Letter FactBox CZZ")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("No.");
            }
            part(VendorDetailFactBox; "Vendor Details FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("Pay-to Vendor No.");
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(31008), "No." = field("No.");
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
            group(AdvanceLetterGr)
            {
                Caption = 'Advance Letter';
                Image = "Invoice";

                action(Dimensions)
                {
                    AccessByPermission = tabledata Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Enabled = "No." <> '';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDocDim();
                        CurrPage.SaveRecord();
                    end;
                }
                action(SuggestedUsage)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Suggested Usage';
                    Image = CoupledInvoice;
                    ToolTip = 'View a list of suggested usages.';
                    RunObject = Page "Suggested Usage CZZ";
                    RunPageLink = "Advance Letter Type" = const(Purchase), "Advance Letter No." = field("No.");
                }
                action(DocAttach)
                {
                    ApplicationArea = Basic, Suite;
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
            group(History)
            {
                Caption = 'History';
                Image = History;

                action(Entries)
                {
                    ApplicationArea = Suite;
                    Caption = 'Advance Letter Entries';
                    Image = Entries;
                    ShortCutKey = 'Ctrl+F7';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'View a list of entries related to this document.';
                    RunObject = Page "Purch. Adv. Letter Entries CZZ";
                    RunPageLink = "Purch. Adv. Letter No." = field("No.");
                }
            }
        }
        area(processing)
        {
            group(ReleaseGr)
            {
                Caption = 'Release';
                Image = ReleaseDoc;

                action(Release)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Release';
                    Enabled = Status = Status::New;
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'Ctrl+F9';
                    ToolTip = 'Release the document.';

                    trigger OnAction()
                    var
                        RelPurchAdvLetterDoc: Codeunit "Rel. Purch.Adv.Letter Doc. CZZ";
                    begin
                        RelPurchAdvLetterDoc.Run(Rec);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reopen';
                    Enabled = Status = Status::"To Pay";
                    Image = ReOpen;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Reopen the document.';

                    trigger OnAction()
                    var
                        RelPurchAdvLetterDoc: Codeunit "Rel. Purch.Adv.Letter Doc. CZZ";
                    begin
                        RelPurchAdvLetterDoc.Reopen(Rec);
                    end;
                }
            }
        }
        area(Reporting)
        {
            action(Print)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advance Letter';
                Image = PrintReport;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Report;
                Ellipsis = true;
                ToolTip = 'Allows the print of advance letter.';

                trigger OnAction()
                var
                    PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
                begin
                    CurrPage.SetSelectionFilter(PurchAdvLetterHeaderCZZ);
                    PurchAdvLetterHeaderCZZ.PrintRecord(true);
                end;
            }
            action(PrintToAttachment)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Attach as PDF';
                Image = PrintAttachment;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedOnly = true;
                ToolTip = 'Create a PDF file and attach it to the document.';

                trigger OnAction()
                begin
                    Rec.PrintToDocumentAttachment();
                end;
            }
            action(AdvanceLetters)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advance Letters';
                Image = PrintReport;
                Ellipsis = true;
                ToolTip = 'Allows the print list of advance letters.';
                RunObject = Report "Purch. Advance Letters CZZ";
            }
            action(AdvanceLettersVAT)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advance Letters VAT';
                Image = PrintReport;
                Ellipsis = true;
                ToolTip = 'Allows the print list of advance letters with VAT.';
                RunObject = Report "Purch. Advance Letters VAT CZZ";
            }
            action(AdvanceLettersRecap)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advance Letters Recapitulation';
                Image = PrintReport;
                Ellipsis = true;
                ToolTip = 'Allows the print list of advance letters recapitulation.';
                RunObject = Report "Purch. Adv. Letters Recap. CZZ";
            }
        }
    }

    trigger OnOpenPage()
    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
    begin
        AdvancePaymentsMgtCZZ.TestIsEnabled();
    end;
}
