// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.FinanceCharge;

using Microsoft.Bank;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Company;
using Microsoft.Sales.Customer;

codeunit 31014 "Fin. Charge Memo Handler CZL"
{
    var
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";

    [EventSubscriber(ObjectType::Table, Database::"Finance Charge Memo Header", 'OnAfterValidateEvent', 'Customer No.', false, false)]
    local procedure UpdateRegNoOnAfterCustomerNoValidate(var Rec: Record "Finance Charge Memo Header")
    var
        CompanyInformation: Record "Company Information";
        Customer: Record Customer;
    begin
        CompanyInformation.Get();
        Rec.Validate("Bank Account Code CZL", CompanyInformation."Default Bank Account Code CZL");

        if Rec."Customer No." <> '' then begin
            Customer.Get(Rec."Customer No.");
            Rec."Registration No. CZL" := Customer.GetRegistrationNoTrimmedCZL();
            Rec."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FinChrgMemo-Issue", 'OnAfterInitGenJnlLine', '', false, false)]
    local procedure UpdateBankInfoOnAfterInitGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; FinChargeMemoHeader: Record "Finance Charge Memo Header")
    begin
        GenJnlLine."VAT Reporting Date" := FinChargeMemoHeader."Posting Date";
        if GenJnlLine."Account Type" <> GenJnlLine."Account Type"::Customer then
            exit;

        GenJnlLine."Specific Symbol CZL" := FinChargeMemoHeader."Specific Symbol CZL";
        if FinChargeMemoHeader."Variable Symbol CZL" <> '' then
            GenJnlLine."Variable Symbol CZL" := FinChargeMemoHeader."Variable Symbol CZL"
        else
            GenJnlLine."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(GenJnlLine."Document No.");
        GenJnlLine."Constant Symbol CZL" := FinChargeMemoHeader."Constant Symbol CZL";
        GenJnlLine."Bank Account Code CZL" := FinChargeMemoHeader."Bank Account Code CZL";
        GenJnlLine."Bank Account No. CZL" := FinChargeMemoHeader."Bank Account No. CZL";
        GenJnlLine."Transit No. CZL" := FinChargeMemoHeader."Transit No. CZL";
        GenJnlLine."IBAN CZL" := FinChargeMemoHeader."IBAN CZL";
        GenJnlLine."SWIFT Code CZL" := FinChargeMemoHeader."SWIFT Code CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FinChrgMemo-Issue", 'OnBeforeIssuedFinChrgMemoHeaderInsert', '', false, false)]
    local procedure UpdateVariableSymbolOnBeforeIssuedFinChrgMemoHeaderInsert(var IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header")
    begin
        if IssuedFinChargeMemoHeader."Variable Symbol CZL" <> '' then
            exit;

        IssuedFinChargeMemoHeader."Variable Symbol CZL" := BankOperationsFunctionsCZL.CreateVariableSymbol(IssuedFinChargeMemoHeader."No.");
    end;
}
