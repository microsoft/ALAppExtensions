// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Address;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

table 10832 "Payment Address FR"
{
    Caption = 'Payment Address';
    DrillDownPageID = "Payment Addresses FR";
    LookupPageID = "Payment Addresses FR";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Account Type"; enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
        }
        field(2; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = if ("Account Type" = const(Customer)) Customer
            else
            if ("Account Type" = const(Vendor)) Vendor;
        }
        field(3; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(4; Name; Text[50])
        {
            Caption = 'Name';

            trigger OnValidate()
            begin
                if ("Search Name" = UpperCase(xRec.Name)) or ("Search Name" = '') then
                    "Search Name" := Name;
            end;
        }
        field(5; "Search Name"; Code[50])
        {
            Caption = 'Search Name';
        }
        field(6; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
        }
        field(7; Address; Text[50])
        {
            Caption = 'Address';
        }
        field(8; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(9; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            TableRelation = if ("Country/Region Code" = const('')) "Post Code"
            else
            if ("Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(10; City; Text[30])
        {
            Caption = 'City';
            TableRelation = if ("Country/Region Code" = const('')) "Post Code".City
            else
            if ("Country/Region Code" = filter(<> '')) "Post Code".City where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(11; Contact; Text[50])
        {
            Caption = 'Contact';
        }
        field(12; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(13; County; Text[30])
        {
            Caption = 'County';
        }
        field(20; "Default Value"; Boolean)
        {
            Caption = 'Default Value';

            trigger OnValidate()
            var
                PaymentAddress: Record "Payment Address FR";
            begin
                if "Default Value" then begin
                    PaymentAddress.SetRange("Account Type", "Account Type");
                    PaymentAddress.SetRange("Account No.", "Account No.");
                    PaymentAddress.SetFilter(Code, '<>%1', Code);
                    PaymentAddress.ModifyAll("Default Value", false, false);
                end;
            end;
        }
    }

    keys
    {
        key(Key1; "Account Type", "Account No.", "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        PostCode: Record "Post Code";
}
