// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

tableextension 148121 "Intrastat Report Header IT" extends "Intrastat Report Header"
{
    fields
    {
        modify("Statistics Period")
        {
            trigger OnBeforeValidate()
            var
                Quarter: Integer;
            begin
                if Periodicity = Periodicity::Quarter then begin
                    TestField(Reported, false);
                    if StrLen("Statistics Period") <> 4 then
                        Error(
                          StatistiscPeriodFormatErr,
                          FieldCaption("Statistics Period"));
                    Evaluate(Quarter, CopyStr("Statistics Period", 4, 1));
                    if (Quarter < 1) or (Quarter > 4) then
                        Error(QuarterNrErr);
                end;
            end;
        }
        field(148121; "Corrected Intrastat Rep. No."; Code[20])
        {
            Caption = 'Corrected Intrastat Report No.';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                IntrastatReportHeader2: Record "Intrastat Report Header";
            begin
                SetIntrastatReportFilter(IntrastatReportHeader2);
                if Page.RunModal(0, IntrastatReportHeader2) = Action::LookupOK then
                    "Corrected Intrastat Rep. No." := IntrastatReportHeader2."No.";
            end;

            trigger OnValidate()
            var
                IntrastatReportHeader2: Record "Intrastat Report Header";
            begin
                SetIntrastatReportFilter(IntrastatReportHeader2);
                IntrastatReportHeader2.SetRange("No.", "Corrected Intrastat Rep. No.");
                if IntrastatReportHeader2.IsEmpty() then
                    Error(NoValueWithinTheFilterErr, "Corrected Intrastat Rep. No.", IntrastatReportHeader2.GetFilters());
            end;
        }
        field(148122; "Include Community Entries"; Boolean)
        {
            Caption = 'Include Intra-Community Entries';
            DataClassification = CustomerContent;
        }
    }
    internal procedure SetIntrastatReportFilter(var IntrastatReportHeader2: Record "Intrastat Report Header")
    begin
        IntrastatReportHeader2.SetRange(Reported, true);
        IntrastatReportHeader2.SetRange("EU Service", Rec."EU Service");
        IntrastatReportHeader2.SetRange("Corrective Entry", false);
        IntrastatReportHeader2.SetRange(Type, Rec.Type);
        IntrastatReportHeader2.SetRange(Periodicity, Rec.Periodicity);
    end;

    var
        NoValueWithinTheFilterErr: Label 'There is no %1 with in the filter.\\Filters: %2', Comment = '%1 - Corrected Intrastat Report No., %2 - Filters';
        StatistiscPeriodFormatErr: Label '%1 must be 4 characters, for example, 9402 for the second quarter, 1994.', Comment = '%1 - Statistics Period';
        QuarterNrErr: Label 'Please check the quarter number.';
}