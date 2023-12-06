// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

using Microsoft.Bank;

codeunit 31042 "Customer Bank Acc. Handler CZL"
{
    var
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnBeforeValidateEvent', 'Bank Account No.', false, false)]
    local procedure CheckCzBankAccountNoOnBeforeBankAccountNoValidate(var Rec: Record "Customer Bank Account")
    begin
        BankOperationsFunctionsCZL.CheckCzBankAccountNo(Rec."Bank Account No.", Rec."Country/Region Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnBeforeValidateEvent', 'Country/Region Code', false, false)]
    local procedure CheckCzBankAccountNoOnBeforeCountryRegionCodeValidate(var Rec: Record "Customer Bank Account")
    begin
        BankOperationsFunctionsCZL.CheckCzBankAccountNo(Rec."Bank Account No.", Rec."Country/Region Code");
    end;
}
