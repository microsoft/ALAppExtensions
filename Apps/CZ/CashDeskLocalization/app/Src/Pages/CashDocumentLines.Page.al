page 31163 "Cash Document Lines CZP"
{
    Caption = 'Cash Document Lines';
    Editable = false;
    PageType = List;
    SourceTable = "Cash Document Line CZP";
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;

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
                    Visible = false;
                }
                field("Cash Document No."; Rec."Cash Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of cash document.';
                }
                field("Gen. Document Type"; Rec."Gen. Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the cash desk general document type is payment or refund.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account thet the entry will be posted to. To see the options, choose the field.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the account that the entry on the journal line will be posted to.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of cash document line.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total amount that the cash document line consists of.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount in the cash document line.';
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
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the unit price on the line should be displayed including or excluding VAT.';
                    Visible = false;
                }
                field("Amount Including VAT (LCY)"; Rec."Amount Including VAT (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the unit price on the line should be displayed including or excluding VAT.';
                    Visible = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                }
                field("Cash Desk Event"; Rec."Cash Desk Event")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the cash desk event in the cash document lines.';
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies which salesperson is assigned to the cash document line.';
                }
            }
        }
    }
}
