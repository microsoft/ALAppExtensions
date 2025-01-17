// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

table 31275 "Posted Compensation Line CZC"
{
    Caption = 'Posted Compensation Line';
    DrillDownPageID = "Posted Compensation Lines CZC";
    LookupPageID = "Posted Compensation Lines CZC";

    fields
    {
        field(5; "Compensation No."; Code[20])
        {
            Caption = 'Compensation No.';
            TableRelation = "Posted Compensation Header CZC";
            DataClassification = CustomerContent;
        }
        field(10; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(13; "Compensation Posting Date"; Date)
        {
            Caption = 'Compensation Posting Date';
            DataClassification = CustomerContent;
        }
        field(15; "Source Type"; Enum "Compensation Source Type CZC")
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
        }
        field(20; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = if ("Source Type" = const(Customer)) Customer."No." else
            if ("Source Type" = const(Vendor)) Vendor."No.";
            DataClassification = CustomerContent;
        }
        field(22; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            TableRelation = if ("Source Type" = const(Customer)) "Customer Posting Group" else
            if ("Source Type" = const(Vendor)) "Vendor Posting Group";
            DataClassification = CustomerContent;
        }
        field(23; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
            DataClassification = CustomerContent;
        }
        field(24; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
            DataClassification = CustomerContent;
        }
        field(25; "Source Entry No."; Integer)
        {
            Caption = 'Source Entry No.';
            TableRelation = if ("Source Type" = const(Customer)) "Cust. Ledger Entry"."Entry No." else
            if ("Source Type" = const(Vendor)) "Vendor Ledger Entry"."Entry No.";
            DataClassification = CustomerContent;
        }
        field(30; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(35; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(40; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(45; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(50; "Variable Symbol"; Code[10])
        {
            Caption = 'Variable Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;
        }
        field(75; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(77; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate(Amount);
            end;
        }
        field(80; "Ledg. Entry Original Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Ledg. Entry Original Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(85; "Ledg. Entry Remaining Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Ledg. Entry Remaining Amount';
            DataClassification = CustomerContent;
        }
        field(87; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(88; "Remaining Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Remaining Amount';
            DataClassification = CustomerContent;
        }
        field(90; "Ledg. Entry Original Amt.(LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Ledg. Entry Original Amt.(LCY)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(95; "Ledg. Entry Rem. Amt. (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Ledg. Entry Rem. Amt. (LCY)';
            DataClassification = CustomerContent;
        }
        field(97; "Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(98; "Remaining Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Remaining Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
    }

    keys
    {
        key(PK; "Compensation No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = "Ledg. Entry Rem. Amt. (LCY)", "Amount (LCY)";
        }
    }

    var
        DimensionManagement: Codeunit DimensionManagement;
        DimensionSetCaptionTok: Label '%1 %2 %3', Comment = '%1 = TableCaption, %2 = Compensation No., %3 = Line No.', Locked = true;

    procedure ShowDimensions()
    begin
        DimensionManagement.ShowDimensionSet("Dimension Set ID", StrSubstNo(DimensionSetCaptionTok, TableCaption, "Compensation No.", "Line No."));
    end;
}
