// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

using Microsoft.Bank.BankAccount;

tableextension 11747 "Company Information CZL" extends "Company Information"
{
    fields
    {
        field(11770; "Default Bank Account Code CZL"; Code[20])
        {
            Caption = 'Default Bank Account Code';
            TableRelation = "Bank Account" where("Currency Code" = const(''));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
            begin
                if "Default Bank Account Code CZL" <> xRec."Default Bank Account Code CZL" then begin
                    BankAccount.SetFilter("Currency Code", '%1', '');
                    BankAccount.ModifyAll("Use as Default for Currency", false);
                end;
                if "Default Bank Account Code CZL" = '' then begin
                    UpdateBankInfoCZL('', '', '', '', '', '', '');
                    exit;
                end;
                BankAccount.Get("Default Bank Account Code CZL");
                UpdateBankInfoCZL(
                  BankAccount."No.",
                  BankAccount."Bank Account No.",
                  BankAccount."Bank Branch No.",
                  BankAccount.Name,
                  BankAccount."Transit No.",
                  BankAccount.IBAN,
                  BankAccount."SWIFT Code");
                BankAccount.Validate("Use as Default for Currency", true);
                BankAccount.Modify(false);
            end;
        }
        field(11771; "Bank Branch Name CZL"; Text[100])
        {
            Caption = 'Bank Branch Name';
            DataClassification = CustomerContent;
        }
        field(11772; "Bank Account Format Check CZL"; Boolean)
        {
            Caption = 'Bank Account Format Check';
            DataClassification = CustomerContent;
        }
        field(11782; "Tax Registration No. CZL"; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;
        }
    }

    procedure UpdateBankInfoCZL(BankAccountCode: Code[20]; BankAccountNo: Text[30]; BankBranchNo: Text[20]; BankName: Text[100]; TransitNo: Text[20]; IBANCode: Code[50]; SWIFTCode: Code[20])
    begin
        "Default Bank Account Code CZL" := BankAccountCode;
        "Bank Account No." := BankAccountNo;
        "Bank Branch No." := BankBranchNo;
        "Bank Name" := BankName;
        "Payment Routing No." := TransitNo;
        "IBAN" := IBANCode;
        "SWIFT Code" := SWIFTCode;
        OnAfterUpdateBankInfoCZL(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateBankInfoCZL(var CompanyInformation: Record "Company Information")
    begin
    end;
}
