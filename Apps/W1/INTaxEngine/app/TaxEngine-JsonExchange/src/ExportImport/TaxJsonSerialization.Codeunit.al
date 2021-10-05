codeunit 20362 "Tax Json Serialization"
{
    procedure SetCanExportUseCases(NewCanExportUseCases: Boolean)
    begin
        CanExportUseCases := NewCanExportUseCases;
    end;

    procedure SetCalledFromCopyUseCase(NewCalledFromCopyUseCase: Boolean)
    begin
        CalledFromCopyUseCase := NewCalledFromCopyUseCase;
    end;

    procedure ExportUseCases(var UseCase: Record "Tax Use Case"; Var JArray: JsonArray)
    var
        TaxUseCaseJObject: JsonObject;
    begin
        UseCase.SetCurrentKey("Presentation Order");
        if not UseCase.FindSet() then
            exit;

        InitUseCaseProgressWindow();
        repeat
            GlobalUseCase := UseCase;
            WriteSingleUseCase(UseCase, TaxUseCaseJObject);
            JArray.Add(TaxUseCaseJObject);
        until UseCase.Next() = 0;

        CloseUseCaseProgressWindow();
    end;

    procedure ExportTaxTypes(var TaxType: Record "Tax Type"; var JArray: JsonArray)
    var
        JObject: JsonObject;
    begin
        if not TaxType.FindSet() then
            exit;
        InitTaxTypeProgressWindow();
        repeat
            ExportTaxType(TaxType, JObject);
            JArray.Add(JObject);
        until TaxType.Next() = 0;

        CloseTaxTypeProgressWindow();
    end;

    procedure ExportTaxType(TaxType: Record "Tax Type"; var JObject: JsonObject)
    var
        UseCase: Record "Tax Use Case";
        TaxTypeJObject: JsonObject;
        AccPeriodJObject: JsonObject;
        JArray: JsonArray;
    begin
        Clear(ScriptSymbolMgmt);
        ScriptSymbolMgmt.UseStrict();
        ScriptSymbolMgmt.SetContext(TaxType.Code, EmptyGuid, EmptyGuid);

        AddJsonProperty(TaxTypeJObject, 'Code', TaxType.Code);
        AddJsonProperty(TaxTypeJObject, 'TaxTypeDescription', TaxType.Description);
        AddJsonProperty(TaxTypeJObject, 'Enable', TaxType.Enabled);
        AddJsonProperty(TaxTypeJObject, 'Version', TaxType."Major Version");
        AddJsonProperty(TaxTypeJObject, 'MinorVersion', TaxType."Minor Version");
        AddJsonProperty(TaxTypeJObject, 'ChangedBy', TaxType."Changed By");

        WriteTaxTypeEntities(TaxType.Code, JArray);
        UpdateTaxTypeProgressWindow(TaxType.Code, 'Tax Entities');
        AddJsonProperty(TaxTypeJObject, 'TaxEntities', JArray);

        Clear(JArray);
        WriteTaxTypeAttributes(TaxType.Code, JArray);
        UpdateTaxTypeProgressWindow(TaxType.Code, 'Tax Attributes');
        AddJsonProperty(TaxTypeJObject, 'Attributes', JArray);

        if TaxType."Accounting Period" <> '' then begin
            Clear(JArray);
            UpdateTaxTypeProgressWindow(TaxType.Code, 'Tax Accounting Periods');
            WriteTaxAccountingPeriod(TaxType."Accounting Period", AccPeriodJObject);
            AddJsonProperty(TaxTypeJObject, 'AccountingPeriod', AccPeriodJObject);
        end;

        Clear(JArray);
        WriteTaxTypeComponent(TaxType.Code, JArray);
        UpdateTaxTypeProgressWindow(TaxType.Code, 'Tax Components');
        AddJsonProperty(TaxTypeJObject, 'Components', JArray);

        Clear(JArray);
        WriteTaxRateColumnSetup(TaxType.Code, JArray);
        UpdateTaxTypeProgressWindow(TaxType.Code, 'Tax Rate Setup');
        AddJsonProperty(TaxTypeJObject, 'TaxRateColumnSetup', JArray);

        if CanExportUseCases then begin
            UpdateTaxTypeProgressWindow(TaxType.Code, 'Tax Use Cases');
            Clear(JArray);
            UseCase.Reset();
            UseCase.SetCurrentKey("Presentation Order");
            UseCase.SetRange("Tax Type", TaxType.Code);
            ExportUseCases(UseCase, JArray);
            AddJsonProperty(TaxTypeJObject, 'UseCases', JArray);
        end;
        JObject := TaxTypeJObject;
    end;

    local procedure WriteTaxTypeEntities(TaxType: Code[20]; var JArray: JsonArray)
    var
        TaxEntity: Record "Tax Entity";
        EntityJObject: JsonObject;
    begin
        TaxEntity.SetRange("Tax Type", TaxType);
        if TaxEntity.FindSet() then
            repeat
                WriteSingleTaxTypeEntity(TaxEntity, EntityJObject);
                JArray.Add(EntityJObject);
            until TaxEntity.Next() = 0;
    end;

    local procedure WriteTaxAccountingPeriod(AccPeriodCode: Code[20]; var JObject: JsonObject)
    var
        TaxAccPeriodSetup: Record "Tax Acc. Period Setup";
        AccPeriodJObject: JsonObject;
    begin
        TaxAccPeriodSetup.Get(AccPeriodCode);
        AddJsonProperty(AccPeriodJObject, 'AccountingPeriodCode', TaxAccPeriodSetup.Code);
        AddJsonProperty(AccPeriodJObject, 'AccountingPeriodDesc', TaxAccPeriodSetup.Description);
        JObject := AccPeriodJObject;
    end;

    local procedure WriteSingleTaxTypeEntity(TaxEntity: Record "Tax Entity"; var JObject: JsonObject)
    var
        EntityJObject: JsonObject;
    begin
        AddJsonProperty(EntityJObject, 'TableName', AppObjectHelper.GetObjectName(ObjectType::Table, TaxEntity."Table ID"));
        AddJsonProperty(EntityJObject, 'Type', TaxEntity."Entity Type");
        JObject := EntityJObject;
    end;

    local procedure WriteTaxTypeAttributes(TaxType: Code[20]; var JArray: JsonArray)
    var
        TaxAttribute: Record "Tax Attribute";
        AttributeJObject: JsonObject;
    begin
        TaxAttribute.SetFilter("Tax Type", '%1|%2', TaxType, '');
        if TaxAttribute.FindSet() then
            repeat
                WriteSingleTaxTypeAttributes(TaxAttribute, AttributeJObject);
                JArray.Add(AttributeJObject);
            until TaxAttribute.Next() = 0;
    end;

    local procedure WriteSingleTaxTypeAttributes(TaxAttribute: Record "Tax Attribute"; var JObject: JsonObject)
    var
        AttributeJObject: JsonObject;
        MappingJArray: JsonArray;
    begin
        AddJsonProperty(AttributeJObject, 'TaxType', TaxAttribute."Tax Type");
        AddJsonProperty(AttributeJObject, 'ID', TaxAttribute.ID);
        AddJsonProperty(AttributeJObject, 'Name', TaxAttribute.Name);
        AddJsonProperty(AttributeJObject, 'Type', TaxAttribute.Type);
        AddJsonProperty(AttributeJObject, 'LookupTable', AppObjectHelper.GetObjectName(
            ObjectType::Table,
            TaxAttribute."Refrence Table ID"));
        AddJsonProperty(AttributeJObject, 'LookupField', AppObjectHelper.GetFieldName(
            TaxAttribute."Refrence Table ID",
            TaxAttribute."Refrence Field ID"));
        AddJsonProperty(AttributeJObject, 'LookupPage', AppObjectHelper.GetObjectName(
            ObjectType::Page,
            TaxAttribute."Lookup Page ID"));
        AddJsonProperty(AttributeJObject, 'GroupedInSubLedger', TaxAttribute."Grouped In SubLedger");
        AddJsonProperty(AttributeJObject, 'VisibleOnInterface', TaxAttribute."Visible on Interface");
        WriteEntityAttributeMapping(TaxAttribute.ID, MappingJArray);
        AddJsonProperty(AttributeJObject, 'EntityMapping', MappingJArray);

        JObject := AttributeJObject;
    end;

    local procedure WriteTaxTypeComponent(TaxType: Code[20]; var JArray: JsonArray)
    var
        TaxComponent: Record "Tax Component";
        ComponentJObject: JsonObject;
    begin
        TaxComponent.SetRange("Tax Type", TaxType);
        if TaxComponent.FindSet() then
            repeat
                WriteSingleTaxTypeComponent(TaxComponent, ComponentJObject);
                JArray.Add(ComponentJObject);
            until TaxComponent.Next() = 0;
    end;

    local procedure WriteSingleTaxTypeComponent(TaxComponent: Record "Tax Component"; var JObject: JsonObject)
    var
        ComponentJObject: JsonObject;
        FormulaJObject: JsonObject;
    begin
        AddJsonProperty(ComponentJObject, 'ID', TaxComponent.ID);
        AddJsonProperty(ComponentJObject, 'Name', TaxComponent.Name);
        AddJsonProperty(ComponentJObject, 'Type', TaxComponent.Type);
        AddJsonProperty(ComponentJObject, 'RoundingPrecision', TaxComponent."Rounding Precision");
        AddJsonProperty(ComponentJObject, 'Direction', TaxComponent.Direction);
        AddJsonProperty(ComponentJObject, 'VisibleOnInterface', TaxComponent."Visible On Interface");
        AddJsonProperty(ComponentJObject, 'SkipPosting', TaxComponent."Skip Posting");
        AddJsonProperty(ComponentJObject, 'ComponentType', TaxComponent."Component Type");
        if TaxComponent."Formula ID" <> EmptyGuid then begin
            WriteComponentFormulaExpression(TaxComponent."Formula ID", FormulaJObject);
            AddJsonProperty(ComponentJObject, 'Formula', FormulaJObject);
        end;

        JObject := ComponentJObject;
    end;

    local procedure WriteEntityAttributeMapping(AttributeID: Integer; var JArray: JsonArray)
    var
        EntityAttributeMapping: Record "Entity Attribute Mapping";
    begin
        EntityAttributeMapping.SetRange("Attribute ID", AttributeID);
        if EntityAttributeMapping.FindSet() then
            repeat
                WriteSingleEntityAttributeMapping(EntityAttributeMapping, JArray);
            until EntityAttributeMapping.Next() = 0;
    end;

    local procedure WriteSingleEntityAttributeMapping(
        EntityAttributeMapping: Record "Entity Attribute Mapping";
        var JArray: JsonArray)
    var
        JObject: JsonObject;
    begin
        AddJsonProperty(JObject, 'Entity', AppObjectHelper.GetObjectName(ObjectType::Table, EntityAttributeMapping."Entity ID"));
        if EntityAttributeMapping."Mapping Field ID" <> 0 then
            AddJsonProperty(JObject, 'MappingField', AppObjectHelper.GetFieldName(EntityAttributeMapping."Entity ID", EntityAttributeMapping."Mapping Field ID"));

        JArray.Add(JObject);
    end;

    local procedure WriteTaxRateColumnSetup(TaxType: Code[20]; var JArray: JsonArray)
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        TaxRateColumnSetup.SetRange("Tax Type", TaxType);
        if TaxRateColumnSetup.FindSet() then
            repeat
                WriteSingleTaxRateColumnSetup(TaxRateColumnSetup, JArray);
            until TaxRateColumnSetup.Next() = 0;
    end;

    local procedure WriteSingleTaxRateColumnSetup(
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        var JArray: JsonArray)
    var
        JObject: JsonObject;
    begin
        AddJsonProperty(JObject, 'Sequence', TaxRateColumnSetup.Sequence);
        AddJsonProperty(JObject, 'ID', TaxRateColumnSetup."Column ID");
        AddJsonProperty(JObject, 'ColumnType', TaxRateColumnSetup."Column Type");
        AddJsonProperty(JObject, 'ColumnName', TaxRateColumnSetup."Column Name");
        AddJsonProperty(JObject, 'VisibleOnInterface', TaxRateColumnSetup."Visible On Interface");
        AddJsonProperty(JObject, 'Type', TaxRateColumnSetup.Type);
        AddJsonProperty(JObject, 'AllowBlank', TaxRateColumnSetup."Allow Blank");
        if TaxRateColumnSetup."Linked Attribute ID" <> 0 then
            AddJsonProperty(JObject, 'LinkedAttributeName', ScriptSymbolMgmt.GetSymbolName(
                "Symbol Type"::"Tax Attributes",
                TaxRateColumnSetup."Linked Attribute ID"));

        JArray.Add(JObject);
    end;

    local procedure WriteSingleUseCase(UseCase: Record "Tax Use Case"; var JObject: JsonObject)
    var
        UseCaseJObject: JsonObject;
        ConditionJObject: JsonObject;
        JArray: JsonArray;
    begin
        UpdateUseCaseProgressWindow('Preperation');

        if not CalledFromCopyUseCase then
            AddJsonProperty(UseCaseJObject, 'CaseID', UseCase.ID);
        AddJsonProperty(UseCaseJObject, 'Description', UseCase.Description);
        if not CalledFromCopyUseCase then begin
            AddJsonProperty(UseCaseJObject, 'Version', UseCase."Major Version");
            AddJsonProperty(UseCaseJObject, 'MinorVersion', UseCase."Minor Version");
        end;
        AddJsonProperty(UseCaseJObject, 'TaxType', UseCase."Tax Type");
        AddJsonProperty(UseCaseJObject, 'ChangedBy', UseCase."Changed By");
        AddJsonProperty(UseCaseJObject, 'Code', UseCase.Code);
        AddJsonProperty(UseCaseJObject, 'TaxEntity', AppObjectHelper.GetObjectName(
            ObjectType::Table,
            UseCase."Tax Table ID"));

        AddJsonProperty(UseCaseJObject, 'ParentUseCase', UseCaseObjectHelper.GetUseCaseName(
            UseCase."Parent Use Case ID"));

        AddJsonProperty(UseCaseJObject, 'ParentCaseId', UseCase."Parent Use Case ID");
        AddJsonProperty(UseCaseJObject, 'PresentationOrder', UseCase."Presentation Order");
        AddJsonProperty(UseCaseJObject, 'Indent', UseCase."Indentation Level");

        Clear(ScriptSymbolMgmt);
        ScriptSymbolMgmt.UseStrict();
        ScriptSymbolMgmt.SetContext(UseCase.ID, EmptyGuid);
        if UseCase."Posting Table ID" <> 0 then begin
            UpdateUseCaseProgressWindow('Posting Table Filters');
            AddJsonProperty(UseCaseJObject, 'PostingTableName', AppObjectHelper.GetObjectName(
                ObjectType::Table,
                UseCase."Posting Table ID"));
            if not IsNullGuid(UseCase."Posting Table Filter ID") then begin
                WriteLookupFieldFilter(UseCase.ID, UseCase."Posting Table Filter ID", JArray);
                AddJsonProperty(UseCaseJObject, 'PostingTableFilters', JArray);
            end;
        end;

        Clear(JArray);
        UpdateUseCaseProgressWindow('Attribute Mapping');
        WriteAttributeMapping(UseCase.ID, JArray);
        AddJsonProperty(UseCaseJObject, 'Attributes', JArray);

        Clear(JArray);
        WriteRateColumnMapping(UseCase.ID, JArray);
        UpdateUseCaseProgressWindow('Rate Setup');
        AddJsonProperty(UseCaseJObject, 'RateColumns', JArray);

        Clear(ScriptSymbolMgmt);
        ScriptSymbolMgmt.UseStrict();
        ScriptSymbolMgmt.SetContext(UseCase.ID, UseCase."Computation Script ID");
        Clear(JArray);
        WriteUseCaseVariable(UseCase.ID, UseCase."Computation Script ID", JArray);
        AddJsonProperty(UseCaseJObject, 'ComputationVariables', JArray);

        if not IsNullGuid(UseCase."Computation Script ID") then begin
            UpdateUseCaseProgressWindow('Computation Script');
            Clear(JArray);
            WriteActionContainer(
                UseCase.ID,
                UseCase."Computation Script ID",
                UseCase.ID,
                "Container Action Type"::USECASE,
                JArray);
            AddJsonProperty(UseCaseJObject, 'ComputationScript', JArray);
        end;
        Clear(ScriptSymbolMgmt);
        ScriptSymbolMgmt.UseStrict();
        ScriptSymbolMgmt.SetContext(UseCase.ID, UseCase."Posting Script ID");

        Clear(ScriptSymbolMgmt);
        ScriptSymbolMgmt.UseStrict();
        ScriptSymbolMgmt.SetContext(UseCase.ID, UseCase."Posting Script ID");
        Clear(JArray);
        WriteUseCaseVariable(UseCase.ID, UseCase."Posting Script ID", JArray);
        AddJsonProperty(UseCaseJObject, 'PostingVariables', JArray);

        if not IsNullGuid(UseCase."Posting Script ID") then begin
            UpdateUseCaseProgressWindow('Posting Script');
            Clear(JArray);
            WriteActionContainer(
                UseCase.ID,
                UseCase."Posting Script ID",
                UseCase.ID,
                "Container Action Type"::USECASE,
                JArray);
            AddJsonProperty(UseCaseJObject, 'PostingScript', JArray);
        end;
        Clear(ScriptSymbolMgmt);
        ScriptSymbolMgmt.UseStrict();
        ScriptSymbolMgmt.SetContext(UseCase.ID, UseCase."Computation Script ID");

        UpdateUseCaseProgressWindow('Calculated Components');
        Clear(JArray);
        WriteComponentCalculation(UseCase.ID, JArray);
        AddJsonProperty(UseCaseJObject, 'Components', JArray);

        if not IsNullGuid(UseCase."Condition ID") then begin
            UpdateUseCaseProgressWindow('Preconditions');
            WriteCondition(UseCase.ID, EmptyGuid, UseCase."Condition ID", ConditionJObject);
            AddJsonProperty(UseCaseJObject, 'Condition', ConditionJObject);
        end;

        if UseCase."Posting Table ID" <> 0 then begin
            Clear(JArray);
            Clear(ScriptSymbolMgmt);

            UpdateUseCaseProgressWindow('Tax Posting Setup');
            ScriptSymbolMgmt.UseStrict();
            ScriptSymbolMgmt.SetContext(UseCase.ID, UseCase."Posting Script ID");
            WriteTaxPostingSetup(UseCase.ID, JArray);
            AddJsonProperty(UseCaseJObject, 'TaxPostingSetup', JArray);
        end;

        JObject := UseCaseJObject;
    end;

    local procedure WriteAttributeMapping(CaseID: Guid; var JArray: JsonArray)
    var
        UseCaseAttributeMapping: Record "Use Case Attribute Mapping";
    begin
        UseCaseAttributeMapping.SetRange("Case ID", CaseID);
        if UseCaseAttributeMapping.FindSet() then
            repeat
                WriteSinglerAttributeMapping(UseCaseAttributeMapping, JArray);
            until UseCaseAttributeMapping.Next() = 0;
    end;

    local procedure WriteRateColumnMapping(CaseID: Guid; var JArray: JsonArray)
    var
        UseCaseRateColumnRelation: Record "Use Case Rate Column Relation";
    begin
        UseCaseRateColumnRelation.SetRange("Case ID", CaseID);
        if UseCaseRateColumnRelation.FindSet() then
            repeat
                WriteSingleRateColumnMapping(UseCaseRateColumnRelation, JArray);
            until UseCaseRateColumnRelation.Next() = 0;
    end;

    local procedure WriteSinglerAttributeMapping(
        UseCaseAttributeMapping: Record "Use Case Attribute Mapping";
        var JArray: JsonArray)
    var
        AttibuteJObject: JsonObject;
        TableRelationJArray: JsonArray;
    begin
        AddJsonProperty(
            AttibuteJObject,
            'Name',
            ScriptSymbolMgmt.GetSymbolName(
                "Symbol Type"::"Tax Attributes",
                UseCaseAttributeMapping."Attribtue ID"));

        WriteSwitchStatement(
            UseCaseAttributeMapping."Case ID",
            UseCaseAttributeMapping."Switch Statement ID",
            TableRelationJArray);
        AddJsonProperty(AttibuteJObject, 'When', TableRelationJArray);
        JArray.Add(AttibuteJObject);
    end;

    local procedure WriteSingleTaxPostingSetup(TaxPostingSetup: Record "Tax Posting Setup"; var JArray: JsonArray)
    var
        UseCase: Record "Tax Use Case";
        ComponentJObject: JsonObject;
        AccountLookupJObject: JsonObject;
        ReverseAccountLookupJObject: JsonObject;
        InsertRecordJArray: JsonArray;
        FilterJArray: JsonArray;
    begin
        UseCase.Get(TaxPostingSetup."Case ID");
        AddJsonProperty(ComponentJObject, 'ComponentName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Component,
            TaxPostingSetup."Component ID"));
        AddJsonProperty(ComponentJObject, 'TableName', AppObjectHelper.GetObjectName(
            ObjectType::Table,
            UseCase."Posting Table ID"));
        AddJsonProperty(ComponentJObject, 'AccountSourceType', TaxPostingSetup."Account Source Type");
        if TaxPostingSetup."Account Source Type" = TaxPostingSetup."Account Source Type"::Field then
            AddJsonProperty(ComponentJObject, 'FieldName', AppObjectHelper.GetFieldName(
                UseCase."Posting Table ID",
                TaxPostingSetup."Field ID"))
        else
            if not IsNullGuid(TaxPostingSetup."Account Lookup ID") then begin
                WriteLookup(
                    TaxPostingSetup."Case ID",
                    EmptyGuid, TaxPostingSetup."Account Lookup ID",
                    AccountLookupJObject);

                AddJsonProperty(ComponentJObject, 'AccountFieldLookup', AccountLookupJObject);
            end;

        AddJsonProperty(ComponentJObject, 'AccountingImpact', TaxPostingSetup."Accounting Impact");
        AddJsonProperty(ComponentJObject, 'ReverseCharge', TaxPostingSetup."Reverse Charge");
        AddJsonProperty(ComponentJObject, 'ReverseAccountSourceType', TaxPostingSetup."Reversal Account Source Type");
        if TaxPostingSetup."Reversal Account Source Type" = TaxPostingSetup."Reversal Account Source Type"::Field then
            AddJsonProperty(ComponentJObject, 'ReverseChargeFieldName', AppObjectHelper.GetFieldName(
                UseCase."Posting Table ID",
                TaxPostingSetup."Reverse Charge Field ID"))
        else
            if not IsNullGuid(TaxPostingSetup."Reversal Account Lookup ID") then begin
                WriteLookup(
                    TaxPostingSetup."Case ID",
                    EmptyGuid, TaxPostingSetup."Reversal Account Lookup ID",
                    ReverseAccountLookupJObject);

                AddJsonProperty(ComponentJObject, 'ReverseAccountFieldLookup', ReverseAccountLookupJObject);
            end;

        if not IsNullGuid(TaxPostingSetup."Table Filter ID") then begin
            WriteLookupFieldFilter(UseCase.ID, TaxPostingSetup."Table Filter ID", FilterJArray);
            AddJsonProperty(ComponentJObject, 'TableFilters', FilterJArray);
        end;
        if not IsNullGuid(TaxPostingSetup."Switch Statement ID") then begin
            WriteSwitchStatement(
                TaxPostingSetup."Case ID",
                TaxPostingSetup."Switch Statement ID",
                InsertRecordJArray);
            AddJsonProperty(ComponentJObject, 'When', InsertRecordJArray);
        end;
        JArray.Add(ComponentJObject);
    end;

    local procedure WriteSingleRateColumnMapping(
        UseCaseRateColumnRelation: Record "Use Case Rate Column Relation";
        var JArray: JsonArray)
    var
        AttibuteJObject: JsonObject;
        TableRelationJArray: JsonArray;
    begin
        AddJsonProperty(
            AttibuteJObject,
            'Name',
            ScriptSymbolMgmt.GetSymbolName(
                "Symbol Type"::Column,
                UseCaseRateColumnRelation."Column ID"));
        WriteSwitchStatement(
            UseCaseRateColumnRelation."Case ID",
            UseCaseRateColumnRelation."Switch Statement ID",
            TableRelationJArray);
        AddJsonProperty(AttibuteJObject, 'When', TableRelationJArray);
        JArray.Add(AttibuteJObject);
    end;

    local procedure WriteComponentCalculation(CaseID: Guid; var JArray: JsonArray)
    var
        UseCaseComponentCalculation: Record "Use Case Component Calculation";
    begin
        UseCaseComponentCalculation.SetRange("Case ID", CaseID);
        if UseCaseComponentCalculation.FindSet() then
            repeat
                WriteSingleComponentCalculation(UseCaseComponentCalculation, JArray);
            until UseCaseComponentCalculation.Next() = 0;
    end;

    local procedure WriteSingleComponentCalculation(
        UseCaseComponentCalculation: Record "Use Case Component Calculation";
        var JArray: JsonArray)
    var
        UseCase: Record "Tax Use Case";
        ComponentJObject: JsonObject;
        FormulaJObject: JsonObject;
    begin
        UseCase.Get(UseCaseComponentCalculation."Case ID");
        AddJsonProperty(ComponentJObject, 'ComponentName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Component,
            UseCaseComponentCalculation."Component ID"));
        AddJsonProperty(ComponentJObject, 'Sequence', UseCaseComponentCalculation.Sequence);
        WriteComponentExpression(
            UseCaseComponentCalculation."Case ID",
            UseCaseComponentCalculation."Formula ID",
            FormulaJObject);
        AddJsonProperty(ComponentJObject, 'Formula', FormulaJObject);
        JArray.Add(ComponentJObject);
    end;

    local procedure WriteNumberExpression(CaseID: Guid; ScriptID: Guid; ExpressionID: Guid; var JObject: JsonObject)
    var
        ActionNumberExpression: Record "Action Number Expression";
    begin
        ActionNumberExpression.SetRange("Case ID", CaseID);
        ActionNumberExpression.SetRange("Script ID", ScriptID);
        ActionNumberExpression.SetRange(ID, ExpressionID);
        if ActionNumberExpression.FindSet() then
            repeat
                WriteSingleNumberExpression(ActionNumberExpression, JObject);
            until ActionNumberExpression.Next() = 0;
    end;

    local procedure WriteComponentExpression(CaseID: Guid; ExpressionID: Guid; var JObject: JsonObject)
    var
        TaxComponentExpression: Record "Tax Component Expression";
    begin
        TaxComponentExpression.SetRange("Case ID", CaseID);
        TaxComponentExpression.SetRange(ID, ExpressionID);
        if TaxComponentExpression.FindSet() then
            repeat
                WriteSingleComponentExpression(TaxComponentExpression, JObject);
            until TaxComponentExpression.Next() = 0;
    end;

    local procedure WriteSingleNumberExpression(
        ActionNumberExpression: Record "Action Number Expression";
        var JObject: JsonObject)
    var
        TokenJArray: JsonArray;
    begin
        AddJsonProperty(JObject, 'VariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionNumberExpression."Variable ID"));
        AddJsonProperty(JObject, 'Expression', ActionNumberExpression.Expression);
        WriteNumberExprTokenToJson(ActionNumberExpression, TokenJArray);
        AddJsonProperty(JObject, 'Tokens', TokenJArray);
    end;

    local procedure WriteSingleComponentExpression(
        TaxComponentExpression: Record "Tax Component Expression";
        var JObject: JsonObject)
    var
        TokenJArray: JsonArray;
    begin
        AddJsonProperty(JObject, 'VariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Component,
            TaxComponentExpression."Component ID"));
        AddJsonProperty(JObject, 'Expression', TaxComponentExpression.Expression);
        WriteComponentExprTokenToJson(TaxComponentExpression, TokenJArray);
        AddJsonProperty(JObject, 'Tokens', TokenJArray);
    end;

    local procedure WriteNumberExprTokenToJson(
        var ActionNumberExpression: Record "Action Number Expression"; JArray: JsonArray)
    var
        ActionNumberExprToken: Record "Action Number Expr. Token";
    begin
        ActionNumberExprToken.Reset();
        ActionNumberExprToken.SetRange("Case ID", ActionNumberExpression."Case ID");
        ActionNumberExprToken.SetRange("Numeric Expr. ID", ActionNumberExpression.ID);
        if ActionNumberExprToken.FindSet() then
            repeat
                WriteSingleNumberExprTokenToJson(ActionNumberExprToken, JArray);
            until ActionNumberExprToken.Next() = 0;

    end;

    local procedure WriteComponentExprTokenToJson(
        var TaxComponentExpression: Record "Tax Component Expression";
        JArray: JsonArray)
    var
        TaxComponentExprToken: Record "Tax Component Expr. Token";
    begin
        TaxComponentExprToken.Reset();
        TaxComponentExprToken.SetRange("Case ID", TaxComponentExpression."Case ID");
        TaxComponentExprToken.SetRange("Script ID", GlobalUseCase."Computation Script ID");
        TaxComponentExprToken.SetRange("Component Expr. ID", TaxComponentExpression.ID);
        if TaxComponentExprToken.FindSet() then
            repeat
                WriteSingleComponentExprTokenToJson(TaxComponentExprToken, JArray);
            until TaxComponentExprToken.Next() = 0;
    end;

    local procedure WriteSingleComponentExprTokenToJson(
        TaxComponentExprToken: Record "Tax Component Expr. Token";
        var JArray: JsonArray)
    var
        JObject: JsonObject;
        TokenJObject: JsonObject;
    begin
        AddJsonProperty(JObject, 'TokenName', TaxComponentExprToken.Token);
        WriteConstantOrLookup(
            TaxComponentExprToken."Case ID",
            TaxComponentExprToken."Script ID",
            TaxComponentExprToken."Value Type",
            TaxComponentExprToken.Value,
            TaxComponentExprToken."Lookup ID",
            TokenJObject);
        AddJsonProperty(JObject, 'TokenValue', TokenJObject);
        JArray.Add(JObject);
    end;

    local procedure WriteSingleNumberExprTokenToJson(
        ActionNumberExprToken: Record "Action Number Expr. Token";
        var JArray: JsonArray)
    var
        JObject: JsonObject;
        TokenJObject: JsonObject;
    begin
        AddJsonProperty(JObject, 'TokenName', ActionNumberExprToken.Token);
        WriteConstantOrLookup(
            ActionNumberExprToken."Case ID",
            ActionNumberExprToken."Script ID",
            ActionNumberExprToken."Value Type",
            ActionNumberExprToken.Value,
            ActionNumberExprToken."Lookup ID",
            TokenJObject);
        AddJsonProperty(JObject, 'TokenValue', TokenJObject);
        JArray.Add(JObject);
    end;

    local procedure WriteSwitchStatement(CaseID: Guid; ID: Guid; var JArray: JsonArray)
    var
        SwitchCase: Record "Switch Case";
    begin
        SwitchCase.SetRange("Case ID", CaseID);
        SwitchCase.SetRange("Switch Statement ID", ID);
        if SwitchCase.FindSet() then
            repeat
                WriteSingleWhenCondition(SwitchCase, JArray);
            until SwitchCase.Next() = 0
    end;

    local procedure WriteSingleWhenCondition(SwitchCase: Record "Switch Case"; var JArray: JsonArray)
    var
        JObject: JsonObject;
        LookupJObject: JsonObject;
        ConditionJObject: JsonObject;
    begin
        if not IsNullGuid(SwitchCase."Condition ID") then begin
            WriteCondition(SwitchCase."Case ID", EmptyGuid, SwitchCase."Condition ID", ConditionJObject);
            AddJsonProperty(JObject, 'Condition', ConditionJObject);
        end;

        AddJsonProperty(JObject, 'ValueType', SwitchCase."Action Type");
        AddJsonProperty(JObject, 'Sequence', SwitchCase.Sequence);
        case SwitchCase."Action Type" of
            SwitchCase."Action Type"::Lookup:
                begin
                    WriteLookup(SwitchCase."Case ID", EmptyGuid, SwitchCase."Action ID", LookupJObject);
                    AddJsonProperty(JObject, 'Lookup', LookupJObject);
                end;
            SwitchCase."Action Type"::Relation:
                begin
                    WriteTableRelation(SwitchCase."Case ID", SwitchCase."Action ID", LookupJObject);
                    AddJsonProperty(JObject, 'Relation', LookupJObject);
                end;
            SwitchCase."Action Type"::"Insert Record":
                begin
                    WriteInsertRecord(
                        SwitchCase."Case ID",
                        GlobalUseCase."Posting Script ID",
                        SwitchCase."Action ID",
                        LookupJObject);
                    AddJsonProperty(JObject, 'InsertRecord', LookupJObject);
                end;
        end;

        JArray.Add(JObject);
    end;

    local procedure WriteUseCaseVariable(CaseID: Guid; ScriptID: Guid; var JArray: JsonArray)
    var
        UseCaseVariable: Record "Script Variable";
    begin
        UseCaseVariable.SetRange("Case ID", CaseID);
        UseCaseVariable.SetRange("Script ID", ScriptID);
        if UseCaseVariable.FindSet() then
            repeat
                WriteSingleUseCaseVariable(UseCaseVariable, JArray);
            until UseCaseVariable.Next() = 0;
    end;

    local procedure WriteSingleUseCaseVariable(UseCaseVariable: Record "Script Variable"; var JArray: JsonArray)
    var
        VariableJObject: JsonObject;
    begin
        AddJsonProperty(VariableJObject, 'Name', ScriptSymbolMgmt.GetSymbolName("Symbol Type"::Variable, UseCaseVariable.ID));
        AddJsonProperty(VariableJObject, 'Datatype', UseCaseVariable.Datatype);
        JArray.Add(VariableJObject);
    end;

    local procedure WriteCondition(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ConditionItem: Record "Tax Test Condition Item";
        ConditionItemJObject: JsonObject;
        ConditionJObject: JsonObject;
        JArrary: JsonArray;
    begin
        ConditionItem.Reset();
        ConditionItem.SetRange("Case ID", CaseID);
        ConditionItem.SetRange("Script ID", ScriptID);
        ConditionItem.SetRange("Condition ID", ID);
        if ConditionItem.FindSet() then
            repeat
                Clear(ConditionItemJObject);
                WriteConditionItem(ConditionItem, ConditionItemJObject);
                JArrary.Add(ConditionItemJObject);
            until ConditionItem.Next() = 0;
        AddJsonProperty(ConditionJObject, 'Body', JArrary);
        JObject := ConditionJObject;
    end;

    local procedure WriteConditionItem(ConditionItem: Record "Tax Test Condition Item"; var JObject: JsonObject)
    var
        LookupJObject: JsonObject;
        ConditionJObject: JsonObject;
    begin
        AddJsonProperty(JObject, 'Operator', Format(ConditionItem."Logical Operator"));
        AddJsonProperty(JObject, 'ConditionType', Format(ConditionItem."Conditional Operator"));
        if not IsNullGuid(ConditionItem."LHS Lookup ID") then begin
            WriteLookup(
                ConditionItem."Case ID",
                ConditionItem."Script ID",
                ConditionItem."LHS Lookup ID",
                LookupJObject);

            AddJsonProperty(ConditionJObject, 'Lookup', LookupJObject);
            AddJsonProperty(JObject, 'LHS', ConditionJObject);
        end;
        WriteConstantOrLookup(ConditionItem."Case ID", ConditionItem."Script ID", ConditionItem."RHS Type", ConditionItem."RHS Value", ConditionItem."RHS Lookup ID", LookupJObject);
        AddJsonProperty(JObject, 'RHS', LookupJObject);
    end;

    local procedure WriteFieldFilter(LookupFieldFilter: Record "Lookup Field Filter"; var JObject: JsonObject)
    var
        LookupJObject: JsonObject;
        FieldJObject: JsonObject;
    begin
        AddJsonProperty(FieldJObject, 'FiterFieldName', AppObjectHelper.GetFieldName(LookupFieldFilter."Table ID", LookupFieldFilter."Field ID"));
        AddJsonProperty(FieldJObject, 'FilterType', LookupFieldFilter."Filter Type");
        WriteConstantOrLookup(LookupFieldFilter."Case ID", LookupFieldFilter."Script ID", LookupFieldFilter."Value Type", LookupFieldFilter.Value, LookupFieldFilter."Lookup ID", LookupJObject);
        AddJsonProperty(FieldJObject, 'FilterValue', LookupJObject);

        JObject := FieldJObject
    end;

    local procedure WriteFieldSorting(LookupFieldSorting: Record "Lookup Field Sorting") JObject: JsonObject
    begin
        AddJsonProperty(JObject, 'FieldName', AppObjectHelper.GetFieldName(LookupFieldSorting."Table ID", LookupFieldSorting."Field ID"));
    end;

    local procedure WriteLookupFieldFilter(CaseID: Guid; ID: Guid; var JArray: JsonArray)
    var
        LookupFieldFilter: Record "Lookup Field Filter";
        JObject: JsonObject;
    begin
        LookupFieldFilter.Reset();
        LookupFieldFilter.SetRange("Case ID", CaseID);
        LookupFieldFilter.SetRange("Table Filter ID", ID);
        if LookupFieldFilter.FindSet() then
            repeat
                WriteFieldFilter(LookupFieldFilter, JObject);
                JArray.Add(JObject);
            until LookupFieldFilter.Next() = 0;
    end;

    local procedure WriteLookupTableSorting(CaseID: Guid; ID: Guid) JArray: JsonArray
    var
        LookupFieldSorting: Record "Lookup Field Sorting";
    begin
        LookupFieldSorting.Reset();
        LookupFieldSorting.SetRange("Case ID", CaseID);
        LookupFieldSorting.SetRange("Table Sorting ID", ID);
        if LookupFieldSorting.FindSet() then
            repeat
                JArray.Add(WriteFieldSorting(LookupFieldSorting));
            until LookupFieldSorting.Next() = 0;
    end;

    local procedure WriteConstantOrLookup(
        CaseID: Guid;
        ScriptID: Guid;
        ValueType: Option Constant,"Lookup";
        Value: Text;
        LookupID: Guid;
        var JObject: JsonObject)
    var
        NewJObject: JsonObject;
    begin
        Clear(JObject);
        AddJsonProperty(JObject, 'Type', ValueType);
        if ValueType = ValueType::Constant then
            AddJsonProperty(JObject, 'Value', Value)
        else begin
            WriteLookup(CaseID, ScriptID, LookupID, NewJObject);
            AddJsonProperty(JObject, 'Lookup', NewJObject);
        end;
    end;

    local procedure WriteLookup(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
    begin
        if IsNullGuid(ID) then
            Exit;

        Clear(JObject);
        ScriptSymbolLookup.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'SourceType', ScriptSymbolLookup."Source Type");
        case ScriptSymbolLookup."Source Type" of
            ScriptSymbolLookup."Source Type"::"Current Record":
                begin
                    AddJsonProperty(JObject, 'TableName', AppObjectHelper.GetObjectName(
                        ObjectType::Table,
                        ScriptSymbolLookup."Source ID"));

                    AddJsonProperty(JObject, 'FieldName', AppObjectHelper.GetFieldName(
                        ScriptSymbolLookup."Source ID",
                        ScriptSymbolLookup."Source Field ID"));
                end;
            ScriptSymbolLookup."Source Type"::"Tax Attributes",
            ScriptSymbolLookup."Source Type"::"Attribute Code",
            ScriptSymbolLookup."Source Type"::"Attribute Name":
                AddJsonProperty(JObject, 'AttributeName', ScriptSymbolMgmt.GetSymbolName(
                    "Symbol Type"::"Tax Attributes",
                    ScriptSymbolLookup."Source Field ID"));
            ScriptSymbolLookup."Source Type"::Component,
            ScriptSymbolLookup."Source Type"::"Component Amount (LCY)",
            ScriptSymbolLookup."Source Type"::"Component Code",
            ScriptSymbolLookup."Source Type"::"Component Name":
                AddJsonProperty(JObject, 'ComponentName', ScriptSymbolMgmt.GetSymbolName(
                    "Symbol Type"::Component,
                    ScriptSymbolLookup."Source Field ID"));
            ScriptSymbolLookup."Source Type"::Column:
                AddJsonProperty(JObject, 'RateColumnName', ScriptSymbolMgmt.GetSymbolName(
                    "Symbol Type"::Column,
                    ScriptSymbolLookup."Source Field ID"));
            ScriptSymbolLookup."Source Type"::"Component Percent":
                AddJsonProperty(JObject, 'ComponentName', ScriptSymbolMgmt.GetSymbolName(
                    "Symbol Type"::"Component Percent",
                    ScriptSymbolLookup."Source Field ID"));
            ScriptSymbolLookup."Source Type"::Table:
                WriteLookupTable(ScriptSymbolLookup, JObject);
            ScriptSymbolLookup."Source Type"::"Attribute Table":
                WriteAttributeTable(ScriptSymbolLookup, JObject);
            ScriptSymbolLookup."Source Type"::Variable:
                AddJsonProperty(JObject, 'VariableName', ScriptSymbolMgmt.GetSymbolName(
                    "Symbol Type"::Variable,
                    ScriptSymbolLookup."Source Field ID"));
            ScriptSymbolLookup."Source Type"::"Posting Field":
                AddJsonProperty(JObject, 'PostingVariableName', ScriptSymbolMgmt.GetSymbolName(
                    "Symbol Type"::"Posting Field",
                    ScriptSymbolLookup."Source Field ID"));
            ScriptSymbolLookup."Source Type"::Database:
                AddJsonProperty(JObject, 'DatabaseVariableName', ScriptSymbolMgmt.GetSymbolName(
                    "Symbol Type"::Database,
                    ScriptSymbolLookup."Source Field ID"));
            ScriptSymbolLookup."Source Type"::System:
                AddJsonProperty(JObject, 'SystemVariableName', ScriptSymbolMgmt.GetSymbolName(
                    "Symbol Type"::System,
                    ScriptSymbolLookup."Source Field ID"));
            ScriptSymbolLookup."Source Type"::"Record Variable":
                AddJsonProperty(JObject, 'RecordFieldName', ScriptSymbolMgmt.GetSymbolName(
                    "Symbol Type"::"Record Variable",
                    ScriptSymbolLookup."Source Field ID"));
        end;
    end;


    local procedure WriteTableRelation(CaseID: Guid; ID: Guid; var JObject: JsonObject)
    var
        TaxTableRelation: Record "Tax Table Relation";
        JArray: JsonArray;
    begin
        if IsNullGuid(ID) then
            Exit;

        TaxTableRelation.GET(CaseID, ID);
        AddJsonProperty(JObject, 'IsCurrentRecord', TaxTableRelation."Is Current Record");
        AddJsonProperty(JObject, 'TableName', AppObjectHelper.GetObjectName(
            ObjectType::Table,
            TaxTableRelation."Source ID"));

        if not IsNullGuid(TaxTableRelation."Table Filter ID") then begin
            WriteLookupFieldFilter(CaseID, TaxTableRelation."Table Filter ID", JArray);
            AddJsonProperty(JObject, 'TableFilters', JArray);
        end;
    end;

    local procedure WriteLookupTable(ScriptSymbolLookup: Record "Script Symbol Lookup"; var JObject: JsonObject)
    var
        JArray: JsonArray;
    begin
        AddJsonProperty(JObject, 'TableName', AppObjectHelper.GetObjectName(ObjectType::Table, ScriptSymbolLookup."Source ID"));
        AddJsonProperty(JObject, 'TableFieldName', AppObjectHelper.GetFieldName(
            ScriptSymbolLookup."Source ID",
            ScriptSymbolLookup."Source Field ID"));

        AddJsonProperty(JObject, 'Method', Format(ScriptSymbolLookup."Table Method"));
        if not IsNullGuid(ScriptSymbolLookup."Table Filter ID") then
            WriteLookupFieldFilter(ScriptSymbolLookup."Case ID", ScriptSymbolLookup."Table Filter ID", JArray);

        AddJsonProperty(JObject, 'TableFilters', JArray);

        if not IsNullGuid(ScriptSymbolLookup."Table Sorting ID") then
            AddJsonProperty(JObject, 'Sorting', WriteLookupTableSorting(ScriptSymbolLookup."Case ID", ScriptSymbolLookup."Table Sorting ID"));
    end;

    local procedure WriteAttributeTable(ScriptSymbolLookup: Record "Script Symbol Lookup"; var JObject: JsonObject)
    var
        JArray: JsonArray;
    begin
        AddJsonProperty(JObject, 'TableName', AppObjectHelper.GetObjectName(ObjectType::Table, ScriptSymbolLookup."Source ID"));
        AddJsonProperty(JObject, 'TableFieldName', AppObjectHelper.GetFieldName(
            ScriptSymbolLookup."Source ID",
            ScriptSymbolLookup."Source Field ID"));

        AddJsonProperty(JObject, 'Method', Format(ScriptSymbolLookup."Table Method"));
        if not IsNullGuid(ScriptSymbolLookup."Table Filter ID") then
            WriteLookupFieldFilter(ScriptSymbolLookup."Case ID", ScriptSymbolLookup."Table Filter ID", JArray);

        AddJsonProperty(JObject, 'TableFilters', JArray);
    end;

    local procedure AddJsonProperty(var ParentJObject: JsonObject; PropertyName: Text; Value: Variant)
    var
        JObject: JsonObject;
        JArray: JsonArray;
        TextValue: Text;
        IntegerValue: Integer;
        BigIntegerValue: BigInteger;
        BooleanValue: Boolean;
        DecimalValue: Decimal;
        GuidValue: Guid;
    begin
        case true of
            value.IsJsonObject():
                begin
                    JObject := Value;
                    ParentJObject.Add(PropertyName, JObject);
                end;
            value.IsJsonArray():
                begin
                    JArray := Value;
                    ParentJObject.Add(PropertyName, JArray);
                end;
            Value.IsText(), Value.IsCode(), Value.IsOption():
                begin
                    TextValue := Format(Value);
                    ParentJObject.Add(PropertyName, TextValue);
                end;
            Value.IsInteger():
                begin
                    IntegerValue := Value;
                    ParentJObject.Add(PropertyName, IntegerValue);
                end;
            Value.IsBoolean():
                begin
                    BooleanValue := Value;
                    ParentJObject.Add(PropertyName, BooleanValue);
                end;
            Value.IsBigInteger():
                begin
                    BigIntegerValue := Value;
                    ParentJObject.Add(PropertyName, BigIntegerValue);
                end;
            Value.IsDecimal():
                begin
                    DecimalValue := Value;
                    ParentJObject.Add(PropertyName, DecimalValue);
                end;
            Value.IsGuid():
                begin
                    GuidValue := Value;
                    ParentJObject.Add(PropertyName, GuidValue);
                end;
        end;
    end;


    local procedure WriteComment(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionComment: Record "Action Comment";
    begin
        ActionComment.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'Comment', ActionComment.Text);
    end;

    local procedure WriteNumberCalculation(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionNumberCalculation: Record "Action Number Calculation";
        LookupJObject: JsonObject;
    begin
        ActionNumberCalculation.GET(CaseID, ScriptID, ID);
        AddJsonProperty(
            JObject,
            'OutputVariableName',
            ScriptSymbolMgmt.GetSymbolName("Symbol Type"::Variable, ActionNumberCalculation."Variable ID"));

        AddJsonProperty(JObject, 'Operator', ActionNumberCalculation."Arithmetic Operator");
        WriteConstantOrLookup(
            ActionNumberCalculation."Case ID",
            ActionNumberCalculation."Script ID",
            ActionNumberCalculation."LHS Type",
            ActionNumberCalculation."LHS Value",
            ActionNumberCalculation."LHS Lookup ID",
            LookupJObject);

        JObject.Add('LHS', LookupJObject);

        WriteConstantOrLookup(
            ActionNumberCalculation."Case ID",
            ActionNumberCalculation."Script ID",
            ActionNumberCalculation."RHS Type",
            ActionNumberCalculation."RHS Value",
            ActionNumberCalculation."RHS Lookup ID",
            LookupJObject);

        JObject.Add('RHS', LookupJObject);

    end;

    local procedure WriteExtractSubstringFromPosition(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionExtSubstrFromPos: Record "Action Ext. Substr. From Pos.";
        LookupJObject: JsonObject;
    begin
        ActionExtSubstrFromPos.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'Output', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionExtSubstrFromPos."Variable ID"));

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionExtSubstrFromPos."String Value Type",
            ActionExtSubstrFromPos."String Value",
            ActionExtSubstrFromPos."String Lookup ID",
            LookupJObject);

        JObject.Add('String', LookupJObject);

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionExtSubstrFromPos."Length Value Type",
            ActionExtSubstrFromPos."Length Value",
            ActionExtSubstrFromPos."Length Lookup ID",
            LookupJObject);

        JObject.Add('Length', LookupJObject);
        AddJsonProperty(JObject, 'Position', ActionExtSubstrFromPos.Position);
    end;

    local procedure WriteFindDateInterval(CaseID: Guid; ScriptID: Guid; ID: Guid; JObject: JsonObject)
    var
        ActionFindDateInterval: Record "Action Find Date Interval";
        LookupJObject: JsonObject;
    begin
        ActionFindDateInterval.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'Output', ScriptSymbolMgmt.GetSymbolName("Symbol Type"::Variable, ActionFindDateInterval."Variable ID"));
        WriteConstantOrLookup(
            ActionFindDateInterval."Case ID",
            ActionFindDateInterval."Script ID",
            ActionFindDateInterval."Date1 Value Type",
            ActionFindDateInterval."Date1 Value",
            ActionFindDateInterval."Date1 Lookup ID",
            LookupJObject);
        JObject.Add('FromDate', LookupJObject);

        WriteConstantOrLookup(
            ActionFindDateInterval."Case ID",
            ActionFindDateInterval."Script ID",
            ActionFindDateInterval."Date2 Value Type",
            ActionFindDateInterval."Date2 Value",
            ActionFindDateInterval."Date2 Lookup ID",
            LookupJObject);
        JObject.Add('ToDate', LookupJObject);
        JObject.Add('Interval', Format(ActionFindDateInterval.Inverval));

    end;

    local procedure WriteSetVariable(CaseID: Guid; ScriptID: Guid; ID: Guid; JObject: JsonObject)
    var
        ActionSetVariable: Record "Action Set Variable";
        LookupJObject: JsonObject;
    begin
        ActionSetVariable.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'OutputVariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionSetVariable."Variable ID"));

        WriteConstantOrLookup(
            ActionSetVariable."Case ID",
            ActionSetVariable."Script ID",
            ActionSetVariable."Value Type",
            ActionSetVariable.Value,
            ActionSetVariable."Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'OutputValue', LookupJObject);

    end;

    local procedure WriteConcatenate(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionConcatenate: Record "Action Concatenate";
        ActionConcatenateLine: Record "Action Concatenate Line";
        JArray: JsonArray;
    begin
        ActionConcatenate.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'OutputVariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionConcatenate."Variable ID"));

        ActionConcatenateLine.Reset();
        ActionConcatenateLine.SetRange("Case ID", CaseID);
        ActionConcatenateLine.SetRange("Script ID", ScriptID);
        ActionConcatenateLine.SetRange("Concatenate ID", ID);
        if ActionConcatenateLine.FindSet() then
            repeat
                WriteConcatenateLine(ActionConcatenateLine);
            until ActionConcatenateLine.Next() = 0;
        AddJsonProperty(JObject, 'Concatenate', JArray);
    end;

    local procedure WriteConcatenateLine(
        ActionConcatenateLine: Record "Action Concatenate Line")
    var
        LookupObject: JsonObject;
        JObject: JsonObject;
    begin
        WriteConstantOrLookup(
            ActionConcatenateLine."Case ID",
            ActionConcatenateLine."Script ID",
            ActionConcatenateLine."Value Type",
            ActionConcatenateLine.Value,
            ActionConcatenateLine."Lookup ID",
            LookupObject);

        AddJsonProperty(JObject, 'Value', LookupObject);
    end;

    local procedure WriteFindSubstring(CaseID: Guid; ScriptID: Guid; ID: Guid; JObject: JsonObject)
    var
        ActionFindSubstring: Record "Action Find Substring";
        LookupJObject: JsonObject;
    begin
        ActionFindSubstring.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'OutputVariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionFindSubstring."Variable ID"));

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionFindSubstring."Substring Value Type",
            ActionFindSubstring."Substring Value",
            ActionFindSubstring."Substring Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'SubstrinText', LookupJObject);

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionFindSubstring."String Value Type",
            ActionFindSubstring."String Value",
            ActionFindSubstring."String Lookup ID",
            LookupJObject);
    end;

    local procedure WriteRepaceSubstring(CaseID: Guid; ScriptID: Guid; ID: Guid; JObject: JsonObject)
    var
        ActionReplaceSubstring: Record "Action Replace Substring";
        LookupJObject: JsonObject;
    begin
        ActionReplaceSubstring.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'OutputVariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionReplaceSubstring."Variable ID"));

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionReplaceSubstring."Substring Value Type",
            ActionReplaceSubstring."Substring Value",
            ActionReplaceSubstring."Substring Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'SubstringText', LookupJObject);

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionReplaceSubstring."String Value Type",
            ActionReplaceSubstring."String Value",
            ActionReplaceSubstring."String Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'StringText', LookupJObject);

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionReplaceSubstring."New String Value Type",
            ActionReplaceSubstring."New String Value",
            ActionReplaceSubstring."New String Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'NewStringText', LookupJObject);

    end;

    local procedure WriteExtractSubstringFromIndex(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionExtSubstrFromIndex: Record "Action Ext. Substr. From Index";
        LookupJObject: JsonObject;
    begin
        ActionExtSubstrFromIndex.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'OutputVariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionExtSubstrFromIndex."Variable ID"));

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionExtSubstrFromIndex."String Value Type",
            ActionExtSubstrFromIndex."String Value",
            ActionExtSubstrFromIndex."String Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'StringText', LookupJObject);

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionExtSubstrFromIndex."Index Value Type",
            ActionExtSubstrFromIndex."Index Value",
            ActionExtSubstrFromIndex."Index Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'IndexText', LookupJObject);
        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionExtSubstrFromIndex."Length Value Type",
            ActionExtSubstrFromIndex."Length Value",
            ActionExtSubstrFromIndex."Length Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'LengthText', LookupJObject);
    end;

    local procedure WriteDateCalculation(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionDateCalculation: Record "Action Date Calculation";
        LookupJObject: JsonObject;
    begin
        ActionDateCalculation.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'OutputVariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionDateCalculation."Variable ID"));

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionDateCalculation."Date Value Type",
            ActionDateCalculation."Date Value",
            ActionDateCalculation."Date Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'StringText', LookupJObject);

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionDateCalculation."Number Value Type",
            ActionDateCalculation."Number Value",
            ActionDateCalculation."Number Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'NumberText', LookupJObject);
        AddJsonProperty(JObject, 'OperatorText', Format(ActionDateCalculation."Arithmetic operators"));
        AddJsonProperty(JObject, 'PeriodText', Format(ActionDateCalculation.Duration));
    end;

    local procedure WriteDateToDateTime(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionDateToDateTime: Record "Action Date To DateTime";
        LookupJObject: JsonObject;
    begin
        ActionDateToDateTime.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'OutputVariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionDateToDateTime."Variable ID"));

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionDateToDateTime."Date Value Type",
            ActionDateToDateTime."Date Value",
            ActionDateToDateTime."Date Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'DateText', LookupJObject);

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionDateToDateTime."Time Value Type",
            ActionDateToDateTime."Time Value",
            ActionDateToDateTime."Time Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'TimeText', LookupJObject);
    end;

    local procedure WriteMessage(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionMessage: Record "Action Message";
        LookupJObject: JsonObject;
    begin
        ActionMessage.GET(CaseID, ScriptID, ID);
        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionMessage."Value Type",
            ActionMessage.Value,
            ActionMessage."Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'MessageText', LookupJObject);
        AddJsonProperty(JObject, 'ThrowError', ActionMessage."Throw Error");
    end;

    local procedure WriteExtractDatePart(CaseID: Guid; ScriptID: Guid; ID: Guid; var JOject: JsonObject)
    var
        ActionExtractDatePart: Record "Action Extract Date Part";
        LookupJObject: JsonObject;
    begin
        ActionExtractDatePart.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JOject, 'OutputVariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionExtractDatePart."Variable ID"));

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionExtractDatePart."Value Type",
            ActionExtractDatePart.Value,
            ActionExtractDatePart."Lookup ID",
            LookupJObject);

        AddJsonProperty(JOject, 'DateLookup', LookupJObject);
        AddJsonProperty(JOject, 'PartText', Format(ActionExtractDatePart."Date Part"));
    end;

    local procedure WriteExtractDateTimePart(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionExtractDateTimePart: Record "Action Extract DateTime Part";
        LookupJObject: JsonObject;
    begin
        ActionExtractDateTimePart.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'OutputVariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionExtractDateTimePart."Variable ID"));

        WriteConstantOrLookup(
            CaseID,
            ScriptID,
            ActionExtractDateTimePart."Value Type",
            ActionExtractDateTimePart.Value,
            ActionExtractDateTimePart."Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'DateLookup', LookupJObject);
        AddJsonProperty(JObject, 'PartText', Format(ActionExtractDateTimePart."Part Type"));
    end;

    local procedure WriteLengthOfString(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionLengthOfString: Record "Action Length Of String";
        LookupJObject: JsonObject;
    begin
        ActionLengthOfString.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'OutputVariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionLengthOfString."Variable ID"));

        WriteConstantOrLookup(
            ActionLengthOfString."Case ID",
            ActionLengthOfString."Script ID",
            ActionLengthOfString."Value Type",
            ActionLengthOfString.Value,
            ActionLengthOfString."Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'LookupVariableName', LookupJObject);
    end;

    local procedure WriteConvertCase(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionConvertCase: Record "Action Convert Case";
        LookupJObject: JsonObject;
    begin
        ActionConvertCase.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'OutputVariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionConvertCase."Variable ID"));

        WriteConstantOrLookup(
            ActionConvertCase."Case ID",
            ActionConvertCase."Script ID",
            ActionConvertCase."Value Type",
            ActionConvertCase.Value,
            ActionConvertCase."Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'LookupVariableName', LookupJObject);
        AddJsonProperty(JObject, 'ConvertToCase', Format(ActionConvertCase."Convert To Case"));
    end;

    local procedure WriteRoundNumber(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionRoundNumber: Record "Action Round Number";
        LookupJObject: JsonObject;
    begin
        ActionRoundNumber.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'OutputVariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionRoundNumber."Variable ID"));

        WriteConstantOrLookup(
            ActionRoundNumber."Case ID",
            ActionRoundNumber."Script ID",
            ActionRoundNumber."Number Value Type",
            ActionRoundNumber."Number Value",
            ActionRoundNumber."Number Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'NumberLookupVariableName', LookupJObject);

        WriteConstantOrLookup(
            ActionRoundNumber."Case ID",
            ActionRoundNumber."Script ID",
            ActionRoundNumber."Precision Value Type",
            ActionRoundNumber."Precision Value",
            ActionRoundNumber."Precision Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'PrecisionLookupVariableName', LookupJObject);
        AddJsonProperty(JObject, 'Direction', Format(ActionRoundNumber.Direction));
    end;

    local procedure WriteComponentFormulaExpression(ID: Guid; var JObject: JsonObject)
    var
        TaxComponentFormula: Record "Tax Component Formula";
        JArray: JsonArray;
    begin
        TaxComponentFormula.Get(ID);
        AddJsonProperty(JObject, 'ComponentName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Component,
            TaxComponentFormula."Component ID"));

        AddJsonProperty(JObject, 'Expression', TaxComponentFormula.Expression);
        WriteComponentFormulaExprToken(TaxComponentFormula, JArray);
        AddJsonProperty(JObject, 'Token', JArray);
    end;

    local procedure WriteComponentFormulaExprToken(
            var TaxComponentFormula: Record "Tax Component Formula";
            var JArray: JsonArray)
    var
        TaxComponentFormulaToken: Record "Tax Component Formula Token";
        ExpressionsJObject: JsonObject;
        ComponentName: Text[30];
    begin
        TaxComponentFormulaToken.Reset();
        TaxComponentFormulaToken.SetRange("Tax Type", TaxComponentFormula."Tax Type");
        TaxComponentFormulaToken.SetRange("Formula Expr. ID", TaxComponentFormula.ID);
        if TaxComponentFormulaToken.FindSet() then
            repeat
                Clear(ExpressionsJObject);
                AddJsonProperty(ExpressionsJObject, 'TokenName', TaxComponentFormulaToken.Token);
                AddJsonProperty(ExpressionsJObject, 'ValueType', TaxComponentFormulaToken."Value Type");
                if TaxComponentFormulaToken."Value Type" = TaxComponentFormulaToken."Value Type"::Constant then
                    AddJsonProperty(ExpressionsJObject, 'Value', TaxComponentFormulaToken.Value)
                else begin
                    ComponentName := ScriptSymbolMgmt.GetSymbolName("Symbol Type"::Component, TaxComponentFormulaToken."Component ID");
                    AddJsonProperty(ExpressionsJObject, 'Value', ComponentName);
                end;
                JArray.Add(ExpressionsJObject);
            until TaxComponentFormulaToken.Next() = 0;
    end;

    local procedure WriteStringExpression(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionStringExpression: Record "Action String Expression";
        JArray: JsonArray;
    begin
        ActionStringExpression.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'OutputVariableName', ScriptSymbolMgmt.GetSymbolName(
            "Symbol Type"::Variable,
            ActionStringExpression."Variable ID"));

        AddJsonProperty(JObject, 'Expression', ActionStringExpression.Expression);
        WriteStringExprToken(ActionStringExpression, JArray);
        AddJsonProperty(JObject, 'Token', JArray);
    end;

    local procedure WriteStringExprToken(
        var ActionStringExpression: Record "Action String Expression";
        var JArray: JsonArray)
    var
        ActionStringExprToken: Record "Action String Expr. Token";
        LookupJObject: JsonObject;
        ExpressionsJObject: JsonObject;
    begin
        ActionStringExprToken.Reset();
        ActionStringExprToken.SetRange("Case ID", ActionStringExpression."Case ID");
        ActionStringExprToken.SetRange("Script ID", ActionStringExpression."Script ID");
        ActionStringExprToken.SetRange("String Expr. ID", ActionStringExpression.ID);
        if ActionStringExprToken.FindSet() then
            repeat
                Clear(ExpressionsJObject);
                AddJsonProperty(ExpressionsJObject, 'TokenName', ActionStringExprToken.Token);
                AddJsonProperty(ExpressionsJObject, 'FormatString', ActionStringExprToken."Format String");
                WriteConstantOrLookup(ActionStringExprToken."Case ID", ActionStringExprToken."Script ID", ActionStringExprToken."Value Type", ActionStringExprToken.Value, ActionStringExprToken."Lookup ID", LookupJObject);
                AddJsonProperty(ExpressionsJObject, 'LookupVariableName', LookupJObject);
                JArray.Add(ExpressionsJObject);
            until ActionStringExprToken.Next() = 0;
    end;

    local procedure WriteIfStatement(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionIfStatement: Record "Action If Statement";
        ConditionJObject: JsonObject;
        ElseIfJObject: JsonObject;
        BodyJArray: JsonArray;
    begin
        ActionIfStatement.GET(CaseID, ScriptID, ID);
        if not IsNullGuid(ActionIfStatement."Condition ID") then begin
            WriteCondition(CaseID, ScriptID, ActionIfStatement."Condition ID", ConditionJObject);
            AddJsonProperty(JObject, 'Condition', ConditionJObject);
        end;

        WriteActionContainer(
            ActionIfStatement."Case ID",
            ActionIfStatement."Script ID",
            ActionIfStatement.ID,
            "Container Action Type"::IFSTATEMENT,
            BodyJArray);
        AddJsonProperty(JObject, 'Body', BodyJArray);

        if not IsNullGuid(ActionIfStatement."Else If Block ID") then begin
            WriteIfStatement(CaseID, ScriptID, ActionIfStatement."Else If Block ID", ElseIfJObject);
            AddJsonProperty(JObject, 'ElseIf', ElseIfJObject);
        end;

    end;

    local procedure WriteLoopNTimes(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionLoopNTimes: Record "Action Loop N Times";
        LookupJObject: JsonObject;
        JArray: JsonArray;
    begin
        ActionLoopNTimes.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'IndexVariable', ScriptSymbolMgmt.GetSymbolName("Symbol Type"::Variable, ActionLoopNTimes."Index Variable"));
        WriteConstantOrLookup(
            ActionLoopNTimes."Case ID",
            ActionLoopNTimes."Script ID",
            ActionLoopNTimes."Value Type",
            ActionLoopNTimes.Value,
            ActionLoopNTimes."Lookup ID",
            LookupJObject);

        AddJsonProperty(JObject, 'NValue', LookupJObject);
        WriteActionContainer(
            ActionLoopNTimes."Case ID",
            ActionLoopNTimes."Script ID",
            ActionLoopNTimes.ID,
            "Container Action Type"::LOOPNTIMES,
            JArray);
        AddJsonProperty(JObject, 'Body', JArray);
    end;

    local procedure WriteLoopWithCondition(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionLoopWithCondition: Record "Action Loop With Condition";
        JArray: JsonArray;
        ConditionJObject: JsonObject;
    begin
        ActionLoopWithCondition.GET(CaseID, ScriptID, ID);
        WriteCondition(CaseID, ScriptID, ActionLoopWithCondition."Condition ID", ConditionJObject);
        AddJsonProperty(JObject, 'Condition', ConditionJObject);
        WriteActionContainer(
            ActionLoopWithCondition."Case ID",
            ActionLoopWithCondition."Script ID",
            ActionLoopWithCondition.ID,
            "Container Action Type"::LOOPWITHCONDITION,
            JArray);
        AddJsonProperty(JObject, 'Body', JArray);
    end;

    local procedure WriteLoopThroughRecords(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionLoopThroughRecords: Record "Action Loop Through Records";
        ActionLoopThroughRecField: Record "Action Loop Through Rec. Field";
        JArray: JsonArray;
        FieldJObject: JsonObject;
    begin
        ActionLoopThroughRecords.GET(CaseID, ScriptID, ID);
        AddJsonProperty(JObject, 'TableName', AppObjectHelper.GetObjectName(
            ObjectType::Table,
            ActionLoopThroughRecords."Table ID"));
        WriteLookupFieldFilter(CaseID, ActionLoopThroughRecords."Table Filter ID", JArray);
        AddJsonProperty(JObject, 'TableFilters', JArray);
        Clear(JArray);

        ActionLoopThroughRecField.Reset();
        ActionLoopThroughRecField.SetRange("Case ID", CaseID);
        ActionLoopThroughRecField.SetRange("Script ID", ScriptID);
        ActionLoopThroughRecField.SetRange("Loop ID", ID);
        if ActionLoopThroughRecField.FindSet() then
            repeat
                Clear(FieldJObject);
                AddJsonProperty(FieldJObject, 'FieldName', AppObjectHelper.GetFieldName(
                    ActionLoopThroughRecField."Table ID",
                    ActionLoopThroughRecField."Field ID"));
                AddJsonProperty(FieldJObject, 'VariableName', ScriptSymbolMgmt.GetSymbolName(
                    "Symbol Type"::Variable,
                    ActionLoopThroughRecField."Variable ID"));
                JArray.Add(FieldJObject);
            until ActionLoopThroughRecField.Next() = 0;

        AddJsonProperty(JObject, 'LoopThroughRecordFields', JArray);
        Clear(JArray);
        WriteActionContainer(
            ActionLoopThroughRecords."Case ID",
            ActionLoopThroughRecords."Script ID",
            ActionLoopThroughRecords.ID,
            "Container Action Type"::LOOPTHROUGHRECORDS,
            JArray);
        AddJsonProperty(JObject, 'Body', JArray);
    end;

    local procedure WriteScriptAction(
        CaseID: Guid;
        ScriptID: Guid;
        ActionType: Enum "Action Type";
        ActionID: Guid;
        var JObject: JsonObject)
    var
        ActionJObject: JsonObject;
        AcitionNames: List of [Text];
    begin
        AcitionNames := ActionType.Names();
        case ActionType of
            ActionType::IFSTATEMENT:
                WriteIfStatement(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::LOOPNTIMES:
                WriteLoopNTimes(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::LOOPWITHCONDITION:
                WriteLoopWithCondition(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::LOOPTHROUGHRECORDS:
                WriteLoopThroughRecords(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::DRAFTROW:
                AddJsonProperty(JObject, Format(ActionType), '');
            ActionType::COMMENT:
                WriteComment(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::NUMBERCALCULATION:
                WriteNumberCalculation(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::EXTRACTSUBSTRINGFROMPOSITION:
                WriteExtractSubstringFromPosition(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::FINDINTERVALBETWEENDATES:
                WriteFindDateInterval(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::SETVARIABLE:
                WriteSetVariable(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::CONCATENATE:
                WriteConcatenate(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::FINDSUBSTRINGINSTRING:
                WriteFindSubstring(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::REPLACESUBSTRINGINSTRING:
                WriteRepaceSubstring(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::EXTRACTSUBSTRINGFROMINDEXOFSTRING:
                WriteExtractSubstringFromIndex(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::DATECALCULATION:
                WriteDateCalculation(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::DATETODATETIME:
                WriteDateToDateTime(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::ALERTMESSAGE:
                WriteMessage(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::EXTRACTDATEPART:
                WriteExtractDatePart(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::EXTRACTDATETIMEPART:
                WriteExtractDateTimePart(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::LENGTHOFSTRING:
                WriteLengthOfString(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::CONVERTCASEOFSTRING:
                WriteConvertCase(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::ROUNDNUMBER:
                WriteRoundNumber(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::NUMERICEXPRESSION:
                WriteNumberExpression(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::STRINGEXPRESSION:
                WriteStringExpression(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::EXITLOOP:
                AddJsonProperty(JObject, Format(ActionType), '');
            ActionType::CONTINUE:
                AddJsonProperty(JObject, Format(ActionType), '');
        end;
        AddJsonProperty(JObject, 'ActivityType', Format(ActionType));
        AddJsonProperty(JObject, 'Activity', ActionJObject);
    end;

    local procedure WriteActionContainer(
        CaseID: Guid;
        ScriptID: Guid;
        ContainerActionID: Guid;
        ContainerType: Enum "Container Action Type";
        var JArray: JsonArray);
    var
        ActionContainer: Record "Action Container";
        ItemJObject: JsonObject;
        AcitivtyJObject: JsonObject;
        SkipRecord: Boolean;
    begin
        ActionContainer.Reset();
        ActionContainer.SetRange("Case ID", CaseID);
        ActionContainer.SetRange("Script ID", ScriptID);
        ActionContainer.SetRange("Container Type", ContainerType);
        ActionContainer.SetRange("Container Action ID", ContainerActionID);
        if ActionContainer.FindSet() then
            repeat
                SkipRecord := false;
                Clear(ItemJObject);
                Clear(AcitivtyJObject);

                if ActionContainer."Action Type" = "Action Type"::IFSTATEMENT then
                    if IsChildIfStatement(ActionContainer."Case ID", ActionContainer."Script ID", ActionContainer."Action ID") then
                        SkipRecord := true;

                if not SkipRecord then begin
                    WriteScriptAction(
                        ActionContainer."Case ID",
                        ActionContainer."Script ID",
                        ActionContainer."Action Type",
                        ActionContainer."Action ID",
                        ItemJObject);

                    JArray.Add(ItemJObject);
                end;
            until ActionContainer.Next() = 0;
    end;

    local procedure IsChildIfStatement(CaseID: Guid; ScriptID: Guid; ActionID: Guid): Boolean
    var
        ActionIfStatement: Record "Action If Statement";
    begin
        ActionIfStatement.Get(CaseID, ScriptID, ActionID);
        exit(not IsNullGuid(ActionIfStatement."Parent If Block ID"));
    end;

    local procedure WriteSingleInsertRecordField(InsertRecordField: Record "Tax Insert Record Field"; var JArray: JsonArray)
    var
        InsertRecFieldsJObject: JsonObject;
        LookupJObject: JsonObject;
    begin
        AddJsonProperty(InsertRecFieldsJObject, 'FieldName', AppObjectHelper.GetFieldName(
            InsertRecordField."Table ID",
            InsertRecordField."Field ID"));

        AddJsonProperty(InsertRecFieldsJObject, 'Sequence', InsertRecordField."Sequence No.");
        AddJsonProperty(InsertRecFieldsJObject, 'ReverseSign', InsertRecordField."Reverse Sign");
        WriteConstantOrLookup(
            InsertRecordField."Case ID",
            InsertRecordField."Script ID",
            InsertRecordField."Value Type",
            InsertRecordField.Value,
            InsertRecordField."Lookup ID",
            LookupJObject);

        AddJsonProperty(InsertRecFieldsJObject, 'Lookup', LookupJObject);
        JArray.Add(InsertRecFieldsJObject);
    end;

    local procedure WriteTaxPostingSetup(CaseID: Guid; var JArray: JsonArray)
    var
        TaxPostingSetup: Record "Tax Posting Setup";
    begin
        TaxPostingSetup.SetRange("Case ID", CaseID);
        if TaxPostingSetup.FindSet() then
            repeat
                WriteSingleTaxPostingSetup(TaxPostingSetup, JArray);
            until TaxPostingSetup.Next() = 0;
    end;

    local procedure WriteInsertRecord(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        InsertRecord: Record "Tax Insert Record";
        InsertRecordField: Record "Tax Insert Record Field";
        InsertJObject: JsonObject;
        InsertRecFieldsJArray: JsonArray;
    begin
        InsertRecord.GET(CaseID, ScriptID, ID);
        AddJsonProperty(InsertJObject, 'TableName', AppObjectHelper.GetObjectName(
            ObjectType::Table,
            InsertRecord."Table ID"));
        AddJsonProperty(InsertJObject, 'RunTrigger', InsertRecord."Run Trigger");
        AddJsonProperty(InsertJObject, 'SubLedgerGrpBy', InsertRecord."Sub Ledger Group By");

        InsertRecordField.Reset();
        InsertRecordField.SetRange("Case ID", CaseID);
        InsertRecordField.SetRange("Script ID", ScriptID);
        InsertRecordField.SetRange("Insert Record ID", ID);
        if InsertRecordField.FindSet() then
            repeat
                WriteSingleInsertRecordField(InsertRecordField, InsertRecFieldsJArray);
            until InsertRecordField.Next() = 0;
        AddJsonProperty(InsertJObject, 'InsertRecordFields', InsertRecFieldsJArray);
        JObject := InsertJObject;
    end;

    procedure InitTaxTypeProgressWindow()
    begin
        if not GuiAllowed() then
            exit;

        TaxTypeDialog.Open(
             ExportingLbl +
             ValueLbl +
             TaxTypeImportStageLbl);
    end;

    local procedure UpdateTaxTypeProgressWindow(TaxType: Code[20]; Stage: Text)
    begin
        if not GuiAllowed() then
            exit;
        TaxTypeDialog.Update(1, TaxTypesLbl);
        TaxTypeDialog.Update(2, TaxType);
        TaxTypeDialog.Update(3, Stage);
    end;

    local procedure CloseTaxTypeProgressWindow()
    begin
        if not GuiAllowed() then
            exit;
        TaxTypeDialog.close();
    end;

    procedure InitUseCaseProgressWindow()
    begin
        if not GuiAllowed() then
            exit;

        UseCaseDialog.Open(
             ExportingLbl +
             SpaceLbl +
             ValueLbl +
             SpaceLbl +
             UseCaseNameLbl +
             SpaceLbl +
             UseCaseImportStageLbl);
    end;

    local procedure UpdateUseCaseProgressWindow(Stage: Text)
    begin
        if not GuiAllowed() then
            exit;
        UseCaseDialog.Update(1, UseCasesLbl);
        UseCaseDialog.Update(2, GlobalUseCase."Tax Type");
        UseCaseDialog.Update(3, GlobalUseCase.Description);
        UseCaseDialog.Update(4, Stage);
    end;

    local procedure CloseUseCaseProgressWindow()
    begin
        if not GuiAllowed() then
            exit;
        UseCaseDialog.close();
    end;

    var
        GlobalUseCase: Record "Tax Use Case";
        UseCaseObjectHelper: Codeunit "Use Case Object Helper";
        ScriptSymbolMgmt: Codeunit "Script Symbols Mgmt.";
        AppObjectHelper: Codeunit "App Object Helper";
        TaxTypeDialog: Dialog;
        UseCaseDialog: Dialog;
        EmptyGuid: Guid;
        CalledFromCopyUseCase: Boolean;
        CanExportUseCases: Boolean;
        TaxTypesLbl: Label 'Tax Types';
        UseCasesLbl: Label 'Use Cases';
        SpaceLbl: Label '              #######\';
        ExportingLbl: Label 'Exporting              #1######\', Comment = 'Tax Type or Use Cases';
        ValueLbl: Label 'Tax Type              #2######\', Comment = 'Tax Type';
        UseCaseNameLbl: Label 'Name              #3######\', Comment = 'Use Case Description';
        TaxTypeImportStageLbl: Label 'Stage      #3######\', Comment = 'Stage of Import for Tax Type';
        UseCaseImportStageLbl: Label 'Stage      #4######\', Comment = 'Stage of Import for Use Case';
}