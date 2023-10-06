// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Maintenance;

table 18633 "Fixed Asset Shift"
{
    Caption = 'Fixed Asset Shift';
    DrillDownPageID = "Fixed Asset Shifts";
    LookupPageID = "Fixed Asset Shifts";
    Permissions = TableData "FA Ledger Entry" = r,
                  TableData "Maintenance Ledger Entry" = r;

    fields
    {
        field(1; "FA No."; Code[20])
        {
            Caption = 'FA No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Fixed Asset";
        }
        field(2; "Depreciation Book Code"; Code[10])
        {
            Caption = 'Depreciation Book Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(3; "Depreciation Method"; enum "Depreciation Method")
        {
            Caption = 'Depreciation Method';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                DepreciationMethodOnValidate();
            end;
        }
        field(4; "Depreciation Starting Date"; Date)
        {
            Caption = 'Depreciation Starting Date';
            Editable = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckPeriodOverlap("Depreciation Starting Date");
                ModifyDeprFields();
                CalcDeprPeriod();
            end;
        }
        field(5; "Straight-Line %"; Decimal)
        {
            Caption = 'Straight-Line %';
            DecimalPlaces = 2 : 8;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                case "Depreciation Method" of
                    "Depreciation Method"::"Declining-Balance 1",
                    "Depreciation Method"::"Declining-Balance 2",
                    "Depreciation Method"::"User-Defined",
                    "Depreciation Method"::Manual:
                        DeprMethodError();
                end;
            end;
        }
        field(6; "No. of Depreciation Years"; Decimal)
        {
            Caption = 'No. of Depreciation Years';
            DecimalPlaces = 2 : 8;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Depreciation Starting Date");
                ModifyDeprFields();
                if ("No. of Depreciation Years" <> 0) and not LinearMethod() then
                    DeprMethodError();

                "No. of Depreciation Months" := Round("No. of Depreciation Years" * 12, 0.00000001);
                AdjustLinearMethod("Straight-Line %", "Fixed Depr. Amount");
                "Depreciation ending Date" := CalcendingDate();
            end;
        }
        field(7; "No. of Depreciation Months"; Decimal)
        {
            Caption = 'No. of Depreciation Months';
            DecimalPlaces = 2 : 8;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Depreciation Starting Date");
                ModifyDeprFields();
                if ("No. of Depreciation Months" <> 0) and not LinearMethod() then
                    DeprMethodError();

                "No. of Depreciation Years" := Round("No. of Depreciation Months" / 12, 0.00000001);
                AdjustLinearMethod("Straight-Line %", "Fixed Depr. Amount");
                "Depreciation ending Date" := CalcendingDate();
            end;
        }
        field(8; "Fixed Depr. Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Fixed Depr. Amount';
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ModifyDeprFields();
                if ("Fixed Depr. Amount" <> 0) and not LinearMethod() then
                    DeprMethodError();

                AdjustLinearMethod("Straight-Line %", "No. of Depreciation Years");
            end;
        }
        field(9; "Declining-Balance %"; Decimal)
        {
            Caption = 'Declining-Balance %';
            DecimalPlaces = 2 : 8;
            MaxValue = 100;
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Declining-Balance %" >= 100 then
                    FieldError("Declining-Balance %", DecliningBalancePercentErr);

                case "Depreciation Method" of
                    "Depreciation Method"::"Straight-Line",
                    "Depreciation Method"::"User-Defined",
                    "Depreciation Method"::Manual:
                        DeprMethodError();
                end;
            end;
        }
        field(10; "Depreciation Table Code"; Code[10])
        {
            Caption = 'Depreciation Table Code';
            TableRelation = "Depreciation Table Header";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ModifyDeprFields();
                if ("Depreciation Table Code" <> '') and not UserDefinedMethod() then
                    DeprMethodError();
            end;
        }
        field(11; "Final Rounding Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Final Rounding Amount';
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ModifyDeprFields();
            end;
        }
        field(12; "ending Book Value"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'ending Book Value';
            MinValue = 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ModifyDeprFields();
            end;
        }
        field(13; "FA Posting Group"; Code[10])
        {
            Caption = 'FA Posting Group';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'New field introduced as Fixed Asset Posting Group';
            ObsoleteTag = '23.0';

            trigger OnValidate()
            begin
                ModifyDeprFields();
            end;
        }
        field(14; "Depreciation ending Date"; Date)
        {
            Caption = 'Depreciation ending Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Depreciation Starting Date");
                CheckPeriodOverlap("Depreciation ending Date");
                CalcDeprPeriod();
            end;
        }
        field(15; "Acquisition Cost"; Decimal)
        {
            AutoFormatType = 1;
            FieldClass = FlowField;
            CalcFormula = sum("FA Ledger Entry".Amount where(
                "FA No." = field("FA No."),
                "Depreciation Book Code" = field("Depreciation Book Code"),
                "FA Posting Category" = const(" "),
                "FA Posting Type" = const("Acquisition Cost"),
                "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Acquisition Cost';
            Editable = false;
        }
        field(16; Depreciation; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("FA Ledger Entry".Amount where(
                "FA No." = field("FA No."),
                "Depreciation Book Code" = field("Depreciation Book Code"),
                "FA Posting Category" = const(" "),
                "FA Posting Type" = const(Depreciation),
                "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Depreciation';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "Book Value"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("FA Ledger Entry".Amount where(
                "FA No." = field("FA No."),
                "Depreciation Book Code" = field("Depreciation Book Code"),
                "Part of Book Value" = const(true),
                "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Book Value';
            Editable = false;
            FieldClass = FlowField;
        }
        field(18; "Proceeds on Disposal"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("FA Ledger Entry".Amount where(
                "FA No." = field("FA No."),
                "Depreciation Book Code" = field("Depreciation Book Code"),
                "FA Posting Category" = const(" "),
                "FA Posting Type" = const("Proceeds on Disposal"),
                "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Proceeds on Disposal';
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; "Gain/Loss"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("FA Ledger Entry".Amount where(
                "FA No." = field("FA No."),
                "Depreciation Book Code" = field("Depreciation Book Code"),
                "FA Posting Category" = const(" "),
                "FA Posting Type" = const("Gain/Loss"),
                "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Gain/Loss';
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "Write-Down"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("FA Ledger Entry".Amount where(
                "FA No." = field("FA No."),
                "Depreciation Book Code" = field("Depreciation Book Code"),
                "FA Posting Category" = const(" "),
                "FA Posting Type" = const("Write-Down"),
                "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Write-Down';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; Appreciation; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("FA Ledger Entry".Amount where(
                "FA No." = field("FA No."),
                "Depreciation Book Code" = field("Depreciation Book Code"),
                "FA Posting Category" = const(" "),
                "FA Posting Type" = const(Appreciation),
                "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Appreciation';
            Editable = false;
            FieldClass = FlowField;
        }
        field(22; "Custom 1"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("FA Ledger Entry".Amount where(
                "FA No." = field("FA No."),
                "Depreciation Book Code" = field("Depreciation Book Code"),
                "FA Posting Category" = const(" "),
                "FA Posting Type" = const("Custom 1"),
                "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Custom 1';
            Editable = false;
            FieldClass = FlowField;
        }
        field(23; "Custom 2"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("FA Ledger Entry".Amount where(
                "FA No." = field("FA No."),
                "Depreciation Book Code" = field("Depreciation Book Code"),
                "FA Posting Category" = const(" "),
                "FA Posting Type" = const("Custom 2"),
                "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Custom 2';
            Editable = false;
            FieldClass = FlowField;
        }
        field(24; "Depreciable Basis"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("FA Ledger Entry".Amount where(
                "FA No." = field("FA No."),
                "Depreciation Book Code" = field("Depreciation Book Code"),
                "Part of Depreciable Basis" = const(true),
                "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Depreciable Basis';
            Editable = false;
            FieldClass = FlowField;
        }
        field(25; "Salvage Value"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("FA Ledger Entry".Amount where(
                "FA No." = field("FA No."),
                "Depreciation Book Code" = field("Depreciation Book Code"),
                "FA Posting Category" = const(" "),
                "FA Posting Type" = const("Salvage Value"),
                "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Salvage Value';
            Editable = false;
            FieldClass = FlowField;
        }
        field(26; "Book Value on Disposal"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("FA Ledger Entry".Amount where(
                "FA No." = field("FA No."),
                "Depreciation Book Code" = field("Depreciation Book Code"),
                "FA Posting Category" = const(Disposal),
                "FA Posting Type" = const("Book Value on Disposal"),
                "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Book Value on Disposal';
            Editable = false;
            FieldClass = FlowField;
        }
        field(27; Maintenance; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Maintenance Ledger Entry".Amount where(
                "FA No." = field("FA No."),
                "Depreciation Book Code" = field("Depreciation Book Code"),
                "Maintenance Code" = field("Maintenance Code Filter"),
                "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Maintenance';
            Editable = false;
            FieldClass = FlowField;
        }
        field(28; "Maintenance Code Filter"; Code[10])
        {
            Caption = 'Maintenance Code Filter';
            FieldClass = FlowFilter;
            TableRelation = Maintenance;
        }
        field(29; "FA Posting Date Filter"; Date)
        {
            Caption = 'FA Posting Date Filter';
            FieldClass = FlowFilter;
        }
        field(30; "Acquisition Date"; Date)
        {
            Caption = 'Acquisition Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(31; "G/L Acquisition Date"; Date)
        {
            Caption = 'G/L Acquisition Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(32; "Disposal Date"; Date)
        {
            Caption = 'Disposal Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(33; "Last Acquisition Cost Date"; Date)
        {
            Caption = 'Last Acquisition Cost Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(34; "Last Depreciation Date"; Date)
        {
            Caption = 'Last Depreciation Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(35; "Last Write-Down Date"; Date)
        {
            Caption = 'Last Write-Down Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(36; "Last Appreciation Date"; Date)
        {
            Caption = 'Last Appreciation Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(37; "Last Custom 1 Date"; Date)
        {
            Caption = 'Last Custom 1 Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(38; "Last Custom 2 Date"; Date)
        {
            Caption = 'Last Custom 2 Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(39; "Last Salvage Value Date"; Date)
        {
            Caption = 'Last Salvage Value Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; "FA Exchange Rate"; Decimal)
        {
            Caption = 'FA Exchange Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 4 : 4;
            MinValue = 0;
        }
        field(41; "Fixed Depr. Amount below Zero"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Fixed Depr. Amount below Zero';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                ModifyDeprFields();
                "Depr. below Zero %" := 0;
                if "Fixed Depr. Amount below Zero" > 0 then begin
                    DeprBook.Get("Depreciation Book Code");
                    DeprBook.TestField("Allow Depr. below Zero", true);
                    TestField("Use FA Ledger Check", true);
                end;
            end;
        }
        field(42; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(43; "First User-Defined Depr. Date"; Date)
        {
            Caption = 'First User-Defined Depr. Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ModifyDeprFields();
                if ("First User-Defined Depr. Date" <> 0D) and not UserDefinedMethod() then
                    DeprMethodError();
            end;
        }
        field(44; "Use FA Ledger Check"; Boolean)
        {
            Caption = 'Use FA Ledger Check';
            DataClassification = CustomerContent;
            InitValue = true;

            trigger OnValidate()
            begin
                if not "Use FA Ledger Check" then begin
                    DeprBook.Get("Depreciation Book Code");
                    DeprBook.TestField("Use FA Ledger Check", false);
                    TestField("Fixed Depr. Amount below Zero", 0);
                    TestField("Depr. below Zero %", 0);
                end;
                ModifyDeprFields();
            end;
        }
        field(45; "Last Maintenance Date"; Date)
        {
            Caption = 'Last Maintenance Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(46; "Depr. below Zero %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Depr. below Zero %';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 8;
            MinValue = 0;

            trigger OnValidate()
            begin
                ModifyDeprFields();
                "Fixed Depr. Amount below Zero" := 0;
                if "Depr. below Zero %" > 0 then begin
                    DeprBook.Get("Depreciation Book Code");
                    DeprBook.TestField("Allow Depr. below Zero", true);
                    TestField("Use FA Ledger Check", true);
                end;
            end;
        }
        field(47; "Projected Disposal Date"; Date)
        {
            Caption = 'Projected Disposal Date';
            DataClassification = CustomerContent;
        }
        field(48; "Projected Proceeds on Disposal"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Projected Proceeds on Disposal';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(50; "Depr. Starting Date (Custom 1)"; Date)
        {
            Caption = 'Depr. Starting Date (Custom 1)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ModifyDeprFields();
            end;
        }
        field(51; "Depr. ending Date (Custom 1)"; Date)
        {
            Caption = 'Depr. ending Date (Custom 1)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ModifyDeprFields();
            end;
        }
        field(52; "Accum. Depr. % (Custom 1)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Accum. Depr. % (Custom 1)';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 8;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                ModifyDeprFields();
            end;
        }
        field(53; "Depr. This Year % (Custom 1)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Depr. This Year % (Custom 1)';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 8;
            MaxValue = 100;
            MinValue = 0;
        }
        field(54; "Property Class (Custom 1)"; Enum "Property Class Custom 1")
        {
            Caption = 'Property Class (Custom 1)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ModifyDeprFields();
            end;
        }
        field(55; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(56; "Main Asset/Component"; Enum "Main Asset/Component")
        {
            Caption = 'Main Asset/Component';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(57; "Component of Main Asset"; Code[20])
        {
            Caption = 'Component of Main Asset';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Fixed Asset";
        }
        field(58; "FA Add.-Currency Factor"; Decimal)
        {
            Caption = 'FA Add.-Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            MinValue = 0;
        }
        field(59; "Use Half-Year Convention"; Boolean)
        {
            Caption = 'Use Half-Year Convention';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ModifyDeprFields();
                TestHalfYearConventionMethod();
            end;
        }
        field(60; "Use DB% First Fiscal Year"; Boolean)
        {
            Caption = 'Use DB% First Fiscal Year';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Use DB% First Fiscal Year" then
                    if not (("Depreciation Method" = "Depreciation Method"::"DB1/SL") or
                            ("Depreciation Method" = "Depreciation Method"::"DB2/SL"))
                    then
                        DeprMethodError();
            end;
        }
        field(61; "Temp. ending Date"; Date)
        {
            Caption = 'Temp. ending Date';
            DataClassification = CustomerContent;
        }
        field(62; "Temp. Fixed Depr. Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Temp. Fixed Depr. Amount';
            DataClassification = CustomerContent;
        }
        field(63; "Shift Type"; Enum "Shift Type")
        {
            Caption = 'Shift Type';
            DataClassification = CustomerContent;
        }
        field(64; "Industry Type"; Enum "Industry Type")
        {
            Caption = 'Industry Type';
            DataClassification = CustomerContent;
        }
        field(65; "Used No. of Days"; Integer)
        {
            Caption = 'Used No. of Days';
            DataClassification = CustomerContent;
        }
        field(66; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(70; "Fixed Asset Posting Group"; Code[20])
        {
            Caption = 'Fixed Asset Posting Group';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ModifyDeprFields();
            end;
        }
        field(100; "Calculate FA Depreciation"; Boolean)
        {
            Caption = 'Calculate FA Depreciation';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "FA No.", "Depreciation Book Code", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Industry Type", "FA No.", "Depreciation Book Code")
        {
        }
    }

    trigger OnDelete()
    begin
        FALedgEntry.Reset();
        FALedgEntry.SetRange("FA No.", "FA No.");
        FALedgEntry.SetRange("Depreciation Book Code", "Depreciation Book Code");
        FALedgEntry.SetRange("FA Posting Type", FALedgEntry."FA Posting Type"::Depreciation);
        FALedgEntry.SetRange("Depreciation Starting Date", "Depreciation Starting Date");
        FALedgEntry.SetRange("Depreciation ending Date", "Depreciation ending Date");
        if FALedgEntry.FindFirst() then
            Error(FAExistsErr);
    end;

    trigger OnInsert()
    begin
        InitShift();
    end;

    var
        FALedgEntry: Record "FA Ledger Entry";
        DeprBook: Record "Depreciation Book";
        FADeprBook: Record "FA Depreciation Book";
        FAShifts: Record "Fixed Asset Shift";
        FADateCalc: Codeunit "FA Date Calculation";
        DepreciationCalc: Codeunit "Depreciation Calculation";
        DecliningBalancePercentErr: Label 'must not be 100';
        DepreciationDateErr: Label '%1 is later than %2.', Comment = '%1= Start Date , %2 = End Date';
        DepreciationMethodErr: Label 'must not be %1', Comment = '%1 = Text of Depeciation method';
        OverlappingPeriodErr: Label 'Overlapping period.';
        FAExistsErr: Label 'FA Ledger Entries exists for this asset.';

    procedure GetExchangeRate(): Decimal
    begin
        DeprBook.Get("Depreciation Book Code");
        if not DeprBook."Use FA Exch. Rate in Duplic." then
            exit(0);

        if "FA Exchange Rate" > 0 then
            exit("FA Exchange Rate");

        exit(DeprBook."Default Exchange Rate");
    end;

    local procedure UserDefinedMethod(): Boolean
    begin
        exit("Depreciation Method" = "Depreciation Method"::"User-Defined");
    end;

    local procedure TestHalfYearConventionMethod(): Boolean
    begin
        if "Depreciation Method" in
           ["Depreciation Method"::"Declining-Balance 2",
            "Depreciation Method"::"DB2/SL",
            "Depreciation Method"::"User-Defined"]
        then
            TestField("Use Half-Year Convention", false);
    end;

    local procedure DeprMethodError()
    begin
        FieldError("Depreciation Method", StrSubstNo(DepreciationMethodErr, "Depreciation Method"));
    end;

    local procedure InitShift()
    begin
        FADeprBook.Get("FA No.", "Depreciation Book Code");
        "Fixed Depr. Amount" := FADeprBook."Fixed Depr. Amount";
        "Depreciation Table Code" := FADeprBook."Depreciation Table Code";
        "Final Rounding Amount" := FADeprBook."Final Rounding Amount";
        "ending Book Value" := FADeprBook."ending Book Value";
        "Acquisition Date" := FADeprBook."Acquisition Date";
        "G/L Acquisition Date" := FADeprBook."G/L Acquisition Date";
        "Disposal Date" := FADeprBook."Disposal Date";
        "Last Acquisition Cost Date" := FADeprBook."Last Acquisition Cost Date";
        "Last Depreciation Date" := FADeprBook."Last Depreciation Date";
        "Last Write-Down Date" := FADeprBook."Last Write-Down Date";
        "Last Appreciation Date" := FADeprBook."Last Appreciation Date";
        "Last Custom 1 Date" := FADeprBook."Last Custom 1 Date";
        "Last Custom 2 Date" := FADeprBook."Last Custom 2 Date";
        "Last Salvage Value Date" := FADeprBook."Last Salvage Value Date";
        "FA Exchange Rate" := FADeprBook."FA Exchange Rate";
        "Fixed Depr. Amount below Zero" := FADeprBook."Fixed Depr. Amount below Zero";
        "Last Date Modified" := FADeprBook."Last Date Modified";
        "First User-Defined Depr. Date" := FADeprBook."First User-Defined Depr. Date";

        FAShifts.Reset();
        FAShifts.SetRange("FA No.", "FA No.");
        FAShifts.SetRange("Depreciation Book Code", "Depreciation Book Code");
        if FAShifts.FindLast() then
            "Line No." := FAShifts."Line No." + 10000
        else
            "Line No." := 10000;
    end;

    local procedure CheckPeriodOverlap(TempDate: Date)
    var
        PeriodOverlapFAShifts: Record "Fixed Asset Shift";
    begin
        PeriodOverlapFAShifts.Reset();
        PeriodOverlapFAShifts.SetRange("FA No.", "FA No.");
        PeriodOverlapFAShifts.SetRange("Depreciation Book Code", "Depreciation Book Code");
        PeriodOverlapFAShifts.SetFilter("Line No.", '<>%1', "Line No.");
        PeriodOverlapFAShifts.SetFilter("Depreciation Starting Date", '<=%1', TempDate);
        PeriodOverlapFAShifts.SetFilter("Depreciation ending Date", '>=%1', TempDate);
        if not PeriodOverlapFAShifts.IsEmpty() then
            Error(OverlappingPeriodErr);
    end;

    local procedure LinearMethod(): Boolean
    begin
        exit(
          "Depreciation Method" in
          ["Depreciation Method"::"Straight-Line",
           "Depreciation Method"::"DB1/SL",
           "Depreciation Method"::"DB2/SL"]);
    end;

    local procedure DepreciationMethodOnValidate()
    begin
        ModifyDeprFields();
        case "Depreciation Method" of
            "Depreciation Method"::"Straight-Line":
                begin
                    "Declining-Balance %" := 0;
                    "Depreciation Table Code" := '';
                    "First User-Defined Depr. Date" := 0D;
                    "Use DB% First Fiscal Year" := false;
                end;

            "Depreciation Method"::"Declining-Balance 1",
            "Depreciation Method"::"Declining-Balance 2":
                begin
                    "Straight-Line %" := 0;
                    "No. of Depreciation Years" := 0;
                    "No. of Depreciation Months" := 0;
                    "Fixed Depr. Amount" := 0;
                    "Depreciation Table Code" := '';
                    "First User-Defined Depr. Date" := 0D;
                    "Use DB% First Fiscal Year" := false;
                end;

            "Depreciation Method"::"DB1/SL",
            "Depreciation Method"::"DB2/SL":
                begin
                    "Depreciation Table Code" := '';
                    "First User-Defined Depr. Date" := 0D;
                end;

            "Depreciation Method"::"User-Defined":
                begin
                    "Straight-Line %" := 0;
                    "No. of Depreciation Years" := 0;
                    "No. of Depreciation Months" := 0;
                    "Fixed Depr. Amount" := 0;
                    "Declining-Balance %" := 0;
                    "Use DB% First Fiscal Year" := false;
                end;

            "Depreciation Method"::Manual:
                begin
                    "Straight-Line %" := 0;
                    "No. of Depreciation Years" := 0;
                    "No. of Depreciation Months" := 0;
                    "Fixed Depr. Amount" := 0;
                    "Declining-Balance %" := 0;
                    "Depreciation Table Code" := '';
                    "First User-Defined Depr. Date" := 0D;
                    "Use DB% First Fiscal Year" := false;
                end;
        end;
        TestHalfYearConventionMethod();
    end;

    local procedure AdjustLinearMethod(var Amount1: Decimal; var Amount2: Decimal)
    begin
        Amount1 := 0;
        Amount2 := 0;
        if "No. of Depreciation Years" = 0 then begin
            "No. of Depreciation Months" := 0;
            "Depreciation ending Date" := 0D;
        end;
    end;

    local procedure ModifyDeprFields()
    begin
        if ("Last Depreciation Date" > 0D) or
           ("Last Write-Down Date" > 0D) or
           ("Last Appreciation Date" > 0D) or
           ("Last Custom 1 Date" > 0D) or
           ("Last Custom 2 Date" > 0D) or
           ("Disposal Date" > 0D)
        then begin
            DeprBook.Get("Depreciation Book Code");
            DeprBook.TestField("Allow Changes in Depr. Fields", true);
        end;
    end;

    local procedure CalcDeprPeriod()
    begin
        if "Depreciation Starting Date" = 0D then begin
            "Depreciation ending Date" := 0D;
            "No. of Depreciation Years" := 0;
            "No. of Depreciation Months" := 0;
        end;

        if ("Depreciation Starting Date" = 0D) or ("Depreciation ending Date" = 0D) then begin
            "No. of Depreciation Years" := 0;
            "No. of Depreciation Months" := 0;
        end else begin
            if "Depreciation Starting Date" > "Depreciation ending Date" then
                Error(
                  DepreciationDateErr,
                  FieldCaption("Depreciation Starting Date"), FieldCaption("Depreciation ending Date"));

            "No. of Depreciation Months" := DepreciationCalc.DeprDays("Depreciation Starting Date", "Depreciation ending Date", false) / 30;
            "No. of Depreciation Months" := Round("No. of Depreciation Months", 0.00000001);
            "No. of Depreciation Years" := Round("No. of Depreciation Months" / 12, 0.00000001);
        end;
    end;

    local procedure CalcendingDate(): Date
    var
        EndingDate: Date;
    begin
        if "No. of Depreciation Years" = 0 then
            exit(0D);
        if DeprBook.Code <> "Depreciation Book Code" then
            DeprBook.Get("Depreciation Book Code");

        EndingDate := FADateCalc.CalculateDate("Depreciation Starting Date", Round("No. of Depreciation Years" * 360, 1), false);
        EndingDate := DepreciationCalc.Yesterday(EndingDate, false);

        if EndingDate < "Depreciation Starting Date" then
            EndingDate := "Depreciation Starting Date";

        exit(EndingDate);
    end;
}
