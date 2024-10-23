// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Payments;
using Microsoft.Finance.TaxBase;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

tableextension 18004 "GST Gen. Journal Line Ext" extends "Gen. Journal Line"
{
    fields
    {
        field(18000; "Nature of Supply"; Enum "GST Nature of Supply")
        {
            Caption = 'Nature of Supply';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18001; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            TableRelation = "GST Group";
            DataClassification = CustomerContent;
        }
        field(18002; "GST Group Type"; Enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18004; "Exclude GST in TCS Base"; Boolean)
        {
            Caption = 'Exclude GST in TCS Base';
            DataClassification = CustomerContent;
        }
        field(18006; "GST Place of Supply"; enum "GST Dependency Type")
        {
            Caption = 'GST Place of Supply';
            DataClassification = CustomerContent;
        }
        field(18007; "GST Customer Type"; enum "GST Customer Type")
        {
            Caption = 'GST Customer Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18008; "GST Vendor Type"; enum "GST Vendor Type")
        {
            Caption = 'GST Vendor Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18009; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
            TableRelation = "HSN/SAC".Code WHERE("GST Group Code" = field("GST Group Code"));
        }
        field(18010; Exempted; Boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;
        }
        field(18011; "GST Component Code"; Code[30])
        {
            Caption = 'GST Component Code';
            DataClassification = CustomerContent;
        }
        field(18012; "GST on Advance Payment"; Boolean)
        {
            Caption = 'GST on Advance Payment';
            DataClassification = CustomerContent;
        }
        field(18013; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Account Type" = const(Customer)) "Ship-to Address".Code where("Customer No." = field("Account No."));
        }
        field(18014; "Tax Type"; enum "Tax Type")
        {
            Caption = 'Tax Type';
            DataClassification = CustomerContent;
        }
        field(18015; "GST Jurisdiction Type"; enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18016; "Adv. Pmt. Adjustment"; Boolean)
        {
            Caption = 'Adv. Pmt. Adjustment';
            DataClassification = CustomerContent;
        }
        field(18017; "GST Bill-to/BuyFrom State Code"; Code[10])
        {
            Caption = 'GST Bill-to/BuyFrom State Code';
            Editable = false;
            TableRelation = State;
            DataClassification = CustomerContent;
        }
        field(18018; "GST Ship-to State Code"; Code[10])
        {
            Caption = 'GST Ship-to State Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = State;
        }
        field(18019; "Location State Code"; Code[10])
        {
            Caption = 'Location State Code';
            Editable = false;
            TableRelation = State;
            DataClassification = CustomerContent;
        }
        field(18020; "GST Inv. Rounding Precision"; Decimal)
        {
            Caption = 'GST Inv. Rounding Precision';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                if ("GST Customer Type" = "GST Customer Type"::" ") and
                    ("GST Vendor Type" = "GST Vendor Type"::" ")
                then
                    TestField("GST Inv. Rounding Precision", 0);
            end;
        }
        field(18021; "GST Inv. Rounding Type"; Enum "GST Inv Rounding Type")
        {
            Caption = 'GST Inv. Rounding Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("GST Customer Type" = "GST Customer Type"::" ") and
                    ("GST Vendor Type" = "GST Vendor Type"::" ")
                then
                    TestField("GST Inv. Rounding Type", "GST Inv. Rounding Type"::Nearest);
            end;
        }
        field(18022; "GST Input Service Distribution"; Boolean)
        {
            Caption = 'GST Input Service Distribution';
            DataClassification = CustomerContent;
        }
        field(18023; "GST Reverse Charge"; Boolean)
        {
            Caption = 'GST Reverse Charge';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18024; "GST Reason Type"; enum "GST Reason Type")
        {
            Caption = 'GST Reason Type';
            DataClassification = CustomerContent;
        }
        field(18025; "Bank Charge"; Boolean)
        {
            Caption = 'Bank Charge';
            DataClassification = CustomerContent;
        }
        field(18027; "RCM Exempt"; Boolean)
        {
            Caption = 'RCM Exempt';
            DataClassification = CustomerContent;
        }
        field(18028; "Order Address Code"; Code[10])
        {
            Caption = 'Order Address Code';
            DataClassification = CustomerContent;
            TableRelation = if ("Account Type" = const(Vendor)) "Order Address".Code where("Vendor No." = field("Account No."));
        }
        field(18029; "Vendor GST Reg. No."; Code[20])
        {
            Caption = 'Vendor GST Reg. No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18030; "Associated Enterprises"; Boolean)
        {
            Caption = 'Associated Enterprises';
            DataClassification = CustomerContent;
        }
        field(18031; "Purch. Invoice Type"; enum "GST Invoice Type")
        {
            Caption = 'Purch. Invoice Type';
            DataClassification = CustomerContent;
        }
        field(18032; "Inc. GST in TDS Base"; Boolean)
        {
            Caption = 'Inc. GST in TDS Base';
            DataClassification = CustomerContent;
        }
        field(18033; "GST Credit"; enum "GST Credit")
        {
            Caption = 'GST Credit';
            DataClassification = CustomerContent;
        }
        field(18034; "GST Without Payment of Duty"; Boolean)
        {
            Caption = 'GST Without Payment of Duty';
            DataClassification = CustomerContent;
        }
        field(18035; "Sales Invoice Type"; enum "Sales Invoice Type")
        {
            Caption = 'Sales Invoice Type';
            DataClassification = CustomerContent;
        }
        field(18036; "Bill Of Export No."; Text[20])
        {
            Caption = 'Bill Of Export No.';
            DataClassification = CustomerContent;
        }
        field(18037; "Bill Of Export Date"; Date)
        {
            Caption = 'Bill Of Export Date';
            DataClassification = CustomerContent;
        }
        field(18040; "Custom Duty Amount"; Decimal)
        {
            Caption = 'Custom Duty Amount';
            DataClassification = CustomerContent;
        }
        field(18041; "GST Assessable Value"; Decimal)
        {
            Caption = 'GST Assessable Value';
            DataClassification = CustomerContent;
        }
        field(18042; "GST in Journal"; Boolean)
        {
            Caption = 'GST in Journal';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18043; "GST Transaction Type"; enum "GST Transaction Type")
        {
            Caption = 'GST Transaction Type';
            DataClassification = CustomerContent;
        }
        field(18044; "Journal Entry"; Boolean)
        {
            Caption = 'Journal Entry';
            DataClassification = CustomerContent;
        }
        field(18045; "Custom Duty Amount (LCY)"; Decimal)
        {
            Caption = 'Custom Duty Amount (LCY)';
            DataClassification = CustomerContent;
        }
        field(18046; "Bill of Entry No."; Text[20])
        {
            Caption = 'Bill of Entry No.';
            DataClassification = CustomerContent;
        }
        field(18047; "Bill of Entry Date"; Date)
        {
            Caption = 'Bill of Entry Date';
            DataClassification = CustomerContent;
        }
        field(18048; "GST in Journal Allocations"; Boolean)
        {
            Caption = 'GST in Journal Allocations';
            DataClassification = CustomerContent;
        }
        field(18049; "Allocation Line No."; Integer)
        {
            Caption = 'Allocation Line No.';
            DataClassification = CustomerContent;
        }
        field(18050; "Journal Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Journal Line No.';
        }
        field(18051; "Journal Alloc. Template Name"; Code[10])
        {
            Caption = 'Journal Alloc. Template Name';
            TableRelation = "Gen. Journal Template";
            DataClassification = CustomerContent;
        }
        field(18053; "GST Adjustment Entry"; Boolean)
        {
            Caption = 'GST Adjustment Entry';
            DataClassification = CustomerContent;
        }
        field(18054; "Location GST Reg. No."; Code[20])
        {
            Caption = 'Location GST Reg. No.';
            TableRelation = "GST Registration Nos.";
            DataClassification = CustomerContent;
        }
        field(18055; "Customer GST Reg. No."; Code[20])
        {
            Caption = 'Customer GST Reg. No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18056; "Ship-to GST Reg. No."; Code[20])
        {
            Caption = 'Ship-to GST Reg. No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18057; "Order Address GST Reg. No."; Code[20])
        {
            Caption = 'Order Address GST Reg. No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18058; "Order Address State Code"; Code[10])
        {
            Caption = 'Order Address State Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18059; "Bill to-Location(POS)"; Code[10])
        {
            Caption = 'Bill to-Location(POS)';
            TableRelation = Location where("Use As In-Transit" = const(FALSE));
            DataClassification = CustomerContent;
        }
        field(18060; "Reference Invoice No."; Code[20])
        {
            Caption = 'Reference Invoice No.';
            DataClassification = CustomerContent;
        }
        field(18061; "Without Bill Of Entry"; Boolean)
        {
            Caption = 'Without Bill Of Entry';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("GST Vendor Type", "GST Vendor Type"::SEZ);
            end;
        }
        field(18062; "Amount Excl. GST"; Decimal)
        {
            Caption = 'Amount Excl. GST';
            DataClassification = CustomerContent;
        }
        field(18064; "GST TDS/TCS %"; Decimal)
        {
            Caption = 'GST TDS/TCS %';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18065; "GST TDS/TCS Base Amount (LCY)"; Decimal)
        {
            Caption = 'GST TDS/TCS Base Amount (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18066; "GST TDS/TCS Amount (LCY)"; Decimal)
        {
            Caption = 'GST TDS/TCS Amount (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18067; "GST TDS/GST TCS"; Enum "TDSTCS Type")
        {
            Caption = 'GST TDS/GST TCS';
            DataClassification = CustomerContent;
        }
        field(18068; "GST TCS State Code"; Code[10])
        {
            Caption = 'GST TCS State Code';
            DataClassification = CustomerContent;
            TableRelation = State;

            trigger OnValidate()
            begin
                TestField("GST TDS/GST TCS", "GST TDS/GST TCS"::" ");
            end;
        }
        field(18069; "GST TDS/TCS Base Amount"; Decimal)
        {
            Caption = 'GST TDS/TCS Base Amount';
            DataClassification = CustomerContent;
        }
        field(18070; "Supply Finish Date"; Enum "GST Rate Change")
        {
            Caption = 'Supply Finish Date';
            DataClassification = CustomerContent;
        }
        field(18071; "Payment Date"; Enum "GST Rate Change")
        {
            Caption = 'Payment Date';
            DataClassification = CustomerContent;
        }
        field(18072; "Rate Change Applicable"; Boolean)
        {
            Caption = 'Rate Change Applicable';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor]) then
                    TestField("Rate Change Applicable", FALSE);
            end;
        }
        field(18073; "POS as Vendor State"; Boolean)
        {
            Caption = 'POS as Vendor State';
            DataClassification = CustomerContent;
        }
        field(18075; "GST On Assessable Value"; Boolean)
        {
            Caption = 'GST On Assessable Value';
            DataClassification = CustomerContent;
        }
        field(18076; "GST Assessable Value Sale(LCY)"; Decimal)
        {
            Caption = 'GST Assessable Value Sale(LCY)';
            DataClassification = CustomerContent;
        }
        field(18079; "POS Out Of India"; Boolean)
        {
            Caption = 'POS Out Of India';
            DataClassification = CustomerContent;
        }
        field(18003; "Transaction Type"; Enum "GenJnl Transaction Type")
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
        }
        field(18005; "Offline Application"; Boolean)
        {
            Caption = 'Offline Application';
            DataClassification = CustomerContent;
        }
        field(18026; "e-Commerce Customer"; Code[20])
        {
            Caption = 'e-Commerce Customer';
            TableRelation = Customer where("e-Commerce Operator" = const(true));
            DataClassification = CustomerContent;
        }

        field(18038; "e-Commerce Merchant Id"; Code[30])
        {
            Caption = 'e-Commerce Merchant Id';
            DataClassification = CustomerContent;
            TableRelation = "E-Commerce Merchant"."Merchant Id"
                where(
                    "Merchant Id" = field("e-Commerce Merchant Id"),
                    "Customer No." = field("e-Commerce Customer"));
            ObsoleteReason = 'New field introduced as E-Comm. Merchant Id';
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
        }

        field(18052; "E-Comm. Merchant Id"; Code[30])
        {
            Caption = 'e-Commerce Merchant Id';
            DataClassification = CustomerContent;
            TableRelation = "E-Comm. Merchant"."Merchant Id" where(
                    "Merchant Id" = field("E-Comm. Merchant Id"),
                    "Customer No." = field("e-Commerce Customer"));
        }
        field(18039; "FA Non-Availment"; Boolean)
        {
            Caption = 'FA Non-Availment';
            DataClassification = CustomerContent;
        }
        field(18074; "FA Custom Duty Amount"; Decimal)
        {
            Caption = 'FA Custom Duty Amount';
            DataClassification = CustomerContent;
        }
        field(18077; "FA Availment"; Boolean)
        {
            Caption = 'FA Availment';
            DataClassification = CustomerContent;
        }
        field(18078; "FA Non-Availment Amount"; Decimal)
        {
            Caption = 'FA Non-Availment Amount';
            DataClassification = CustomerContent;
        }
        field(18166; State; Code[10])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
            TableRelation = State;
        }
    }
}
