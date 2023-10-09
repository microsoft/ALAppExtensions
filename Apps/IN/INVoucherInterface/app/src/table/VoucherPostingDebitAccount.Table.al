// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Intercompany.Partner;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 18929 "Voucher Posting Debit Account"
{
    Caption = 'Voucher Posting Debit Accounts';

    fields
    {
        field(1; "Location code"; Code[10])
        {
            TableRelation = Location.Code;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Type"; Enum "Gen. Journal Template Type")
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Account Type"; Enum "Gen. Journal Account Type")
        {
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            begin
                CheckAccountType();
            end;
        }
        field(4; "Account No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor
            else
            if ("Account Type" = const("Bank Account")) "Bank Account"
            else
            if ("Account Type" = const("Fixed Asset")) "Fixed Asset"
            else
            if ("Account Type" = const("IC Partner")) "IC Partner";

            trigger OnValidate()
            begin
                CheckAccountType();
            end;
        }
        field(5; "For UPI Payments"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
            begin
                if "For UPI Payments" then begin
                    CheckAccountType();
                    BankAccount.Get("Account No.");
                    BankAccount.TestField("UPI ID");
                end;
            end;
        }
    }
    keys
    {
        key(Key1; "Location code", "Type", "Account Type", "Account No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        CheckAccountType();
    end;

    trigger OnModify()
    begin
        CheckAccountType();
    end;

    local procedure CheckAccountType()
    begin
        if (("Type" = "Type"::"Cash Receipt Voucher") or
            ("Type" = "Type"::"Cash Payment Voucher"))
        then
            TestField("Account Type", "Account Type"::"G/L Account");
        if (("Type" = "Type"::"Bank Receipt Voucher") or
            ("Type" = "Type"::"Bank Payment Voucher"))
        then
            TestField("Account Type", "Account Type"::"Bank Account");
    end;
}
