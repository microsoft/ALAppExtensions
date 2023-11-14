// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

page 31152 "Cash Desk Statistics CZP"
{
    Caption = 'Cash Desk Statistics';
    Editable = false;
    PageType = Card;
    SourceTable = "Cash Desk CZP";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(BalanceToDate; BalanceToDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Start Balance';
                    ToolTip = 'Specifies the cash desk''s start balanc denominated in the applicable foreign currency.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                }
            }
            group("Net Change")
            {
                Caption = 'Net Change';
                fixed(Control1)
                {
                    ShowCaption = false;
                    group(Released)
                    {
                        Caption = 'Released';
                        field(RelReceipt; ReleasedReceipt)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Receipts';
                            ToolTip = 'Specifies quantity of receipts.';

                            trigger OnDrillDown()
                            begin
                                CashDocumentHeaderCZP.SetRange("Cash Desk No.", Rec."No.");
                                CashDocumentHeaderCZP.SetRange(Status, CashDocumentHeaderCZP.Status::Released);
                                CashDocumentHeaderCZP.SetRange("Document Type", CashDocumentHeaderCZP."Document Type"::Receipt);
                                Rec.CopyFilter("Date Filter", CashDocumentHeaderCZP."Posting Date");
                                Page.RunModal(0, CashDocumentHeaderCZP);
                            end;
                        }
                        field("-RelWithdrawal"; -ReleasedWithdrawal)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Withdrawals';
                            ToolTip = 'Specifies quantity of withdrawals.';

                            trigger OnDrillDown()
                            begin
                                CashDocumentHeaderCZP.SetRange("Cash Desk No.", Rec."No.");
                                CashDocumentHeaderCZP.SetRange(Status, CashDocumentHeaderCZP.Status::Released);
                                CashDocumentHeaderCZP.SetRange("Document Type", CashDocumentHeaderCZP."Document Type"::Withdrawal);
                                Rec.CopyFilter("Date Filter", CashDocumentHeaderCZP."Posting Date");
                                Page.RunModal(0, CashDocumentHeaderCZP);
                            end;
                        }
                    }
                    group(Posted)
                    {
                        Caption = 'Posted';
                        field(PostReceipt; PostedReceipt)
                        {
                            Caption = 'Posted Receipt';
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'Specifies the amount of posted receipts.';

                            trigger OnDrillDown()
                            begin
                                PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", Rec."No.");
                                PostedCashDocumentHdrCZP.SetRange("Document Type", PostedCashDocumentHdrCZP."Document Type"::Receipt);
                                Rec.CopyFilter("Date Filter", PostedCashDocumentHdrCZP."Posting Date");
                                Page.RunModal(0, PostedCashDocumentHdrCZP);
                            end;
                        }
                        field(PostWithdrawal; -PostedWithdrawal)
                        {
                            Caption = 'Posted Withdrawal';
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'Specifies the amount of posted withdrawals.';

                            trigger OnDrillDown()
                            begin
                                PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", Rec."No.");
                                PostedCashDocumentHdrCZP.SetRange("Document Type", PostedCashDocumentHdrCZP."Document Type"::Withdrawal);
                                Rec.CopyFilter("Date Filter", PostedCashDocumentHdrCZP."Posting Date");
                                Page.RunModal(0, PostedCashDocumentHdrCZP);
                            end;
                        }
                    }
                }
            }
            group(Total)
            {
                Caption = 'Total';
                field(BalanceTotal; BalanceTotal)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'End Balance';
                    ToolTip = 'Specifies the amount of end balance cash desk.';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        CashDeskCZP: Record "Cash Desk CZP";
    begin
        if Rec.GetFilter("Date Filter") <> '' then begin
            CashDeskCZP."No." := Rec."No.";
            CashDeskCZP.SetFilter("Date Filter", '..%1', CalcDate('<-1D>', Rec.GetRangeMin("Date Filter")));
            BalanceToDate := CashDeskCZP.CalcBalance();
        end else
            BalanceToDate := 0;
        ReleasedReceipt := Rec.CalcOpenedReceipts();
        ReleasedWithdrawal := Rec.CalcOpenedWithdrawals();
        PostedReceipt := Rec.CalcPostedReceipts();
        PostedWithdrawal := Rec.CalcPostedWithdrawals();
        BalanceTotal := BalanceToDate + ReleasedReceipt + ReleasedWithdrawal + PostedReceipt + PostedWithdrawal;
    end;

    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        BalanceToDate: Decimal;
        ReleasedReceipt: Decimal;
        ReleasedWithdrawal: Decimal;
        PostedReceipt: Decimal;
        PostedWithdrawal: Decimal;
        BalanceTotal: Decimal;
}
