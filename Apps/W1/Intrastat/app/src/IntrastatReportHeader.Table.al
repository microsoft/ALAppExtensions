// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Finance.Currency;
using Microsoft.Foundation.NoSeries;

table 4811 "Intrastat Report Header"
{
    DataClassification = CustomerContent;
    Caption = 'Intrastat Report Header';
    DataCaptionFields = "No.", Description;
    LookupPageID = "Intrastat Report List";
    DrillDownPageID = "Intrastat Report List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    IntrastatReportSetup.Get();
                    NoSeriesMgt.TestManual(IntrastatReportSetup."Intrastat Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Status; Enum "Intrastat Report Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(13; Reported; Boolean)
        {
            Caption = 'Reported';
            Editable = false;
        }
        field(14; "Statistics Period"; Code[10])
        {
            Caption = 'Statistics Period';

            trigger OnValidate()
            begin
                TestField(Reported, false);
                if StrLen("Statistics Period") <> 4 then
                    Error(
                      StatistiscPeriodFormatErr,
                      FieldCaption("Statistics Period"));
                Evaluate(Month, CopyStr("Statistics Period", 3, 2));
                if (Month < 1) or (Month > 12) then
                    Error(MonthNrErr);
            end;
        }
        field(15; "Amounts in Add. Currency"; Boolean)
        {
            AccessByPermission = TableData Currency = R;
            Caption = 'Amounts in Add. Currency';
        }
        field(16; "Currency Identifier"; Code[10])
        {
            AccessByPermission = TableData Currency = R;
            Caption = 'Currency Identifier';
        }
        field(17; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(18; "Arrivals Reported"; Boolean)
        {
            Caption = 'Arrivals Reported';
            Editable = false;

            trigger OnValidate()
            begin
                UpdateReported();
            end;
        }
        field(19; "Dispatches Reported"; Boolean)
        {
            Caption = 'Dispatches Reported';
            Editable = false;

            trigger OnValidate()
            begin
                UpdateReported();
            end;
        }
        field(20; Type; Enum "Intrastat Report Type")
        {
            Caption = 'Type';
        }
        field(21; Periodicity; Enum "Intrastat Report Periodicity")
        {
            Caption = 'Periodicity';

            trigger OnValidate()
            begin
                Validate("Statistics Period");
            end;
        }
        field(22; "File Disk No."; Code[20])
        {
            Caption = 'File Disk No.';
            Numeric = true;

            trigger OnValidate()
            var
                IntrastatReportHeader: Record "Intrastat Report Header";
            begin
                if xRec."File Disk No." <> "File Disk No." then begin
                    TestField("File Disk No.");
                    if "File Disk No." <> '' then begin
                        IntrastatReportHeader.SetRange("File Disk No.", "File Disk No.");
                        if not IntrastatReportHeader.IsEmpty() then
                            FieldError("File Disk No.");
                    end;
                end;
            end;
        }
        field(23; "Corrective Entry"; Boolean)
        {
            Caption = 'Corrective Entry';

            trigger OnValidate()
            begin
                TestField(Reported, false);
                if ("Corrective Entry" <> xRec."Corrective Entry") then
                    ErrorIfIntrastatReportLineExist(FieldCaption("Corrective Entry"));
            end;
        }
        field(24; "EU Service"; Boolean)
        {
            Caption = 'EU Service';

            trigger OnValidate()
            begin
                TestField(Reported, false);
                if "EU Service" and (Periodicity = Periodicity::Year) then
                    FieldError(Periodicity);
                if ("EU Service" <> xRec."EU Service") then
                    ErrorIfIntrastatReportLineExist(FieldCaption("EU Service"));
            end;
        }
        field(25; "Export Date"; Date)
        {
            Caption = 'Export Date';
            Editable = false;
        }
        field(26; "Export Time"; Time)
        {
            Caption = 'Export Time';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        CheckStatusOpen();
        IntrastatReportLine.SetRange("Intrastat No.", "No.");
        IntrastatReportLine.DeleteAll();
    end;

    trigger OnInsert()
    begin
        IntrastatReportSetup.Get();
        InitIntrastatNo();

        LockTable();
    end;

    trigger OnModify()
    begin
        CheckStatusOpen();
    end;

    trigger OnRename()
    begin
        CheckStatusOpen();
        IntrastatReportLine.SetRange("Document No.", "No.");
        while IntrastatReportLine.FindFirst() do
            IntrastatReportLine.Rename("No.", IntrastatReportLine."Line No.");
    end;

    var
        IntrastatReportLine: Record "Intrastat Report Line";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Month: Integer;
        StatistiscPeriodFormatErr: Label '%1 must be 4 characters, for example, 9410 for October, 1994.', Comment = '%1 - Statistics Period';
        MonthNrErr: Label 'Please check the month number.';
        LinesExistErr: Label 'You cannot change %1 when Intrastat Report Lines for report %2 exists.', Comment = '%1 - Changed Field Name, %2 - Intrastat Report No.';

    procedure AssistEdit(xIntrastatReportHeader: Record "Intrastat Report Header") Result: Boolean
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAssistEdit(Rec, xIntrastatReportHeader, Result, IsHandled);
        if IsHandled then
            exit(Result);

        IntrastatReportHeader := Rec;
        IntrastatReportSetup.Get();
        IntrastatReportSetup.TestField("Intrastat Nos.");
        if NoSeriesMgt.SelectSeries(IntrastatReportSetup."Intrastat Nos.", xIntrastatReportHeader."No. Series", IntrastatReportHeader."No. Series") then begin
            NoSeriesMgt.SetSeries(IntrastatReportHeader."No.");
            Rec := IntrastatReportHeader;
            exit(true);
        end;
    end;

    procedure GetStatisticsStartDate(): Date
    var
        Century: Integer;
        Year: Integer;
    begin
        TestField("Statistics Period");
        Century := Date2DMY(WorkDate(), 3) div 100;
        Evaluate(Year, CopyStr("Statistics Period", 1, 2));
        Year := Year + Century * 100;
        Evaluate(Month, CopyStr("Statistics Period", 3, 2));
        exit(DMY2Date(1, Month, Year));
    end;

    local procedure InitIntrastatNo()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitIntrastatNo(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if "No." = '' then begin
            IntrastatReportSetup.TestField("Intrastat Nos.");
            NoSeriesMgt.InitSeries(IntrastatReportSetup."Intrastat Nos.", xRec."No. Series", 0D, "No.", "No. Series");
        end;
    end;

    procedure UpdateReported()
    begin
        Reported := "Arrivals Reported" and "Dispatches Reported";
    end;

    procedure ErrorIfIntrastatReportLineExist(ChangedFieldName: Text)
    begin
        if IntrastatReportLinesExist() then
            Error(
              LinesExistErr,
              ChangedFieldName, "No.");
    end;

    procedure IntrastatReportLinesExist(): Boolean
    var
        IntrastatReportLine2: Record "Intrastat Report Line";
    begin
        IntrastatReportLine2.Reset();
        IntrastatReportLine2.SetRange("Intrastat No.", "No.");
        exit(not IntrastatReportLine2.IsEmpty())
    end;

    procedure CheckEUServAndCorrection(IntrastatNo: Code[20]; CheckEUService: Boolean; CheckCorrective: Boolean)
    begin
        if Get(IntrastatNo) then begin
            if CheckEUService then
                TestField("EU Service");
            if CheckCorrective then
                TestField("Corrective Entry");
        end;
    end;

    procedure CheckStatusOpen()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckStatusOpen(xRec, Rec, IsHandled);
        if IsHandled then
            exit;

        TestField(Status, Status::Open);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckStatusOpen(xIntrastatReportHeader: Record "Intrastat Report Header"; IntrastatReportHeader: Record "Intrastat Report Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssistEdit(var IntrastatReportHeader: Record "Intrastat Report Header"; var xIntrastatReportHeader: Record "Intrastat Report Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitIntrastatNo(var IntrastatReportHeader: Record "Intrastat Report Header"; var xIntrastatReportHeader: Record "Intrastat Report Header"; var IsHandled: Boolean)
    begin
    end;
}