// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TaxBase;
using System.Security.AccessControl;
using Microsoft.Finance.Currency;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Customer;

table 18810 "TCS Entry"
{
    Caption = 'TCS Entry';
    LookupPageId = "TCS Entries";
    DrillDownPageId = "TCS Entries";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            AutoIncrement = true;
        }
        field(2; "Account Type"; Enum "TCS Account Type")
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Account No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Account Type" = const(Customer)) Customer;
        }
        field(4; "Posting Date"; Date)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Document Type"; Enum "Gen. Journal Document Type")
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Document No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
#pragma warning disable AS0086
        field(7; Description; Text[100])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
#pragma warning restore
        field(8; "TCS Amount Including Surcharge"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(9; "TCS Base Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; "Customer No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; "TCS Nature of Collection"; Code[10])
        {
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "Assessee Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(13; "TCS Paid"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; "Challan Date"; Date)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(16; "Challan No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(17; "Bank Name"; Text[100])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18; "TCS %"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(19; Adjusted; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(20; "Adjusted TCS %"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(21; "Bal. TCS Including SHE CESS"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(22; "Pay TCS Document No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(24; "Surcharge %"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(25; "Transaction No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(26; "Customer P.A.N. No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(27; "Surcharge Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(28; "Concessional Code"; Code[10])
        {
            TableRelation = "Concessional Code";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(29; "Invoice Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(30; Applied; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(31; "TCS Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(32; "Remaining Surcharge Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(33; "Remaining TCS Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(34; "Adjusted Surcharge %"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(35; "Surcharge Base Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(36; "G/L Enty No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(37; "eCESS %"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(38; "eCESS Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(39; "Total TCS Including SHE CESS"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(40; "Adjusted eCESS %"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(41; "T.C.A.N. No."; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(42; "Customer Account No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(43; Reversed; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(44; "Reversed by Entry No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(45; "Reversed Entry No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(46; "User ID"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(47; "Source Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(48; "TCS Payment Date"; Date)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(49; "Challan Register Entry No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(50; "SHE Cess %"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(51; "SHE Cess Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(52; "Adjusted SHE CESS %"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(53; "Original TCS Base Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(54; "TCS Base Amount Adjusted"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(55; "Payment Amount"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(56; "Check/DD No."; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(57; "Check Date"; Date)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(58; "Currency Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = Currency;
        }
        field(59; "Currency Factor"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(60; "Rem. Total TCS Incl. SHE CESS"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(61; "Concessional Form No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(62; "Per Contract"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(63; "BSR Code"; Code[20])
        {
            Caption = 'BSR Code';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(64; "Minor Head Code"; Enum "Minor Head Type")
        {
            Caption = 'Minor Head Code';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(65; "TCS on Recpt. Of Pmt."; Boolean)
        {
            Caption = 'TCS on Recpt. Of Pmt.';
            DataClassification = SystemMetadata;
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
        key(Key3; "Posting Date", "Assessee Code", Applied)
        {
            SumIndexFields = "TCS Base Amount", "TCS Amount Including Surcharge", "Surcharge Amount", "Invoice Amount", "Bal. TCS Including SHE CESS", "TCS Amount";
        }
        key(Key4; "Document No.", "Posting Date")
        {
        }
        key(Key5; "Posting Date", "Assessee Code", "Document Type")
        {
            SumIndexFields = "TCS Base Amount", "TCS Amount Including Surcharge", "Surcharge Amount", "Invoice Amount", "Bal. TCS Including SHE CESS", "TCS Amount";
        }
        key(Key6; "Pay TCS Document No.", "Posting Date")
        {
        }
        key(Key7; "Transaction No.")
        {
        }
        key(Key8; "Posting Date", "Document No.")
        {
        }
        key(Key9; "Challan No.")
        {
        }
    }


    trigger OnInsert()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        TCSManagement: Codeunit "TCS Management";
    begin
        CustLedgerEntry.SetRange("Transaction No.", Rec."Transaction No.");
        CustLedgerEntry.SetRange("Document No.", Rec."Document No.");
        if CustLedgerEntry.FindFirst() then begin
            if Rec."Document Type" in [Rec."Document Type"::Invoice, Rec."Document Type"::Payment] then
                CustLedgerEntry."Total TCS Including SHE CESS" -= Abs(Rec."Total TCS Including SHE CESS");

            if CustLedgerEntry."TCS Nature of Collection" = '' then
                CustLedgerEntry."TCS Nature of Collection" := Rec."TCS Nature of Collection";

            if IsMultiSectionTransaction() then
                CustLedgerEntry."TCS Nature of Collection" := '';
            CustLedgerEntry.Modify();
        end;

        if "Currency Code" <> '' then begin
            "TCS Base Amount" := TCSManagement.ConvertTCSAmountToLCY(Rec."Currency Code", Rec."TCS Base Amount", Rec."Currency Factor", Rec."Posting Date");
            "TCS Amount" := TCSManagement.ConvertTCSAmountToLCY(Rec."Currency Code", Rec."TCS Amount", Rec."Currency Factor", Rec."Posting Date");
            "Surcharge Amount" := TCSManagement.ConvertTCSAmountToLCY(Rec."Currency Code", Rec."Surcharge Amount", Rec."Currency Factor", Rec."Posting Date");
            "eCESS Amount" := TCSManagement.ConvertTCSAmountToLCY(Rec."Currency Code", Rec."eCESS Amount", Rec."Currency Factor", Rec."Posting Date");
            "SHE Cess Amount" := TCSManagement.ConvertTCSAmountToLCY(Rec."Currency Code", Rec."SHE Cess Amount", Rec."Currency Factor", Rec."Posting Date");
            "TCS Amount Including Surcharge" := TCSManagement.ConvertTCSAmountToLCY(Rec."Currency Code", Rec."TCS Amount Including Surcharge", Rec."Currency Factor", Rec."Posting Date");
            "Bal. TCS Including SHE CESS" := TCSManagement.ConvertTCSAmountToLCY(Rec."Currency Code", Rec."Bal. TCS Including SHE CESS", Rec."Currency Factor", Rec."Posting Date");
            "Invoice Amount" := TCSManagement.ConvertTCSAmountToLCY(Rec."Currency Code", Rec."Invoice Amount", Rec."Currency Factor", Rec."Posting Date");
            "Rem. Total TCS Incl. SHE CESS" := TCSManagement.ConvertTCSAmountToLCY(Rec."Currency Code", Rec."Rem. Total TCS Incl. SHE CESS", Rec."Currency Factor", Rec."Posting Date");
            "Remaining Surcharge Amount" := TCSManagement.ConvertTCSAmountToLCY(Rec."Currency Code", Rec."Remaining Surcharge Amount", Rec."Currency Factor", Rec."Posting Date");
            "Remaining TCS Amount" := TCSManagement.ConvertTCSAmountToLCY(Rec."Currency Code", Rec."Remaining TCS Amount", Rec."Currency Factor", Rec."Posting Date");
            "Surcharge Base Amount" := TCSManagement.ConvertTCSAmountToLCY(Rec."Currency Code", Rec."Surcharge Base Amount", Rec."Currency Factor", Rec."Posting Date");
            "Total TCS Including SHE CESS" := TCSManagement.ConvertTCSAmountToLCY(Rec."Currency Code", Rec."Total TCS Including SHE CESS", Rec."Currency Factor", Rec."Posting Date");
        end;
    end;

    local procedure IsMultiSectionTransaction(): Boolean
    var
        TCSEntry: Record "TCS Entry";
    begin
        TCSEntry.Reset();
        TCSEntry.SetCurrentKey("Transaction No.");
        TCSEntry.SetRange("Transaction No.", "Transaction No.");
        TCSEntry.SetFilter("Entry No.", '<>%1', "Entry No.");
        TCSEntry.SetFilter("TCS Nature of Collection", '<>%1', "TCS Nature of Collection");
        exit(not TCSEntry.IsEmpty);
    end;
}
