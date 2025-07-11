// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.Bank.BankAccount;
using Microsoft.DemoData.Finance;

codeunit 10873 "Create Bank Acc. Post. Grp FR"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccountingpostingGrp(var Rec: Record "Bank Account Posting Group")
    var
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateBankAccPostingGroup: Codeunit "Create Bank Acc. Posting Grp";
    begin
        case Rec.Code of
            CreateBankAccPostingGroup.Checking():
                ValidateBankAccountingpostingGrp(Rec, CreateGLAccount.BankLcy());
            CreateBankAccPostingGroup.Operating():
                ValidateBankAccountingpostingGrp(Rec, CreateGLAccount.RevolvingCredit());
            CreateBankAccPostingGroup.Savings():
                ValidateBankAccountingpostingGrp(Rec, CreateGLAccount.GiroAccount());
        end;
    end;

    local procedure ValidateBankAccountingpostingGrp(var BankAccountPostingGrp: Record "Bank Account Posting Group"; GLAccountNo: Code[20])
    begin
        BankAccountPostingGrp.Validate("G/L Account No.", GLAccountNo);
    end;
}
