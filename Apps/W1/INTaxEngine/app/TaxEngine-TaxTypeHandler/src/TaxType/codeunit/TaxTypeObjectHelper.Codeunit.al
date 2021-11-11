codeunit 20232 "Tax Type Object Helper"
{
    procedure SearchTaxTypeTable(var TableID: Integer; var TableName: Text[30]; TaxType: Code[20]; IsTransactionTable: Boolean)
    var
        TaxEntity: Record "Tax Entity";
        TmpObjectID: Integer;
        IsInteger: Boolean;
    begin
        if TableName = '' then begin
            TableID := 0;
            Exit;
        end;

        IsInteger := Evaluate(TmpObjectID, TableName, 2);

        TaxEntity.Reset();
        TaxEntity.SetRange("Tax Type", TaxType);
        if IsTransactionTable then
            TaxEntity.SetRange("Entity Type", TaxEntity."Entity Type"::Transaction);
        if IsInteger then
            TaxEntity.SetRange("Table ID", TmpObjectID)
        else
            TaxEntity.SetFilter("Table Name", '%1', '@' + TableName + '*');

        if TaxEntity.FindFirst() then begin
            TableID := TaxEntity."Table ID";
            TableName := TaxEntity."Table Name";
        end else
            Error(InvalidTableNoErr, TableName);
    end;

    procedure SearchTaxOptionAttribute(TaxType: Code[20]; AttributeID: Integer; var AttributeValue: Text[250]);
    var
        TaxAttributeValue: Record "Tax Attribute Value";
        InvalidAttributeValueErr: Label 'You cannot enter ''%1'' in Attribute Value.', Comment = '%1 = Attribute Value';
    begin
        if AttributeID = 0 then
            Exit;

        if StrLen(AttributeValue) = 0 then
            exit;

        TaxAttributeValue.Reset();
        TaxAttributeValue.SetRange("Attribute ID", AttributeID);
        TaxAttributeValue.SetFilter(Value, '%1', '@' + AttributeValue + '*');

        if TaxAttributeValue.FindFirst() then
            AttributeValue := TaxAttributeValue.Value
        else
            Error(InvalidAttributeValueErr, AttributeValue);
    end;

    procedure OpenTaxTypeTableLookup(var TableID: Integer; var TableName: Text[30]; SearchText: Text; TaxType: Code[20]);
    var
        TaxEntity: Record "Tax Entity";
    begin
        TaxEntity.Reset();
        TaxEntity.SetRange("Tax Type", TaxType);
        if TableID <> 0 then begin
            TaxEntity."Table ID" := TableID;
            TaxEntity.Find('<>=');
        end else
            if SearchText <> '' then begin
                TaxEntity."Table Name" := CopyStr(SearchText, 1, 30);
                TaxEntity.Find('<>=');
            end;

        if Page.RunModal(Page::"Tax Entities", TaxEntity) = ACTION::LookupOK then begin
            TableID := TaxEntity."Table ID";
            TableName := TaxEntity."Table Name";
        end;
    end;

    procedure OpenTaxTypeTransactionTableLookup(var TableID: Integer; var TableName: Text[30]; SearchText: Text; TaxType: Code[20]);
    var
        TaxEntity: Record "Tax Entity";
    begin
        TaxEntity.Reset();
        TaxEntity.SetRange("Tax Type", TaxType);
        TaxEntity.SetRange("Entity Type", TaxEntity."Entity Type"::Transaction);
        if TableID <> 0 then begin
            TaxEntity."Table ID" := TableID;
            TaxEntity.Find('<>=');
        end else
            if SearchText <> '' then begin
                TaxEntity."Table Name" := CopyStr(SearchText, 1, 30);
                TaxEntity.Find('<>=');
            end;

        if Page.RunModal(Page::"Tax Entities", TaxEntity) = ACTION::LookupOK then begin
            TableID := TaxEntity."Table ID";
            TableName := TaxEntity."Table Name";
        end;
    end;

    procedure CreateComponentFormula(TaxTypeCode: Code[20]; ID: Integer): Guid;
    var
        TaxComponentFormula: Record "Tax Component Formula";
    begin
        TaxComponentFormula.Init();
        TaxComponentFormula."Tax Type" := TaxTypeCode;
        TaxComponentFormula.ID := CreateGuid();
        TaxComponentFormula."Component ID" := ID;
        TaxComponentFormula.Insert(true);

        exit(TaxComponentFormula.ID);
    end;

    procedure DeleteComponentFormula(ID: Guid);
    var
        TaxComponentFormula: Record "Tax Component Formula";
    begin
        TaxComponentFormula.Get(ID);
        TaxComponentFormula.Delete(true);
    end;

    procedure OpenComponentFormulaDialog(ID: Guid);
    var
        TaxComponentFormula: Record "Tax Component Formula";
        TaxComponentFormulaDialog: Page "Tax Component Formula Dialog";
    begin
        TaxComponentFormula.Get(ID);
        TaxComponentFormulaDialog.SetCurrentRecord(TaxComponentFormula);
        TaxComponentFormulaDialog.RunModal();
    end;

    procedure EnableSelectedTaxTypes(var TaxType: Record "Tax Type")
    begin
        if TaxType.FindSet() then
            repeat
                if TaxType.Status <> TaxType.Status::Released then
                    TaxType.Validate(Status, TaxType.Status::Released);

                TaxType.Validate(Enabled, true);
                TaxType.Modify(true);
            until TaxType.Next() = 0;
    end;

    procedure DisableSelectedTaxTypes(var TaxType: Record "Tax Type")
    begin
        if TaxType.FindSet() then
            repeat
                TaxType.Validate(Status, TaxType.Status::Draft);
                TaxType.Validate(Enabled, false);
                TaxType.Modify(true);
            until TaxType.Next() = 0;
    end;

    procedure GetFormulaValue(FromTransactionValue: Record "Tax Transaction Value"; SymbolID: Integer; FormulaID: Guid) Value: Decimal
    var
        TaxComponentFormula: Record "Tax Component Formula";
        TaxComponentFormulaToken: Record "Tax Component Formula Token";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        Values: Dictionary of [Text, Decimal];
        ValueVariant: Variant;
    begin
        if not TaxComponentFormula.Get(FormulaID) then
            exit;

        TaxComponentFormulaToken.Reset();
        TaxComponentFormulaToken.SetRange("Tax Type", TaxComponentFormula."Tax Type");
        TaxComponentFormulaToken.SetRange("Formula Expr. ID", FormulaID);
        if TaxComponentFormulaToken.FindSet() then
            repeat
                if TaxComponentFormulaToken."Value Type" = TaxComponentFormulaToken."Value Type"::Component then
                    ValueVariant := GetComponentAmount(FromTransactionValue."Tax Type", TaxComponentFormulaToken."Component ID", FromTransactionValue."Tax Record ID")
                else
                    ValueVariant := TaxComponentFormulaToken.Value;

                Values.Add(TaxComponentFormulaToken.Token, ValueVariant)
            until TaxComponentFormulaToken.Next() = 0;

        Value := ScriptDataTypeMgmt.EvaluateExpression(TaxComponentFormula.Expression, Values);
    end;

    local procedure GetComponentAmount(TaxType: Code[20]; ValueID: Integer; RecID: RecordId) Amount: Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxComponent: Record "Tax Component";
        TaxRateComputation: Codeunit "Tax Rate Computation";
    begin
        TaxTransactionValue.SetRange("Tax Record ID", RecID);
        TaxTransactionValue.SetRange("Tax Type", TaxType);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        TaxTransactionValue.SetRange("Value ID", ValueID);
        if TaxTransactionValue.FindFirst() then begin
            TaxComponent.Get(TaxType, ValueID);
            Amount := TaxRateComputation.RoundAmount(TaxTransactionValue.Amount, TaxComponent."Rounding Precision", TaxComponent.Direction);
        end;
    end;

    procedure GetComponentAmountFrmTransValue(TaxTransactionValue: Record "Tax Transaction Value"): Decimal
    var
        TaxComponent: Record "Tax Component";
        TaxRateComputation: Codeunit "Tax Rate Computation";
        ComponentAmt: Decimal;
    begin
        TaxComponent.Get(TaxTransactionValue."Tax Type", TaxTransactionValue."Value ID");
        if TaxComponent."Component Type" = TaxComponent."Component Type"::Formula then
            ComponentAmt := GetFormulaValue(TaxTransactionValue, TaxTransactionValue."Value ID", TaxComponent."Formula ID")
        else
            ComponentAmt := TaxTransactionValue.Amount;

        exit(TaxRateComputation.RoundAmount(ComponentAmt, TaxComponent."Rounding Precision", TaxComponent.Direction));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbol Store", 'OnEvaluateSymbolFormula', '', false, false)]
    local procedure OnEvaluateSymbolFormula(
        SymbolType: Enum "Symbol Type";
        SymbolID: Integer;
        sender: Codeunit "Script Symbol Store";
        FormulaID: Guid;
        var Symbols: Record "Script Symbol Value";
        var Value: Variant;
        var Handled: Boolean)
    var
        TaxComponentFormula: Record "Tax Component Formula";
        TaxComponentFormulaToken: Record "Tax Component Formula Token";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        Values: Dictionary of [Text, Decimal];
    begin
        if not TaxComponentFormula.Get(FormulaID) then
            exit;

        TaxComponentFormulaToken.Reset();
        TaxComponentFormulaToken.SetRange("Tax Type", TaxComponentFormula."Tax Type");
        TaxComponentFormulaToken.SetRange("Formula Expr. ID", FormulaID);
        if TaxComponentFormulaToken.FindSet() then
            repeat
                GetFormulaValue(Values, Symbols, sender, SymbolType, TaxComponentFormulaToken);
            until TaxComponentFormulaToken.Next() = 0;

        Value := ScriptDataTypeMgmt.EvaluateExpression(TaxComponentFormula.Expression, Values);
        Handled := true;
    end;

    local procedure GetFormulaValue(
        var Values: Dictionary of [Text, Decimal];
        var Symbols: Record "Script Symbol Value";
        var ScriptSymbolStore: Codeunit "Script Symbol Store";
        SymbolType: Enum "Symbol Type";
        TaxComponentFormulaToken: Record "Tax Component Formula Token")
    var
        ValueVariant: Variant;
    begin
        if TaxComponentFormulaToken."Value Type" = TaxComponentFormulaToken."Value Type"::Component then begin
            //This if block is needed as a component defined on formula may not be used in use case.
            if Symbols.Get(SymbolType, TaxComponentFormulaToken."Component ID") then
                ScriptSymbolStore.GetSymbolValue(Symbols, ValueVariant)
            else
                ValueVariant := 0;
        end else
            ValueVariant := TaxComponentFormulaToken.Value;

        Values.Add(TaxComponentFormulaToken.Token, ValueVariant)
    end;

    [EventSubscriber(ObjectType::Page, Page::"Script Symbol Lookup Dialog", 'OnValidateLookupTableName', '', false, false)]
    local procedure OnValidateLookupTableName(CaseID: Guid; ScriptID: Guid; var TableID: Integer; var TableName: Text[30]; IsTransactionTable: Boolean)
    var
        TaxUseCase: Record "Tax Use Case";
    begin
        TaxUseCase.SetRange(id, CaseID);
        TaxUseCase.FindFirst();
        SearchTaxTypeTable(TableID, TableName, TaxUseCase."Tax Type", IsTransactionTable);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Script Symbol Lookup Dialog", 'OnLookupLookupTableName', '', false, false)]
    local procedure OnLookupLookupTableName(CaseID: Guid; ScriptID: Guid; var TableID: Integer; var TableName: Text[30]; SearchText: Text)
    var
        TaxUseCase: Record "Tax Use Case";
    begin
        TaxUseCase.SetRange(id, CaseID);
        TaxUseCase.FindFirst();
        OpenTaxTypeTableLookup(TableID, TableName, SearchText, TaxUseCase."Tax Type");
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeValidateIfUpdateIsAllowed(TaxType: Code[20])
    begin
    end;

    var
        InvalidTableNoErr: Label 'You cannot enter ''%1'' in TableNo.', Comment = '%1, Table No. or Table Name';
}