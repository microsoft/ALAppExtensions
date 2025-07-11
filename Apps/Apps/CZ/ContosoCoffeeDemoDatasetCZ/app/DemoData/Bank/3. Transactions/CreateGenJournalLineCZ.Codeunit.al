// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.Finance.GeneralLedger.Journal;

codeunit 31285 "Create Gen. Journal Line CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertGenJournalLine(var Rec: Record "Gen. Journal Line")
    var
        CreateBankAccount: Codeunit "Create Bank Account";
        CreateBankAccountCZ: Codeunit "Create Bank Account CZ";
        CreateCurrencyExRateCZ: Codeunit "Create Currency Ex. Rate CZ";
    begin
        if (Rec."Account Type" = Rec."Account Type"::"Bank Account") and
           (Rec."Account No." = CreateBankAccount.Checking())
        then
            Rec.Validate("Account No.", CreateBankAccountCZ.WWBEUR());
        if (Rec."Bal. Account Type" = Rec."Bal. Account Type"::"Bank Account") and
           (Rec."Bal. Account No." = CreateBankAccount.Checking())
        then
            Rec.Validate("Bal. Account No.", CreateBankAccountCZ.WWBEUR());
        if (Rec."Account Type" = Rec."Account Type"::"Bank Account") and
           (Rec."Account No." = CreateBankAccount.Savings())
        then
            Rec.Validate("Account No.", CreateBankAccountCZ.NBL());
        if (Rec."Bal. Account Type" = Rec."Bal. Account Type"::"Bank Account") and
           (Rec."Bal. Account No." = CreateBankAccount.Savings())
        then
            Rec.Validate("Bal. Account No.", CreateBankAccountCZ.NBL());
        if Rec."Currency Code" = '' then
            Rec.Validate(Amount, Rec.Amount / CreateCurrencyExRateCZ.GetLocalCurrencyFactor());
    end;
}
