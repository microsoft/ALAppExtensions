// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Account;
using System.Security.AccessControl;
using Microsoft.Finance.Currency;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;

table 18689 "TDS Entry"
{
    Caption = 'TDS Entry';
    LookupPageId = "TDS Entries";
    DrillDownPageId = "TDS Entries";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(3; "T.A.N. No."; Code[10])
        {
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(4; "Section"; Code[10])
        {
            Caption = 'Section';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(5; "Assessee Code"; Code[10])
        {
            Caption = 'Assessee Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(8; "TDS Base Amount"; Decimal)
        {
            Caption = 'TDS Base Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(9; "TDS Paid"; Boolean)
        {
            Caption = 'TDS Paid';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(10; "TDS %"; Decimal)
        {
            Caption = 'TDS %';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11; "TDS Amount"; Decimal)
        {
            Caption = 'TDS Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(12; "Surcharge %"; Decimal)
        {
            Caption = 'Surcharge %';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(13; "Surcharge Amount"; Decimal)
        {
            Caption = 'Surcharge Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(14; "eCess %"; Decimal)
        {
            Caption = 'eCess %';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(15; "eCess Amount"; Decimal)
        {
            Caption = 'eCess Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(16; "SHE Cess %"; Decimal)
        {
            Caption = 'SHE Cess %';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(17; "SHE Cess Amount"; Decimal)
        {
            Caption = 'SHE Cess Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(18; "Concessional Code"; Code[10])
        {
            Caption = 'Concessional Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(19; "Concessional Form No."; Code[20])
        {
            Caption = 'Concessional Form No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(20; "Deductee PAN No."; Code[20])
        {
            Caption = 'Deductee PAN No.';
            DataClassification = CustomerContent;
        }
        field(21; "Non Resident Payments"; Boolean)
        {
            Caption = 'Non Resident Payments';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(22; "Nature of Remittance"; Code[20])
        {
            Caption = 'Nature of Remittance';
            Editable = false;
            TableRelation = "TDS Nature of Remittance";
            DataClassification = CustomerContent;
        }
        field(23; "Act Applicable"; Code[10])
        {
            Caption = 'Act Applicable';
            Editable = false;
            TableRelation = "Act Applicable";
            DataClassification = CustomerContent;
        }
        field(27; "Invoice Amount"; Decimal)
        {
            Caption = 'Invoice Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(28; "Challan Date"; Date)
        {
            Caption = 'Challan Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(29; "Challan No."; Code[20])
        {
            Caption = 'Challan No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(30; "Bank Name"; Text[100])
        {
            Caption = 'Bank Name';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(32; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(33; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(34; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(35; "Account Type"; enum "TDS Account Type")
        {
            Caption = 'Account Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(36; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            Editable = false;
            DataClassification = CustomerContent;
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Account Type" = const(Vendor)) Vendor;
        }
        field(37; "Party Type"; Enum "TDS Party Type")
        {
            Caption = 'Party Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(38; "Party Code"; Code[20])
        {
            Caption = 'Party Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(39; "Country Code"; Code[10])
        {
            Caption = 'Country Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(40; "TDS Adjustment"; Boolean)
        {
            Caption = 'TDS Adjustment';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(41; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(43; "TDS Amount Including Surcharge"; Decimal)
        {
            Caption = 'TDS Amount Including Surcharge';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(45; Adjusted; Boolean)
        {
            Caption = 'Adjusted';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(46; "Adjusted TDS %"; Decimal)
        {
            Caption = 'Adjusted TDS %';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(47; "Bal. TDS Including SHE CESS"; Decimal)
        {
            Caption = 'Bal. TDS Including SHE CESS';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(48; "Pay TDS Document No."; Code[20])
        {
            Caption = 'Pay TDS Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(49; "Include GST in TDS Base"; Boolean)
        {
            Caption = 'Include GST in TDS Base';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; Applied; Boolean)
        {
            Caption = 'Applied';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(51; "Remaining Surcharge Amount"; Decimal)
        {
            Caption = 'Remaining Surcharge Amount';
            DataClassification = CustomerContent;
        }
        field(52; "Remaining TDS Amount"; Decimal)
        {
            Caption = 'Remaining TDS Amount';
            DataClassification = CustomerContent;
        }
        field(53; "Adjusted Surcharge %"; Decimal)
        {
            Caption = 'Adjusted Surcharge %';
            DataClassification = CustomerContent;
        }
        field(55; "TDS Line Amount"; Decimal)
        {
            Caption = 'TDS Line Amount';
            DataClassification = CustomerContent;
        }
        field(56; "Total TDS Including SHE CESS"; Decimal)
        {
            Caption = 'Total TDS Including SHE CESS';
            DataClassification = CustomerContent;
        }
        field(57; "Adjusted eCESS %"; Decimal)
        {
            Caption = 'Adjusted eCESS %';
            DataClassification = CustomerContent;
        }
        field(58; "Per Contract"; Boolean)
        {
            Caption = 'Per Contract';
            DataClassification = CustomerContent;
        }
        field(59; "Party Account No."; Code[20])
        {
            Caption = 'Party Account No.';
            DataClassification = CustomerContent;
        }
        field(60; Reversed; Boolean)
        {
            Caption = 'Reversed';
            DataClassification = CustomerContent;
        }
        field(61; "Reversed by Entry No."; Integer)
        {
            Caption = 'Reversed by Entry No.';
            DataClassification = CustomerContent;
        }
        field(62; "Reversed Entry No."; Integer)
        {
            Caption = 'Reversed Entry No.';
            DataClassification = CustomerContent;
        }
        field(63; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = SystemMetadata;
            TableRelation = User."User Name";
        }
        field(64; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(65; "Party P.A.N. No."; Code[20])
        {
            Caption = 'Party P.A.N. No.';
            DataClassification = CustomerContent;
        }
        field(66; "Check/DD No."; Code[10])
        {
            Caption = 'Check/DD No.';
            DataClassification = CustomerContent;
        }
        field(67; "Check Date"; Date)
        {
            Caption = 'Check Date';
            DataClassification = CustomerContent;
        }
        field(68; "TDS Payment Date"; Date)
        {
            Caption = 'TDS Payment Date';
            DataClassification = CustomerContent;
        }
        field(69; "Challan Register Entry No."; Integer)
        {
            Caption = 'Challan Register Entry No.';
            DataClassification = CustomerContent;
        }
        field(71; "Adjusted SHE CESS %"; Decimal)
        {
            Caption = 'Adjusted SHE CESS %';
            DataClassification = CustomerContent;
        }
        field(72; "Original TDS Base Amount"; Decimal)
        {
            Caption = 'Original TDS Base Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(73; "TDS Base Amount Adjusted"; Boolean)
        {
            Caption = 'TDS Base Amount Adjusted';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(75; "Payment Amount"; Decimal)
        {
            Caption = 'Payment Amount';
            DataClassification = CustomerContent;
        }
        field(80; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(81; "Currency Factor"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(85; "Surcharge Base Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Surcharge Base Amount';
        }
        field(87; "G/L Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'G/L Entry No.';
        }
        field(88; "BSR Code"; Code[7])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(89; "Minor Head Code"; Enum "Minor Head Type")
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(90; "NIL Challan Indicator"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(91; "Over & Above Threshold Opening"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Account Type")
        {
        }
        key(Key3; "Posting Date", "Assessee Code", Applied, "Per Contract")
        {
            SumIndexFields = "TDS Base Amount", "TDS Amount Including Surcharge", "Surcharge Amount", "Invoice Amount", "Bal. TDS Including SHE CESS", "TDS Amount";
        }
        key(Key4; "Document No.", "Posting Date")
        {
        }
        key(Key5; "Posting Date", "Assessee Code", Applied)
        {
            SumIndexFields = "Invoice Amount", "Payment Amount";
        }
        key(Key6; "Posting Date", "Assessee Code", "Document Type")
        {
            SumIndexFields = "TDS Base Amount", "TDS Amount Including Surcharge", "Surcharge Amount", "Invoice Amount", "Bal. TDS Including SHE CESS", "TDS Amount";
        }
        key(Key7; "Pay TDS Document No.", "Posting Date")
        {
        }
        key(Key9; "Transaction No.")
        {
        }
        key(Key10; "Posting Date", "Document No.")
        {
        }
        key(Key11; "Challan No.")
        {
        }
    }


    trigger OnInsert()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        TDSEntityManagement: Codeunit "TDS Entity Management";
    begin
        VendorLedgerEntry.SetRange("Transaction No.", Rec."Transaction No.");
        if VendorLedgerEntry.FindFirst() then begin
            if VendorLedgerEntry."Document Type" in [VendorLedgerEntry."Document Type"::Invoice, VendorLedgerEntry."Document Type"::Payment] then
                VendorLedgerEntry."Total TDS Including SHE CESS" += Rec."Total TDS Including SHE CESS";

            if VendorLedgerEntry."TDS Section Code" = '' then
                VendorLedgerEntry."TDS Section Code" := Rec.Section;
            if IsMultiSectionTransaction() then
                VendorLedgerEntry."TDS Section Code" := '';
            VendorLedgerEntry.Modify();
        end;

        if "Currency Code" <> '' then begin
            "TDS Base Amount" := TDSEntityManagement.ConvertTDSAmountToLCY(Rec."Currency Code", Rec."TDS Base Amount", Rec."Currency Factor", Rec."Posting Date");
            "TDS Amount" := TDSEntityManagement.ConvertTDSAmountToLCY(Rec."Currency Code", Rec."TDS Amount", Rec."Currency Factor", Rec."Posting Date");
            "Surcharge Amount" := TDSEntityManagement.ConvertTDSAmountToLCY(Rec."Currency Code", Rec."Surcharge Amount", Rec."Currency Factor", Rec."Posting Date");
            "Surcharge Base Amount" := TDSEntityManagement.ConvertTDSAmountToLCY(Rec."Currency Code", Rec."Surcharge Base Amount", Rec."Currency Factor", Rec."Posting Date");
            "eCESS Amount" := TDSEntityManagement.ConvertTDSAmountToLCY(Rec."Currency Code", Rec."eCESS Amount", Rec."Currency Factor", Rec."Posting Date");
            "SHE Cess Amount" := TDSEntityManagement.ConvertTDSAmountToLCY(Rec."Currency Code", Rec."SHE Cess Amount", Rec."Currency Factor", Rec."Posting Date");
            "TDS Amount Including Surcharge" := TDSEntityManagement.ConvertTDSAmountToLCY(Rec."Currency Code", Rec."TDS Amount Including Surcharge", Rec."Currency Factor", Rec."Posting Date");
            "Bal. TDS Including SHE CESS" := TDSEntityManagement.ConvertTDSAmountToLCY(Rec."Currency Code", Rec."Bal. TDS Including SHE CESS", Rec."Currency Factor", Rec."Posting Date");
            "Invoice Amount" := TDSEntityManagement.ConvertTDSAmountToLCY(Rec."Currency Code", Rec."Invoice Amount", Rec."Currency Factor", Rec."Posting Date");
            "Remaining Surcharge Amount" := TDSEntityManagement.ConvertTDSAmountToLCY(Rec."Currency Code", Rec."Remaining Surcharge Amount", Rec."Currency Factor", Rec."Posting Date");
            "Remaining TDS Amount" := TDSEntityManagement.ConvertTDSAmountToLCY(Rec."Currency Code", Rec."Remaining TDS Amount", Rec."Currency Factor", Rec."Posting Date");
            "Total TDS Including SHE CESS" := TDSEntityManagement.ConvertTDSAmountToLCY(Rec."Currency Code", Rec."Total TDS Including SHE CESS", Rec."Currency Factor", Rec."Posting Date");
        end;

        if Rec."Document Type" = Rec."Document Type"::Invoice then begin
            DetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");
            DetailedVendorLedgEntry.CalcSums("Amount (LCY)");
            Rec."TDS Line Amount" := Abs(DetailedVendorLedgEntry."Amount (LCY)") + Rec."Total TDS Including SHE CESS";
            "TDS Line Amount" := "TDS Base Amount";
        end;
    end;

    local procedure IsMultiSectionTransaction(): Boolean
    var
        TDSEntry: Record "TDS Entry";
    begin
        TDSEntry.Reset();
        TDSEntry.SetCurrentKey("Transaction No.");
        TDSEntry.SetRange("Transaction No.", "Transaction No.");
        TDSEntry.SetFilter("Entry No.", '<>%1', "Entry No.");
        TDSEntry.SetFilter(Section, '<>%1', Section);
        exit(not TDSEntry.IsEmpty);
    end;
}
