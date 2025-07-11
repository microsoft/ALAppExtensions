// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.Inventory.Intrastat;

tableextension 12215 "Service Decl. Header IT" extends "Service Declaration Header"
{
    fields
    {
        field(12214; Type; Enum "Serv. Decl. Report Type IT")
        {
            Caption = 'Type';
        }
        field(12215; Periodicity; Enum "Serv. Decl. Periodicity IT")
        {
            Caption = 'Periodicity';

            trigger OnValidate()
            begin
                Validate("Statistics Period");
            end;
        }
        field(12216; "Statistics Period"; Code[10])
        {
            Caption = 'Statistics Period';

            trigger OnValidate()
            var
                Quarter, Month : Integer;
            begin
                TestField(Reported, false);
                if StrLen("Statistics Period") <> 4 then
                    Error(StatistiscPeriodFormatErr, FieldCaption("Statistics Period"));

                if Periodicity = Periodicity::Quarter then begin
                    Evaluate(Quarter, CopyStr("Statistics Period", 4, 1));
                    if (Quarter < 1) or (Quarter > 4) then
                        Error(QuarterNrErr);
                end else begin
                    Evaluate(Month, CopyStr("Statistics Period", 3, 2));
                    if (Month < 1) or (Month > 12) then
                        Error(MonthNrErr);
                end;
                UpdateDates();
            end;
        }
        field(12217; "File Disk No."; Code[20])
        {
            Caption = 'File Disk No.';
            Numeric = true;

            trigger OnValidate()
            var
                ServiceDeclarationHeader: Record "Service Declaration Header";
            begin
                if xRec."File Disk No." <> "File Disk No." then begin
                    TestField("File Disk No.");
                    if "File Disk No." <> '' then begin
                        ServiceDeclarationHeader.SetRange("File Disk No.", "File Disk No.");
                        if not ServiceDeclarationHeader.IsEmpty() then
                            FieldError("File Disk No.");
                    end;
                end;
            end;
        }
        field(12218; "Corrective Entry"; Boolean)
        {
            Caption = 'Corrective Entry';

            trigger OnValidate()
            begin
                TestField(Reported, false);
                if ("Corrective Entry" <> xRec."Corrective Entry") then
                    ErrorIfServDeclLineExist(FieldCaption("Corrective Entry"));
            end;
        }
        field(12219; "Customs Office No."; Code[10])
        {
            Caption = 'Customs Office No.';
            TableRelation = "Customs Office";
        }
        field(12220; "Corrected Serv. Decl. No."; Code[20])
        {
            Caption = 'Corrected Service Declaration No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                ServiceDeclarationHeader2: Record "Service Declaration Header";
            begin
                SetServDeclFilter(ServiceDeclarationHeader2);
                if Page.RunModal(0, ServiceDeclarationHeader2) = Action::LookupOK then
                    "Corrected Serv. Decl. No." := ServiceDeclarationHeader2."No.";
            end;

            trigger OnValidate()
            var
                ServiceDeclarationHeader2: Record "Service Declaration Header";
            begin
                SetServDeclFilter(ServiceDeclarationHeader2);
                ServiceDeclarationHeader2.SetRange("No.", "Corrected Serv. Decl. No.");
                if ServiceDeclarationHeader2.IsEmpty() then
                    Error(NoValueWithinTheFilterErr, "Corrected Serv. Decl. No.", ServiceDeclarationHeader2.GetFilters());
            end;
        }
    }

    var
        StatistiscPeriodFormatErr: Label '%1 must be 4 characters, for example, 9410 for October, 1994, or 9402 for the second quarter, 1994.', Comment = '%1 - Statistics Period';
        MonthNrErr: Label 'Please check the month number.';
        QuarterNrErr: Label 'Please check the quarter number.';
        LinesExistErr: Label 'You cannot change %1 when Service Declaration Lines for report %2 exists.', Comment = '%1 - Changed Field Name, %2 - Service Declaration No.';
        NoValueWithinTheFilterErr: Label 'There is no %1 with in the filter.\\Filters: %2', Comment = '%1 - Corrected Service Declaration No., %2 - Filters';

    local procedure ErrorIfServDeclLineExist(ChangedFieldName: Text)
    begin
        if ServDeclLinesExist() then
            Error(LinesExistErr, ChangedFieldName, "No.");
    end;

    local procedure ServDeclLinesExist(): Boolean
    var
        ServiceDeclarationLine: Record "Service Declaration Line";
    begin
        ServiceDeclarationLine.Reset();
        ServiceDeclarationLine.SetRange("Service Declaration No.", "No.");
        exit(not ServiceDeclarationLine.IsEmpty())
    end;

    local procedure SetServDeclFilter(var ServiceDeclarationHeader2: Record "Service Declaration Header")
    begin
        ServiceDeclarationHeader2.SetRange(Reported, true);
        ServiceDeclarationHeader2.SetRange("Corrective Entry", false);
        ServiceDeclarationHeader2.SetRange(Type, Rec.Type);
        ServiceDeclarationHeader2.SetRange(Periodicity, Rec.Periodicity);
    end;

    local procedure UpdateDates();
    var
        Century, Year, Quarter, Month : Integer;
    begin
        TestField("Statistics Period");
        Century := Date2DMY(WorkDate(), 3) div 100;
        Evaluate(Year, CopyStr("Statistics Period", 1, 2));
        Year := Year + Century * 100;

        if Periodicity = Periodicity::Month then begin
            Evaluate(Month, CopyStr("Statistics Period", 3, 2));
            "Starting Date" := DMY2Date(1, Month, Year);
        end else begin
            Evaluate(Quarter, CopyStr("Statistics Period", 4, 1));
            "Starting Date" := CalcDate(StrSubstNo('<+%1Q>', Quarter - 1), DMY2Date(1, 1, Year));
        end;

        case Periodicity of
            Periodicity::Month:
                "Ending Date" := CalcDate('<+1M-1D>', "Starting Date");
            Periodicity::Quarter:
                "Ending Date" := CalcDate('<+1Q-1D>', "Starting Date");
        end;
    end;
}
