// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.Bank.BankAccount;
using Microsoft.DemoData.Finance;

codeunit 11158 "Create Bank Acc Posting Grp AT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccPostingGroup(var Rec: Record "Bank Account Posting Group"; RunTrigger: Boolean)
    var
        CreateBankAccPostingGrp: Codeunit "Create Bank Acc. Posting Grp";
        CreateATGLAccount: Codeunit "Create AT GL Account";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        case Rec.Code of
            CreateBankAccPostingGrp.Checking():
                ValidateRecordFields(Rec, CreateGLAccount.BankLcy());
            CreateBankAccPostingGrp.Savings(),
            CreateBankAccPostingGrp.Operating():
                ValidateRecordFields(Rec, CreateGLAccount.GiroAccount());
            CreateBankAccPostingGrp.Cash():
                ValidateRecordFields(Rec, CreateATGLAccount.BankCurrencies());
        end;
    end;

    local procedure ValidateRecordFields(var BankAccountPostingGroup: Record "Bank Account Posting Group"; GLAccountNo: Code[20])
    begin
        BankAccountPostingGroup.Validate("G/L Account No.", GLAccountNo);
    end;
}
