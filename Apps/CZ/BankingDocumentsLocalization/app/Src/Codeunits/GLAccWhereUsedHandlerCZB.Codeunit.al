// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using System.Utilities;

codeunit 31372 "G/L Acc.Where-Used Handler CZB"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnAfterFillTableBuffer', '', false, false)]
    local procedure AddSetupTableOnAfterFillTableBuffer(var TableBuffer: Record "Integer")
    var
        CalcGLAccWhereUsed: Codeunit "Calc. G/L Acc. Where-Used";
    begin
        CalcGLAccWhereUsed.AddTable(TableBuffer, Database::"Bank Account");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnShowExtensionPage', '', false, false)]
    local procedure ShowSetupPageOnShowExtensionPage(GLAccountWhereUsed: Record "G/L Account Where-Used")
    var
        BankAccount: Record "Bank Account";
    begin
        if GLAccountWhereUsed."Table ID" = Database::"Bank Account" then begin
            BankAccount."No." := CopyStr(GLAccountWhereUsed."Key 1", 1, MaxStrLen(BankAccount."No."));
            Page.Run(0, BankAccount);
        end;
    end;
}
