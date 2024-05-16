// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.Finance.Currency;
using Microsoft.Foundation.Address;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;

table 5024 "Service Declaration Line"
{

    fields
    {
        field(1; "Service Declaration No."; Code[20])
        {
            Caption = 'Service Declaration No.';
            TableRelation = "Service Declaration Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; "Service Transaction Code"; Code[20])
        {
            Caption = 'Service Transaction Code';
            TableRelation = "Service Transaction Type";
        }
        field(6; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(7; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            ValidateTableRelation = false;
        }
        field(8; "Sales Amount"; Decimal)
        {
            Caption = 'Sales Amount';
        }
        field(9; "Purchase Amount"; Decimal)
        {
            Caption = 'Purchase Amount';
        }
        field(10; "Sales Amount (LCY)"; Decimal)
        {
            Caption = 'Sales Amount (LCY)';
        }
        field(11; "Purchase Amount (LCY)"; Decimal)
        {
            Caption = 'Purchase Amount (LCY)';
        }
        field(12; "Item Charge No."; Code[20])
        {
            Caption = 'Item Charge No.';
            TableRelation = "Item Charge";
        }
        field(14; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            ObsoleteReason = 'Replaced with the VAT Reg. No.';
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
        }
        field(15; "VAT Reg. No."; Text[50])
        {
            Caption = 'Partner VAT ID';
        }
        field(30; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(31; "Document Type"; Enum "Item Ledger Document Type")
        {
            Caption = 'Document Type';
        }
        field(32; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(34; Description; Text[100])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Service Declaration No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        CheckHeaderStatusOpen();
    end;

    trigger OnInsert()
    begin
        CheckHeaderStatusOpen();
    end;

    trigger OnModify()
    begin
        CheckHeaderStatusOpen();
    end;

    trigger OnRename()
    begin
        xRec.CheckHeaderStatusOpen();
    end;

    procedure CheckHeaderStatusOpen()
    var
        ServiceDeclHeader: Record "Service Declaration Header";
    begin
        ServiceDeclHeader.Get(Rec."Service Declaration No.");
        ServiceDeclHeader.CheckStatusOpen();
    end;
}
