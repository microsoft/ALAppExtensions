// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TCS.TCSBase;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Sales.Customer;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using Microsoft.Finance.TaxBase;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Bank.BankAccount;
using Microsoft.Projects.Project.Job;
using Microsoft.CRM.Campaign;
using Microsoft.CRM.Team;
using Microsoft.Purchases.Vendor;

table 18870 "TCS Journal Line"
{
    Caption = 'TCS Journal Line';
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "TCS Journal Template";
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Account Type"; Enum "TCS Account Type")
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                AccountErr: Label '%1 or %2 must be G/L Account or Bank Account.', Comment = '%1= G/L Account., %2=Bank Account.';
            begin
                if ("Account Type" = "Account Type"::Customer) and
                   ("Bal. Account Type" in ["Bal. Account Type"::Customer, "Bal. Account Type"::Vendor])
                then
                    Error(
                      AccountErr,
                      FieldCaption("Account Type"), FieldCaption("Bal. Account Type"));
                Validate("Account No.", '');
            end;
        }
        field(4; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Account Type" = const(Customer)) Customer;


            trigger OnValidate()
            begin
                if "Account No." = '' then begin
                    CreateDimFromDefaultDim(FieldNo("Account No."));
                    exit;
                end;
                UpdateDataOnAccountNo();
                CreateDimFromDefaultDim(FieldNo("Account No."));
            end;
        }
        field(5; "Posting Date"; Date)
        {
            ClosingDates = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                DateValidateErr: Label 'Posting Date %1 for TCS Adjustment cannot be earlier than the Invoice Date %2.', Comment = '%1=Posting date., %2=Invoice Date.';
            begin
                if "Posting Date" < xRec."Posting Date" then
                    Error(DateValidateErr, "Posting Date", xRec."Posting Date");
                Validate("Document Date", "Posting Date");
            end;
        }
        field(6; "Document Type"; Enum "Gen. Journal Document Type")
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Cust: Record Customer;
            begin
                if "Account No." <> '' then
                    if "Account Type" = "Account Type"::Customer then begin
                        Cust.Get("Account No.");
                        Cust.CheckBlockedCustOnJnls(Cust, "Document Type", false);
                    end;
                if "Bal. Account No." <> '' then
                    if "Bal. Account Type" = "Account Type"::Customer then begin
                        Cust.Get("Bal. Account No.");
                        Cust.CheckBlockedCustOnJnls(Cust, "Document Type", false);
                    end;
            end;
        }
        field(7; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(8; Description; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(9; "Bal. Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = if ("Bal. Account Type" = const("G/L Account")) "G/L Account"
            else
            if ("Bal. Account Type" = const(Customer)) Customer
            else
            if ("Bal. Account Type" = const(Vendor)) Vendor
            else
            if ("Bal. Account Type" = const("Bank Account")) "Bank Account";

            trigger OnValidate()
            begin
                if "Bal. Account No." = '' then begin
                    CreateDimFromDefaultDim(FieldNo("Bal. Account No."));
                    exit;
                end;
                UpdateDataOnBalAccountNo();
                CreateDimFromDefaultDim(FieldNo("Bal. Account No."));
            end;
        }
        field(10; "Customer No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(11; Amount; Decimal)
        {
            AutoFormatType = 1;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Currency: Record Currency;
            begin
                GetCurrency();
                Amount := Round(Amount, Currency."Amount Rounding Precision");
            end;
        }
        field(12; "Debit Amount"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Currency: Record Currency;
            begin
                GetCurrency();
                "Debit Amount" := Round("Debit Amount", Currency."Amount Rounding Precision");
                Amount := "Debit Amount";
                Validate(Amount);
            end;
        }
        field(13; "Credit Amount"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Currency: Record Currency;
            begin
                GetCurrency();
                "Credit Amount" := Round("Credit Amount", Currency."Amount Rounding Precision");
                Amount := -"Credit Amount";
                Validate(Amount);
            end;
        }
        field(14; "Balance (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(15; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(16; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            DataClassification = CustomerContent;
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(17; "Journal Batch Name"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "TCS Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
        }
        field(18; "TCS Adjusted"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(19; "Surcharge Adjusted"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(20; "eCess Adjusted"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(21; "Bal. Account Type"; Enum "Bal. Account Type")
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                AccountErr: Label '%1 or %2 must be G/L Account or Bank Account.', Comment = '%1= G/L Account., %2=Bank Account.';
            begin
                if ("Account Type" = "Account Type"::Customer) and
                   ("Bal. Account Type" in ["Bal. Account Type"::Customer, "Bal. Account Type"::Vendor])
                then
                    Error(
                      AccountErr,
                      FieldCaption("Account Type"), FieldCaption("Bal. Account Type"));
                Validate("Bal. Account No.", '');
            end;
        }
        field(22; "Document Date"; Date)
        {
            ClosingDates = true;
            DataClassification = CustomerContent;
        }
        field(23; "External Document No."; Code[35])
        {
            DataClassification = CustomerContent;
        }
        field(24; "Posting No. Series"; Code[10])
        {
            TableRelation = "No. Series";
            DataClassification = EndUserIdentifiableInformation;
        }
        field(25; "Dimension Set ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
        field(26; "State Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(27; "TCS Nature of Collection"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "TCS Nature Of Collection";
        }
        field(28; "TCS Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(29; "SHE Cess Adjusted"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(30; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(31; "Assessee Code"; Code[10])
        {
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = "Assessee Code";
        }
        field(32; "TCS %"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            var
                Currency: Record Currency;
                TCSAmt: Decimal;
            begin
                if xRec."TCS %" > 0 then begin
                    if "Debit Amount" <> 0 then
                        TCSAmt := "Debit Amount"
                    else
                        TCSAmt := "Credit Amount";

                    if "Bal. TCS Including SHECESS" <> 0 then
                        TCSAmt := "Bal. TCS Including SHECESS";
                    "Bal. TCS Including SHECESS" := Round("TCS %" * TCSAmt / xRec."TCS %", Currency."Amount Rounding Precision");
                    "TCS Amount" := Round("TCS %" * TCSAmt / xRec."TCS %", Currency."Amount Rounding Precision");
                end else begin
                    "Bal. TCS Including SHECESS" := Round(("TCS %" * (1 + "Surcharge %" / 100)) * Amount / 100,
                        Currency."Amount Rounding Precision");
                    "TCS Amount" := Round("TCS %" * Amount / 100, Currency."Amount Rounding Precision");
                end;
            end;
        }
        field(33; "TCS Amt Incl Surcharge"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(34; "Bal. TCS Including SHECESS"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(35; "eCess Amount"; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate(Amount,
                  "Surcharge Amount" +
                  "eCess Amount" + "SHE Cess Amount");
            end;
        }
        field(36; "Surcharge %"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(37; "Surcharge Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(38; "Concessional Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Concessional Code";
        }
        field(39; "TCS % Applied"; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                "TCS Adjusted" := true;
                "Balance TCS Amount" := "TCS % Applied" * "TCS Base Amount" / 100;
                "Surcharge Base Amount" := "Balance TCS Amount";

                UpdateBalSurchargeAmount(Rec);
                UpdateBalECessAmount(Rec);
                UpdateBalSHECessAmount(Rec);

                if ("TCS % Applied" = 0) and "TCS Adjusted" then begin
                    Validate("Surcharge % Applied", 0);
                    Validate("eCESS % Applied", 0);
                    Validate("SHE Cess % Applied", 0);
                end;

                RoundTCSAmounts(Rec, "Balance TCS Amount");
                UpdateAmountForTCS(Rec);
            end;
        }
        field(40; "TCS Invoice No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(41; "TCS Base Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(42; "Challan No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(43; "Challan Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(44; Adjustment; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(45; "TCS Transaction No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(46; "Balance Surcharge Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(47; "Surcharge % Applied"; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TCSManagement: Codeunit "TCS Management";
                BalanceTCS: Decimal;
            begin
                if ("TCS % Applied" = 0) and (not "TCS Adjusted") then
                    BalanceTCS := "TCS Base Amount" * "TCS %" / 100
                else
                    BalanceTCS := "TCS Base Amount" * "TCS % Applied" / 100;

                "Surcharge Adjusted" := true;
                "Balance Surcharge Amount" := "Surcharge % Applied" * BalanceTCS / 100;

                if ("eCESS % Applied" = 0) and (not "eCess Adjusted") then
                    "Balance eCESS on TCS Amt" := ("Balance Surcharge Amount" + BalanceTCS) * "eCESS %" / 100
                else
                    "Balance eCESS on TCS Amt" := TCSManagement.RoundTCSAmount(("Balance Surcharge Amount" + BalanceTCS) * "eCESS % Applied" / 100);

                if ("SHE Cess % Applied" = 0) and (not "SHE Cess Adjusted") then
                    "Bal. SHE Cess on TCS Amt" := ("Balance Surcharge Amount" + BalanceTCS) * "SHE Cess % on TCS" / 100
                else
                    "Bal. SHE Cess on TCS Amt" := TCSManagement.RoundTCSAmount(("Balance Surcharge Amount" + BalanceTCS) * "SHE Cess % Applied" / 100);

                RoundTCSAmounts(Rec, BalanceTCS);
                UpdateAmount(rec);
            end;
        }
        field(48; "Surcharge Base Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(49; "Balance TCS Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "eCESS %"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(51; "eCESS on TCS Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(52; "Total TCS Incl. SHE CESS"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(53; "eCESS Base Amount"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(54; "eCESS % Applied"; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BalanceTCS: Decimal;
                BalanceSurcharge: Decimal;
            begin
                if ("TCS % Applied" = 0) and (not "TCS Adjusted") then
                    BalanceTCS := "TCS Base Amount" * "TCS %" / 100
                else
                    BalanceTCS := "TCS Base Amount" * "TCS % Applied" / 100;

                if ("Surcharge % Applied" = 0) and (not "Surcharge Adjusted") then
                    BalanceSurcharge := BalanceTCS * "Surcharge %" / 100
                else
                    BalanceSurcharge := BalanceTCS * "Surcharge % Applied" / 100;

                "eCess Adjusted" := true;
                "Balance eCESS on TCS Amt" := (BalanceTCS + BalanceSurcharge) * "eCESS % Applied" / 100;

                if ("SHE Cess % Applied" = 0) and (not "SHE Cess Adjusted") then
                    "Bal. SHE Cess on TCS Amt" := (BalanceTCS + BalanceSurcharge) * "SHE Cess % on TCS" / 100
                else
                    "Bal. SHE Cess on TCS Amt" := (BalanceTCS + BalanceSurcharge) * "SHE Cess % Applied" / 100;

                RoundTCSAmounts(Rec, BalanceTCS);
                UpdateAmount(Rec);
            end;
        }
        field(55; "Balance eCESS on TCS Amt"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(56; "Bal. SHE Cess on TCS Amt"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(57; "Pay TCS"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(58; "T.C.A.N. No."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "T.C.A.N. No.";
        }
        field(59; "SHE Cess Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
        field(60; "SHE Cess % on TCS"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(61; "SHE Cess on TCS Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(62; "SHE Cess Base Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(63; "SHE Cess % Applied"; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BalanceTCS: Decimal;
                BalanceSurcharge: Decimal;
            begin
                if ("TCS % Applied" = 0) and (not "TCS Adjusted") then
                    BalanceTCS := "TCS Base Amount" * "TCS %" / 100
                else
                    BalanceTCS := "TCS Base Amount" * "TCS % Applied" / 100;

                if ("Surcharge % Applied" = 0) and (not "Surcharge Adjusted") then
                    BalanceSurcharge := BalanceTCS * "Surcharge %" / 100
                else
                    BalanceSurcharge := BalanceTCS * "Surcharge % Applied" / 100;

                if ("eCESS % Applied" = 0) and (not "eCess Adjusted") then
                    "Balance eCESS on TCS Amt" := (BalanceTCS + BalanceSurcharge) * "eCESS %" / 100
                else
                    "Balance eCESS on TCS Amt" := (BalanceTCS + BalanceSurcharge) * "eCESS % Applied" / 100;

                "SHE Cess Adjusted" := true;
                "Bal. SHE Cess on TCS Amt" := (BalanceTCS + BalanceSurcharge) * "SHE Cess % Applied" / 100;

                RoundTCSAmounts(Rec, BalanceTCS);
                UpdateAmount(Rec);
            end;
        }
        field(64; "TCS Base Amount Applied"; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TCSManagement: Codeunit "TCS Management";
            begin
                TestField("TCS Base Amount Applied", 0);
                "TCS Base Amount Adjusted" := true;
                "TCS Base Amount" := "TCS Base Amount Applied";

                if ("TCS % Applied" = 0) and (not "TCS Adjusted") then begin
                    "TCS % Applied" := "TCS %";
                    "Balance TCS Amount" := "TCS %" * "TCS Base Amount" / 100;
                end else
                    "Balance TCS Amount" := TCSManagement.RoundTCSAmount("TCS Base Amount" * "TCS % Applied" / 100);

                "Surcharge Base Amount" := "Balance TCS Amount";
                UpdateBalSurchargeAmount(Rec);
                UpdateBalECessAmount(Rec);
                UpdateBalSHECessAmount(Rec);

                if ("TCS Base Amount Applied" = 0) and "TCS Base Amount Adjusted" then begin
                    Validate("TCS % Applied", 0);
                    Validate("Surcharge % Applied", 0);
                    Validate("eCESS % Applied", 0);
                    Validate("SHE Cess % Applied", 0);
                end;

                RoundTCSAmounts(Rec, "Balance TCS Amount");
                UpdateAmountForTCS(Rec);
            end;
        }
        field(65; "TCS Base Amount Adjusted"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(66; "Source Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Source Code";
        }
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
            MaintainSifTIndex = false;
            SumIndexFields = "Balance (LCY)";
        }
        key(Key2; "Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.")
        {
            MaintainSQLIndex = false;
        }
        key(Key3; "Journal Template Name", "Journal Batch Name", "Location Code", "Document No.")
        {
        }
    }

    trigger OnInsert()
    var
        TCSJournalTemplate: Record "TCS Journal Template";
    begin
        LockTable();
        TCSJournalTemplate.Get("Journal Template Name");
        TCSJournalBatch.Get("Journal Template Name", "Journal Batch Name");

        ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
        ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
    end;

    var
        TCSJournalBatch: Record "TCS Journal Batch";
        DimensionManagement: Codeunit DimensionManagement;
        ReplaceInfo: Boolean;

    procedure EmptyLine(): Boolean
    begin
        exit(
          ("Account No." = '') and (Amount = 0) and
          ("Bal. Account No." = ''));
    end;

    procedure SetUpNewLine(
        LastTCSJournalLine: Record "TCS Journal Line";
        BottomLine: Boolean)
    var
        TCSJournalLine: Record "TCS Journal Line";
        TCSJournalTemplate: Record "TCS Journal Template";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        TCSJournalTemplate.Get("Journal Template Name");
        TCSJournalBatch.Get("Journal Template Name", "Journal Batch Name");
        TCSJournalLine.SetRange("Journal Template Name", "Journal Template Name");
        TCSJournalLine.SetRange("Journal Batch Name", "Journal Batch Name");
        if not TCSJournalLine.IsEmpty() then begin
            Validate("Posting Date", LastTCSJournalLine."Posting Date");
            Validate("Document Date", LastTCSJournalLine."Posting Date");
            Validate("Document No.", LastTCSJournalLine."Document No.");
            if BottomLine and
               (LastTCSJournalLine."Balance (LCY)" = 0) and
               not LastTCSJournalLine.EmptyLine()
            then
                "Document No." := IncStr("Document No.");
        end else begin
            Validate("Posting Date", WorkDate());
            Validate("Document Date", WorkDate());
            if TCSJournalBatch."No. Series" <> '' then begin
                Clear(NoSeriesManagement);
                "Document No." := NoSeriesManagement.GetNextNo(TCSJournalBatch."No. Series", "Posting Date", false);
            end;
        end;

        Validate("Account Type", LastTCSJournalLine."Account Type");
        Validate("Document Type", LastTCSJournalLine."Document Type");
        Validate("Posting No. Series", TCSJournalBatch."Posting No. Series");
        Validate("Bal. Account Type", TCSJournalBatch."Bal. Account Type");
        Validate("Location Code", TCSJournalBatch."Location Code");
        Validate("Source Code", TCSJournalTemplate."Source Code");
        if ("Account Type" = "Account Type"::Customer) and
           ("Bal. Account Type" in ["Bal. Account Type"::Customer, "Bal. Account Type"::Vendor])
        then
            Validate("Account Type", "Account Type"::"G/L Account");
        Validate("Bal. Account No.", TCSJournalBatch."Bal. Account No.");
        Description := '';
    end;

    procedure CreateDim(DefaultDimSource: List of [Dictionary of [Integer, Code[20]]])
    begin
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';
        "Dimension Set ID" := DimensionManagement.GetDefaultDimID(DefaultDimSource, '', "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code", 0, 0);
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimensionManagement.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimensionManagement.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    procedure ShowDimensions()
    var
        ShowDimensionLbl: Label '%1 %2 %3', Comment = '%1= Journal Template Name %2= Journal Batch Name %3 = Line No.';
    begin
        "Dimension Set ID" :=
          DimensionManagement.EditDimensionSet(
            "Dimension Set ID", StrSubstNo(ShowDimensionLbl),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    local procedure CheckGLAcc()
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.CheckGLAcc();
        if GLAccount."Direct Posting" or ("Journal Template Name" = '') then
            exit;

        if "Posting Date" <> 0D then
            if "Posting Date" = ClosingDate("Posting Date") then
                exit;

        GLAccount.TestField("Direct Posting", true);
    end;

    local procedure GetCurrency()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        Currency: Record Currency;
    begin
        GeneralLedgerSetup.Get();
        Currency.InitRoundingPrecision();
    end;

    local procedure UpdateDataOnAccountNo()
    var
        Customer: Record Customer;
        GLAccount: Record "G/L Account";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        case "Account Type" of
            "Account Type"::"G/L Account":
                begin
                    GLAccount.Get("Account No.");
                    CheckGLAcc();
                    GeneralLedgerSetup.Get();
                    ReplaceInfo := "Bal. Account No." = '';
                    if not ReplaceInfo then begin
                        TCSJournalBatch.Get("Journal Template Name", "Journal Batch Name");
                        ReplaceInfo := TCSJournalBatch."Bal. Account No." <> '';
                    end;
                    if ReplaceInfo then
                        Description := GLAccount.Name;
                end;
            "Account Type"::Customer:
                begin
                    Customer.Get("Account No.");
                    Customer.CheckBlockedCustOnJnls(Customer, "Document Type", false);
                    Description := Customer.Name;
                end;
        end;
    end;

    local procedure UpdateDataOnBalAccountNo()
    var
        Customer: Record Customer;
        BankAccount: Record "Bank Account";
        GLAccount: Record "G/L Account";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        case "Bal. Account Type" of
            "Bal. Account Type"::"G/L Account":
                begin
                    GLAccount.Get("Bal. Account No.");
                    CheckGLAcc();
                    GeneralLedgerSetup.Get();
                    if "Account No." = '' then
                        Description := GLAccount.Name;
                end;
            "Bal. Account Type"::Customer:
                begin
                    Customer.Get("Bal. Account No.");
                    Customer.CheckBlockedCustOnJnls(Customer, "Document Type", false);
                    if "Account No." = '' then
                        Description := Customer.Name;
                end;
            "Bal. Account Type"::"Bank Account":
                begin
                    BankAccount.Get("Bal. Account No.");
                    BankAccount.TestField(Blocked, false);
                    if "Account No." = '' then
                        Description := BankAccount.Name;
                end;
        end;
    end;

    local procedure UpdateAmount(var TCSJournalLine: Record "TCS Journal Line")
    var
        TCSManagement: Codeunit "TCS Management";
        TDSAmount: Decimal;
    begin
        TDSAmount := TCSJournalLine."Balance TCS Amount" +
            TCSJournalLine."Balance Surcharge Amount" +
            TCSJournalLine."Balance eCESS on TCS Amt" +
            TCSJournalLine."Bal. SHE Cess on TCS Amt";

        if TCSJournalLine."Debit Amount" < TCSManagement.RoundTCSAmount(TDSAmount) then begin
            TCSJournalLine.Amount := (TCSManagement.RoundTCSAmount(TDSAmount) - TCSJournalLine."Debit Amount");
            TCSJournalLine."Bal. TCS Including SHECESS" := Abs(TCSManagement.RoundTCSAmount(TDSAmount));
        end else begin
            TCSJournalLine.Amount := -(TCSJournalLine."Debit Amount" - TCSManagement.RoundTCSAmount(TDSAmount));
            TCSJournalLine."Bal. TCS Including SHECESS" := Abs(TCSManagement.RoundTCSAmount(TDSAmount));
        end;
        TCSJournalLine.Modify();
    end;

    local procedure UpdateBalSurchargeAmount(var TCSJournalLine: Record "TCS Journal Line")
    var
        TCSManagement: Codeunit "TCS Management";
    begin
        if (TCSJournalLine."Surcharge % Applied" = 0) and (not TCSJournalLine."Surcharge Adjusted") then begin
            TCSJournalLine."Surcharge % Applied" := TCSJournalLine."Surcharge %";
            TCSJournalLine."Balance Surcharge Amount" := TCSJournalLine."Surcharge %" * TCSJournalLine."Balance TCS Amount" / 100;
        end else
            TCSJournalLine."Balance Surcharge Amount" := TCSManagement.RoundTCSAmount(TCSJournalLine."Balance TCS Amount" * TCSJournalLine."Surcharge % Applied" / 100);
        TCSJournalLine.Modify();
    end;

    local procedure UpdateBalECessAmount(var TCSJournalLine: Record "TCS Journal Line")
    var
        TCSManagement: Codeunit "TCS Management";
        TCSAmount: Decimal;
    begin
        TCSAmount := TCSJournalLine."Balance TCS Amount" + TCSJournalLine."Balance Surcharge Amount";

        if (TCSJournalLine."eCESS % Applied" = 0) and (not TCSJournalLine."eCess Adjusted") then begin
            TCSJournalLine."eCESS % Applied" := TCSJournalLine."eCESS %";
            TCSJournalLine."Balance eCESS on TCS Amt" := TCSJournalLine."eCESS %" * TCSAmount / 100;
        end else
            TCSJournalLine."Balance eCESS on TCS Amt" := TCSManagement.RoundTCSAmount(TCSAmount * TCSJournalLine."eCESS % Applied" / 100);
        TCSJournalLine.Modify();
    end;

    local procedure UpdateBalSHECessAmount(var TCSJournalLine: Record "TCS Journal Line")
    var
        TCSManagement: Codeunit "TCS Management";
    begin
        if (TCSJournalLine."SHE Cess % Applied" = 0) and (not TCSJournalLine."SHE Cess Adjusted") then begin
            TCSJournalLine."SHE Cess % Applied" := TCSJournalLine."SHE Cess % on TCS";
            TCSJournalLine."Bal. SHE Cess on TCS Amt" := TCSJournalLine."SHE Cess % on TCS" * (TCSJournalLine."Balance TCS Amount" + TCSJournalLine."Balance Surcharge Amount") / 100;
        end else
            TCSJournalLine."Bal. SHE Cess on TCS Amt" := TCSManagement.RoundTCSAmount((TCSJournalLine."Balance TCS Amount" + TCSJournalLine."Balance Surcharge Amount")
               * TCSJournalLine."SHE Cess % Applied" / 100);
        TCSJournalLine.Modify();
    end;

    local procedure RoundTCSAmounts(var TCSJournalLine: Record "TCS Journal Line"; TCSAmount: Decimal)
    var
        TCSManagement: Codeunit "TCS Management";
    begin
        TCSJournalLine."Balance TCS Amount" := TCSManagement.RoundTCSAmount(TCSAmount);
        TCSJournalLine."Balance Surcharge Amount" := TCSManagement.RoundTCSAmount(TCSJournalLine."Balance Surcharge Amount");
        TCSJournalLine."Balance eCESS on TCS Amt" := TCSManagement.RoundTCSAmount(TCSJournalLine."Balance eCESS on TCS Amt");
        TCSJournalLine."Bal. SHE Cess on TCS Amt" := TCSManagement.RoundTCSAmount(TCSJournalLine."Bal. SHE Cess on TCS Amt");
        TCSJournalLine.Modify();
    end;

    local procedure UpdateAmountForTCS(var TCSJournalLine: Record "TCS Journal Line")
    var
        TCSManagement: Codeunit "TCS Management";
        TCSAmount: Decimal;
    begin
        TCSAmount := TCSJournalLine."Balance TCS Amount" +
            TCSJournalLine."Balance Surcharge Amount" +
            TCSJournalLine."Balance eCESS on TCS Amt" +
            TCSJournalLine."Bal. SHE Cess on TCS Amt";

        if TCSJournalLine."Debit Amount" < TCSManagement.RoundTCSAmount(TCSAmount) then begin
            TCSJournalLine.Amount := (TCSManagement.RoundTCSAmount(TCSAmount) - TCSJournalLine."Debit Amount");
            TCSJournalLine."Total TCS Incl. SHE CESS" := Abs(TCSManagement.RoundTCSAmount(TCSAmount));
            TCSJournalLine."Bal. TCS Including SHECESS" := Abs(TCSManagement.RoundTCSAmount(TCSAmount));
        end else begin
            TCSJournalLine.Amount := -(TCSJournalLine."Debit Amount" - TCSManagement.RoundTCSAmount(TCSAmount));
            TCSJournalLine."Total TCS Incl. SHE CESS" := Abs(TCSManagement.RoundTCSAmount(TCSAmount));
            TCSJournalLine."Bal. TCS Including SHECESS" := Abs(TCSManagement.RoundTCSAmount(TCSAmount));
        end;
        TCSJournalLine.Modify();
    end;

    procedure CreateDimFromDefaultDim(FromFieldNo: Integer)
    var
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        InitDefaultDimensionSources(DefaultDimSource, FromFieldNo);
        CreateDim(DefaultDimSource);
    end;

    local procedure InitDefaultDimensionSources(var DefaultDimSource: List of [Dictionary of [Integer, Code[20]]]; FromFieldNo: Integer)
    begin
        DimensionManagement.AddDimSource(DefaultDimSource, DimensionManagement.TypeToTableID1("Account Type".AsInteger()), Rec."Account No.", FromFieldNo = Rec.Fieldno("Account No."));
        DimensionManagement.AddDimSource(DefaultDimSource, DimensionManagement.TypeToTableID1("Bal. Account Type".AsInteger()), Rec."Bal. Account No.", FromFieldNo = Rec.Fieldno("Bal. Account No."));
        DimensionManagement.AddDimSource(DefaultDimSource, Database::Job, '', false);
        DimensionManagement.AddDimSource(DefaultDimSource, Database::"Salesperson/Purchaser", '', false);
        DimensionManagement.AddDimSource(DefaultDimSource, Database::Campaign, '', false);
    end;
}
