// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

table 31273 "Compensation Line CZC"
{
    Caption = 'Compensation Line';
    DrillDownPageID = "Compensation Lines CZC";
    LookupPageID = "Compensation Lines CZC";

    fields
    {
        field(5; "Compensation No."; Code[20])
        {
            Caption = 'Compensation No.';
            TableRelation = "Compensation Header CZC";
            DataClassification = CustomerContent;
        }
        field(10; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(15; "Source Type"; Enum "Compensation Source Type CZC")
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Source Type" <> xRec."Source Type" then
                    Validate("Source No.", '');
            end;
        }
        field(20; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            TableRelation = if ("Source Type" = const(Customer)) Customer."No." else
            if ("Source Type" = const(Vendor)) Vendor."No.";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Source No." <> xRec."Source No." then
                    Validate("Source Entry No.", 0);
            end;
        }
        field(22; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            TableRelation = if ("Source Type" = const(Customer)) "Customer Posting Group" else
            if ("Source Type" = const(Vendor)) "Vendor Posting Group";
            DataClassification = CustomerContent;
#if not CLEAN22
#pragma warning disable AL0432

            trigger OnValidate()
            var
                PostingGroupManagementCZL: Codeunit "Posting Group Management CZL";
            begin
                if CurrFieldNo = FieldNo("Posting Group") then
                    PostingGroupManagementCZL.CheckPostingGroupChange("Posting Group", xRec."Posting Group", Rec);
            end;
#pragma warning restore AL0432
#else

            trigger OnValidate()
            var
                PostingGroupChange: Codeunit "Posting Group Change";
            begin
                if CurrFieldNo = FieldNo("Posting Group") then
                    PostingGroupChange.ChangePostingGroup("Posting Group", xRec."Posting Group", Rec);
            end;
#endif
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
            TableRelation = if ("Source Type" = const(Customer)) "Cust. Ledger Entry"."Entry No." where(Open = const(true)) else
            if ("Source Type" = const(Vendor)) "Vendor Ledger Entry"."Entry No." where(Open = const(true));
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                CustLedgerEntry: Record "Cust. Ledger Entry";
                VendorLedgerEntry: Record "Vendor Ledger Entry";
            begin
                case "Source Type" of
                    "Source Type"::Customer:
                        begin
                            CustLedgerEntry.SetCurrentKey(Open);
                            CustLedgerEntry.SetRange(Open, true);
                            CustLedgerEntry.SetRange(Prepayment, false);
                            CustLedgerEntry.SetRange("Compensation Amount (LCY) CZC", 0);
                            if CustLedgerEntry.FindSet() then
                                repeat
                                    if not CustLedgerEntry.RelatedToAdvanceLetterCZL() then
                                        CustLedgerEntry.Mark(true);
                                until CustLedgerEntry.Next() = 0;
                            CustLedgerEntry.MarkedOnly(true);
                            if Rec."Source Entry No." <> 0 then begin
                                CustLedgerEntry.SetRange("Entry No.", Rec."Source Entry No.");
                                if CustLedgerEntry.FindFirst() then;
                                CustLedgerEntry.SetRange("Entry No.");
                            end;
                            if Action::LookupOK = Page.RunModal(0, CustLedgerEntry) then
                                Validate("Source Entry No.", CustLedgerEntry."Entry No.");
                        end;
                    "Source Type"::Vendor:
                        begin
                            VendorLedgerEntry.SetCurrentKey(Open);
                            VendorLedgerEntry.SetRange(Open, true);
                            VendorLedgerEntry.SetRange(Prepayment, false);
                            VendorLedgerEntry.SetRange("Compensation Amount (LCY) CZC", 0);
                            if VendorLedgerEntry.FindSet() then
                                repeat
                                    if not VendorLedgerEntry.RelatedToAdvanceLetterCZL() then
                                        VendorLedgerEntry.Mark(true);
                                until VendorLedgerEntry.Next() = 0;
                            VendorLedgerEntry.MarkedOnly(true);
                            if Rec."Source Entry No." <> 0 then begin
                                VendorLedgerEntry.SetRange("Entry No.", Rec."Source Entry No.");
                                if VendorLedgerEntry.FindFirst() then;
                                VendorLedgerEntry.SetRange("Entry No.");
                            end;
                            if Action::LookupOK = Page.RunModal(0, VendorLedgerEntry) then
                                Validate("Source Entry No.", VendorLedgerEntry."Entry No.");
                        end;
                end;
            end;

            trigger OnValidate()
            var
                CustLedgerEntry: Record "Cust. Ledger Entry";
                VendorLedgerEntry: Record "Vendor Ledger Entry";
                RelatedToAdvanceLetterErr: Label '%1 %2 is related to Advance Letter.', Comment = '%1 = Ledger Entry TableCaption, %2 = Ledger Entry No.';
            begin
                case "Source Type" of
                    "Source Type"::Customer:
                        begin
                            if not CustLedgerEntry.Get("Source Entry No.") then
                                Clear(CustLedgerEntry);
                            CustLedgerEntry.CalcFields(Amount, "Remaining Amount", "Amount (LCY)", "Remaining Amt. (LCY)", "Compensation Amount (LCY) CZC");
                            if CustLedgerEntry."Entry No." <> 0 then begin
                                CustLedgerEntry.TestField(Open, true);
                                CustLedgerEntry.TestField(Prepayment, false);
                                if CustLedgerEntry.RelatedToAdvanceLetterCZL() then
                                    Error(RelatedToAdvanceLetterErr, CustLedgerEntry.TableCaption(), CustLedgerEntry."Entry No.");
                            end;
                            CustLedgerEntry.TestField("Compensation Amount (LCY) CZC", 0);
                            "Source No." := CustLedgerEntry."Customer No.";
                            "Posting Group" := CustLedgerEntry."Customer Posting Group";
                            Description := CustLedgerEntry.Description;
                            "Currency Code" := CustLedgerEntry."Currency Code";
                            "Ledg. Entry Original Amount" := CustLedgerEntry.Amount;
                            "Ledg. Entry Remaining Amount" := CustLedgerEntry."Remaining Amount";
                            "Ledg. Entry Original Amt.(LCY)" := CustLedgerEntry."Amount (LCY)";
                            "Ledg. Entry Rem. Amt. (LCY)" := CustLedgerEntry."Remaining Amt. (LCY)";
                            Amount := CustLedgerEntry."Remaining Amount";
                            "Amount (LCY)" := CustLedgerEntry."Remaining Amt. (LCY)";
                            "Posting Date" := CustLedgerEntry."Posting Date";
                            "Document Type" := CustLedgerEntry."Document Type";
                            "Document No." := CustLedgerEntry."Document No.";
                            "Variable Symbol" := CustLedgerEntry."Variable Symbol CZL";
                        end;
                    "Source Type"::Vendor:
                        begin
                            if not VendorLedgerEntry.Get("Source Entry No.") then
                                Clear(VendorLedgerEntry);
                            VendorLedgerEntry.CalcFields(Amount, "Remaining Amount", "Amount (LCY)", "Remaining Amt. (LCY)", "Compensation Amount (LCY) CZC");
                            if VendorLedgerEntry."Entry No." <> 0 then begin
                                VendorLedgerEntry.TestField(Open, true);
                                VendorLedgerEntry.TestField(Prepayment, false);
                                if VendorLedgerEntry.RelatedToAdvanceLetterCZL() then
                                    Error(RelatedToAdvanceLetterErr, VendorLedgerEntry.TableCaption(), VendorLedgerEntry."Entry No.");
                            end;
                            VendorLedgerEntry.TestField("Compensation Amount (LCY) CZC", 0);
                            "Source No." := VendorLedgerEntry."Vendor No.";
                            "Posting Group" := VendorLedgerEntry."Vendor Posting Group";
                            Description := VendorLedgerEntry.Description;
                            "Currency Code" := VendorLedgerEntry."Currency Code";
                            "Ledg. Entry Original Amount" := VendorLedgerEntry.Amount;
                            "Ledg. Entry Remaining Amount" := VendorLedgerEntry."Remaining Amount";
                            "Ledg. Entry Original Amt.(LCY)" := VendorLedgerEntry."Amount (LCY)";
                            "Ledg. Entry Rem. Amt. (LCY)" := VendorLedgerEntry."Remaining Amt. (LCY)";
                            Amount := VendorLedgerEntry."Remaining Amount";
                            "Amount (LCY)" := VendorLedgerEntry."Remaining Amt. (LCY)";
                            "Posting Date" := VendorLedgerEntry."Posting Date";
                            "Document Type" := VendorLedgerEntry."Document Type";
                            "Document No." := VendorLedgerEntry."Document No.";
                            "Variable Symbol" := VendorLedgerEntry."Variable Symbol CZL";
                        end;
                end;
                CheckPostingDate();
                if "Line No." <> 0 then begin
                    CopyLedgerEntryDimensions();
                    GetCurrencyFactor();
                end;
            end;
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

            trigger OnValidate()
            begin
                TestField(Amount);
                if Abs(Amount) > Abs("Ledg. Entry Remaining Amount") then
                    Error(MustBeLessOrEqualErr, FieldCaption(Amount), FieldCaption("Ledg. Entry Remaining Amount"));
                if (Amount > 0) and ("Ledg. Entry Remaining Amount" < 0) or
                   (Amount < 0) and ("Ledg. Entry Remaining Amount" > 0)
                then
                    Error(MustHaveSameSignErr, FieldCaption(Amount), FieldCaption("Ledg. Entry Remaining Amount"));

                "Remaining Amount" := "Ledg. Entry Remaining Amount" - Amount;
                ConvertLCYAmounts();
            end;
        }
        field(88; "Remaining Amount"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Remaining Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if (Abs("Remaining Amount") >= Abs("Ledg. Entry Remaining Amount")) and ("Remaining Amount" <> 0) then
                    Error(MustBeLessErr, FieldCaption("Remaining Amount"), FieldCaption("Ledg. Entry Remaining Amount"));
                if ("Remaining Amount" > 0) and ("Ledg. Entry Remaining Amount" < 0) or
                   ("Remaining Amount" < 0) and ("Ledg. Entry Remaining Amount" > 0)
                then
                    Error(MustHaveSameSignErr, FieldCaption("Remaining Amount"), FieldCaption("Ledg. Entry Remaining Amount"));

                Amount := "Ledg. Entry Remaining Amount" - "Remaining Amount";
                ConvertLCYAmounts();
            end;
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

            trigger OnValidate()
            begin
                TestField("Amount (LCY)");
                if Abs("Amount (LCY)") > Abs("Ledg. Entry Rem. Amt. (LCY)") then
                    Error(MustBeLessOrEqualErr, FieldCaption("Amount (LCY)"), FieldCaption("Ledg. Entry Rem. Amt. (LCY)"));
                if ("Amount (LCY)" > 0) and ("Ledg. Entry Rem. Amt. (LCY)" < 0) or
                   ("Amount (LCY)" < 0) and ("Ledg. Entry Rem. Amt. (LCY)" > 0)
                then
                    Error(MustHaveSameSignErr, FieldCaption("Amount (LCY)"), FieldCaption("Ledg. Entry Rem. Amt. (LCY)"));

                ConvertAmounts();
                Validate(Amount);
            end;
        }
        field(98; "Remaining Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Remaining Amount (LCY)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if (Abs("Remaining Amount (LCY)") >= Abs("Ledg. Entry Rem. Amt. (LCY)")) and ("Remaining Amount (LCY)" <> 0) then
                    Error(MustBeLessErr, FieldCaption("Remaining Amount (LCY)"), FieldCaption("Ledg. Entry Rem. Amt. (LCY)"));
                if ("Remaining Amount (LCY)" > 0) and ("Ledg. Entry Rem. Amt. (LCY)" < 0) or
                   ("Remaining Amount (LCY)" < 0) and ("Ledg. Entry Rem. Amt. (LCY)" > 0)
                then
                    Error(MustHaveSameSignErr, FieldCaption("Remaining Amount (LCY)"), FieldCaption("Ledg. Entry Rem. Amt. (LCY)"));

                ConvertAmounts();
                Validate("Remaining Amount");
            end;
        }
        field(100; "Manual Change Only"; Boolean)
        {
            Caption = 'Manual Change Only';
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

            trigger OnValidate()
            begin
                DimensionManagement.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
            end;
        }
    }

    keys
    {
        key(PK; "Compensation No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Compensation No.", "Source Type", "Source Entry No.")
        {
            SumIndexFields = "Ledg. Entry Rem. Amt. (LCY)", "Amount (LCY)";
        }
    }

    trigger OnDelete()
    begin
        TestStatusOpen();
    end;

    trigger OnInsert()
    begin
        TestStatusOpen();
        TestField("Source Entry No.");
        CopyLedgerEntryDimensions();
        GetCurrencyFactor();
    end;

    trigger OnModify()
    begin
        TestStatusOpen();
    end;

    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        DimensionManagement: Codeunit DimensionManagement;
        StatusCheckSuspend: Boolean;
        MustBeLessOrEqualErr: Label '%1 must be less or equal to %2.', Comment = '%1 = FieldCaption, %2 = FieldCaption';
        MustHaveSameSignErr: Label '%1 must have the same sign as %2.', Comment = '%1 = FieldCaption, %2 = FieldCaption';
        MustBeLessErr: Label '%1 must be less than %2.', Comment = '%1 = FieldCaption, %2 = FieldCaption';
        DateMustBeLessOrEqualErr: Label 'must be less or equal to %1', Comment = '%1 = Posting Date';
        DimensionSetCaptionTok: Label '%1 %2', Comment = '%1 = Compensation No., %2 = Line No.', Locked = true;

    procedure ShowDimensions()
    begin
        "Dimension Set ID" := DimensionManagement.EditDimensionSet("Dimension Set ID", StrSubstNo(DimensionSetCaptionTok, "Compensation No.", "Line No."));
        DimensionManagement.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    procedure CopyLedgerEntryDimensions()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        "Dimension Set ID" := 0;
        "Shortcut Dimension 1 Code" := '';
        "Shortcut Dimension 2 Code" := '';

        if "Source Entry No." = 0 then
            exit;
        case "Source Type" of
            "Source Type"::Customer:
                begin
                    CustLedgerEntry.Get("Source Entry No.");
                    "Dimension Set ID" := CustLedgerEntry."Dimension Set ID";
                    "Shortcut Dimension 1 Code" := CustLedgerEntry."Global Dimension 1 Code";
                    "Shortcut Dimension 2 Code" := CustLedgerEntry."Global Dimension 2 Code";
                end;
            "Source Type"::Vendor:
                begin
                    VendorLedgerEntry.Get("Source Entry No.");
                    "Dimension Set ID" := VendorLedgerEntry."Dimension Set ID";
                    "Shortcut Dimension 1 Code" := VendorLedgerEntry."Global Dimension 1 Code";
                    "Shortcut Dimension 2 Code" := VendorLedgerEntry."Global Dimension 2 Code";
                end;
        end;
    end;

    local procedure TestStatusOpen()
    begin
        if StatusCheckSuspend then
            exit;
        GetCompensationHeaderCZC();
        CompensationHeaderCZC.TestField(Status, CompensationHeaderCZC.Status::Open);
    end;

    procedure SuspendStatusCheck(Suspend: Boolean)
    begin
        StatusCheckSuspend := Suspend;
    end;

    local procedure GetCurrency()
    begin
        if "Currency Code" = '' then begin
            Clear(Currency);
            Currency.InitRoundingPrecision();
        end else
            if "Currency Code" <> Currency.Code then begin
                Currency.Get("Currency Code");
                Currency.TestField("Amount Rounding Precision");
            end;
    end;

    local procedure GetCurrencyFactor()
    begin
        GetCompensationHeaderCZC();
        CompensationHeaderCZC.TestField("Posting Date");
        if "Currency Code" = '' then
            "Currency Factor" := 1
        else
            "Currency Factor" := CurrencyExchangeRate.ExchangeRate(CompensationHeaderCZC."Posting Date", "Currency Code");
        ConvertLCYAmounts();
    end;

    procedure SetCompensationHeaderCZC(NewCompensationHeader: Record "Compensation Header CZC")
    begin
        CompensationHeaderCZC := NewCompensationHeader;
    end;

    local procedure GetCompensationHeaderCZC()
    begin
        TestField("Compensation No.");
        if "Compensation No." <> CompensationHeaderCZC."No." then
            CompensationHeaderCZC.Get("Compensation No.");
    end;

    procedure ConvertLCYAmounts()
    begin
        GetCompensationHeaderCZC();
        GetCurrency();
        if "Currency Code" = '' then begin
            "Amount (LCY)" := Amount;
            "Remaining Amount (LCY)" := "Remaining Amount";
        end else begin
            "Amount (LCY)" := Round(
                CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                  CompensationHeaderCZC."Posting Date", "Currency Code",
                  Amount, "Currency Factor"));
            "Remaining Amount (LCY)" := Round(
                CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                  CompensationHeaderCZC."Posting Date", "Currency Code",
                  "Remaining Amount", "Currency Factor"));
        end;
        Amount := Round(Amount, Currency."Amount Rounding Precision");
        "Remaining Amount" := Round("Remaining Amount", Currency."Amount Rounding Precision");
    end;

    procedure ConvertAmounts()
    begin
        GetCompensationHeaderCZC();
        GetCurrency();
        if "Currency Code" = '' then begin
            Amount := "Amount (LCY)";
            "Remaining Amount" := "Remaining Amount (LCY)";
        end else begin
            Amount := Round(
                CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                  CompensationHeaderCZC."Posting Date", "Currency Code",
                  "Amount (LCY)", "Currency Factor"),
                Currency."Amount Rounding Precision");
            "Remaining Amount" := Round(
                CurrencyExchangeRate.ExchangeAmtLCYToFCY(
                  CompensationHeaderCZC."Posting Date", "Currency Code",
                  "Remaining Amount (LCY)", "Currency Factor"),
                Currency."Amount Rounding Precision");
        end;

        Clear(Currency);
        Currency.InitRoundingPrecision();
        "Amount (LCY)" := Round("Amount (LCY)", Currency."Amount Rounding Precision");
        "Remaining Amount (LCY)" := Round("Remaining Amount (LCY)", Currency."Amount Rounding Precision");
    end;

    procedure CheckPostingDate()
    begin
        TestField("Compensation No.");
        CompensationHeaderCZC.Get("Compensation No.");
        if (CompensationHeaderCZC."Posting Date" <> 0D) and ("Posting Date" <> 0D) then
            if CompensationHeaderCZC."Posting Date" < "Posting Date" then
                FieldError("Posting Date", StrSubstNo(DateMustBeLessOrEqualErr, CompensationHeaderCZC."Posting Date"));
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimensionManagement.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20])
    begin
        DimensionManagement.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber, ShortcutDimCode);
    end;

    procedure ShowShortcutDimCode(var ShortcutDimCode: array[8] of Code[20])
    begin
        DimensionManagement.GetShortcutDimensions("Dimension Set ID", ShortcutDimCode);
    end;

    procedure CalcRelatedAmountToApply(): Decimal
    var
        TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
    begin
        FindRelatedAmountToApply(TempCrossApplicationBufferCZL);
        TempCrossApplicationBufferCZL.CalcSums("Amount (LCY)");
        exit(TempCrossApplicationBufferCZL."Amount (LCY)");
    end;

    procedure DrillDownRelatedAmountToApply()
    var
        TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary;
    begin
        FindRelatedAmountToApply(TempCrossApplicationBufferCZL);
        Page.Run(Page::"Cross Application CZL", TempCrossApplicationBufferCZL);
    end;

    local procedure FindRelatedAmountToApply(var TempCrossApplicationBufferCZL: Record "Cross Application Buffer CZL" temporary)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CrossApplicationMgtCZL: Codeunit "Cross Application Mgt. CZL";
    begin
        if Rec."Source No." = '' then
            exit;

        case Rec."Source Type" of
            Rec."Source Type"::Customer:
                if Rec."Source Entry No." <> 0 then
                    if CustLedgerEntry.Get(Rec."Source Entry No.") then
                        CrossApplicationMgtCZL.OnGetSuggestedAmountForCustLedgerEntry(CustLedgerEntry, TempCrossApplicationBufferCZL,
                                                                                      Database::"Compensation Line CZC", Rec."Compensation No.", Rec."Line No.");
            Rec."Source Type"::Vendor:
                if Rec."Source Entry No." <> 0 then
                    if VendorLedgerEntry.Get(Rec."Source Entry No.") then
                        CrossApplicationMgtCZL.OnGetSuggestedAmountForVendLedgerEntry(VendorLedgerEntry, TempCrossApplicationBufferCZL,
                                                                                      Database::"Compensation Line CZC", Rec."Compensation No.", Rec."Line No.");
        end;
    end;
}
