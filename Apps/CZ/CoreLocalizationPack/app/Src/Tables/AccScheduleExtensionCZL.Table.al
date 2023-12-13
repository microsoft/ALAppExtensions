// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using Microsoft.Warehouse.Structure;

table 31092 "Acc. Schedule Extension CZL"
{
    Caption = 'Acc. Schedule Extension';
    LookupPageId = "Acc. Schedule Extensions CZL";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Source Table"; Enum "Acc. Schedule Source Table CZL")
        {
            Caption = 'Source Table';
            DataClassification = CustomerContent;
        }
        field(11; "Source Type"; Enum "Acc. Schedule Source Type CZL")
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
        }
        field(12; "Source Filter"; Text[100])
        {
            Caption = 'Source Filter';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                case "Source Type" of
                    "Source Type"::Customer:
                        if Page.RunModal(0, Customer) = Action::LookupOK then
                            "Source Filter" += Customer."No.";
                    "Source Type"::Vendor:
                        if Page.RunModal(0, Vendor) = Action::LookupOK then
                            "Source Filter" += Vendor."No.";
                    "Source Type"::"Bank Account":
                        if Page.RunModal(0, BankAccount) = Action::LookupOK then
                            "Source Filter" += BankAccount."No.";
                    "Source Type"::"Fixed Asset":
                        if Page.RunModal(0, FixedAsset) = Action::LookupOK then
                            "Source Filter" += FixedAsset."No.";
                end;
            end;
        }
        field(13; "G/L Account Filter"; Text[100])
        {
            Caption = 'G/L Account Filter';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                if Page.RunModal(0, GLAccount) = Action::LookupOK then
                    "G/L Account Filter" += GLAccount."No.";
            end;
        }
        field(14; "G/L Amount Type"; Option)
        {
            Caption = 'G/L Amount Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Debit,Credit';
            OptionMembers = " ",Debit,Credit;
        }
        field(15; "Amount Sign"; Option)
        {
            Caption = 'Amount Sign';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Positive,Negative';
            OptionMembers = " ",Positive,Negative;
        }
        field(16; "Entry Type"; Option)
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Purchase,Sale';
            OptionMembers = " ",Purchase,Sale;
        }
        field(17; Prepayment; Option)
        {
            Caption = 'Prepayment';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Yes,No';
            OptionMembers = " ",Yes,No;
            ObsoleteState = Removed;
            ObsoleteTag = '23.0';
            ObsoleteReason = 'Replaced by Advance Payments field in Advance Payments Localization for Czech app';
        }
        field(18; "Reverse Sign"; Boolean)
        {
            Caption = 'Reverse Sign';
            DataClassification = CustomerContent;
        }
        field(20; "VAT Amount Type"; Option)
        {
            Caption = 'VAT Amount Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Base,Amount';
            OptionMembers = " ",Base,Amount;
        }
        field(21; "VAT Bus. Post. Group Filter"; Text[100])
        {
            Caption = 'VAT Bus. Post. Group Filter';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                if Page.RunModal(0, VATBusinessPostingGroup) = Action::LookupOK then
                    "VAT Bus. Post. Group Filter" += VATBusinessPostingGroup.Code;
            end;
        }
        field(22; "VAT Prod. Post. Group Filter"; Text[100])
        {
            Caption = 'VAT Prod. Post. Group Filter';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                if Page.RunModal(0, VATProductPostingGroup) = Action::LookupOK then
                    "VAT Prod. Post. Group Filter" += VATProductPostingGroup.Code;
            end;
        }
        field(30; "Location Filter"; Text[100])
        {
            Caption = 'Location Filter';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                if "Source Table" = "Source Table"::"Value Entry" then
                    if Page.RunModal(0, Location) = Action::LookupOK then
                        "Location Filter" += Location.Code;
            end;
        }
        field(31; "Bin Filter"; Text[100])
        {
            Caption = 'Bin Filter';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                if "Source Table" = "Source Table"::"Value Entry" then begin
                    Bin.SetFilter("Location Code", "Location Filter");
                    if Page.RunModal(0, Bin) = Action::LookupOK then
                        "Bin Filter" += Bin.Code;
                end;
            end;
        }
        field(56; "Posting Group Filter"; Code[250])
        {
            Caption = 'Posting Group Filter';
            DataClassification = CustomerContent;
            TableRelation = if ("Source Table" = const("Customer Entry")) "Customer Posting Group"
            else
            if ("Source Table" = const("Vendor Entry")) "Vendor Posting Group";
            ValidateTableRelation = false;
        }
        field(57; "Posting Date Filter"; Code[20])
        {
            Caption = 'Posting Date Filter';
            DataClassification = CustomerContent;
        }
        field(58; "Due Date Filter"; Code[20])
        {
            Caption = 'Due Date Filter';
            DataClassification = CustomerContent;
        }
        field(59; "Document Type Filter"; Text[100])
        {
            Caption = 'Document Type Filter';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                case "Source Table" of
                    "Source Table"::"Customer Entry":
                        begin
                            CustLedgerEntry.SetFilter("Document Type", "Document Type Filter");
                            "Document Type Filter" := CopyStr(CustLedgerEntry.GetFilter("Document Type"),
                              1, MaxStrLen("Document Type Filter"));
                        end;
                    "Source Table"::"Vendor Entry":
                        begin
                            VendorLedgerEntry.SetFilter("Document Type", "Document Type Filter");
                            "Document Type Filter" := CopyStr(VendorLedgerEntry.GetFilter("Document Type"),
                              1, MaxStrLen("Document Type Filter"));
                        end;
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnRename()
    begin
        Error(RenameErr, TableCaption);
    end;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
        FixedAsset: Record "Fixed Asset";
        GLAccount: Record "G/L Account";
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        Location: Record Location;
        Bin: Record Bin;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        RenameErr: Label 'You cannot rename a %1.', Comment = '%1 = TableCaption';
}
