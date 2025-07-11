// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10041 "IRS 1099 Form Statement Line"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Period No."; Code[20])
        {
            TableRelation = "IRS Reporting Period";
        }
        field(2; "Form No."; Code[20])
        {
            TableRelation = "IRS 1099 Form"."No." where("Period No." = field("Period No."));
        }
        field(3; "Line No."; Integer)
        {
        }
        field(5; "Row No."; Code[20])
        {
        }
        field(6; Description; Text[100])
        {
        }
        field(7; "Print Value Type"; Enum "IRS 1099 Print Value Type")
        {
        }
        field(10; "Filter Expression"; Text[1024])
        {
            trigger OnValidate()
            var
                IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
            begin
                if "Filter Expression" <> '' then begin
                    IRS1099FormDocLine.SetView(ConvertFilterStringToView("Filter Expression"));
                    "Record View String" := CopyStr(IRS1099FormDocLine.GetView(false), 1, MaxStrLen("Record View String"));
                    "Filter Expression" := CopyStr(IRS1099FormDocLine.GetFilters(), 1, MaxStrLen("Filter Expression"));
                end else
                    "Record View String" := '';
            end;

            trigger OnLookup()
            begin
                LookupFilterExpression();
            end;
        }
        field(11; "Record View String"; Text[1024])
        {
            Editable = false;
        }
        field(20; "Row Totaling"; Text[250])
        {
        }
        field(21; "Print with"; Option)
        {
            Caption = 'Print with';
            OptionCaption = 'Sign,Opposite Sign';
            OptionMembers = Sign,"Opposite Sign";
        }
    }

    keys
    {
        key(PK; "Period No.", "Form No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        FilterStringParseErr: Label 'Could not parse the filter expression. Use the lookup action, or type a string in the following format: "Type: Shipment, Quantity: <>0".';
        FilterTxt: Label '%1=FILTER(%2)', Locked = true;
        WhereTxt: Label '%1 WHERE(%2)', Locked = true;

    local procedure LookupFilterExpression()
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        FilterPageBuilder: FilterPageBuilder;
        TableCaptionValue: Text;
    begin
        TableCaptionValue := IRS1099FormDocLine.TableCaption();
        FilterPageBuilder.AddTable(TableCaptionValue, Database::"IRS 1099 Form Doc. Line");
        if "Record View String" <> '' then
            FilterPageBuilder.SetView(TableCaptionValue, "Record View String");
        if FilterPageBuilder.RunModal() then begin
            IRS1099FormDocLine.SetView(FilterPageBuilder.GetView(TableCaptionValue, false));
            "Record View String" := CopyStr(IRS1099FormDocLine.GetView(false), 1, MaxStrLen("Record View String"));
            "Filter Expression" := CopyStr(IRS1099FormDocLine.GetFilters(), 1, MaxStrLen("Filter Expression"));
        end;
    end;

    local procedure ConvertFilterStringToView(FilterString: Text): Text
    var
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
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
            exit(StrSubstNo(WhereTxt, IRS1099FormDocLine.GetView(), ConvertedFilterString));

        exit('');
    end;
}
