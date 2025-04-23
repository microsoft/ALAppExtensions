// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;
using Microsoft.Bank.BankAccount;

codeunit 31193 "Create Bank Acc. Post. Grp CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
    begin
        ContosoPostingGroup.InsertBankAccountPostingGroup(NBL(), CreateGLAccountCZ.BankAccountKB());
        ContosoPostingGroup.InsertBankAccountPostingGroup(WWBEUR(), CreateGLAccountCZ.BankAccountEUR());
        ContosoPostingGroup.InsertBankAccountPostingGroup(CashDesk(), CreateGLAccountCZ.CashDeskLm());
        ContosoPostingGroup.InsertBankAccountPostingGroup(Credit(), CreateGLAccountCZ.ShortTermBankLoans());
    end;

    procedure DeleteBankAccountPostingGroups()
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
    begin
        BankAccountPostingGroup.DeleteAll();
    end;

    procedure CashDesk(): Code[20]
    begin
        exit(CashDeskTok);
    end;

    procedure Credit(): Code[20]
    begin
        exit(CreditTok);
    end;

    procedure NBL(): Code[20]
    begin
        exit(CreateBankAccountCZ.NBL());
    end;

    procedure WWBEUR(): Code[20]
    begin
        exit(CreateBankAccountCZ.WWBEUR());
    end;

    var
        CreateBankAccountCZ: Codeunit "Create Bank Account CZ";
        CashDeskTok: Label 'CASHDESK', MaxLength = 20;
        CreditTok: Label 'CREDIT', MaxLength = 20;
}
