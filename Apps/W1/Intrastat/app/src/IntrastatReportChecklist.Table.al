// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using System.Reflection;

table 4813 "Intrastat Report Checklist"
{
    DataClassification = CustomerContent;
    Caption = 'Intrastat Report Checklist';
    DataCaptionFields = "Field No.", "Field Name";
    LookupPageID = "Intrastat Report Checklist";
    DrillDownPageID = "Intrastat Report Checklist";

    fields
    {
        field(1; "Field No."; Integer)
        {
            Caption = 'Field No.';
            NotBlank = true;
            TableRelation = Field."No." where(TableNo = const(4812), "No." = filter(<> 1 & <> 2 & < 2000000000), Class = const(Normal), ObsoleteState = const(No)); // Intrastat Report Line table fields excluding key and system fields
        }
        field(2; "Field Name"; Text[250])
        {
            Caption = 'Field Name';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Lookup(Field."Field Caption" where(TableNo = const(4812), "No." = field("Field No.")));   // lookup Intrastat Report Line table
        }
        field(3; "Filter Expression"; Text[1024])
        {
            Caption = 'Filter Expression';
            trigger OnValidate()
            var
                IntrastatReportLine: Record "Intrastat Report Line";
            begin
                if "Filter Expression" <> '' then begin
                    IntrastatReportLine.SetView(ConvertFilterStringToView("Filter Expression"));
                    "Record View String" := CopyStr(IntrastatReportLine.GetView(false), 1, MaxStrLen("Record View String"));
                    "Filter Expression" := CopyStr(IntrastatReportLine.GetFilters(), 1, MaxStrLen("Filter Expression"));
                end else
                    "Record View String" := '';
            end;

            trigger OnLookup()
            begin
                LookupFilterExpression();
            end;
        }
        field(4; "Record View String"; Text[1024])
        {
            Caption = 'Record View String';
            Editable = false;
        }
        field(5; "Reversed Filter Expression"; Boolean)
        {
            Caption = 'Reversed Filter Expression';
        }
        field(6; "Must Be Blank For Filter Expr."; Text[1024])
        {
            Caption = 'Field Must Be Blank For Filter Expression';
            trigger OnValidate()
            var
                IntrastatReportLine: Record "Intrastat Report Line";
            begin
                if "Must Be Blank For Filter Expr." <> '' then begin
                    IntrastatReportLine.SetView(ConvertFilterStringToView("Must Be Blank For Filter Expr."));
                    "Must Be Blank Rec. View String" := CopyStr(IntrastatReportLine.GetView(false), 1, MaxStrLen("Must Be Blank Rec. View String"));
                    "Must Be Blank For Filter Expr." := CopyStr(IntrastatReportLine.GetFilters(), 1, MaxStrLen("Must Be Blank For Filter Expr."));
                end else
                    "Must Be Blank Rec. View String" := '';
            end;

            trigger OnLookup()
            begin
                LookupFilterExpressionForBlank();
            end;
        }
        field(7; "Must Be Blank Rec. View String"; Text[1024])
        {
            Caption = 'Field Must Be Blank Record View String';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Field No.")
        {
            Clustered = true;
        }
    }

    var
        FilterStringParseErr: Label 'Could not parse the filter expression. Use the lookup action, or type a string in the following format: "Type: Shipment, Quantity: <>0".';
        FilterTxt: Label '%1=FILTER(%2)', Locked = true;
        WhereTxt: Label '%1 WHERE(%2)', Locked = true;

    procedure AssistEditFieldName()
    var
        Field: Record Field;
        FieldSelection: Codeunit "Field Selection";
    begin
        Field.SetRange(TableNo, Database::"Intrastat Report Line");
        Field.SetRange(IsPartOfPrimaryKey, false);
        Field.SetFilter("No.", '<%1', Field.FieldNo(SystemId));
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetRange(ObsoleteState, Field.ObsoleteState::No);
        if FieldSelection.Open(Field) then
            Validate("Field No.", Field."No.");
    end;

    local procedure LookupFilterExpression()
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        FilterPageBuilder: FilterPageBuilder;
        TableCaptionValue: Text;
    begin
        TableCaptionValue := IntrastatReportLine.TableCaption();
        FilterPageBuilder.AddTable(TableCaptionValue, Database::"Intrastat Report Line");
        if "Record View String" <> '' then
            FilterPageBuilder.SetView(TableCaptionValue, "Record View String");
        if FilterPageBuilder.RunModal() then begin
            IntrastatReportLine.SetView(FilterPageBuilder.GetView(TableCaptionValue, false));
            "Record View String" := CopyStr(IntrastatReportLine.GetView(false), 1, MaxStrLen("Record View String"));
            "Filter Expression" := CopyStr(IntrastatReportLine.GetFilters(), 1, MaxStrLen("Filter Expression"));
        end;
    end;

    local procedure LookupFilterExpressionForBlank()
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        FilterPageBuilder: FilterPageBuilder;
        TableCaptionValue: Text;
    begin
        TableCaptionValue := IntrastatReportLine.TableCaption();
        FilterPageBuilder.AddTable(TableCaptionValue, Database::"Intrastat Report Line");
        if "Must Be Blank Rec. View String" <> '' then
            FilterPageBuilder.SetView(TableCaptionValue, "Must Be Blank Rec. View String");
        if FilterPageBuilder.RunModal() then begin
            IntrastatReportLine.SetView(FilterPageBuilder.GetView(TableCaptionValue, false));
            "Must Be Blank Rec. View String" := CopyStr(IntrastatReportLine.GetView(false), 1, MaxStrLen("Must Be Blank Rec. View String"));
            "Must Be Blank For Filter Expr." := CopyStr(IntrastatReportLine.GetFilters(), 1, MaxStrLen("Must Be Blank For Filter Expr."));
        end;
    end;

    local procedure ConvertFilterStringToView(FilterString: Text): Text
    var
        IntrastatReportLine: Record "Intrastat Report Line";
        ConvertedFilterString: Text;
        MidPos: Integer;
        FinishPos: Integer;
    begin
        while FilterString <> '' do begin
            // Convert "Type: Receipt" to "Type=FILTER(Receipt)"
            MidPos := StrPos(FilterString, ':');
            if MidPos < 2 then
                Error(FilterStringParseErr);
            FinishPos := StrPos(FilterString, ',');
            if FinishPos = 0 then
                FinishPos := StrLen(FilterString) + 1;
            if ConvertedFilterString <> '' then
                ConvertedFilterString += ',';
            ConvertedFilterString +=
              StrSubstNo(FilterTxt, CopyStr(FilterString, 1, MidPos - 1), CopyStr(FilterString, MidPos + 1, FinishPos - MidPos - 1));
            FilterString := DelStr(FilterString, 1, FinishPos);
        end;

        if ConvertedFilterString <> '' then
            exit(StrSubstNo(WhereTxt, IntrastatReportLine.GetView(), ConvertedFilterString));

        exit('');
    end;

    procedure LinePassesFilterExpression(IntrastatReportLine: Record "Intrastat Report Line"): Boolean
    var
        TempIntrastatReportLine: Record "Intrastat Report Line" temporary;
    begin
        if "Record View String" = '' then
            exit("Must Be Blank Rec. View String" = '');

        TempIntrastatReportLine := IntrastatReportLine;
        TempIntrastatReportLine.Insert();
        TempIntrastatReportLine.SetView("Record View String");
        exit(not TempIntrastatReportLine.IsEmpty() xor "Reversed Filter Expression");
    end;

    internal procedure LinePassesFilterExpressionForMustBeBlank(IntrastatReportLine: Record "Intrastat Report Line"): Boolean
    var
        TempIntrastatReportLine: Record "Intrastat Report Line" temporary;
    begin
        if "Must Be Blank Rec. View String" = '' then
            exit(false);

        TempIntrastatReportLine := IntrastatReportLine;
        TempIntrastatReportLine.Insert();
        TempIntrastatReportLine.SetView("Must Be Blank Rec. View String");
        exit(not TempIntrastatReportLine.IsEmpty());
    end;
}