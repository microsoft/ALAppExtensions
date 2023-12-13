// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Setup;
using Microsoft.Finance.Currency;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

tableextension 31021 "Posted Gen. Journal Line CZL" extends "Posted Gen. Journal Line"
{
    fields
    {
        field(11712; "VAT Delay CZL"; Boolean)
        {
            Caption = 'VAT Delay';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11717; "Specific Symbol CZL"; Code[10])
        {
            Caption = 'Specific Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;
        }
        field(11718; "Variable Symbol CZL"; Code[10])
        {
            Caption = 'Variable Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;
        }
        field(11719; "Constant Symbol CZL"; Code[10])
        {
            Caption = 'Constant Symbol';
            CharAllowed = '09';
            TableRelation = "Constant Symbol CZL";
            DataClassification = CustomerContent;
        }
        field(11720; "Bank Account Code CZL"; Code[20])
        {
            Caption = 'Bank Account Code';
            TableRelation = if ("Account Type" = const(Customer), "Document Type" = filter(Payment | "Credit Memo"))
              "Customer Bank Account".Code where("Customer No." = field("Bill-to/Pay-to No.")) else
            if ("Account Type" = const(Customer), "Document Type" = filter(Refund | Invoice))
              "Bank Account" else
            if ("Bal. Account Type" = const(Customer), "Document Type" = filter(Payment | "Credit Memo"))
              "Customer Bank Account".Code where("Customer No." = field("Bill-to/Pay-to No.")) else
            if ("Bal. Account Type" = const(Customer), "Document Type" = filter(Refund | Invoice))
              "Bank Account" else
            if ("Account Type" = const(Vendor), "Document Type" = filter(Payment | "Credit Memo"))
              "Bank Account" else
            if ("Account Type" = const(Vendor), "Document Type" = filter(Refund | Invoice))
              "Vendor Bank Account".Code where("Vendor No." = field("Bill-to/Pay-to No.")) else
            if ("Bal. Account Type" = const(Vendor), "Document Type" = filter(Payment | "Credit Memo"))
              "Bank Account" else
            if ("Bal. Account Type" = const(Vendor), "Document Type" = filter(Refund | Invoice))
              "Vendor Bank Account".Code where("Vendor No." = field("Bill-to/Pay-to No."));
            DataClassification = CustomerContent;
        }
        field(11721; "Bank Account No. CZL"; Text[30])
        {
            Caption = 'Bank Account No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11724; "Transit No. CZL"; Text[20])
        {
            Caption = 'Transit No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11725; "IBAN CZL"; Code[50])
        {
            Caption = 'IBAN';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11726; "SWIFT Code CZL"; Code[20])
        {
            Caption = 'SWIFT Code';
            Editable = false;
            TableRelation = "SWIFT Code";
            DataClassification = CustomerContent;
        }
        field(11776; "VAT Currency Factor CZL"; Decimal)
        {
            Caption = 'VAT Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(11777; "VAT Currency Code CZL"; Code[10])
        {
            Caption = 'VAT Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(11780; "VAT Date CZL"; Date)
        {
            Caption = 'VAT Date';
            DataClassification = CustomerContent;
        }
        field(11781; "Registration No. CZL"; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
        }
        field(11782; "Tax Registration No. CZL"; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;
        }
        field(31072; "EU 3-Party Intermed. Role CZL"; Boolean)
        {
            Caption = 'EU 3-Party Intermediate Role';
            DataClassification = CustomerContent;
        }
        field(31110; "Original Doc. Partner Type CZL"; Option)
        {
            Caption = 'Original Document Partner Type';
            OptionCaption = ' ,Customer,Vendor';
            OptionMembers = " ",Customer,Vendor;
            DataClassification = CustomerContent;
        }
        field(31111; "Original Doc. Partner No. CZL"; Code[20])
        {
            Caption = 'Original Document Partner No.';
            TableRelation = if ("Original Doc. Partner Type CZL" = const(Customer)) Customer else
            if ("Original Doc. Partner Type CZL" = const(Vendor)) Vendor;
            DataClassification = CustomerContent;
        }
        field(31112; "Original Doc. VAT Date CZL"; Date)
        {
            Caption = 'Original Document VAT Date';
            DataClassification = CustomerContent;
        }
    }
}
