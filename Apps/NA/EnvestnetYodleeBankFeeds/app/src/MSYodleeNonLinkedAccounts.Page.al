namespace Microsoft.Bank.StatementImport.Yodlee;

using Microsoft.Bank.BankAccount;

page 1453 "MS - Yodlee NonLinked Accounts"
{
    Caption = 'Non-Linked Bank Accounts';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "MS - Yodlee Bank Acc. Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the name of the online bank account.';
                }
                field(BankBranchNo; BankBranchNumber)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Branch No.';
                    Editable = false;
                    ToolTip = 'Specifies the branch number of the online bank account.';
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the account number of the online bank account.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the currency that is primarily used in the online bank account. This must match the bank account that it is linked to.';
                }
                field(LinkedBankAccount; LinkedBankAccountNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Linked Bank Account';
                    TableRelation = "Bank Account"."No.";
                    ToolTip = 'Specifies the bank account that the online bank account is linked to.';

                    trigger OnValidate();
                    begin
                        ValidateLinkedBankAccount();
                    end;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(LinkToNewBankAccount)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Link to New Bank Account';
                Ellipsis = true;
                Enabled = CreateActionEnabled;
                Image = NewBank;
                Promoted = true;
                PromotedIsBig = true;
                ToolTip = 'Create a new bank account with information from the non-linked bank account and link it to the related online bank account.';

                trigger OnAction();
                var
                    BankAccount: Record "Bank Account";
                    MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
                begin
                    MSYodleeServiceMgt.CreateNewBankAccountFromTemp(BankAccount, Rec);

                    LinkedBankAccountNo := BankAccount."No.";
                    BankBranchNumber := BankAccount."Bank Branch No.";
                    UpdateTempLink(LinkedBankAccountNo);

                    CurrPage.UPDATE(true);
                end;
            }
            action(LinkToExistingBankAccount)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Link to Existing Bank Account';
                Ellipsis = true;
                Image = LinkWithExisting;
                Promoted = true;
                PromotedIsBig = true;
                ToolTip = 'Link the non-linked bank account to an online bank account.';

                trigger OnAction();
                var
                    TempBankAccount: Record "Bank Account" temporary;
                    BankAccountList: Page "Bank Account List";
                begin
                    TempBankAccount.GetUnlinkedBankAccounts(TempBankAccount);
                    BankAccountList.SETTABLEVIEW(TempBankAccount);
                    BankAccountList.LOOKUPMODE := true;
                    if BankAccountList.RUNMODAL() = ACTION::LookupOK then begin
                        BankAccountList.GETRECORD(TempBankAccount);
                        LinkedBankAccountNo := TempBankAccount."No.";
                        ValidateLinkedBankAccount();
                    end;
                end;
            }
            action(UnlinkOnlineBankAccount)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Remove Online Bank Account';
                Image = UnLinkAccount;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Remove the non-linked online bank account.';

                trigger OnAction();
                var
                    MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
                begin
                    if LinkedBankAccountNo <> '' then
                        Rec.RENAME(LinkedBankAccountNo);

                    MSYodleeServiceMgt.UnlinkBankAccountFromYodlee(Rec);

                    if Rec.COUNT() = 0 then begin
                        MESSAGE(NoMoreAccountsMsg);
                        CurrPage.CLOSE();
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord();
    begin
        UpdateLinkedBankAccountValues(LinkedBankAccountNo, BankBranchNumber);
        CreateActionEnabled := LinkedBankAccountNo = '';
    end;

    trigger OnAfterGetRecord();
    begin
        UpdateLinkedBankAccountValues(LinkedBankAccountNo, BankBranchNumber);
    end;

    var
        CreateActionEnabled: Boolean;
        LinkedBankAccountNo: Code[20];
        BankBranchNumber: Text[20];
        AccountIsAlreadyLinkedErr: Label '%1 is already linked. Please select another account.', Comment = '%1 is the bank account name';
        NoMoreAccountsMsg: Label 'All non-linked bank accounts have been removed. This page will now close.';

    local procedure UpdateLinkedBankAccountValues(var AccountNo: Code[20]; var BankBranchNum: Text[20]);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        BankAccount: Record "Bank Account";
    begin
        AccountNo := '';
        BankBranchNum := '';

        if Rec."Online Bank Account ID" = '' then
            exit;

        MSYodleeBankAccLink.SETRANGE("Online Bank Account ID", Rec."Online Bank Account ID");
        if MSYodleeBankAccLink.FINDFIRST() then begin
            AccountNo := MSYodleeBankAccLink."No.";
            BankAccount.GET(AccountNo);
            BankBranchNum := BankAccount."Bank Branch No.";
        end;
    end;

    local procedure UpdateTempLink(Value: Code[20]);
    begin
        Rec."Temp Linked Bank Account No." := Value;
        Rec.MODIFY();
        CurrPage.UPDATE(false);
    end;

    local procedure ValidateLinkedBankAccount();
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        MSYodleeServiceMgt: Codeunit "MS - Yodlee Service Mgt.";
    begin
        if MSYodleeBankAccLink.GET(LinkedBankAccountNo) then
            ERROR(AccountIsAlreadyLinkedErr, MSYodleeBankAccLink.Name);

        if Rec."Online Bank Account ID" <> '' then begin // re-select?
            MSYodleeBankAccLink.SETRANGE("Online Bank Account ID", Rec."Online Bank Account ID");
            if MSYodleeBankAccLink.FINDFIRST() then
                if (LinkedBankAccountNo = '') or (MSYodleeBankAccLink."No." <> LinkedBankAccountNo) then begin
                    MSYodleeServiceMgt.MarkBankAccountAsUnlinked(MSYodleeBankAccLink."No.");

                    UpdateTempLink('');
                end else
                    exit;
        end;

        if LinkedBankAccountNo = '' then
            exit;

        if MSYodleeServiceMgt.MarkBankAccountAsLinked(LinkedBankAccountNo, Rec) then
            UpdateTempLink(LinkedBankAccountNo);
    end;
}

#pragma implicitwith restore

