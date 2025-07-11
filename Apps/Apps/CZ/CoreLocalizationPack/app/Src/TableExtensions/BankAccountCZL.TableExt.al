// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.BankAccount;

using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;
using System.Utilities;

tableextension 11746 "Bank Account CZL" extends "Bank Account"
{
    fields
    {
        field(11751; "Excl. from Exch. Rate Adj. CZL"; Boolean)
        {
            Caption = 'Exclude from Exch. Rate Adj.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Excl. from Exch. Rate Adj. CZL" then begin
                    TestField("Currency Code");
                    if not ConfirmManagement.GetResponseOrDefault(ExcludeEntriesQst, false) then
                        "Excl. from Exch. Rate Adj. CZL" := xRec."Excl. from Exch. Rate Adj. CZL";
                end;
            end;
        }
    }
    procedure CheckOpenBankAccLedgerEntriesCZL()
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.Get("No.");
        BankAccount.CalcFields(Balance, "Balance (LCY)");
        BankAccount.TestField(Balance, 0);
        BankAccount.TestField("Balance (LCY)", 0);
    end;

    procedure GetDefaultBankAccountNoCZL(ResponsibilityCenterCode: Code[10]; CurrencyCode: Code[10]) BankAccountNo: Code[20]
    begin
        if CurrencyCode = '' then begin
            BankAccountNo := GetDefaultBankAccountNoForResponsibilityCenterCZL(ResponsibilityCenterCode);
            if BankAccountNo = '' then
                BankAccountNo := GetDefaultBankAccountNoForCurrency(CurrencyCode);
        end else begin
            BankAccountNo := GetDefaultBankAccountNoForCurrency(CurrencyCode);
            if BankAccountNo = '' then
                BankAccountNo := GetDefaultBankAccountNoForResponsibilityCenterCZL(ResponsibilityCenterCode);
        end;
        if BankAccountNo = '' then
            BankAccountNo := GetDefaultBankAccountNoForCompanyInformationCZL();
    end;

    procedure GetDefaultBankAccountNoForResponsibilityCenterCZL(ResponsibilityCenterCode: Code[10]): Code[20]
    var
        ResponsibilityCenter: Record "Responsibility Center";
    begin
        if ResponsibilityCenterCode = '' then
            exit('');
        if not ResponsibilityCenter.Get(ResponsibilityCenterCode) then
            exit('');
        exit(ResponsibilityCenter."Default Bank Account Code CZL");
    end;

    procedure GetDefaultBankAccountNoForCompanyInformationCZL(): Code[20]
    var
        CompanyInformation: Record "Company Information";
    begin
        if not CompanyInformation.Get() then
            exit('');
        exit(CompanyInformation."Default Bank Account Code CZL");
    end;

    var
        ConfirmManagement: Codeunit "Confirm Management";
        ExcludeEntriesQst: Label 'All entries will be excluded from Exchange Rates Adjustment. Do you want to continue?';
}
