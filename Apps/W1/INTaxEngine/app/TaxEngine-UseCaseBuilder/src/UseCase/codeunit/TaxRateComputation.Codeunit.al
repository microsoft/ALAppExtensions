codeunit 20291 "Tax Rate Computation"
{
    procedure GetTaxAttributes(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecordRef: RecordRef;
        CaseID: Guid)
    var
        UseCaseAttributeMapping: Record "Use Case Attribute Mapping";
    begin
        UseCaseAttributeMapping.SetRange("Case ID", CaseID);
        if UseCaseAttributeMapping.FindSet() then
            repeat
                UpdateTaxAttributeValue(SymbolStore, SourceRecordRef, CaseID, UseCaseAttributeMapping."Switch Statement ID", UseCaseAttributeMapping."Attribtue ID");
            until UseCaseAttributeMapping.Next() = 0;
    end;

    procedure GetTaxColumns(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecordRef: RecordRef;
        CaseID: Guid);
    var
        UseCaseRateColumnRelation: Record "Use Case Rate Column Relation";
    begin
        UseCaseRateColumnRelation.SetRange("Case ID", CaseID);
        UseCaseRateColumnRelation.SetFilter("Column ID", '<>%1', 0);
        if UseCaseRateColumnRelation.FindSet() then
            repeat
                UpdateTaxColumnValue(
                    SymbolStore,
                    SourceRecordRef,
                    CaseID,
                    UseCaseRateColumnRelation."Switch Statement ID",
                    UseCaseRateColumnRelation."Column ID");
            until UseCaseRateColumnRelation.Next() = 0;
    end;

    procedure CalculateTaxComponent(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecordRef: RecordRef;
        CaseID: Guid;
        CurrencyCode: Code[20];
        CurrencyFactor: Decimal)
    var
        UseCaseComponentCalculation: Record "Use Case Component Calculation";
    begin
        UseCaseComponentCalculation.SetCurrentKey(Sequence);
        UseCaseComponentCalculation.SetRange("Case ID", CaseID);
        if UseCaseComponentCalculation.FindSet() then
            repeat
                if not IsNullGuid(UseCaseComponentCalculation."Formula ID") then
                    ExecuteComponentExpression(
                        SymbolStore,
                        SourceRecordRef,
                        CaseID,
                        UseCaseComponentCalculation."Formula ID",
                        CurrencyCode,
                        CurrencyFactor);
            until UseCaseComponentCalculation.Next() = 0;
    end;

    procedure RoundAmount(Amount: Decimal; Precision: Decimal; Direction: Enum "Rounding Direction"): Decimal
    begin
        case Direction of
            Direction::Down:
                Amount := ROUND(Amount, Precision, '<');
            Direction::Up:
                Amount := ROUND(Amount, Precision, '>');
            Direction::Nearest:
                Amount := ROUND(Amount, Precision, '=');
        end;

        exit(Amount);
    end;

    procedure UpdateComponentPercentages(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecordRef: RecordRef;
        CaseID: Guid)
    var
        UseCase: Record "Tax Use Case";
        TaxRate: Record "Tax Rate";
        RowID: Guid;
        RateID: Text;
    begin
        UseCase.Get(CaseID);
        RateID := GenerateTransactionRateID(SymbolStore, CaseID);

        RowID := GetTaxRateRowID(SymbolStore, UseCase."Tax Type", RateID);

        if not IsNullGuid(RowID) then begin
            TaxRate.Get(UseCase."Tax Type", RowID);
            UpdateTaxComponentRatesAndOutput(SymbolStore, SourceRecordRef, CaseID, TaxRate);
        end;
    end;

    local procedure GetTaxRateRowID(var SymbolStore: Codeunit "Script Symbol Store"; TaxType: Code[20]; RateID: Text): Guid
    var
        TaxRate: Record "Tax Rate";
        TempTaxRate: Record "Tax Rate" Temporary;
        Rank: Text;
    begin
        TaxRate.SetRange("Tax Type", TaxType);
        TaxRate.SetRange("Tax Rate ID", RateID);
        if TaxRate.findSet() then
            repeat
                Rank := '';
                if QualifyTaxRateRow(SymbolStore, TaxRate, Rank) then begin
                    TempTaxRate := TaxRate;
                    TempTaxRate."Tax Rate ID" := Rank;
                    TempTaxRate.Insert();
                end;
            until TaxRate.Next() = 0;

        TempTaxRate.Reset();
        TempTaxRate.SetCurrentKey("Tax Rate ID");
        if TempTaxRate.FindLast() then
            exit(TempTaxRate.ID);
    end;

    local procedure QualifyAllowBlankColumn(
        var SymbolStore: Codeunit "Script Symbol Store";
        var TaxRate: Record "Tax Rate";
        var TaxRateColumnSetup: Record "Tax Rate Column Setup";
        var Score: Integer): Boolean
    var
        Value: Variant;
        ColumnValue: Text;
    begin
        ColumnValue := GetTaxRateColumnValue(TaxRate, TaxRateColumnSetup);
        if ColumnValue = '' then begin
            Score := 1;
            exit(true);
        end;

        if TaxRateColumnSetup."Column Type" = TaxRateColumnSetup."Column Type"::Value then
            SymbolStore.GetSymbolOfType("Symbol Type"::Column, TaxRateColumnSetup."Column ID", Value)
        else
            SymbolStore.GetSymbolOfType("Symbol Type"::"Tax Attributes", TaxRateColumnSetup."Attribute ID", Value);

        if Format(Value, 0, 2) = ColumnValue then begin
            Score := 2;
            exit(true);
        end;
    end;

    local procedure GetTaxRateColumnValue(TaxRate: Record "Tax Rate"; var TaxRateColumnSetup: Record "Tax Rate Column Setup"): Text
    var
        TaxRateValue: Record "Tax Rate Value";
    begin
        TaxRateValue.SetRange("Tax Type", TaxRateColumnSetup."Tax Type");
        TaxRateValue.SetRange("Config ID", TaxRate.ID);
        TaxRateValue.SetRange("Column ID", TaxRateColumnSetup."Column ID");
        if TaxRateValue.findfirst() then
            exit(TaxRateValue.Value);

        exit('')
    end;

    local procedure UpdateTransactionValue(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecordRef: RecordRef;
        CaseID: Guid;
        ID: Integer;
        Value: Variant;
        ValueLCY: Variant;
        TransactionValueType: Enum "Transaction Value Type")
    var
        UseCase: Record "Tax Use Case";
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        UseCase.Get(CaseID);

        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetRange("Tax Type", UseCase."Tax Type");
        TaxTransactionValue.SetRange("Tax Record ID", SourceRecordRef.RecordId());
        TaxTransactionValue.SetRange("Value Type", TransactionValueType);
        TaxTransactionValue.SetRange("Value ID", ID);
        if not TaxTransactionValue.FindFirst() then
            InsertTaxTransactionValue(SourceRecordRef.RecordId(), CaseID, ID, UseCase."Tax Type", TransactionValueType, TaxTransactionValue);

        ModifyTaxTransactionValue(SymbolStore, ID, TaxTransactionValue, Value, ValueLCY);
    end;

    local procedure InsertTaxTransactionValue(
        SourceRecID: RecordId;
        CaseID: Guid;
        ID: Integer;
        TaxType: Code[20];
        TransactionValueType: Enum "Transaction Value Type";
        var TaxTransactionValue: Record "Tax Transaction Value")
    begin
        TaxTransactionValue.Init();
        TaxTransactionValue."Case ID" := CaseID;
        TaxTransactionValue."Tax Record ID" := SourceRecID;
        TaxTransactionValue."Value Type" := TransactionValueType;
        TaxTransactionValue."Tax Type" := TaxType;
        TaxTransactionValue."Value ID" := ID;
        TaxTransactionValue.Insert();
    end;

    local procedure ModifyTaxTransactionValue(
        var SymbolStore: Codeunit "Script Symbol Store";
        ID: Integer;
        var TaxTransactionValue: Record "Tax Transaction Value";
        Value: Variant;
        ValueLCY: Variant)
    var
        RelatedValue: Variant;
    begin
        Evaluate(TaxTransactionValue."Column Value", Format(Value, 0, 9));

        if TaxTransactionValue."Value Type" = TaxTransactionValue."Value Type"::COMPONENT then begin
            SymbolStore.GetSymbolOfType("Symbol Type"::"Component Percent", ID, RelatedValue);
            ModifyComponentTaxTransactionValue(TaxTransactionValue, ID, RelatedValue, Value, ValueLCY);
        end;

        if TaxTransactionValue."Value Type" = TaxTransactionValue."Value Type"::ATTRIBUTE then
            ModifyAttributeTaxTransactionValue(Value, TaxTransactionValue);

        TaxTransactionValue."Visible on Interface" := TaxTransactionValue.ShouldAttributeBeVisible();
        TaxTransactionValue.Modify();
    end;

    local procedure ModifyComponentTaxTransactionValue(var TaxTransactionValue: Record "Tax Transaction Value"; ID: Integer; RelatedValue: Variant; Value: Variant; ValueLCY: Variant)
    var
        TaxComponent: Record "Tax Component";
    begin
        TaxComponent.Get(TaxTransactionValue."Tax Type", ID);
        TaxTransactionValue.Amount := Value;
        TaxTransactionValue."Amount (LCY)" := ValueLCY;
        TaxTransactionValue."Value ID" := ID;
        TaxTransactionValue.Percent := RelatedValue;
    end;

    local procedure ModifyAttributeTaxTransactionValue(Value: Variant; var TaxTransactionValue: Record "Tax Transaction Value")
    var
        TaxAttribute: Record "Tax Attribute";
    begin
        TaxAttribute.SetFilter("Tax Type", '%1|%2', TaxTransactionValue."Tax Type", '');
        TaxAttribute.SetRange(ID, TaxTransactionValue."Value ID");
        TaxAttribute.FindFirst();
        if (TaxAttribute.Type = TaxAttribute.Type::Option) and Value.IsInteger() then begin
            Value := TaxAttributeMgmt.GetAttributeOptionText(TaxAttribute."Tax Type", TaxAttribute.ID, Value);
            Evaluate(TaxTransactionValue."Column Value", Format(Value));
        end else
            Evaluate(TaxTransactionValue."Column Value", Format(Value));
    end;

    local procedure GenerateTransactionRateID(var SymbolStore: Codeunit "Script Symbol Store"; CaseID: Guid): Text
    var
        UseCase: Record "Tax Use Case";
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        SetupID: Text;
        Value: Variant;
    begin
        UseCase.Get(CaseID);

        TaxRateColumnSetup.SetCurrentKey(Sequence);
        TaxRateColumnSetup.SetRange("Tax Type", UseCase."Tax Type");
        TaxRateColumnSetup.SetFilter("Column Type", '%1|%2', TaxRateColumnSetup."Column Type"::Value, TaxRateColumnSetup."Column Type"::"Tax Attributes");
        TaxRateColumnSetup.SetRange("Allow Blank", false);
        if TaxRateColumnSetup.FindSet() then
            repeat
                if TaxRateColumnSetup."Column Type" = TaxRateColumnSetup."Column Type"::Value then
                    SymbolStore.GetSymbolOfType("Symbol Type"::Column, TaxRateColumnSetup."Column ID", Value)
                else
                    SymbolStore.GetSymbolOfType("Symbol Type"::"Tax Attributes", TaxRateColumnSetup."Attribute ID", Value);

                SetupID += ScriptDataTypeMgmt.Variant2Text(Value, '') + '|';
            until TaxRateColumnSetup.Next() = 0;

        exit(SetupID);
    end;

    local procedure QualifyTaxRateRow(var SymbolStore: Codeunit "Script Symbol Store"; var TaxRate: Record "Tax Rate"; var Rank: Text): Boolean
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        RHSValue: Variant;
        ColumnScore: Integer;
        ColumnRank: Text;
        ColumnValue: Text;
    begin
        TaxRateColumnSetup.SetCurrentKey(Sequence);
        TaxRateColumnSetup.SetRange("Tax Type", TaxRate."Tax Type");
        if TaxRateColumnSetup.FindSet() then
            repeat
                if TaxRateColumnSetup."Column Type" in [
                    TaxRateColumnSetup."Column Type"::"Range From and Range To",
                    TaxRateColumnSetup."Column Type"::"Range From",
                    TaxRateColumnSetup."Column Type"::"Range To"]
                then begin
                    SymbolStore.GetSymbolOfType("Symbol Type"::Column, TaxRateColumnSetup."Column ID", RHSValue);
                    if not QualifyRangeColumn(TaxRate, TaxRateColumnSetup, RHSValue, ColumnScore) then
                        exit(false);

                    ColumnValue := Format(ColumnScore, 0, 2);
                    ColumnRank := ColumnValue.PadLeft(10, '0');
                    Rank += ColumnRank;
                end else
                    if (TaxRateColumnSetup."Column Type" in [
                        TaxRateColumnSetup."Column Type"::Value,
                        TaxRateColumnSetup."Column Type"::"Tax Attributes"]) and
                        (TaxRateColumnSetup."Allow Blank")
                    then begin
                        if not QualifyAllowBlankColumn(SymbolStore, TaxRate, TaxRateColumnSetup, ColumnScore) then
                            exit(false);

                        ColumnValue := Format(ColumnScore, 0, 2);
                        ColumnRank := ColumnValue.PadLeft(10, '0');
                        Rank += ColumnRank;
                    end;
            until TaxRateColumnSetup.Next() = 0;

        exit(true);
    end;

    local procedure QualifyRangeColumn(var TaxRate: Record "Tax Rate"; var TaxRateColumnSetup: Record "Tax Rate Column Setup"; RHSValue: Variant; var Score: Integer): Boolean
    var
        TaxRateValue: Record "Tax Rate Value";
        CompareDate: Date;
    begin
        TaxRateValue.SetRange("Tax Type", TaxRateColumnSetup."Tax Type");
        TaxRateValue.SetRange("Config ID", TaxRate.ID);
        TaxRateValue.SetRange("Column ID", TaxRateColumnSetup."Column ID");
        if TaxRateValue.FindSet() then
            repeat
                if not ParamterInRange(TaxRateColumnSetup, TaxRateValue."Config ID", RHSValue) then
                    exit(false);

                case TaxRateColumnSetup.Type of
                    TaxRateColumnSetup.Type::Date:
                        begin
                            CompareDate := RHSValue;
                            if TaxRateValue."Date Value" <> 0D then
                                Score := CompareDate - TaxRateValue."Date Value"
                            else
                                Score := CompareDate - 17530101D;

                            Score := 10000 - Score;
                        end;
                    TaxRateColumnSetup.Type::Decimal:
                        Score := RHSValue;
                end;
            until TaxRateValue.Next() = 0;
        exit(true);
    end;

    local procedure ParamterInRange(TaxRateColumnSetup: Record "Tax Rate Column Setup"; ConfigID: Guid; var RHSValue: Variant): Boolean
    var
        TaxRateValue: Record "Tax Rate Value";
    begin
        TaxRateValue.Reset();
        TaxRateValue.SetRange("Tax Type", TaxRateColumnSetup."Tax Type");
        TaxRateValue.SetRange("Config ID", ConfigID);
        TaxRateValue.SetRange("Column ID", TaxRateColumnSetup."Column ID");

        case TaxRateColumnSetup."Column Type" of
            TaxRateColumnSetup."Column Type"::"Range From and Range To":
                FilterBasedOnFromAndToRange(TaxRateValue, TaxRateColumnSetup, RHSValue);
            TaxRateColumnSetup."Column Type"::"Range From":
                FilterBasedOnFromRange(TaxRateValue, TaxRateColumnSetup, RHSValue);
            TaxRateColumnSetup."Column Type"::"Range To":
                FilterBasedOnToRange(TaxRateValue, TaxRateColumnSetup, RHSValue);
        end;

        if Not TaxRateValue.IsEmpty() then
            exit(true);
    end;

    local procedure FilterBasedOnFromAndToRange(var TaxRateValue: Record "Tax Rate Value"; TaxRateColumnSetup: Record "Tax Rate Column Setup"; RHSValue: Variant)
    var
        CompareDecimal: Decimal;
        CompareDate: Date;
    begin
        if TaxRateColumnSetup.Type = TaxRateColumnSetup.Type::Date then begin
            CompareDate := RHSValue;
            TaxRateValue.SetFilter("Date Value", '<=%1', CompareDate);
            TaxRateValue.SetFilter("Date Value To", '>=%1', CompareDate);
        end else
            if TaxRateColumnSetup.Type = TaxRateColumnSetup.Type::Decimal then begin
                CompareDecimal := RHSValue;
                TaxRateValue.SetFilter("Decimal Value", '<=%1', CompareDecimal);
                TaxRateValue.SetFilter("Decimal Value To", '>=%1', CompareDecimal);
            end;
    end;

    local procedure FilterBasedOnFromRange(var TaxRateValue: Record "Tax Rate Value"; TaxRateColumnSetup: Record "Tax Rate Column Setup"; RHSValue: Variant)
    var
        CompareDecimal: Decimal;
        CompareDate: Date;
    begin
        case TaxRateColumnSetup.Type of
            TaxRateColumnSetup.Type::Date:
                begin
                    CompareDate := RHSValue;
                    TaxRateValue.SetFilter("Date Value", '<=%1', CompareDate);
                end;
            TaxRateColumnSetup.Type::Decimal:
                begin
                    CompareDecimal := RHSValue;
                    TaxRateValue.SetFilter("Decimal Value", '<=%1', CompareDecimal);
                end;
        end;
    end;

    local procedure FilterBasedOnToRange(var TaxRateValue: Record "Tax Rate Value"; TaxRateColumnSetup: Record "Tax Rate Column Setup"; RHSValue: Variant)
    var
        CompareDecimal: Decimal;
        CompareDate: Date;
    begin
        case TaxRateColumnSetup.Type of
            TaxRateColumnSetup.Type::Date:
                begin
                    CompareDate := RHSValue;
                    TaxRateValue.SetFilter("Date Value", '>=%1', CompareDate);
                end;
            TaxRateColumnSetup.Type::Decimal:
                begin
                    CompareDecimal := RHSValue;
                    TaxRateValue.SetFilter("Decimal Value", '>=%1', CompareDecimal);
                end;
        end;
    end;

    local procedure UpdateTaxColumnValue(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecordRef: RecordRef;
        CaseID: Guid;
        RefrenceId: Guid;
        ColumnID: Integer)
    var
        UseCase: Record "Tax Use Case";
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        TaxAttribute: Record "Tax Attribute";
        LookupID: Guid;
        Value: Variant;
        AttributeId: Integer;
    begin
        LookupID := SwitchStatementExecution.GetActionID(SymbolStore, SourceRecordRef, CaseID, RefrenceId);
        UseCase.Get(CaseID);
        if IsNullGuid(LookupID) then
            Error(BlankColumSwitchCaseErr, ColumnID, UseCase.Description);

        SymbolStore.GetLookupValue(SourceRecordRef, CaseID, EmptyGUID, LookupID, Value);
        TaxRateColumnSetup.Get(UseCase."Tax Type", ColumnID);
        if TaxRateColumnSetup.Type = TaxRateColumnSetup.Type::Option then begin
            if TaxRateColumnSetup."Linked Attribute ID" <> 0 then
                AttributeId := TaxRateColumnSetup."Linked Attribute ID"
            else
                AttributeId := TaxRateColumnSetup."Attribute ID";

            if (Value.IsText()) or (Value.IsOption()) then
                Value := TaxAttributeMgmt.GetAttributeOptionIndex(TaxRateColumnSetup."Tax Type", AttributeId, Value)
        end;

        SymbolStore.SetSymbol2("Symbol Type"::Column, ColumnID, Value);
        if TaxRateColumnSetup.Type = TaxRateColumnSetup.Type::Option then
            if Value.IsInteger() then begin
                TaxAttribute.SetFilter("Tax Type", '%1|%2', UseCase."Tax Type", '');
                TaxAttribute.SetRange(ID, AttributeId);
                TaxAttribute.FindFirst();
                Value := TaxAttributeMgmt.GetAttributeOptionText(TaxAttribute."Tax Type", AttributeId, Value);
            end;

        UpdateTransactionValue(SymbolStore, SourceRecordRef, CaseID, ColumnID, Value, 0, "Transaction Value Type"::COLUMN);
    end;

    local procedure UpdateTaxAttributeValue(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecordRef: RecordRef;
        CaseID: Guid;
        RefrenceId: Guid;
        AttributeID: Integer)
    var
        UseCase: Record "Tax Use Case";
        RecRef: RecordRef;
        TableRelationID: Guid;
        Value: Variant;
    begin
        TableRelationID := SwitchStatementExecution.GetActionID(SymbolStore, SourceRecordRef, CaseID, RefrenceId);

        if IsNullGuid(TableRelationID) then begin
            UseCase.Get(CaseID);
            Error(BlankAttributeSwitchCaseErr, TaxAttributeMgmt.GetAttributeName(AttributeID), UseCase.Description);
        end;

        GetRelationRecordID(SymbolStore, SourceRecordRef, RecRef, CaseID, TableRelationID);
        UseCaseVariableMgmt.GetTaxAttributeValue(CaseID, RecRef, AttributeID, Value);
        SymbolStore.SetSymbol2("Symbol Type"::"Tax Attributes", AttributeID, Value);
        UpdateTransactionValue(SymbolStore, SourceRecordRef, CaseID, AttributeID, Value, 0, "Transaction Value Type"::ATTRIBUTE);
    end;

    local procedure UpdateTaxComponentRatesAndOutput(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecordRef: RecordRef;
        CaseID: Guid;
        TaxRate: Record "Tax Rate")
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        TaxRateColumnSetup.SetCurrentKey(Sequence);
        TaxRateColumnSetup.SetRange("Tax Type", TaxRate."Tax Type");
        TaxRateColumnSetup.SetFilter("Column Type", '%1|%2', TaxRateColumnSetup."Column Type"::Component, TaxRateColumnSetup."Column Type"::"Output Information");
        if TaxRateColumnSetup.FindSet() then
            repeat
                UpdateSymbolsFromTaxRateValue(CaseID, TaxRate.ID, TaxRateColumnSetup, SymbolStore, SourceRecordRef);
            until TaxRateColumnSetup.Next() = 0;
    end;

    local procedure UpdateSymbolsFromTaxRateValue(
        CaseID: Guid;
        ConfigID: Guid;
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecordRef: RecordRef)
    var
        TaxRateValue: Record "Tax Rate Value";
    begin
        TaxRateValue.SetRange("Tax Type", TaxRateColumnSetup."Tax Type");
        TaxRateValue.SetRange("Config ID", ConfigID);
        TaxRateValue.SetRange("Column ID", TaxRateColumnSetup."Column ID");
        if TaxRateValue.FindFirst() then
            if TaxRateColumnSetup."Column Type" = TaxRateColumnSetup."Column Type"::Component then
                UpdatComponentPercentSymbols(CaseID, SourceRecordRef, SymbolStore, TaxRateColumnSetup, TaxRateValue)
            else
                UpdateRateColumnSymbols(CaseID, TaxRateValue, TaxRateColumnSetup, SourceRecordRef, SymbolStore);
    end;

    local procedure UpdateRateColumnSymbols(
        CaseID: Guid;
        TaxRateValue: Record "Tax Rate Value";
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        var SourceRecordRef: RecordRef;
        var SymbolStore: Codeunit "Script Symbol Store")
    var
        DataTypeMgmt: Codeunit "Use Case Data Type Mgmt.";
        ColumnDataType: Enum "Symbol Data Type";
        Value: Variant;
    begin
        ColumnDataType := DataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxRateColumnSetup.Type);
        ScriptDataTypeMgmt.ConvertText2Type(TaxRateValue.Value, ColumnDataType, '', Value);
        SymbolStore.SetSymbol2("Symbol Type"::Column, TaxRateValue."Column ID", Value);

        UpdateTransactionValue(
            SymbolStore,
            SourceRecordRef,
            CaseID,
            TaxRateValue."Column ID",
            Value,
            0,
            "Transaction Value Type"::COLUMN);
    end;

    local procedure UpdatComponentPercentSymbols(
        CaseID: Guid;
        var SourceRecordRef: RecordRef;
        var SymbolStore: Codeunit "Script Symbol Store";
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        TaxRateValue: Record "Tax Rate Value")
    begin
        SymbolStore.SetSymbol2(
            "Symbol Type"::"Component Percent",
            TaxRateColumnSetup."Attribute ID",
            ScriptDataTypeMgmt.Text2Number(TaxRateValue.Value));

        UpdateTransactionValue(
            SymbolStore,
            SourceRecordRef,
            CaseID,
            TaxRateValue."Column ID",
            TaxRateValue.Value,
            0,
            "Transaction Value Type"::"COMPONENT PERCENT");
    end;

    local procedure ExecuteComponentExpression(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecordRef: RecordRef;
        CaseID: Guid;
        ActivityID: Guid;
        CurrencyCode: Code[20];
        CurrencyFactor: Decimal);
    var
        TaxComponentExpression: Record "Tax Component Expression";
        TaxComponentExprToken: Record "Tax Component Expr. Token";
        Values: Dictionary of [Text, Decimal];
        ValueVariant: Variant;
        OutputValue: Variant;
        ComponentLCY: Decimal;
    begin
        TaxComponentExpression.Get(CaseID, ActivityID);

        TaxComponentExprToken.Reset();
        TaxComponentExprToken.SetRange("Case ID", CaseID);
        TaxComponentExprToken.SetRange("Component Expr. ID", ActivityID);
        if TaxComponentExprToken.FindSet() then
            repeat
                SymbolStore.GetConstantOrLookupValue(
                    SourceRecordRef,
                    TaxComponentExprToken."Case ID",
                    TaxComponentExprToken."Script ID",
                    TaxComponentExprToken."Value Type",
                    TaxComponentExprToken.Value,
                    TaxComponentExprToken."Lookup ID",
                    ValueVariant);

                Values.Add(TaxComponentExprToken.Token, ValueVariant)
            until TaxComponentExprToken.Next() = 0;

        OutputValue := ScriptDataTypeMgmt.EvaluateExpression(TaxComponentExpression.Expression, Values);

        SymbolStore.SetSymbol2(
            "Symbol Type"::Component,
            TaxComponentExpression."Component ID",
            OutputValue);

        ComponentLCY := OutputValue;
        if (CurrencyCode <> '') and (CurrencyFactor <> 0) then begin
            ComponentLCY := ComponentLCY / CurrencyFactor;
            SymbolStore.SetSymbol2(
                "Symbol Type"::"Component Amount (LCY)",
                TaxComponentExpression."Component ID",
                ComponentLCY);
        end else
            SymbolStore.SetSymbol2(
                "Symbol Type"::"Component Amount (LCY)",
                TaxComponentExpression."Component ID",
                OutputValue);

        UpdateTransactionValue(
            SymbolStore,
            SourceRecordRef,
            CaseID,
            TaxComponentExpression."Component ID",
            OutputValue,
            ComponentLCY,
            "Transaction Value Type"::COMPONENT);
    end;

    local procedure GetRelationRecordID(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        var RecRef: RecordRef;
        CaseID: Guid;
        TableRelationID: Guid);
    var
        TaxTableRelation: Record "Tax Table Relation";
    begin
        TaxTableRelation.Get(CaseID, TableRelationID);
        if TaxTableRelation."Is Current Record" then begin
            RecRef := SourceRecRef;
            exit;
        end;

        RecRef.Open(TaxTableRelation."Source ID");
        SymbolStore.ApplyTableFilters(SourceRecRef, CaseID, EmptyGUID, RecRef, TaxTableRelation."Table Filter ID");
        if RecRef.FindFirst() then;
    end;

    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TaxAttributeMgmt: Codeunit "Tax Attribute Management";
        UseCaseVariableMgmt: Codeunit "Use Case Variables Mgmt.";
        SwitchStatementExecution: Codeunit "Switch Statement Execution";
        EmptyGUID: Guid;
        BlankColumSwitchCaseErr: Label 'Switch Case not defiend for ColumnID: %1 in Use Case: %2.', Comment = '%1 Columnd ID,%2= Use Case Description';
        BlankAttributeSwitchCaseErr: Label 'Switch Case not defiend for Attribute : %1 in Use Case: %2.', Comment = '%1 Attribute Name,%2= Use Case Description';
}