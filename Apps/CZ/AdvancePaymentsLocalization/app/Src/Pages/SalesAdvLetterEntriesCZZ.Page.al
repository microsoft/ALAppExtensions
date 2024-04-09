// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.VAT.Ledger;
using Microsoft.Foundation.Navigate;
using Microsoft.Sales.Receivables;

#pragma warning disable AL0604
page 31173 "Sales Adv. Letter Entries CZZ"
{
    Caption = 'Sales Adv. Letter Entries';
    PageType = List;
    SourceTable = "Sales Adv. Letter Entry CZZ";
    Editable = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Sales Adv. Letter No."; Rec."Sales Adv. Letter No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies sales advance letter no.';
                    Visible = false;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies entry type';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies document no.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies posting date.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies currency code.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount (LCY).';
                }
                field("Cust. Ledger Entry No."; Rec."Cust. Ledger Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies customer ledger entry no.';

                    trigger OnDrillDown()
                    var
                        CustLedgerEntry: Record "Cust. Ledger Entry";
                    begin
                        if Rec."Cust. Ledger Entry No." = 0 then
                            exit;

                        CustLedgerEntry.Get(Rec."Cust. Ledger Entry No.");
                        Page.Run(Page::"Customer Ledger Entries", CustLedgerEntry);
                    end;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                    Visible = false;
                }
                field("VAT Date"; Rec."VAT Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT date.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT bus. posting group.';
                    Visible = false;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT prod. posting group.';
                    Visible = false;
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT %.';
                    Visible = false;
                }
                field("VAT Base Amount"; Rec."VAT Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT base amount.';
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT amount.';
                }
                field("VAT Base Amount (LCY)"; Rec."VAT Base Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT base amount (LCY).';
                    Visible = false;
                }
                field("VAT Amount (LCY)"; Rec."VAT Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT amount (LCY).';
                    Visible = false;
                }
                field("VAT Calculation Type"; Rec."VAT Calculation Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT calculation type.';
                    Visible = false;
                }
                field("VAT Identifier"; Rec."VAT Identifier")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT identifier.';
                    Visible = false;
                }
                field("VAT Entry No."; Rec."VAT Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT entry no.';

                    trigger OnDrillDown()
                    var
                        VATEntry: Record "VAT Entry";
                    begin
                        if Rec."VAT Entry No." = 0 then
                            exit;

                        VATEntry.Get(Rec."VAT Entry No.");
                        Page.Run(Page::"VAT Entries", VATEntry);
                    end;
                }
                field(Cancelled; Rec.Cancelled)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies id entry was cancelled.';
                }
                field("Related Entry"; Rec."Related Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies related entry.';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies entry no.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(AdvanceLetterVAT)
            {
                Caption = 'Posting';
                Image = PostingEntries;

                action(PostPaymentVAT)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Payment VAT';
                    Enabled = ("Entry Type" = "Entry Type"::Payment) and (not IsClosed) and (not Cancelled);
                    Image = Post;
                    ToolTip = 'Post payment VAT.';

                    trigger OnAction()
                    begin
                        SalesPostAdvanceLetter.PostPaymentVAT(Rec, false);
                    end;
                }
                action(PostAndSendPaymentVAT)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Payment VAT and &Send';
                    Enabled = ("Entry Type" = "Entry Type"::Payment) and (not IsClosed) and (not Cancelled);
                    Ellipsis = true;
                    Image = PostSendTo;
                    ToolTip = 'Finalize and prepare to send the document according to the customer''s sending profile, such as attached to an email. The Send document to window opens first so you can confirm or select a sending profile.';

                    trigger OnAction()
                    var
                        SalesAdvLetterManagement: Codeunit "SalesAdvLetterManagement CZZ";
                    begin
                        SalesAdvLetterManagement.PostAndSendAdvancePaymentVAT(Rec);
                    end;
                }
                action(PostPaymentVATPreview)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Payment VAT Preview';
                    Enabled = ("Entry Type" = "Entry Type"::Payment) and (not IsClosed) and (not Cancelled);
                    Image = ViewPostedOrder;
                    ToolTip = 'Review the result of the posting lines before the actual posting.';

                    trigger OnAction()
                    begin
                        SalesPostAdvanceLetter.PostPaymentVAT(Rec, true);
                    end;
                }
                action(PostPaymentVATUsage)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Payment VAT Usage';
                    Enabled = ("Entry Type" = "Entry Type"::Usage) and (not IsClosed) and (not Cancelled);
                    Image = Post;
                    ToolTip = 'Post payment VAT usage.';

                    trigger OnAction()
                    begin
                        SalesPostAdvanceLetter.PostPaymentUsageVAT(Rec, false);
                    end;
                }
                action(PostPaymentVATUsagePreview)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Payment VAT Usage Preview';
                    Enabled = ("Entry Type" = "Entry Type"::Usage) and (not IsClosed) and (not Cancelled);
                    Image = ViewPostedOrder;
                    ToolTip = 'Review the result of the posting lines before the actual posting.';

                    trigger OnAction()
                    begin
                        SalesPostAdvanceLetter.PostPaymentUsageVAT(Rec, true);
                    end;
                }
                action(PostCreditMemoVAT)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Credit Memo VAT';
                    Enabled = ("Entry Type" = "Entry Type"::"VAT Payment") and (not IsClosed) and (not Cancelled);
                    Image = Post;
                    ToolTip = 'Post credit memo VAT.';

                    trigger OnAction()
                    begin
                        SalesPostAdvanceLetter.PostCreditMemoVAT(Rec, false);
                    end;
                }
                action(PostCreditMemoVATPreview)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Credit Memo VAT Preview';
                    Enabled = ("Entry Type" = "Entry Type"::"VAT Payment") and (not IsClosed) and (not Cancelled);
                    Image = ViewPostedOrder;
                    ToolTip = 'Review the result of the posting lines before the actual posting.';

                    trigger OnAction()
                    begin
                        SalesPostAdvanceLetter.PostCreditMemoVAT(Rec, true);
                    end;
                }
            }
            group(Payment)
            {
                Caption = 'Payment';
                Image = Payment;

                action(UnlinkAdvancePayment)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Unlink Advance Payment';
                    Enabled = ("Entry Type" = "Entry Type"::Payment) and (not IsClosed) and (not Cancelled);
                    Image = UnApply;
                    ToolTip = 'Unlink advance payment.';

                    trigger OnAction()
                    var
                        SalesAdvLetterManagement: Codeunit "SalesAdvLetterManagement CZZ";
                    begin
                        SalesAdvLetterManagement.UnlinkAdvancePayment(Rec);
                    end;
                }
            }
            group(NavigateGr)
            {
                Caption = 'Navigate';
                Image = Navigate;

                action(Navigate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Find Entries';
                    Image = Navigate;
                    Ellipsis = true;
                    ShortCutKey = 'Ctrl+Alt+Q';
                    ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.';

                    trigger OnAction()
                    var
                        Navigate: Page Navigate;
                    begin
                        Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                        Navigate.Run();
                    end;
                }
                action(AdvanceCard)
                {
                    Caption = 'Advance Card';
                    ToolTip = 'Show advance card.';
                    ApplicationArea = Basic, Suite;
                    Image = "Invoicing-Document";
                    RunObject = page "Sales Advance Letter CZZ";
                    RunPageLink = "No." = field("Sales Adv. Letter No.");
                    RunPageMode = View;
                }
            }
        }
        area(Reporting)
        {
            action(PrintVATDocument)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT Document';
                Enabled = ("Entry Type" = "Entry Type"::"VAT Payment") or ("Entry Type" = "Entry Type"::"VAT Usage") or ("Entry Type" = "Entry Type"::"VAT Close");
                Image = PrintReport;
                Ellipsis = true;
                ToolTip = 'Print VAT document.';

                trigger OnAction()
                var
                    SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
                begin
                    CurrPage.SetSelectionFilter(SalesAdvLetterEntryCZZ);
                    SalesAdvLetterEntryCZZ.PrintRecords(true);
                end;
            }
            action(Email)
            {
                ApplicationArea = Basic, Suite;
                Caption = '&Send by Email';
                Enabled = ("Entry Type" = "Entry Type"::"VAT Payment") or ("Entry Type" = "Entry Type"::"VAT Usage") or ("Entry Type" = "Entry Type"::"VAT Close");
                Image = Email;
                ToolTip = 'Prepare to email the document. The Send Email window opens prefilled with the customer''s email address so you can add or edit information.';

                trigger OnAction()
                var
                    SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
                begin
                    SalesAdvLetterEntryCZZ := Rec;
                    CurrPage.SetSelectionFilter(SalesAdvLetterEntryCZZ);
                    SalesAdvLetterEntryCZZ.EmailRecords(true);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Report)
            {
                Caption = 'Reports';

                actionref(Email_Promoted; Email)
                {
                }
            }
        }
    }

    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesPostAdvanceLetter: Codeunit "Sales Post Advance Letter CZZ";
        IsClosed: Boolean;

    trigger OnAfterGetRecord()
    begin
        GetAdvanceLetter();
        IsClosed := SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::Closed;
    end;

    local procedure GetAdvanceLetter()
    begin
        if SalesAdvLetterHeaderCZZ."No." <> "Sales Adv. Letter No." then
            SalesAdvLetterHeaderCZZ.Get("Sales Adv. Letter No.");
    end;
}
