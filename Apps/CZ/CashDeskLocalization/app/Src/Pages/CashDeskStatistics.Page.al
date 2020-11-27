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
                                CashDocHeaderCZP.SetRange("Cash Desk No.", Rec."No.");
                                CashDocHeaderCZP.SetRange(Status, CashDocHeaderCZP.Status::Released);
                                CashDocHeaderCZP.SetRange("Document Type", CashDocHeaderCZP."Document Type"::Receipt);
                                Rec.CopyFilter("Date Filter", CashDocHeaderCZP."Posting Date");
                                Page.RunModal(0, CashDocHeaderCZP);
                            end;
                        }
                        field("-RelWithdrawal"; -ReleasedWithdrawal)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Withdrawals';
                            ToolTip = 'Specifies quantity of withdrawals.';

                            trigger OnDrillDown()
                            begin
                                CashDocHeaderCZP.SetRange("Cash Desk No.", Rec."No.");
                                CashDocHeaderCZP.SetRange(Status, CashDocHeaderCZP.Status::Released);
                                CashDocHeaderCZP.SetRange("Document Type", CashDocHeaderCZP."Document Type"::Withdrawal);
                                Rec.CopyFilter("Date Filter", CashDocHeaderCZP."Posting Date");
                                Page.RunModal(0, CashDocHeaderCZP);
                            end;
                        }
                    }
                    group(Posted)
                    {
                        Caption = 'Posted';
                        field(PostReceipt; PostedReceipt)
                        {
                            Caption = 'PostedReceipt';
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'Specifies quantity of post receipts.';

                            trigger OnDrillDown()
                            begin
                                PostedCashDocHeader.SetRange("Cash Desk No.", Rec."No.");
                                PostedCashDocHeader.SetRange("Document Type", PostedCashDocHeader."Document Type"::Receipt);
                                Rec.CopyFilter("Date Filter", PostedCashDocHeader."Posting Date");
                                Page.RunModal(0, PostedCashDocHeader);
                            end;
                        }
                        field(PostWithdrawal; -PostedWithdrawal)
                        {
                            Caption = 'Posted Withdrawal';
                            ApplicationArea = Basic, Suite;
                            ToolTip = 'Specifies quantity of post withdrawals.';

                            trigger OnDrillDown()
                            begin
                                PostedCashDocHeader.SetRange("Cash Desk No.", Rec."No.");
                                PostedCashDocHeader.SetRange("Document Type", PostedCashDocHeader."Document Type"::Withdrawal);
                                Rec.CopyFilter("Date Filter", PostedCashDocHeader."Posting Date");
                                Page.RunModal(0, PostedCashDocHeader);
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
        CashDocHeaderCZP: Record "Cash Document Header CZP";
        PostedCashDocHeader: Record "Posted Cash Document Hdr. CZP";
        BalanceToDate: Decimal;
        ReleasedReceipt: Decimal;
        ReleasedWithdrawal: Decimal;
        PostedReceipt: Decimal;
        PostedWithdrawal: Decimal;
        BalanceTotal: Decimal;
}
