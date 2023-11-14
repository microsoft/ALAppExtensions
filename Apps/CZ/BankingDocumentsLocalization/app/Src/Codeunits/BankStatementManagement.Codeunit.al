// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Security.User;

codeunit 31360 "Bank Statement Management CZB"
{
    procedure BankStatementSelection(var BankStatementHeaderCZB: Record "Bank Statement Header CZB"; var SelectedBankAccountForBankStatement: Boolean)
    var
        BankAccount: Record "Bank Account";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeBankStatementSelection(BankStatementHeaderCZB, SelectedBankAccountForBankStatement, IsHandled);
        if IsHandled then
            exit;

        BankAccount.SetRange(Blocked, false);
        SelectedBankAccountForBankStatement := SelectBankAccount(BankAccount);
        if SelectedBankAccountForBankStatement then begin
            CheckBankAccessAllowed(BankAccount."No.");
            BankStatementHeaderCZB.FilterGroup := 2;
            BankStatementHeaderCZB.SetRange("Bank Account No.", BankAccount."No.");
            BankStatementHeaderCZB.FilterGroup := 0;
        end;
    end;

    procedure IssuedBankStatementSelection(var IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; var SelectedBankAccountForBankStatement: Boolean)
    var
        BankAccount: Record "Bank Account";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeIssuedBankStatementSelection(IssBankStatementHeaderCZB, SelectedBankAccountForBankStatement, IsHandled);
        if IsHandled then
            exit;

        SelectedBankAccountForBankStatement := SelectBankAccount(BankAccount);
        if SelectedBankAccountForBankStatement then begin
            CheckBankAccessAllowed(BankAccount."No.");
            IssBankStatementHeaderCZB.FilterGroup := 2;
            IssBankStatementHeaderCZB.SetRange("Bank Account No.", BankAccount."No.");
            IssBankStatementHeaderCZB.FilterGroup := 0;
        end;
    end;

    local procedure SelectBankAccount(var BankAccount: Record "Bank Account") IsSelected: Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeSelectBankAccount(BankAccount, IsSelected, IsHandled);
        if IsHandled then
            exit;

        case BankAccount.Count() of
            0:
                exit(false);
            1:
                begin
                    BankAccount.FindFirst();
                    exit(true);
                end;
            else
                exit(Page.RunModal(Page::"Bank Account List", BankAccount) = Action::LookupOK);
        end;
    end;

    local procedure CheckBankAccessAllowed(BankAccountNo: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        UserSetupAdvManagementCZB: Codeunit "User Setup Adv. Management CZB";
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."User Checks Allowed CZL" then
            UserSetupAdvManagementCZB.CheckBankAccountNo(UserSetupLineTypeCZL::"Bank Statement", BankAccountNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBankStatementSelection(var BankStatementHeaderCZB: Record "Bank Statement Header CZB"; var BankStatementSelected: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIssuedBankStatementSelection(var IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; var BankStatementSelected: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSelectBankAccount(var BankAccount: Record "Bank Account"; var IsSelected: Boolean; var IsHandled: Boolean)
    begin
    end;
}
