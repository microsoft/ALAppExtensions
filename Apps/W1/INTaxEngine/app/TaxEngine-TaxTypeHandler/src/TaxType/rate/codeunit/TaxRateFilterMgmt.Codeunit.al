codeunit 20241 "Tax Rate Filter Mgmt."
{
    var
        TempTaxRateFilter: Record "Tax Rate Filter" temporary;
        TempTaxRateValueInterim: Record "Tax Rate Value" temporary;
        TempGlobalTaxRateValue: Record "Tax Rate Value" temporary;

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
        TaxRate.ClearMarks();
        TaxRate.MarkedOnly(false);

        TempTaxRateFilter.Reset();
        TempTaxRateFilter.DeleteAll();

        if TaxRate.FindSet() then;
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
    var
        TempTaxRateValue: Record "Tax Rate Value" temporary;
    begin
        FillTempTaxRates(TaxRate."Tax Type", TempTaxRateValue);

        TaxRateFilter.SetFilter(Value, '<>%1', '');
        if TaxRateFilter.FindSet() then begin
            FilterApplied := true;
            repeat
                ApplyFilter(TempTaxRateValue, TaxRateFilter);
            until TaxRateFilter.Next() = 0;

            MarkTaxRate(TaxRate, TempTaxRateValue);
        end;
    end;

    local procedure FillTempTaxRates(
        TaxTypeCode: Code[20];
        var TempTaxRateValue: Record "Tax Rate Value" temporary)
    var
        TaxRate: Record "Tax Rate";
    begin
        DeleteTemp();

        TaxRate.Setrange("Tax Type", TaxTypeCode);
        if TaxRate.FindSet() then
            repeat
                FillRateValue(TempTaxRateValue, TaxRate.ID);
            until TaxRate.Next() = 0;
    end;

    local procedure FillRateValue(var TempTaxRateValue: Record "Tax Rate Value" temporary; ConfigID: Guid)
    var
        TaxRateValue: Record "Tax Rate Value";
    begin
        TaxRateValue.SetRange("Config ID", ConfigID);
        if TaxRateValue.FindSet() then
            repeat
                TempTaxRateValue.Init();
                TempTaxRateValue := TaxRateValue;
                TempTaxRateValue.Insert();

                TempGlobalTaxRateValue.Init();
                TempGlobalTaxRateValue := TaxRateValue;
                TempGlobalTaxRateValue.Insert();
            until TaxRateValue.Next() = 0;
    end;

    local procedure DeleteTemp()
    begin
        TempGlobalTaxRateValue.Reset();
        TempGlobalTaxRateValue.DeleteAll();
    end;

    local procedure ApplyFilter(
        var TaxRateValue: Record "Tax Rate Value" temporary;
        TaxRateFilter: Record "Tax Rate Filter")
    begin
        ApplyFilterByColumnType(TaxRateValue, TaxRateFilter);
        MarkFilterRecords(TaxRateValue);
        UpdateCacheRecords(TaxRateValue);
    end;

    local procedure ApplyFilterByColumnType(
        var TaxRateValue: Record "Tax Rate Value" temporary;
        TaxRateFilter: Record "Tax Rate Filter")
    var
        TaxAttribute: Record "Tax Attribute";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        RHSvalue: Variant;
        OptionText: Text;
    begin
        TaxRateValue.Reset();
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
        var TaxRateValue: Record "Tax Rate Value" temporary;
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
        var TaxRateValue: Record "Tax Rate Value" temporary;
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
        var TaxRateValue: Record "Tax Rate Value" temporary)
    begin
        TaxRateValue.Reset();
        if TaxRateValue.FindSet() then
            repeat
                TaxRate.Get(TaxRateValue."Tax Type", TaxRateValue."Config ID");
                if not TaxRate.Mark() then
                    TaxRate.Mark(true);
            until TaxRateValue.Next() = 0;
    end;

    local procedure MarkFilterRecords(var TaxRateValue: Record "Tax Rate Value" temporary)
    begin
        if TaxRateValue.FindSet() then
            repeat
                FillInterimRecord(TaxRateValue."Config ID");
            until TaxRateValue.Next() = 0;
    end;

    local procedure UpdateCacheRecords(var TaxRateValue: Record "Tax Rate Value" temporary)
    begin
        TaxRateValue.Reset();
        TaxRateValue.DeleteAll();

        TempTaxRateValueInterim.Reset();
        if TempTaxRateValueInterim.FindSet() then
            repeat
                TaxRateValue.Init();
                TaxRateValue := TempTaxRateValueInterim;
                TaxRateValue.Insert();
                TempTaxRateValueInterim.Delete();
            until TempTaxRateValueInterim.Next() = 0;
    end;

    local procedure FillInterimRecord(ConfigID: Guid)
    begin
        TempTaxRateValueInterim.Reset();
        TempTaxRateValueInterim.SetRange("Config ID", ConfigID);
        if not TempTaxRateValueInterim.IsEmpty() then
            exit;

        TempGlobalTaxRateValue.Reset();
        TempGlobalTaxRateValue.SetRange("Config ID", ConfigID);
        if TempGlobalTaxRateValue.FindSet() then
            repeat
                TempTaxRateValueInterim.Init();
                TempTaxRateValueInterim := TempGlobalTaxRateValue;
                TempTaxRateValueInterim.Insert();
            until TempGlobalTaxRateValue.Next() = 0;
    end;
}