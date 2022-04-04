page 1697 "Posted Bank Deposit Subform"
{
    AutoSplitKey = true;
    Caption = 'Posted Bank Deposit Subform';
    Editable = false;
    PageType = ListPart;
    PromotedActionCategories = 'New,Process,Report,Line,Functions';
    SourceTable = "Posted Bank Deposit Line";
    Permissions = tabledata "Posted Bank Deposit Line" = r;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account type from which the deposit was received.';
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the account number from which the deposit was received.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the transaction on the deposit line.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of the deposit document.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number of the document (usually a check) that was deposited.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the document (usually a check) that was deposited.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the item, such as a check, that was deposited.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the value assigned to this dimension for this deposit line.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the value assigned to this dimension for this deposit line.';
                    Visible = false;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry number from the general ledger account entry.';
                    Visible = false;
                }
            }
            group(Footer)
            {
                ShowCaption = false;
                group(LinesTotal)
                {
                    ShowCaption = false;
                    field(TotalDepositLines; TotalDepositLines)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Total Deposit Lines';
                        Editable = false;
                        ToolTip = 'Specifies the sum of the amounts in the Amount fields on the associated posted bank deposit lines.';
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(AccountCard)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Account &Card';
                    Image = Account;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View or change detailed information about the account on the deposit line.';

                    trigger OnAction()
                    begin
                        Rec.ShowAccountCard();
                    end;
                }
                action(AccountLedgerEntries)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Account Ledger E&ntries';
                    Image = LedgerEntries;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View ledger entries that are posted for the account on the deposit line.';

                    trigger OnAction()
                    begin
                        Rec.ShowAccountLedgerEntries();
                    end;
                }
                action(Dimensions)
                {
                    ApplicationArea = Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        TotalDepositLines := GetLinesTotal();
    end;

    local procedure GetLinesTotal(): Decimal
    begin
        if not PostedBankDepositHeader.Get(Rec."Bank Deposit No.") then
            exit(0);

        PostedBankDepositHeader.CalcFields("Total Deposit Lines");
        exit(PostedBankDepositHeader."Total Deposit Lines");
    end;

    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        TotalDepositLines: Decimal;

}

