// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Finance.Currency;
using Microsoft.Foundation.Attachment;

page 31266 "Iss. Payment Order CZB"
{
    Caption = 'Issued Payment Order';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = "Iss. Payment Order Header CZB";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number of the payment order.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the no. of bank account.';
                }
                field("Bank Account Name"; Rec."Bank Account Name")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of bank account.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number used by the bank for the bank account.';
                }
                field("Foreign Payment Order"; Rec."Foreign Payment Order")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the foreign or domestic payment order.';
                }
                field("No. exported"; Rec."No. exported")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies how many times was payment order exported.';
                }
                field(CancelLinesFilter; CancelLinesFilter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Canceled Lines Filter';
                    OptionCaption = ' ,Not Canceled,Canceled';
                    ToolTip = 'Specifies to filter out the canceled or not canceled or all lines.';

                    trigger OnValidate()
                    begin
                        CurrPage.Lines.Page.FilterCanceledLines(CancelLinesFilter);
                        CurrPage.Lines.Page.Update(false);
                        CancelLinesFilterOnAfterVal();
                    end;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the date on which you created the document.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                    Importance = Additional;

                    trigger OnAssistEdit()
                    var
                        ChangeExchangeRate: Page "Change Exchange Rate";
                    begin
                        ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", Rec."Document Date");
                        ChangeExchangeRate.Editable(false);
                        if ChangeExchangeRate.RunModal() = Action::OK then begin
                            Rec.Validate("Currency Factor", ChangeExchangeRate.GetParameter());
                            CurrPage.Update();
                        end;
                    end;
                }
                field("Payment Order Currency Code"; Rec."Payment Order Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the payment order currency code.';

                    trigger OnAssistEdit()
                    var
                        ChangeExchangeRate: Page "Change Exchange Rate";
                    begin
                        ChangeExchangeRate.SetParameter(Rec."Payment Order Currency Code", Rec."Payment Order Currency Factor", Rec."Document Date");
                        ChangeExchangeRate.Editable(false);
                        if ChangeExchangeRate.RunModal() = Action::OK then begin
                            Rec.Validate("Payment Order Currency Factor", ChangeExchangeRate.GetParameter());
                            CurrPage.Update();
                        end;
                    end;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number of vendor''s document.';
                    Importance = Additional;
                }
                field("No. of Lines"; Rec."No. of Lines")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the number of lines in the payment order.';
                    Importance = Additional;
                }
                field("Unreliable Pay. Check DateTime"; Rec."Unreliable Pay. Check DateTime")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of the check of unreliability.';
                }
            }
            part(Lines; "Iss. Payment Order Subform CZB")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                SubPageLink = "Payment Order No." = field("No.");
            }
            group("Debet/Credit")
            {
                Caption = 'Debet/Credit';
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the total amount for payment order lines. The program calculates this amount from the sum of line amount fields on payment order lines.';
                }
                field(Debit; Rec.Debit)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the total amount that the line consists of, if it is a debit amount.';
                }
                field(Credit; Rec.Credit)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the total credit amount for issued payment order lines. The program calculates this credit amount from the sum of line credit fields on issued payment order lines.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the total amount that the line consists of. The amount is in the local currency.';
                }
                field("Debit (LCY)"; Rec."Debit (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the total amount that the line consists of, if it is a debit amount. The amount is in the local currency.';
                }
                field("Credit (LCY)"; Rec."Credit (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the total amount that the line consists of, if it is a credit amount. The amount is in the local currency.';
                }
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(31258), "No." = field("No.");
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
        area(Navigation)
        {
            action(Statistics)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Statistics';
                Image = Statistics;
                ShortCutKey = 'F7';
                ToolTip = 'View the statistics on the selected payment order.';

                trigger OnAction()
                begin
                    Rec.ShowStatistics();
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
        area(Processing)
        {
            action("Payment Order Export")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Payment Order Export';
                Ellipsis = true;
                Image = ExportToBank;
                ToolTip = 'Open the report for expor payment order to the bank.';

                trigger OnAction()
                begin
                    Rec.ExportPaymentOrder();
                end;
            }
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
        area(Reporting)
        {
            action(IssuedPaymentOrder)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Issued Payment Order';
                Ellipsis = true;
                Image = BankAccountStatement;
                ToolTip = 'Open the report for payment order.';

                trigger OnAction()
                begin
                    PrintPaymentOrder();
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
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("&Navigate_Promoted"; "&Navigate")
                {
                }
                actionref("Payment Order Export_Promoted"; "Payment Order Export")
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Print';

                actionref(IssuedPaymentOrder_Promoted; IssuedPaymentOrder)
                {
                }
                actionref(PrintToAttachment_Promoted; PrintToAttachment)
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Payment Order';

                actionref(Statistics_Promoted; Statistics)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.FilterGroup(2);
        if not (Rec.GetFilter("Bank Account No.") <> '') then
            if Rec."Bank Account No." <> '' then
                Rec.SetRange("Bank Account No.", Rec."Bank Account No.");
        Rec.FilterGroup(0);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.FilterGroup(2);
        if Rec.GetFilter("Bank Account No.") <> '' then
            Rec."Bank Account No." := Rec.GetRangeMax("Bank Account No.");
        Rec.FilterGroup(0);
    end;

    trigger OnOpenPage()
    begin
        CurrPage.Lines.Page.FilterCanceledLines(CancelLinesFilter);
    end;

    var
        CancelLinesFilter: Option " ","Not Canceled",Canceled;

    local procedure CancelLinesFilterOnAfterVal()
    begin
        CurrPage.Update();
    end;

    local procedure PrintPaymentOrder()
    var
        IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
    begin
        IssPaymentOrderHeaderCZB := Rec;
        IssPaymentOrderHeaderCZB.SetRecFilter();
        IssPaymentOrderHeaderCZB.PrintRecords(true);
    end;
}
