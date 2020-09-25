page 1453 "MS - Yodlee NonLinked Accounts"
{
    Caption = 'Non-Linked Bank Accounts';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = 1451;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
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
                field("Bank Account No."; "Bank Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the account number of the online bank account.';
                }
                field("Currency Code"; "Currency Code")
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
                    BankAccount: Record 270;
                    MSYodleeServiceMgt: Codeunit 1450;
                begin
                    MSYodleeServiceMgt.CreateNewBankAccountFromTemp(BankAccount, Rec);

                    LinkedBankAccountNo := BankAccount."No.";
                    BankBranchNumber := BankAccount."Bank Branch No.";
                    UpdateTempLink(LinkedBankAccountNo);

                    CurrPage.UPDATE(TRUE);
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
                    TempBankAccount: Record 270 temporary;
                    BankAccountList: Page 371;
                begin
                    TempBankAccount.GetUnlinkedBankAccounts(TempBankAccount);
                    BankAccountList.SETTABLEVIEW(TempBankAccount);
                    BankAccountList.LOOKUPMODE := TRUE;
                    IF BankAccountList.RUNMODAL() = ACTION::LookupOK THEN BEGIN
                        BankAccountList.GETRECORD(TempBankAccount);
                        LinkedBankAccountNo := TempBankAccount."No.";
                        ValidateLinkedBankAccount();
                    END;
                end;
            }
            action(UnlinkOnlineBankAccount)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Remove Online Bank Account';
                Image = UnLinkAccount;
                Promoted = true;
                PromotedIsBig = true;
                ToolTip = 'Remove the non-linked online bank account.';

                trigger OnAction();
                var
                    MSYodleeServiceMgt: Codeunit 1450;
                begin
                    IF LinkedBankAccountNo <> '' THEN
                        RENAME(LinkedBankAccountNo);

                    MSYodleeServiceMgt.UnlinkBankAccountFromYodlee(Rec);

                    IF COUNT() = 0 THEN BEGIN
                        MESSAGE(NoMoreAccountsMsg);
                        CurrPage.CLOSE();
                    END;
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

    local procedure UpdateLinkedBankAccountValues(var AccountNo: Code[20]; var BankBranchNo: Text[20]);
    var
        MSYodleeBankAccLink: Record 1451;
        BankAccount: Record 270;
    begin
        AccountNo := '';
        BankBranchNo := '';

        IF "Online Bank Account ID" = '' THEN
            EXIT;

        MSYodleeBankAccLink.SETRANGE("Online Bank Account ID", "Online Bank Account ID");
        IF MSYodleeBankAccLink.FINDFIRST() THEN BEGIN
            AccountNo := MSYodleeBankAccLink."No.";
            BankAccount.GET(AccountNo);
            BankBranchNo := BankAccount."Bank Branch No.";
        END;
    end;

    local procedure UpdateTempLink(Value: Code[20]);
    begin
        "Temp Linked Bank Account No." := Value;
        MODIFY();
        CurrPage.UPDATE(FALSE);
    end;

    local procedure ValidateLinkedBankAccount();
    var
        MSYodleeBankAccLink: Record 1451;
        MSYodleeServiceMgt: Codeunit 1450;
    begin
        IF MSYodleeBankAccLink.GET(LinkedBankAccountNo) THEN
            ERROR(AccountIsAlreadyLinkedErr, MSYodleeBankAccLink.Name);

        IF "Online Bank Account ID" <> '' THEN BEGIN // re-select?
            MSYodleeBankAccLink.SETRANGE("Online Bank Account ID", "Online Bank Account ID");
            IF MSYodleeBankAccLink.FINDFIRST() THEN
                IF (LinkedBankAccountNo = '') OR (MSYodleeBankAccLink."No." <> LinkedBankAccountNo) THEN BEGIN
                    MSYodleeServiceMgt.MarkBankAccountAsUnlinked(MSYodleeBankAccLink."No.");

                    UpdateTempLink('');
                END ELSE
                    EXIT;
        END;

        IF LinkedBankAccountNo = '' THEN
            EXIT;

        IF MSYodleeServiceMgt.MarkBankAccountAsLinked(LinkedBankAccountNo, Rec) THEN
            UpdateTempLink(LinkedBankAccountNo);
    end;
}

