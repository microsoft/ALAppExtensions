// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.Bank.Reconciliation;

codeunit 31286 "Create Bank Acc. Rec. CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Acc. Reconciliation", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertBankAccReconciliation(var Rec: Record "Bank Acc. Reconciliation")
    var
        CreateBankAccount: Codeunit "Create Bank Account";
        CreateBankAccountCZ: Codeunit "Create Bank Account CZ";
    begin
        if Rec."Bank Account No." = CreateBankAccount.Checking() then
            Rec.Validate("Bank Account No.", CreateBankAccountCZ.WWBEUR());
        if Rec."Bank Account No." = CreateBankAccount.Savings() then
            Rec.Validate("Bank Account No.", CreateBankAccountCZ.NBL());
    end;
}
