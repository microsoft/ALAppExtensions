// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

page 18930 "Journal Voucher Posting Setup"
{
    Caption = 'Voucher Posting Setup';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Journal Voucher Posting Setup";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Type"; "Type")
                {
                    Caption = 'Type';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the journal template being created.';
                }
                field("Posting No. Series"; "Posting No. Series")
                {
                    Caption = 'Posting No. Series';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies code of the number series that will be used to assign document numbers to ledger entries that are posted from this journal batch.';
                }
                field("Transaction Direction"; "Transaction Direction")
                {
                    Caption = 'Transaction Direction';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of transaction directions such as debit or credit.';
                    trigger OnValidate()
                    begin
                        SetActionEditable();
                        CurrPage.Update(true);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Debit Account")
            {
                PromotedOnly = true;
                ApplicationArea = Basic, Suite;
                Caption = 'Debit Account';
                ToolTip = 'Specifies the account type and account number for debit transaction.';
                Image = ChartOfAccounts;
                Enabled = DebitActionEditable;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Voucher Posting Debit Accounts";
                RunPageLink = "Location code" = field("Location Code"), Type = field(Type);
            }
            action("Credit Account")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Credit Account';
                ToolTip = 'Specifies the account type and account number for credit transaction.';
                Image = ChartOfAccounts;
                Enabled = CreditActionEditable;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Voucher Posting Credit Account";
                RunPageLink = "Location code" = field("Location Code"), Type = field(Type);
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetActionEditable();
    end;

    var
        DebitActionEditable: Boolean;
        CreditActionEditable: Boolean;

    local procedure SetActionEditable()
    begin
        DebitActionEditable := false;
        CreditActionEditable := false;
        case "Transaction Direction" of
            "Transaction Direction"::Both:
                begin
                    DebitActionEditable := true;
                    CreditActionEditable := true;
                end;
            "Transaction Direction"::Credit:
                CreditActionEditable := true;
            "Transaction Direction"::Debit:
                DebitActionEditable := true;
        end;
    end;
}
