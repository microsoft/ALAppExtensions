// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine.TaxTypeHandler;

using Microsoft.Finance.TaxEngine.Core;

codeunit 20241 "Tax Rate Filter Mgmt."
{
    var
        TempTaxRateFilter: Record "Tax Rate Filter" temporary;
        ColumnCounts: Dictionary of [Integer, Integer];

    procedure OpenTaxRateFilter(var TaxRate: Record "Tax Rate")
    var
        TaxRateFilter: Record "Tax Rate Filter";
    begin
        TaxRateFilter.SetRange("Tax Type", TaxRate."Tax Type");
        if TaxRateFilter.IsEmpty() then
            UpdateTaxRateFilters(TaxRate."Tax Type");

        OpenFilterPage(TaxRate);
    end;

    procedure ClearTaxRateFilter(var TaxRate: Record "Tax Rate")
    begin
        ClearCache(TaxRate);
    end;

    procedure UpdateTaxRateFilters(TaxTypeCode: Code[20])
    var
        TaxRateFilter: Record "Tax Rate Filter";
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        id: Integer;
    begin
        TaxRateColumnSetup.SetCurrentKey(Sequence);
        TaxRateColumnSetup.SetRange("Tax Type", TaxTypeCode);
        if TaxRateColumnSetup.FindSet() then
            repeat
                id += 1;
                TaxRateFilter.Init();
                TaxRateFilter.ID := id;
                TaxRateFilter."Tax Type" := TaxTypeCode;
                TaxRateFilter."Column ID" := TaxRateColumnSetup."Column ID";
                TaxRateFilter."Column Name" := TaxRateColumnSetup."Column Name";
                TaxRateFilter."Column Type" := TaxRateColumnSetup."Column Type";
                TaxRateFilter."Attribute ID" := TaxRateColumnSetup."Attribute ID";
                TaxRateFilter."Linked Attribute ID" := TaxRateColumnSetup."Linked Attribute ID";
                TaxRateFilter.Type := TaxRateColumnSetup.Type;
                TaxRateFilter.Insert();

                case TaxRateColumnSetup."Column Type" of
                    TaxRateColumnSetup."Column Type"::Component:
                        begin
                            TaxRateFilter."Column Name" := TaxRateColumnSetup."Column Name" + ' ' + '%';
                            TaxRateFilter.Modify();
                        end;
                    TaxRateColumnSetup."Column Type"::"Range From and Range To":
                        begin
                            TaxRateFilter."Column Name" := TaxRateColumnSetup."Column Name" + ' From';
                            TaxRateFilter.Modify();

                            TaxRateFilter.Init();
                            id += 1;
                            TaxRateFilter.ID := id;
                            TaxRateFilter."Tax Type" := TaxTypeCode;
                            TaxRateFilter."Column ID" := TaxRateColumnSetup."Column ID";
                            TaxRateFilter."Column Name" := TaxRateColumnSetup."Column Name" + ' To';
                            TaxRateFilter."Column Type" := TaxRateColumnSetup."Column Type";
                            TaxRateFilter.Type := TaxRateColumnSetup.Type;
                            TaxRateFilter."Attribute ID" := TaxRateColumnSetup."Attribute ID";
                            TaxRateFilter."Linked Attribute ID" := TaxRateColumnSetup."Linked Attribute ID";
                            TaxRateFilter."Is Range Column" := true;
                            TaxRateFilter.Insert();
                        end;
                end;
            until TaxRateColumnSetup.Next() = 0;
    end;

    local procedure OpenFilterPage(var TaxRate: Record "Tax Rate")
    var
        TaxRateFilters: Page "Tax Rate Filters";
        FilterApplied: Boolean;
    begin
        TempTaxRateFilter.Reset();
        if TempTaxRateFilter.IsEmpty() then
            UpdateTempTaxRateFilter(TaxRate."Tax Type");

        TaxRateFilters.UpateCache(TempTaxRateFilter);
        Commit();
        if TaxRateFilters.RunModal() = Action::OK then begin
            TaxRateFilters.GetFilterDimension(TempTaxRateFilter);

            TaxRate.ClearMarks();
            FilterTaxRates(TempTaxRateFilter, TaxRate, FilterApplied);
            if FilterApplied then
                TaxRate.MarkedOnly(true);
        end;

        if TaxRate.FindSet() then;
    end;

    local procedure UpdateTempTaxRateFilter(TaxTypeCode: Code[20])
    var
        TaxRateFilter: Record "Tax Rate Filter";
    begin
        TaxRateFilter.SetRange("Tax Type", TaxTypeCode);
        if TaxRateFilter.FindSet() then
            repeat
                TempTaxRateFilter.Init();
                TempTaxRateFilter := TaxRateFilter;
                TempTaxRateFilter.Insert();
            until TaxRateFilter.Next() = 0;
    end;

    local procedure FilterTaxRates(
        var TaxRateFilter: Record "Tax Rate Filter" temporary;
        var TaxRate: Record "Tax Rate";
        var FilterApplied: Boolean)
    begin
        TaxRateFilter.SetFilter(Value, '<>%1', '');
        if TaxRateFilter.FindSet() then begin
            FilterApplied := true;
            repeat
                UpdateCountByColumnType(TaxRateFilter);
            until TaxRateFilter.Next() = 0;
        end;

        if FilterApplied then
            MarkRecordsForStats(TempTaxRateFilter, TaxRate);
    end;

    local procedure MarkRecordsForStats(
        var TaxRateFilter: Record "Tax Rate Filter" temporary;
        var TaxRate: Record "Tax Rate")
    var
        ConfigIDList: List of [Guid];
    begin
        ConfigIDList := GetConfigIDList(TaxRateFilter);
        MarkTaxRate(TaxRate, TaxRateFilter."Tax Type", ConfigIDList);
    end;

    local procedure FilterTaxRateFilter(var TaxRateFilter: Record "Tax Rate Filter" temporary; ColumnID: Integer)
    begin
        TaxRateFilter.Reset();
        TaxRateFilter.SetRange("Column ID", ColumnID);
        TaxRateFilter.FindFirst();
    end;

    local procedure GetConfigIDList(var TaxRateFilter: Record "Tax Rate Filter" temporary): List of [Guid]
    var
        ColumnID: Integer;
        RecordCount: Integer;
        ConfigIDList: List of [Guid];
    begin
        while (ColumnCounts.Count) > 0 do begin
            ColumnID := GetSmallestColumnID();
            RecordCount := ColumnCounts.Get(ColumnID);
            ColumnCounts.Remove(ColumnID);

            if RecordCount = 0 then
                break;

            FilterTaxRateFilter(TaxRateFilter, ColumnID);
            ConfigIDList := UpdateConfigIDList(TaxRateFilter, ConfigIDList);

            if ConfigIDList.Count = 0 then
                break;
        end;

        exit(ConfigIDList);
    end;

    local procedure CreateFilteredString(ConfigID: List of [Guid]): Text
    var
        i: Integer;
        FilterTxt: Text;
    begin
        for i := 1 to ConfigID.Count do begin
            if FilterTxt <> '' then
                FilterTxt += '|';
            FilterTxt += Format(ConfigID.Get(i));
        end;

        exit(FilterTxt);
    end;

    local procedure UpdateConfigIDList(TaxRateFilter: Record "Tax Rate Filter" temporary; ConfigIDList: List of [Guid]): List of [Guid]
    var
        TaxRateValue: Record "Tax Rate Value";
        CurrentConfigIDList: List of [Guid];
        ConfigIDList2: List of [Guid];
        ConfigIDCount: Integer;
        IsConfigEmpty: Boolean;
        FilterTxt: Text;
    begin
        ApplyFilterByColumnType(TaxRateFilter, TaxRateValue);
        IsConfigEmpty := ConfigIDList.Count = 0;

        repeat
            if (not IsConfigEmpty) then begin
                ConfigIDCount := ConfigIDList.Count;
                if ConfigIDCount > 500 then
                    ConfigIDCount := 500;

                ConfigIDList2 := ConfigIDList.GetRange(1, ConfigIDCount);
                ConfigIDList.RemoveRange(1, ConfigIDCount);
                FilterTxt := CreateFilteredString(ConfigIDList2);
                TaxRateValue.SetFilter("Config ID", FilterTxt);
            end;

            if TaxRateValue.FindSet() then
                repeat
                    if IsConfigEmpty or (ConfigIDList2.Contains(TaxRateValue."Config ID")) then
                        CurrentConfigIDList.Add(TaxRateValue."Config ID");
                until TaxRateValue.Next() = 0;

        until (ConfigIDList.Count = 0);

        exit(CurrentConfigIDList);
    end;

    local procedure UpdateCountByColumnType(TaxRateFilter: Record "Tax Rate Filter")
    var
        TaxRateValue: Record "Tax Rate Value";
    begin
        ApplyFilterByColumnType(TaxRateFilter, TaxRateValue);
        ColumnCounts.Add(TaxRateFilter."Column ID", TaxRateValue.Count);
    end;

    local procedure ApplyFilterByColumnType(
        TaxRateFilter: Record "Tax Rate Filter";
        var TaxRateValue: Record "Tax Rate Value")
    var
        TaxAttribute: Record "Tax Attribute";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        RHSvalue: Variant;
        OptionText: Text;
    begin
        TaxRateValue.SetRange("Tax Type", TaxRateFilter."Tax Type");
        TaxRateValue.SetRange("Column ID", TaxRateFilter."Column ID");

        if TaxRateFilter.Type = TaxRateFilter.Type::Option then
            if TaxRateFilter."Attribute ID" <> 0 then
                TaxAttribute.Get(TaxRateFilter."Tax Type", TaxRateFilter."Attribute ID")
            else
                TaxAttribute.Get(TaxRateFilter."Tax Type", TaxRateFilter."Linked Attribute ID");

        OptionText := TaxAttribute.GetValues();

        if TaxRateFilter.Value.Contains('..') or TaxRateFilter.Value.Contains('|') then
            RHSvalue := TaxRateFilter.Value
        else
            case TaxRateFilter.Type of
                TaxRateFilter.Type::Date:
                    begin
                        TaxRateFilter.Value := ScriptDataTypeMgmt.ConvertLocalToXmlFormat(TaxRateFilter.Value, "Symbol Data Type"::Date);
                        ScriptDataTypeMgmt.ConvertText2Type(TaxRateFilter.Value, "Symbol Data Type"::Date, OptionText, RHSvalue);
                    end;
                TaxRateFilter.Type::Decimal, TaxRateFilter.Type::Integer:
                    begin
                        TaxRateFilter.Value := ScriptDataTypeMgmt.ConvertLocalToXmlFormat(TaxRateFilter.Value, "Symbol Data Type"::Number);
                        ScriptDataTypeMgmt.ConvertText2Type(TaxRateFilter.Value, "Symbol Data Type"::Number, OptionText, RHSvalue);
                    end;
                TaxRateFilter.Type::Boolean:
                    ScriptDataTypeMgmt.ConvertText2Type(TaxRateFilter.Value, "Symbol Data Type"::Boolean, OptionText, RHSvalue);
                TaxRateFilter.Type::Option:
                    begin
                        TaxRateFilter.Value := ScriptDataTypeMgmt.ConvertLocalToXmlFormat(TaxRateFilter.Value, "Symbol Data Type"::Option);
                        ScriptDataTypeMgmt.ConvertText2Type(TaxRateFilter.Value, "Symbol Data Type"::Option, OptionText, RHSvalue);
                    end;
                else
                    ScriptDataTypeMgmt.ConvertText2Type(TaxRateFilter.Value, "Symbol Data Type"::String, OptionText, RHSvalue);
            end;

        ApplyFieldFilter(TaxRateValue, TaxRateFilter, TaxRateFilter."Conditional Operator", RHSvalue);
    end;

    local procedure ApplyFieldFilter(
        var TaxRateValue: Record "Tax Rate Value";
        TaxRateFilter: Record "Tax Rate Filter";
    FilterType: Enum "Conditional Operator";
        Value: Variant)
    begin
        if Format(Value).Contains('..') or Format(Value).Contains('|') then
            ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '', Value)
        else
            case FilterType of
                FilterType::"CAL Filter":
                    ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '', Value);
                FilterType::Equals:
                    ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '%1', Value);
                FilterType::"Not Equals":
                    ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '<>%1', Value);
                FilterType::"Is Less Than":
                    ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '<%1', Value);
                FilterType::"Is Less Than Or Equals To":
                    ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '<=%1', Value);
                FilterType::"Is Greater Than":
                    ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '>%1', Value);
                FilterType::"Is Greater Than Or Equals To":
                    ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '>=%1', Value);
                FilterType::"Begins With":
                    ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '%1*', Value);
                FilterType::"Ends With":
                    ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '*%1', Value);
                FilterType::Contains:
                    ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '*%1*', Value);
                FilterType::"Does Not Contain":
                    ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '<>*%1*', Value);
                FilterType::"Does Not End With":
                    ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '<>*%1', Value);
                FilterType::"Contains Ignore Case":
                    ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '@*%1', Value);
                FilterType::"Equals Ignore Case":
                    ApplyFilterWithOperator(TaxRateValue, TaxRateFilter, '@%1', Value);
            end;
    end;

    local procedure ApplyFilterWithOperator(
        var TaxRateValue: Record "Tax Rate Value";
        TaxRateFilter: Record "Tax Rate Filter";
        Operator: Text;
        Value: Variant)
    begin
        case TaxRateFilter."Column Type" of
            TaxRateFilter."Column Type"::"Range From and Range To",
                  TaxRateFilter."Column Type"::"Range From",
                  TaxRateFilter."Column Type"::"Range To":
                case TaxRateFilter.Type of
                    TaxRateFilter.Type::Date:
                        if TaxRateFilter."Is Range Column" then begin
                            if Operator <> '' then
                                TaxRateValue.SetFilter("Date Value To", Operator, Value)
                            else
                                TaxRateValue.SetFilter("Date Value To", Value);
                        end else
                            if Operator <> '' then
                                TaxRateValue.SetFilter("Date Value", Operator, Value)
                            else
                                TaxRateValue.SetFilter("Date Value", Value);
                    TaxRateFilter.Type::Decimal, TaxRateFilter.Type::Integer:
                        if TaxRateFilter."Is Range Column" then begin
                            if Operator <> '' then
                                TaxRateValue.SetFilter("Decimal Value To", Operator, Value)
                            else
                                TaxRateValue.SetFilter("Decimal Value To", Value);
                        end else
                            if Operator <> '' then
                                TaxRateValue.SetFilter("Decimal Value", Operator, Value)
                            else
                                TaxRateValue.SetFilter("Decimal Value", Value);
                    else
                        if TaxRateFilter."Is Range Column" then begin
                            if Operator <> '' then
                                TaxRateValue.SetFilter("Value To", Operator, Value)
                            else
                                TaxRateValue.SetFilter("Value To", Value);
                        end else
                            if Operator <> '' then
                                TaxRateValue.SetFilter(Value, Operator, Value)
                            else
                                TaxRateValue.SetFilter(Value, Value);
                end;
            else
                if Operator <> '' then
                    TaxRateValue.SetFilter(Value, Operator, Value)
                else
                    TaxRateValue.SetFilter(Value, Value);
        end;
    end;

    local procedure MarkTaxRate(
        var TaxRate: Record "Tax Rate";
        TaxTypeCode: Code[20];
        ConfigIDList: List of [Guid])
    var
        i: Integer;
    begin
        for i := 1 to ConfigIDList.Count do begin
            TaxRate.Get(TaxTypeCode, ConfigIDList.Get(i));
            if not TaxRate.Mark() then
                TaxRate.Mark(true);
        end;
    end;

    local procedure ClearCache(var TaxRate: Record "Tax Rate")
    begin
        Clear(ColumnCounts);

        TaxRate.ClearMarks();
        TaxRate.MarkedOnly(false);

        TempTaxRateFilter.Reset();
        TempTaxRateFilter.DeleteAll();

        if TaxRate.FindSet() then;
    end;

    local procedure GetSmallestColumnID(): Integer
    var
        SmallestColumnID: Integer;
        SmallestValue: Integer;
        ColumnID: Integer;
        Value: Integer;
        IsFirstIteration: Boolean;
    begin
        SmallestColumnID := 0;
        SmallestValue := 0;

        foreach ColumnID in ColumnCounts.Keys() do begin
            Value := ColumnCounts.Get(ColumnID);
            if (Value < SmallestValue) or (not IsFirstIteration) then begin
                SmallestValue := Value;
                SmallestColumnID := ColumnID;
                IsFirstIteration := true;
            end;
        end;

        exit(SmallestColumnID);
    end;
}
