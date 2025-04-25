// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.Bank.BankAccount;
using Microsoft.DemoData.Finance;

codeunit 11370 "Create Bank Acc Posting Grp BE"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccPostingGroup(var Rec: Record "Bank Account Posting Group"; RunTrigger: Boolean)
    var
        CreateBankAccPostingGrp: Codeunit "Create Bank Acc. Posting Grp";
        CreateBEGLAccount: Codeunit "Create GL Account BE";
    begin
        case Rec.Code of
            CreateBankAccPostingGrp.Checking():
                ValidateRecordFields(Rec, CreateBEGLAccount.BankLocalCurrency());
            CreateBankAccPostingGrp.Operating():
                ValidateRecordFields(Rec, CreateBEGLAccount.BankProcessing());
            CreateBankAccPostingGrp.Savings():
                ValidateRecordFields(Rec, CreateBEGLAccount.PostAccount());
        end;
    end;

    local procedure ValidateRecordFields(var BankAccountPostingGroup: Record "Bank Account Posting Group"; GLAccountNo: Code[20])
    begin
        BankAccountPostingGroup.Validate("G/L Account No.", GLAccountNo);
    end;
}
