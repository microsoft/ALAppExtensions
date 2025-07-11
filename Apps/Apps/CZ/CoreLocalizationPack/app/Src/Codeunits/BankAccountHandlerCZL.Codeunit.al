// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.BankAccount;

using Microsoft.Bank;

codeunit 11776 "Bank Account Handler CZL"
{
    var
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeValidateEvent', 'Bank Account No.', false, false)]
    local procedure CheckCzBankAccountNoOnBeforeBankAccountNoValidate(var Rec: Record "Bank Account")
    begin
        BankOperationsFunctionsCZL.CheckCzBankAccountNo(Rec."Bank Account No.", Rec."Country/Region Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeValidateEvent', 'Country/Region Code', false, false)]
    local procedure CheckCzBankAccountNoOnBeforeCountryRegionCodeValidate(var Rec: Record "Bank Account")
    begin
        BankOperationsFunctionsCZL.CheckCzBankAccountNo(Rec."Bank Account No.", Rec."Country/Region Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnBeforeValidateEvent', 'Bank Acc. Posting Group', false, false)]
    local procedure CheckChangeBankAccPostingGroupOnBeforeBankAccPostingGroupValidate(var Rec: Record "Bank Account"; var xRec: Record "Bank Account")
    begin
        if Rec."Bank Acc. Posting Group" <> xRec."Bank Acc. Posting Group" then
            Rec.CheckOpenBankAccLedgerEntriesCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnAfterValidateEvent', 'Currency Code', false, false)]
    local procedure ExclFromExchRateAdjOnAfterCurrencyCodeValidate(var Rec: Record "Bank Account")
    begin
        if Rec."Currency Code" = '' then
            Rec."Excl. from Exch. Rate Adj. CZL" := false;
    end;
}
