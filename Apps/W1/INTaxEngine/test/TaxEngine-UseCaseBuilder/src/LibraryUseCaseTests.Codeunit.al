codeunit 136869 "Library - Use Case Tests"
{
    EventSubscriberInstance = Manual;

    procedure CreateTableFilters(var CaseID: Guid; var TableFilterID: Guid; TableID: Integer)
    var
        LookupEntityMgmt: Codeunit "Lookup Entity Mgmt.";
        EmptyGuid: Guid;
    begin
        Init(CaseID);
        TableFilterID := LookupEntityMgmt.CreateTableFilters(CaseID, EmptyGuid, TableID);
    end;

    procedure AddLookupFieldFilter(CaseID: Guid; TableFilterID: Guid; TableID: Integer; FieldID: Integer; Value: Text[250])
    var
        LookupFieldFilter: Record "Lookup Field Filter";
    begin
        LookupFieldFilter."Case ID" := CaseID;
        LookupFieldFilter."Table Filter ID" := TableFilterID;
        LookupFieldFilter."Table ID" := TableID;
        LookupFieldFilter."Field ID" := FieldID;
        LookupFieldFilter."Value Type" := LookupFieldFilter."Value Type"::Constant;
        LookupFieldFilter.Value := Value;
        LookupFieldFilter.Insert();
    end;

    procedure CreateTableRelation(var CaseID: Guid; var TableRelationID: Guid; TableFilterID: Guid; TableID: Integer)
    var
        TaxTableRelation: Record "Tax Table Relation";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
    begin
        Init(CaseID);
        TableRelationID := UseCaseEntityMgmt.CreateTableRelation(CaseID);
        TaxTableRelation.Get(CaseID, TableRelationID);
        TaxTableRelation."Source ID" := TableID;
        TaxTableRelation."Table Filter ID" := TableFilterID;
        TaxTableRelation.Modify();
    end;

    procedure CreateComponentExpression(var CaseID: Guid; var ComponentExpressionID: Guid; ComponentID: Integer)
    var
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
    begin
        Init(CaseID);
        ComponentExpressionID := UseCaseEntityMgmt.CreateComponentExpression(CaseID, ComponentID);
    end;

    procedure AddComponentExpressionToken(var CaseID: Guid; ComponentExpressionID: Guid; Token: Text[250]; LookupID: Guid)
    var
        TaxComponentExprToken: Record "Tax Component Expr. Token";
    begin
        TaxComponentExprToken.Init();
        TaxComponentExprToken."Case ID" := CaseID;
        TaxComponentExprToken."Component Expr. ID" := ComponentExpressionID;
        TaxComponentExprToken.Token := Token;
        TaxComponentExprToken."Value Type" := TaxComponentExprToken."Value Type"::Lookup;
        TaxComponentExprToken."Lookup ID" := LookupID;
        TaxComponentExprToken.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbol Store", 'OnInitSymbols', '', false, false)]
    local procedure OnInitSymbols(
        CaseID: Guid;
        ScriptID: Guid;
        var Symbols: Record "Script Symbol Value" Temporary;
        var sender: Codeunit "Script Symbol Store")
    begin
        sender.InsertSymbolValue("Symbol Type"::Component, "Symbol Data Type"::NUMBER, 1);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbols Mgmt.", 'OnGetTaxType', '', false, false)]
    procedure OnGetTaxType(CaseID: Guid; var TaxType: Code[20]; var Handled: Boolean)
    begin
        TaxType := 'XGST';
        Handled := true;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbols Mgmt.", 'OnInitScriptSymbols', '', false, false)]
    procedure OnInitScriptSymbols(TaxType: Code[20]; CaseID: Guid; ScriptID: Guid; var Symbols: Record "Script Symbol" temporary; sender: Codeunit "Script Symbols Mgmt.");
    begin
        sender.InsertScriptSymbol("Symbol Type"::Component, 1, 'XGST', "Symbol Data Type"::NUMBER);
    end;

    procedure Init(var CaseID: Guid)
    var
        UseCase: Record "Tax Use Case";
    begin
        if not Initilized then begin
            GlobalCaseID := CreateGuid();

            UseCase.Init();
            UseCase."Tax Type" := 'XGST';
            UseCase.Description := 'Test Use Case Description';
            UseCase.ID := GlobalCaseID;
            UseCase.Insert();

            Initilized := true;
        end;

        CaseID := GlobalCaseID;
    end;

    procedure CreateUseCase(TaxTypCode: Code[20]; CaseID: Guid; SourceTableID: Integer; Desc: Text[2000]; ConditionID: Guid)
    var
        TaxUseCase: Record "Tax Use Case";
    begin
        if TaxUseCase.Get(CaseID) then
            exit;

        TaxUseCase.Init();
        TaxUseCase.Validate("Tax Type", TaxTypCode);
        TaxUseCase.Validate(ID, CaseID);
        TaxUseCase.Validate(Description, Desc);
        TaxUseCase.Validate("Tax Table ID", SourceTableID);
        TaxUseCase.Validate("Condition ID", ConditionID);
        TaxUseCase.Insert(true);
    end;

    procedure CreateTransactionValue(CaseID: Guid; ID: Integer; ValueType: Enum "Transaction Value Type"; Value: Text[2000]; Amount: Decimal; Percent: Decimal; RecId: RecordId; TaxTypeCode: Code[20])
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.Init();
        TaxTransactionValue.Validate("Case ID", CaseID);
        TaxTransactionValue.Validate("Tax Type", TaxTypeCode);
        TaxTransactionValue.Validate("Tax Record ID", RecId);
        TaxTransactionValue.Validate("Value ID", ID);
        TaxTransactionValue.Validate("Value Type", ValueType);
        TaxTransactionValue.Validate("Column Value", Value);
        TaxTransactionValue.Validate(Amount, Amount);
        TaxTransactionValue.Validate("Amount (LCY)", Amount);
        TaxTransactionValue.Validate(Percent, Percent);
        TaxTransactionValue.Insert(true);
    end;

    procedure CreateAttributeMapping(TaxTypeCode: Code[20]; CaseID: Guid; AttributeID: Integer)
    var
        UseCaseAttributeMapping: Record "Use Case Attribute Mapping";
    begin
        UseCaseAttributeMapping.Init();
        UseCaseAttributeMapping.Validate("Tax Type", TaxTypeCode);
        UseCaseAttributeMapping.Validate("Case ID", CaseID);
        UseCaseAttributeMapping.Validate("Attribtue ID", AttributeID);
        UseCaseAttributeMapping.Insert(true);
    end;

    var
        GlobalCaseID: Guid;
        Initilized: Boolean;
}