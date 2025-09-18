// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;

table 4401 "EXR Aging Report Buffer"
{
    AllowInCustomizations = Never;
    Caption = 'Aging Report Buffer';
    DataClassification = CustomerContent;
    TableType = Temporary;
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "Period Start Date"; Date)
        {
            Caption = 'Period Start Date';
        }
        field(3; "Period End Date"; Date)
        {
            Caption = 'Period End Date';
        }
        field(4; "Vendor Source No."; Code[20])
        {
            Caption = 'Source No.';
        }
        field(10; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(11; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(12; "Currency Code"; Code[20])
        {
            Caption = 'Currency Code';
        }
        field(13; "Remaining Amount"; Decimal)
        {
            Caption = 'Remaining Amount';
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
        }
        field(14; "Remaining Amount (LCY)"; Decimal)
        {
            Caption = 'Remaining Amount (LCY)';
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
        field(15; "Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Dimension 1 Code';
        }
        field(16; "Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Dimension 2 Code';
        }
        field(20; "Original Amount"; Decimal)
        {
            Caption = 'Original Amount';
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
        }
        field(21; "Original Amount (LCY)"; Decimal)
        {
            Caption = 'Original Amount (LCY)';
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
        field(22; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(23; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(25; "Source Name"; Text[100])
        {
            Caption = 'Source Name';
        }
        field(26; "Aged By"; Option)
        {
            Caption = 'Aged By';
            OptionMembers = "Due Date","Posting Date","Document Date";
            OptionCaption = 'Due Date, Posting Date, Document Date';
        }
        field(27; "Reporting Date"; Date)
        {
            Caption = 'Reporting Date';
            CaptionClass = '3,' + GetReportingDateCaption();
        }
        field(28; "Reporting Date Month"; Integer)
        {
            Caption = 'Reporting Date (Month)';
            CaptionClass = '3,' + GetReportingDateMonthCaption();
        }
        field(29; "Reporting Date Quarter"; Integer)
        {
            Caption = 'Reporting Date (Quarter)';
            CaptionClass = '3,' + GetReportingDateQuarterCaption();
        }
        field(30; "Reporting Date Year"; Integer)
        {
            Caption = 'Reporting Date (Year)';
            CaptionClass = '3,' + GetReportingDateYearCaption();
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key1; "Vendor Source No.")
        {
        }
    }

    local procedure GetReportingDateCaption(): Text
    begin
        OnOverrideAgedBy(Rec);
        case Rec."Aged By" of
            Rec."Aged By"::"Document Date":
                exit(FieldCaption("Document Date"));
            Rec."Aged By"::"Due Date":
                exit(FieldCaption("Due Date"));
            Rec."Aged By"::"Posting Date":
                exit(FieldCaption("Posting Date"));
        end;
    end;

    local procedure GetReportingDateMonthCaption(): Text
    begin
        exit(StrSubstNo(MonthLbl, GetReportingDateCaption()));
    end;

    local procedure GetReportingDateQuarterCaption(): Text
    begin
        exit(StrSubstNo(QuarterLbl, GetReportingDateCaption()));
    end;

    local procedure GetReportingDateYearCaption(): Text
    begin
        exit(StrSubstNo(YearLbl, GetReportingDateCaption()));
    end;

    internal procedure SetReportingDate()
    begin
        case Rec."Aged By" of
            Rec."Aged By"::"Due Date":
                Rec."Reporting Date" := Rec."Due Date";
            Rec."Aged By"::"Posting Date":
                Rec."Reporting Date" := Rec."Posting Date";
            Rec."Aged By"::"Document Date":
                Rec."Reporting Date" := Rec."Document Date";
        end;

        Rec."Reporting Date Month" := Date2DMY(Rec."Reporting Date", 2);
        Rec."Reporting Date Year" := Date2DMY(Rec."Reporting Date", 3);
        Rec."Reporting Date Quarter" := GetQuarterIndex(Rec."Reporting Date");
    end;

    local procedure GetQuarterIndex(Date: Date): Integer
    begin
        exit((Date2DMY(Date, 2) - 1) div 3 + 1);
    end;

    internal procedure SetPeriodStartAndEndDate(PeriodStarts: List of [Date]; PeriodEnds: List of [Date])
    begin
        case Rec."Aged By" of
            Rec."Aged By"::"Due Date":
                begin
                    Rec."Period Start Date" := FindPeriodStart(Rec."Due Date", PeriodStarts);
                    Rec."Period End Date" := FindPeriodEnd(Rec."Due Date", PeriodEnds);
                end;
            Rec."Aged By"::"Posting Date":
                begin
                    Rec."Period Start Date" := FindPeriodStart(Rec."Posting Date", PeriodStarts);
                    Rec."Period End Date" := FindPeriodEnd(Rec."Posting Date", PeriodEnds);
                end;
            Rec."Aged By"::"Document Date":
                begin
                    Rec."Period Start Date" := FindPeriodStart(Rec."Document Date", PeriodStarts);
                    Rec."Period End Date" := FindPeriodEnd(Rec."Document Date", PeriodEnds);
                end;
        end;
    end;

    local procedure FindPeriodStart(WhatDate: Date; PeriodStarts: List of [Date]): Date
    var
        PossibleDate: Date;
    begin
        foreach PossibleDate in PeriodStarts do
            if WhatDate >= PossibleDate then
                exit(PossibleDate);

        exit(PossibleDate);
    end;

    local procedure FindPeriodEnd(WhatDate: Date; PeriodEnds: List of [Date]): Date
    var
        PossibleDate: Date;
    begin
        foreach PossibleDate in PeriodEnds do
            if WhatDate < PossibleDate then
                exit(PossibleDate);

        exit(PossibleDate);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnOverrideAgedBy(var EXRAgingReportBuffer: Record "EXR Aging Report Buffer")
    begin
    end;

    var
        MonthLbl: Label '%1 (Month)', Comment = '%1 is Document Date, Due Date or Posting Date';
        QuarterLbl: Label '%1 (Quarter)', Comment = '%1 is Document Date, Due Date or Posting Date';
        YearLbl: Label '%1 (Year)', Comment = '%1 is Document Date, Due Date or Posting Date';
}
