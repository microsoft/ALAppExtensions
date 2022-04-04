codeunit 20361 "Tax Json Deserialization"
{
    procedure SetCanImportUseCases(NewCanImportUseCases: Boolean)
    begin
        CanImportUseCases := NewCanImportUseCases;
    end;

    procedure SetGlobalCaseID(NewGlobalCaseId: Guid)
    begin
        GlobalCaseId := NewGlobalCaseId;
    end;

    procedure GetCreatedCaseID(): Guid
    begin
        exit(GlobalUseCase.ID);
    end;

    procedure HideDialog(NewHideDialog: Boolean)
    begin
        GlobalHideDialog := NewHideDialog;
    end;

    procedure SkipVersionCheck(SkipVersionCheck: Boolean)
    begin
        GlobalSkipVersionCheck := SkipVersionCheck;
    end;

    procedure SkipUseCaseIndentation(SkipIndentation: Boolean)
    begin
        GlobalSkipIndentation := SkipIndentation;
    end;

    procedure ImportTaxTypes(JsonText: Text)
    var
        JArray: JsonArray;
    begin
        JArray.ReadFrom(JsonText);
        InitTaxTypeProgressWindow();
        ReadTaxTypes(JArray);
        CloseTaxTypeProgressWindow();
        if not GlobalHideDialog then
            Message('Tax Type(s) Imported.');
    end;

    procedure ImportUseCases(JsonText: Text)
    var
        TaxUseCaseJArray: JsonArray;
        PresentationOrder: Integer;
    begin
        TaxUseCaseJArray.ReadFrom(JsonText);
        InitUseCaseProgressWindow();
        ReadUseCases(TaxUseCaseJArray);
        if not GlobalSkipIndentation then
            UseCaseMgmt.IndentUseCases(EmptyGuid, PresentationOrder);
        CloseUseCaseProgressWindow();
    end;

    local procedure ReadTaxAccountingPeriod(JObject: JsonObject; var AccountingPeriodCode: Text[10])
    var
        TaxAccPeriodSetup: Record "Tax Acc. Period Setup";
        JToken: JsonToken;
        property: Text;
    begin
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'AccountingPeriodCode':
                    if not TaxAccPeriodSetup.Get(JToken2Text10(JToken)) then begin
                        TaxAccPeriodSetup.Init();
                        TaxAccPeriodSetup.Code := JToken2Text10(JToken);
                        TaxAccPeriodSetup.Insert();
                    end;
                'AccountingPeriodDesc':
                    TaxAccPeriodSetup.Description := JToken2Text50(JToken);
            end;
        end;
        TaxAccPeriodSetup.Modify();
        AccountingPeriodCode := TaxAccPeriodSetup.Code;
    end;

    local procedure ReadTaxTypeEntity(TaxType: Code[20]; JObject: JsonObject)
    var
        TaxEntity: Record "Tax Entity";
        JToken: JsonToken;
        property: Text;
        TableID: Integer;
    begin
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'TableName':
                    begin
                        TableID := AppObjectHelper.GetObjectID(ObjectType::Table, JToken2Text30(JToken));
                        if not TaxEntity.Get(TableID, TaxType) then begin
                            TaxEntity.Init();
                            TaxEntity."Tax Type" := TaxType;
                            TaxEntity."Table ID" := TableID;
                            TaxEntity."Table Name" := AppObjectHelper.GetObjectName(ObjectType::Table, TaxEntity."Table ID");
                            TaxEntity.Insert();
                        end;
                    end;
                'Type':
                    TaxEntity."Entity Type" := ScriptDataTypeMgmt.GetFieldOptionIndex(
                        Database::"Tax Entity",
                        TaxEntity.FieldNo("Entity Type"),
                        JToken2Text(JToken));
            end;
        end;
        TaxEntity.Modify();
    end;

    local procedure ReadTaxAttributes(JObject: JsonObject)
    var
        TaxAttribute: Record "Tax Attribute";
        JToken: JsonToken;
        AttributeID: Integer;
        property: Text;
    begin
        AttributeID := GetIntPropertyValue(JObject, 'ID');
        TaxAttribute.Init();
        if AttributeID <> 0 then
            TaxAttribute.ID := AttributeID;

        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'TaxType':
                    if not TaxAttribute.Get(JToken2Text20(JToken), AttributeID) then begin
                        TaxAttribute."Tax Type" := JToken2Text20(JToken);
                        TaxAttribute.ID := AttributeID;
                        TaxAttribute.Insert()
                    end;
                'Name':
                    TaxAttribute.Name := JToken2Text30(JToken);
                'Type':
                    TaxAttribute.Type := ScriptDataTypeMgmt.GetFieldOptionIndex(
                        Database::"Tax Attribute",
                        TaxAttribute.FieldNo(Type),
                        JToken2Text(JToken));
                'LookupTable':
                    TaxAttribute."Refrence Table ID" := AppObjectHelper.GetObjectID(ObjectType::Table, JToken2Text30(JToken));
                'LookupField':
                    TaxAttribute."Refrence Field ID" := AppObjectHelper.GetFieldID(
                        TaxAttribute."Refrence Table ID",
                        JToken2Text30(JToken));
                'LookupPage':
                    TaxAttribute."Lookup Page ID" := AppObjectHelper.GetObjectID(ObjectType::Page, JToken2Text30(JToken));
                'VisibleOnInterface':
                    TaxAttribute."Visible on Interface" := JToken.AsValue().AsBoolean();
                'GroupedInSubLedger':
                    TaxAttribute."Grouped In SubLedger" := JToken.AsValue().AsBoolean();
                'EntityMapping':
                    ReadEntityAttributeMapping(TaxAttribute.ID, JToken.AsArray());
            end;
        end;
        TaxAttribute.Validate("Refrence Field ID");
        TaxAttribute.Modify();
    end;

    local procedure ReadTaxTypeComponent(TaxType: Code[20]; JObject: JsonObject)
    var
        TaxComponent: Record "Tax Component";
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
        JToken: JsonToken;
        property: Text;
        ComponentID: Integer;
    begin
        ComponentID := GetIntPropertyValue(JObject, 'ID');
        if ComponentID = 0 then
            ComponentID := GetComponentID(TaxType);

        if not TaxComponent.Get(TaxType, ComponentID) then begin
            TaxComponent.Init();
            TaxComponent."Tax Type" := TaxType;
            TaxComponent.ID := ComponentID;
            TaxComponent.Name := GetText30PropertyValue(JObject, 'Name');
            TaxComponent.Type := TaxComponent.Type::Decimal;
            TaxComponent.Insert();
        end;

        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'ID', 'Name', 'Type':
                    ;
                'RoundingPrecision':
                    begin
                        TaxComponent."Rounding Precision" := JToken.AsValue().AsDecimal();
                        TaxComponent.Modify();
                    end;
                'VisibleOnInterface':
                    begin
                        TaxComponent."Visible On Interface" := JToken.AsValue().AsBoolean();
                        TaxComponent.Modify();
                    end;
                'Direction':
                    begin
                        TaxComponent.Type := ScriptDataTypeMgmt.GetFieldOptionIndex(
                            Database::"Tax Component",
                            TaxComponent.FieldNo(Direction),
                            JToken2Text(JToken));
                        TaxComponent.Modify();
                    end;
                'SkipPosting':
                    begin
                        TaxComponent."Skip Posting" := JToken.AsValue().AsBoolean();
                        TaxComponent.Modify();
                    end;
                'ComponentType':
                    begin
                        TaxComponent."Component Type" := ScriptDataTypeMgmt.GetFieldOptionIndex(Database::"Tax Component", TaxComponent.FieldNo("Component Type"), JToken.AsValue().AsText());
                        TaxComponent.Modify();
                    end;
                'Formula':
                    begin
                        TaxComponent."Formula ID" := TaxTypeObjectHelper.CreateComponentFormula(TaxType, TaxComponent.ID);
                        TaxComponent.Modify();
                        ReadComponentFormulaExpression(TaxType, TaxComponent."Formula ID", JToken.AsObject());
                    end;
            end;
        end;
        TaxComponent.Type := TaxComponent.Type::Decimal;
        TaxComponent.Modify();
    end;

    local procedure ReadEntityAttributeMapping(AttributeID: Integer; JObject: JsonObject)
    var
        EntityAttributeMapping: Record "Entity Attribute Mapping";
        EntityAttributeMapping2: Record "Entity Attribute Mapping";
        JToken: JsonToken;
        property: Text;
    begin
        EntityAttributeMapping.Init();
        EntityAttributeMapping."Attribute ID" := AttributeID;

        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'Entity':
                    begin
                        EntityAttributeMapping."Entity ID" := AppObjectHelper.GetObjectID(
                            ObjectType::Table,
                            JToken2Text30(JToken));
                        EntityAttributeMapping."Entity Name" :=
                            AppObjectHelper.GetObjectName(ObjectType::Table, EntityAttributeMapping."Entity ID");
                    end;
                'MappingField':
                    begin
                        EntityAttributeMapping."Mapping Field ID" := AppObjectHelper.GetFieldID(
                            EntityAttributeMapping."Entity ID",
                            JToken2Text30(JToken));
                        EntityAttributeMapping."Mapping Field Name" := AppObjectHelper.GetFieldName(
                            EntityAttributeMapping."Entity ID",
                            EntityAttributeMapping."Mapping Field ID");
                    end;
            end;
        end;
        EntityAttributeMapping2.SetRange("Attribute ID", EntityAttributeMapping."Attribute ID");
        EntityAttributeMapping2.SetRange("Entity ID", EntityAttributeMapping."Entity ID");
        EntityAttributeMapping2.SetRange("Mapping Field ID", EntityAttributeMapping."Mapping Field ID");
        if EntityAttributeMapping2.IsEmpty() then
            EntityAttributeMapping.Insert(true);
    end;

    local procedure ReadTaxRateColumnSetup(TaxType: Code[20]; JObject: JsonObject)
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        ColumnID: Integer;
        JToken: JsonToken;
        Property: Text;
    begin
        ColumnID := GetIntPropertyValue(JObject, 'ID');
        if not TaxRateColumnSetup.Get(TaxType, ColumnID) then begin
            TaxRateColumnSetup.Init();
            TaxRateColumnSetup."Tax Type" := TaxType;
            TaxRateColumnSetup."Column ID" := ColumnID;
            TaxRateColumnSetup.Insert();
        end;

        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'Sequence':
                    TaxRateColumnSetup.Sequence := JToken.AsValue().AsInteger();
                'ColumnName':
                    TaxRateColumnSetup."Column Name" := JToken2Text30(JToken);
                'ColumnType':
                    TaxRateColumnSetup."Column Type" := "Column Type".FromInteger(ScriptDataTypeMgmt.GetFieldOptionIndex(
                        Database::"Tax Rate Column Setup",
                        TaxRateColumnSetup.FieldNo("Column Type"),
                        JToken2Text(JToken)));
                'VisibleOnInterface':
                    TaxRateColumnSetup."Visible On Interface" := JToken.AsValue().AsBoolean();
                'Type':
                    TaxRateColumnSetup.Type := ScriptDataTypeMgmt.GetFieldOptionIndex(
                        Database::"Tax Rate Column Setup",
                        TaxRateColumnSetup.FieldNo(Type),
                        JToken2Text(JToken));
                'LinkedAttributeName':
                    TaxRateColumnSetup."Linked Attribute ID" := GetAttributeID(TaxRateColumnSetup."Tax Type", JToken2Text30(JToken));
                'AllowBlank':
                    TaxRateColumnSetup."Allow Blank" := JToken.AsValue().AsBoolean();
            end;
        end;

        if TaxRateColumnSetup."Column Type" = TaxRateColumnSetup."Column Type"::"Tax Attributes" then
            TaxRateColumnSetup."Attribute ID" := GetAttributeID(TaxRateColumnSetup."Tax Type", TaxRateColumnSetup."Column Name");
        if TaxRateColumnSetup."Column Type" = TaxRateColumnSetup."Column Type"::Component then
            TaxRateColumnSetup."Attribute ID" := GetComponentID(TaxRateColumnSetup."Tax Type", TaxRateColumnSetup."Column Name");

        TaxRateColumnSetup.modify();
    end;

    local procedure ReadTaxEntities(TaxType: Code[20]; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadTaxTypeEntity(TaxType, JToken.AsObject());
    end;

    local procedure ReadTaxAttributes(JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadTaxAttributes(JToken.AsObject());
    end;

    local procedure ReadTaxRateColumnSetup(TaxType: Code[20]; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadTaxRateColumnSetup(TaxType, JToken.AsObject());
    end;

    local procedure ReadLoopThroughRecordFields(
        ActionLoopThroughRecords: Record "Action Loop Through Records";
        JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadLoopThroughRecordsField(ActionLoopThroughRecords, JToken.AsObject());
    end;

    local procedure ReadTaxComponents(TaxType: Code[20]; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadTaxTypeComponent(TaxType, JToken.AsObject());
    end;

    local procedure ReadEntityAttributeMapping(AttributeID: Integer; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadEntityAttributeMapping(AttributeID, JToken.AsObject());
    end;

    local procedure ReadTaxTypes(JArray: JsonArray)
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadTaxType(JToken.AsObject());
    end;

    local procedure ReadTaxType(JObject: JsonObject)
    var
        TaxType: record "Tax Type";
        TaxTypeArchivalLogEntry: Record "Tax Type Archival Log Entry";
        TaxJsonSingleInstance: Codeunit "Tax Json Single Instance";
        JToken: JsonToken;
        JArray: JsonArray;
        UpgradedTaxType: Boolean;
        MajorVersion: Integer;
        MinorVersion: Integer;
        OldMajorVersion: Integer;
        OldMinorVersion: Integer;
        TaxTypeCode: Code[20];
        property: Text;
        JsonText: Text;
    begin
        JObject.Get('Code', JToken);
        TaxTypeCode := JToken2Text20(JToken);
        MajorVersion := GetIntPropertyValue(JObject, 'Version');
        MinorVersion := GetIntPropertyValue(JObject, 'MinorVersion');

        if not TaxType.Get(TaxTypeCode) then begin
            TaxType.Init();
            TaxType.Code := TaxTypeCode;
            TaxType.Insert();
        end else begin
            OldMajorVersion := TaxType."Major Version";
            OldMinorVersion := TaxType."Minor Version";

            if GlobalSkipVersionCheck then begin
                if (OldMajorVersion = MajorVersion) and (OldMinorVersion = MinorVersion) then
                    exit;

                TaxTypeArchivalLogEntry.SetRange("Tax Type", TaxTypeCode);
                TaxTypeArchivalLogEntry.SetRange("Major Version", MajorVersion);
                TaxTypeArchivalLogEntry.SetRange("Minor Version", MinorVersion);
                if not TaxTypeArchivalLogEntry.IsEmpty() then
                    exit;

                if OldMinorVersion <> 0 then
                    TaxJsonSingleInstance.UpdateReplacedTaxType(TaxType);
                TaxType.Validate(Status, TaxType.Status::Draft);
            end else begin
                MajorVersion := TaxType."Major Version";

                if TaxType.Status = TaxType.Status::Draft then
                    MinorVersion := TaxType."Minor Version"
                else begin
                    TaxType.Validate(Status, TaxType.Status::Draft);
                    MinorVersion := TaxType."Minor Version";
                end;
            end;
            UpgradedTaxType := true;
        end;

        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'TaxTypeDescription':
                    TaxType.Description := CopyStr(JToken2Text(JToken), 1, 100);
                'AccountingPeriod':
                    ReadTaxAccountingPeriod(JToken.AsObject(), TaxType."Accounting Period");
                'ChangedBy':
                    TaxType."Changed By" := JToken2Text80(JToken);
                'Enable':
                    begin
                        TaxType.Enabled := JToken.AsValue().AsBoolean();
                        TaxType.Modify();
                    end;
                'TaxEntities':
                    begin
                        UpdateTaxTypeProgressWindow(TaxType.Code, 'Tax Entities');
                        ReadTaxEntities(TaxType.Code, JToken.AsArray());
                    end;
                'Attributes':
                    begin
                        UpdateTaxTypeProgressWindow(TaxType.Code, 'Tax Attributes');
                        ReadTaxAttributes(JToken.AsArray());
                    end;
                'Components':
                    begin
                        UpdateTaxTypeProgressWindow(TaxType.Code, 'Tax Components');
                        ReadTaxComponents(TaxType.Code, JToken.AsArray());
                    end;
                'TaxRateColumnSetup':
                    begin
                        UpdateTaxTypeProgressWindow(TaxType.Code, 'Rate Setup');
                        ReadTaxRateColumnSetup(TaxType.Code, JToken.AsArray());
                        UpdateTaxRateKeys(TaxType.Code);
                    end;
                'UseCases':
                    if CanImportUseCases then begin
                        UpdateTaxTypeProgressWindow(TaxType.Code, 'Use Cases');
                        JArray := JToken.AsArray();
                        JArray.WriteTo(JsonText);
                        ImportUseCases(JsonText);
                    end;
            end;
        end;
        TaxType."Major Version" := MajorVersion;
        TaxType."Minor Version" := MinorVersion;
        TaxType.Status := TaxType.Status::Released;
        TaxType."Effective From" := CurrentDateTime();
        TaxType.Modify();

        if UpgradedTaxType then
            LogTaxTypeUpgradeTelemetry(TaxType.Code, GetVersionText(TaxType."Major Version", TaxType."Minor Version"))
        else
            LogTaxTypeImportTelemetry(TaxType.Code, GetVersionText(TaxType."Major Version", TaxType."Minor Version"));
    end;

    local procedure UpdateTaxRateKeys(TaxType: Code[20])
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        TaxRateColumnSetup.SetRange("Tax Type", TaxType);
        if TaxRateColumnSetup.FindFirst() then
            TaxRateColumnSetup.UpdateTransactionKeys();
    end;

    local procedure ReadUseCases(JArray: JsonArray) JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadUseCase(JToken.AsObject());
    end;

    local procedure ReadInsertRecordField(InsertRecord: Record "Tax Insert Record"; JArray: JsonArray) JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadInsertRecordField(InsertRecord, JToken.AsObject());
    end;

    local procedure ReadConcatenateLines(ActionConcatenate: Record "Action Concatenate"; JArray: JsonArray) JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadConcatenateLine(ActionConcatenate, JToken.AsObject());
    end;

    local procedure ReadUseCase(JObject: JsonObject)
    var
        UseCase: Record "Tax Use Case";
        UseCaseArchivalLog: Record "Use Case Archival Log Entry";
        TaxJsonSingleInstance: Codeunit "Tax Json Single Instance";
        TaxType: Code[20];
        UseCaseID: Guid;
        Description: Text[250];
        property: Text;
        JToken: JsonToken;
        UpgradedUseCase: Boolean;
        MajorVersion: Integer;
        MinorVersion: Integer;
        OldMajorVersion: Integer;
        OldMinorVersion: Integer;
    begin
        UseCaseID := GetGuidPropertyValue(JObject, 'CaseID');
        TaxType := GetCode20PropertyValue(JObject, 'TaxType');
        Description := GetText250PropertyValue(JObject, 'Description');
        MajorVersion := GetIntPropertyValue(JObject, 'Version');
        MinorVersion := GetIntPropertyValue(JObject, 'MinorVersion');

        if not IsNullGuid(UseCaseID) then begin
            if UseCase.Get(UseCaseID) then begin
                OldMajorVersion := UseCase."Major Version";
                OldMinorVersion := UseCase."Minor Version";

                if GlobalSkipVersionCheck then begin
                    if (OldMajorVersion = MajorVersion) and (OldMinorVersion = MinorVersion) then
                        exit;

                    UseCaseArchivalLog.SetRange("Case ID", UseCaseID);
                    UseCaseArchivalLog.SetRange("Major Version", MajorVersion);
                    UseCaseArchivalLog.SetRange("Minor Version", MinorVersion);
                    if not UseCaseArchivalLog.IsEmpty() then
                        exit;

                    if OldMinorVersion <> 0 then
                        TaxJsonSingleInstance.UpdateReplacedUseCase(UseCase);
                    UseCase.Validate(Status, UseCase.Status::Draft);
                end else begin
                    MajorVersion := UseCase."Major Version";

                    if UseCase.Status = UseCase.Status::Draft then
                        MinorVersion := UseCase."Minor Version"
                    else begin
                        UseCase.Validate(Status, UseCase.Status::Draft);
                        MinorVersion := UseCase."Minor Version";
                    end;
                end;

                UseCase.Modify();
                UseCase.SkipTreeOnDelete(true); //This will ensure that tree is not cleared at the time of usecase upgrade

                UseCase.Delete(true);
                UpgradedUseCase := true;
            end;
        end else
            UseCaseID := CreateGuid();

        UseCase.Init();
        UseCase.ID := UseCaseID;
        UseCase."Tax Type" := TaxType;
        UseCase.Description := Description;
        UpdateUseCaseProgressWindow('Preperation');
        UseCase."Major Version" := MajorVersion;
        UseCase."Minor Version" := MinorVersion;
        UseCase."Computation Script ID" := JsonEntityMgmt.CreateScriptContext(UseCase.ID);
        UseCase."Posting Script ID" := JsonEntityMgmt.CreateScriptContext(UseCase.ID);
        UseCase.Insert();

        GlobalUseCase := UseCase;
        GlobalCaseId := UseCase.ID;

        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'TaxType', 'CaseID', 'Description', 'Version', 'MinorVersion':
                    ;
                'Components', 'ComputationVariables', 'ComputationScript',
                'PostingVariables', 'PostingScript', 'TaxPostingSetup':
                    ;
                'ChangedBy':
                    UseCase."Changed By" := JToken2Text80(JToken);
                'Code':
                    UseCase.Code := JToken2Text20(JToken);
                'ParentUseCase':
                    ;
                'ParentCaseId':
                    begin
                        UpdateUseCaseProgressWindow('Updating Parent Use Case ID');
                        UseCase."Parent Use Case ID" := JToken.AsValue().AsText();
                        GlobalUseCase := UseCase;
                        UseCase.Modify();
                    end;
                'PresentationOrder':
                    UseCase."Presentation Order" := JToken.AsValue().AsInteger();
                'Indent':
                    UseCase."Indentation Level" := JToken.AsValue().AsInteger();
                'TaxEntity':
                    begin
                        UseCase."Tax Table ID" := AppObjectHelper.GetObjectID(ObjectType::Table, JToken2Text30(JToken));
                        GlobalUseCase := UseCase;
                        UseCase.Modify();
                    end;
                'PostingTableName':
                    begin
                        UseCase."Posting Table ID" := AppObjectHelper.GetObjectID(ObjectType::Table, JToken2Text30(JToken));
                        GlobalUseCase := UseCase;
                        UseCase.Modify();
                    end;
                'PostingTableFilters':
                    begin
                        UpdateUseCaseProgressWindow('Updating Posting Table Filters');
                        UseCase."Posting Table Filter ID" := JsonEntityMgmt.CreateTableFilters(
                            UseCase.ID,
                            EmptyGuid,
                            UseCase."Posting Table ID");
                        UseCase.Modify();
                        ReadTableFilters(UseCase.ID, EmptyGuid, UseCase."Posting Table Filter ID", JToken.AsArray());
                    end;
                'Condition':
                    begin
                        UpdateUseCaseProgressWindow('Preconditions');
                        UseCase."Condition ID" := JsonEntityMgmt.CreateCondition(UseCase.ID, EmptyGuid);
                        ReadCondition(UseCase.ID, EmptyGuid, UseCase."Condition ID", JToken.AsObject());
                        GlobalUseCase := UseCase;
                        UseCase.Modify();
                    end;
                'Attributes':
                    begin
                        UpdateUseCaseProgressWindow('Attribute Mapping');
                        ReadTaxAttributeMapping(UseCase.ID, JToken.AsArray());
                    end;
                'RateColumns':
                    begin
                        UpdateUseCaseProgressWindow('Rate Columns');
                        ReadRateColumnRelation(UseCase.ID, JToken.AsArray());
                    end;
                'AttachedEvents':
                    ;
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        UpdateUseCaseProgressWindow('Computation Scripts');
        ReadComputationScript(UseCase, JObject);
        UpdateUseCaseProgressWindow('Posting Scripts');
        ReadPostingScript(UseCase, JObject);

        UseCase.Status := UseCase.Status::Released;
        UseCase.Enable := true;
        UseCase."Effective From" := CurrentDateTime;
        UseCase.Modify();

        if UpgradedUseCase then
            LogUseCaseUpgradedTelemetry(UseCase.ID, GetVersionText(UseCase."Major Version", UseCase."Minor Version"))
        else
            LogUseCaseImportTelemetry(UseCase.ID, GetVersionText(UseCase."Major Version", UseCase."Minor Version"));
    end;

    local procedure ReadComputationScript(var UseCase: Record "Tax Use Case"; JObject: JsonObject)
    var
        JToken: JsonToken;
    begin
        if JObject.Get('ComputationVariables', JToken) then
            ReadVariables(UseCase.ID, UseCase."Computation Script ID", JToken.AsArray());

        if JObject.Get('ComputationScript', JToken) then
            ReadActionContainer(
                UseCase.ID,
                UseCase."Computation Script ID",
                UseCase.ID,
                "Container Action Type"::USECASE,
                JToken.AsArray());

        if JObject.Get('Components', JToken) then
            ReadComponentFormula(UseCase.ID, UseCase."Computation Script ID", JToken.AsArray());
    end;

    local procedure ReadPostingScript(var UseCase: Record "Tax Use Case"; JObject: JsonObject)
    var
        JToken: JsonToken;
    begin
        if JObject.Get('PostingVariables', JToken) then
            ReadVariables(UseCase.ID, UseCase."Posting Script ID", JToken.AsArray());

        if JObject.Get('PostingScript', JToken) then
            ReadActionContainer(
                UseCase.ID,
                UseCase."Posting Script ID",
                UseCase.ID,
                "Container Action Type"::USECASE,
                JToken.AsArray());

        if JObject.Get('TaxPostingSetup', JToken) then
            ReadTaxPostingSetup(UseCase.ID, JToken.AsArray());
    end;

    local procedure ReadTaxAttributeMapping(CaseID: Guid; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadAttributeMapping(CaseID, JToken.AsObject());
    end;

    local procedure ReadTaxPostingSetup(CaseID: Guid; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadTaxPostingSetup(CaseID, JToken.AsObject());
    end;

    local procedure ReadRateColumnRelation(CaseID: Guid; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadRateColumnRelation(CaseID, JToken.AsObject());
    end;

    local procedure ReadVariables(CaseID: Guid; ScriptID: Guid; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadScriptVariable(CaseID, ScriptID, JToken.AsObject());
    end;

    local procedure ReadActionContainer(
        CaseID: Guid;
        ScriptID: Guid;
        ParentID: Guid;
        ContainerType: Enum "Container Action Type";
                           JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadAction(CaseID, ScriptID, ParentID, ContainerType, JToken.AsObject());
    end;

    local procedure ReadComponentFormula(CaseID: Guid; ScriptID: Guid; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadComponentCalculation(CaseID, ScriptID, JToken.AsObject());
    end;

    local procedure ReadAttributeMapping(CaseID: Guid; JObject: JsonObject)
    var
        UseCaseAttributeMapping: Record "Use Case Attribute Mapping";
        JToken: JsonToken;
    begin
        UseCaseAttributeMapping.Get(CaseID, UseCaseEntityMgmt.CreateUseCaseAttributeMapping(CaseID));
        UseCaseAttributeMapping."Tax Type" := GlobalUseCase."Tax Type";
        JObject.Get('Name', JToken);
        UseCaseAttributeMapping."Attribtue ID" := GetAttributeID(GlobalUseCase."Tax Type", JToken2Text30(JToken));
        JObject.get('When', JToken);
        UseCaseAttributeMapping."Switch Statement ID" := SwitchStatementHelper.CreateSwitchStatement(CaseID);
        ReadSwitchStatement(CaseID, UseCaseAttributeMapping."Switch Statement ID", "Switch Case Action Type"::Relation, JToken.AsArray());
        UseCaseAttributeMapping.Modify();
    end;

    local procedure ReadTaxPostingSetup(CaseID: Guid; JObject: JsonObject)
    var
        TaxPostingSetup: Record "Tax Posting Setup";
        JToken: JsonToken;
        property: Text;
    begin
        TaxPostingSetup.Init();
        TaxPostingSetup."Case ID" := CaseID;
        TaxPostingSetup.ID := CreateGuid();
        TaxPostingSetup.Insert();

        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'ComponentName':
                    begin
                        TaxPostingSetup."Component ID" := GetComponentID(GlobalUseCase."Tax Type", JToken2Text30(JToken));
                        TaxPostingSetup.Modify()
                    end;
                'TableName':
                    begin
                        TaxPostingSetup."Table ID" := AppObjectHelper.GetObjectID(ObjectType::Table, JToken2Text30(JToken));
                        TaxPostingSetup.Modify();
                    end;
                'FieldName':
                    begin
                        TaxPostingSetup."Field ID" := AppObjectHelper.GetFieldID(TaxPostingSetup."Table ID", JToken2Text30(JToken));
                        TaxPostingSetup.Modify();
                    end;
                'AccountSourceType':
                    begin
                        TaxPostingSetup."Account Source Type" := ScriptDataTypeMgmt.GetFieldOptionIndex(
                            Database::"Tax Posting Setup",
                            TaxPostingSetup.FieldNo("Account Source Type"),
                            JToken.AsValue().AsText());

                        TaxPostingSetup.Modify();
                    end;
                'AccountFieldLookup':
                    begin
                        ReadLookup(TaxPostingSetup."Case ID", EmptyGuid, TaxPostingSetup."Account Lookup ID", JToken.AsObject());
                        TaxPostingSetup.Modify();
                    end;
                'ReverseCharge':
                    begin
                        TaxPostingSetup."Reverse Charge" := JToken.AsValue().AsBoolean();
                        TaxPostingSetup.Modify();
                    end;
                'ReverseChargeFieldName':
                    begin
                        TaxPostingSetup."Reverse Charge Field ID" := AppObjectHelper.GetFieldID(TaxPostingSetup."Table ID", JToken2Text30(JToken));
                        TaxPostingSetup.Modify();
                    end;
                'ReverseAccountSourceType':
                    begin
                        TaxPostingSetup."Reversal Account Source Type" := ScriptDataTypeMgmt.GetFieldOptionIndex(
                            Database::"Tax Posting Setup",
                            TaxPostingSetup.FieldNo("Reversal Account Source Type"),
                            JToken.AsValue().AsText());

                        TaxPostingSetup.Modify();
                    end;
                'ReverseAccountFieldLookup':
                    begin
                        ReadLookup(TaxPostingSetup."Case ID", EmptyGuid, TaxPostingSetup."Reversal Account Lookup ID", JToken.AsObject());
                        TaxPostingSetup.Modify();
                    end;
                'TableFilters':
                    begin
                        TaxPostingSetup."Table Filter ID" := JsonEntityMgmt.CreateTableFilters(TaxPostingSetup."Case ID", EmptyGuid, TaxPostingSetup."Table ID");
                        TaxPostingSetup.Modify();
                        ReadTableFilters(TaxPostingSetup."Case ID", EmptyGuid, TaxPostingSetup."Table Filter ID", JToken.AsArray());
                    end;
                'When':
                    begin
                        TaxPostingSetup."Switch Statement ID" := SwitchStatementHelper.CreateSwitchStatement(CaseID);
                        TaxPostingSetup.Modify();
                        ReadSwitchStatement(CaseID, TaxPostingSetup."Switch Statement ID", "Switch Case Action Type"::"Insert Record", JToken.AsArray());
                    end;
                'SubLedgerGrpBy':
                    ;
                'AccountingImpact':
                    begin
                        TaxPostingSetup."Accounting Impact" := ScriptDataTypeMgmt.GetFieldOptionIndex(Database::"Tax Posting Setup", TaxPostingSetup.FieldNo("Accounting Impact"), JToken.AsValue().AsText());
                        TaxPostingSetup.Modify();
                    end;
                else
                    Error(InvalidPropertyErr);
            end;

        end;
    end;

    local procedure ReadSwitchStatement(
        CaseID: Guid;
        SwitchStatementID: Guid;
        ActionType: Enum "Switch Case Action Type";
                        JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadSwitchStatement(CaseID, SwitchStatementID, ActionType, JToken.AsObject());
    end;

    local procedure ReadSwitchStatement(
        CaseID: Guid;
        SwitchStatementID: Guid;
        ActionType: Enum "Switch Case Action Type";
                        JObject: JsonObject)
    var
        SwitchCase: Record "Switch Case";
    begin
        SwitchCase.Init();
        SwitchCase."Case ID" := CaseID;
        SwitchCase."Switch Statement ID" := SwitchStatementID;
        SwitchCase.ID := CreateGuid();
        SwitchCase.Insert();
        ReadSwitchCase(SwitchCase, ActionType, JObject);
        SwitchCase.Modify();
    end;

    local procedure ReadRateColumnRelation(CaseID: Guid; JObject: JsonObject)
    var
        UseCaseRateColumnRelation: Record "Use Case Rate Column Relation";
        ColumnID: Integer;
        JToken: JsonToken;
    begin
        UseCaseRateColumnRelation.Get(CaseId, UseCaseEntityMgmt.CreateRateColumnRelation(CaseId));
        JObject.Get('Name', JToken);
        ColumnID := GetColumnID(GlobalUseCase."Tax Type", JToken2Text30(JToken));
        if ColumnID = 0 then
            Error(ColumnNameNotFoundErr, JToken2Text30(JToken), GlobalUseCase."Tax Type", GlobalUseCase.Description);

        UseCaseRateColumnRelation."Column ID" := ColumnID;
        JObject.get('When', JToken);
        UseCaseRateColumnRelation."Switch Statement ID" := SwitchStatementHelper.CreateSwitchStatement(CaseID);
        ReadSwitchStatement(CaseID, UseCaseRateColumnRelation."Switch Statement ID", "Switch Case Action Type"::Lookup, JToken.AsArray());
        UseCaseRateColumnRelation.Modify();
    end;

    local procedure ReadNumberExpression(CaseID: Guid; ScriptID: Guid; var ID: Guid; JObject: JsonObject)
    var
        ActionNumberExpression: Record "Action Number Expression";
        JToken: JsonToken;
    begin
        ActionNumberExpression.get(CaseID, ScriptID, ID);
        ActionNumberExpression."Script ID" := ScriptID;
        if JObject.get('VariableName', JToken) then
            ActionNumberExpression."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
        if JObject.get('Expression', JToken) then
            ActionNumberExpression.Expression := JToken2Text250(JToken);
        ActionNumberExpression.Modify();
        if JObject.Get('Tokens', JToken) then
            ReadNumericExprToken(ActionNumberExpression."Case ID", ScriptID, ActionNumberExpression.ID, JToken.AsArray());
        ID := ActionNumberExpression.ID;
    end;

    local procedure ReadInsertRecord(CaseID: Guid; ScriptID: Guid; var ID: Guid; JObject: JsonObject)
    var
        TaxInsertRecord: Record "Tax Insert Record";
        JToken: JsonToken;
        property: Text;
    begin
        TaxInsertRecord.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'TableName':
                    begin
                        TaxInsertRecord."Table ID" := AppObjectHelper.GetObjectID(ObjectType::Table, JToken2Text30(JToken));
                        TaxInsertRecord.Modify();
                    end;
                'RunTrigger':
                    begin
                        TaxInsertRecord."Run Trigger" := JToken.AsValue().AsBoolean();
                        TaxInsertRecord.Modify();
                    end;
                'RecordVariable':
                    ;
                'InsertRecordFields':
                    ReadInsertRecordField(TaxInsertRecord, JToken.AsArray());
                'SubLedgerGrpBy':
                    begin
                        TaxInsertRecord."Sub Ledger Group By" := ScriptDataTypeMgmt.GetFieldOptionIndex(Database::"Tax Insert Record", TaxInsertRecord.FieldNo("Sub Ledger Group By"), JToken.AsValue().AsText());
                        TaxInsertRecord.Modify();
                    end;
            end;
        end;
        TaxInsertRecord.Modify();
    end;

    local procedure ReadInsertRecordField(InsertRecord: Record "Tax Insert Record"; JObject: JsonObject)
    var
        TaxInsertRecordField: Record "Tax Insert Record Field";
        JToken: JsonToken;
        property: Text;
    begin
        TaxInsertRecordField.Init();
        TaxInsertRecordField."Case ID" := InsertRecord."Case ID";
        TaxInsertRecordField."Script ID" := InsertRecord."Script ID";
        TaxInsertRecordField."Insert Record ID" := InsertRecord.ID;
        TaxInsertRecordField."Table ID" := InsertRecord."Table ID";
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'FieldName':
                    begin
                        TaxInsertRecordField."Field ID" := AppObjectHelper.GetFieldID(TaxInsertRecordField."Table ID", JToken2Text30(JToken));
                        TaxInsertRecordField.Insert();
                    end;
                'Sequence':
                    begin
                        TaxInsertRecordField."Sequence No." := JToken.AsValue().AsInteger();
                        TaxInsertRecordField.Modify();
                    end;
                'RunValidate':
                    begin
                        TaxInsertRecordField."Run Validate" := JToken.AsValue().AsBoolean();
                        TaxInsertRecordField.Modify();
                    end;
                'Value':
                    begin
                        TaxInsertRecordField.Value := JToken2Text250(JToken);
                        TaxInsertRecordField.Modify();
                    end;
                'ReverseSign':
                    begin
                        TaxInsertRecordField."Reverse Sign" := JToken.AsValue().AsBoolean();
                        TaxInsertRecordField.Modify();
                    end;
                'Lookup':
                    begin
                        ConstantOrLookupText(InsertRecord."Case ID", InsertRecord."Script ID", TaxInsertRecordField."Value Type", TaxInsertRecordField.Value, TaxInsertRecordField."Lookup ID", JToken.AsObject());
                        TaxInsertRecordField.Modify();
                    end;
            end;
        end;
    end;

    local procedure ReadComponentExprToken(CaseID: Guid; ScriptID: Guid; ID: Guid; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadComponentExprToken(CaseID, ScriptID, ID, JToken.AsObject());
    end;

    local procedure ReadNumericExprToken(CaseID: Guid; ScriptID: Guid; ID: Guid; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadNumericExprToken(CaseID, ScriptID, ID, JToken.AsObject());
    end;

    local procedure ReadStringExprTokens(CaseID: Guid; ScriptID: Guid; ID: Guid; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadStringExprToken(CaseID, ScriptID, ID, JToken.AsObject());
    end;

    local procedure ReadComponentExprTokens(TaxType: Code[20]; ID: Guid; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadComponentFormulaExprToken(TaxType, ID, JToken.AsObject());
    end;

    local procedure ReadComponentExprToken(CaseID: Guid; ScriptID: Guid; ID: Guid; JObject: JsonObject)
    var
        TaxComponentExprToken: Record "Tax Component Expr. Token";
        LookupJObject: JsonObject;
        JToken: JsonToken;
    begin
        TaxComponentExprToken.Init();
        TaxComponentExprToken."Case ID" := CaseID;
        TaxComponentExprToken."Script ID" := ScriptID;
        TaxComponentExprToken."Component Expr. ID" := ID;
        JObject.Get('TokenName', JToken);
        TaxComponentExprToken.Token := JToken2Text250(JToken);
        JObject.Get('TokenValue', JToken);
        LookupJObject := JToken.AsObject();
        ConstantOrLookupText(TaxComponentExprToken."Case ID", TaxComponentExprToken."Script ID", TaxComponentExprToken."Value Type", TaxComponentExprToken.Value, TaxComponentExprToken."Lookup ID", LookupJObject);
        TaxComponentExprToken.Insert();
    end;


    local procedure ReadNumericExprToken(CaseID: Guid; ScriptID: Guid; ID: Guid; JObject: JsonObject)
    var
        ActionNumberExprToken: Record "Action Number Expr. Token";
        LookupJObject: JsonObject;
        JToken: JsonToken;
    begin
        ActionNumberExprToken.Init();
        ActionNumberExprToken."Case ID" := CaseID;
        ActionNumberExprToken."Script ID" := ScriptID;
        ActionNumberExprToken."Numeric Expr. ID" := ID;
        JObject.Get('TokenName', JToken);
        ActionNumberExprToken.Token := JToken2Text250(JToken);
        JObject.Get('TokenValue', JToken);
        LookupJObject := JToken.AsObject();
        ConstantOrLookupText(ActionNumberExprToken."Case ID", ActionNumberExprToken."Script ID", ActionNumberExprToken."Value Type", ActionNumberExprToken.Value, ActionNumberExprToken."Lookup ID", LookupJObject);
        ActionNumberExprToken.Insert();
    end;

    local procedure ReadSwitchCase(
        var SwitchCase: Record "Switch Case";
        ActionType: enum "Switch Case Action Type";
                        JObject: JsonObject)
    var
        LookupJObject: JsonObject;
        JToken: JsonToken;
    begin
        if JObject.get('Condition', JToken) then begin
            SwitchCase."Condition ID" := JsonEntityMgmt.CreateCondition(SwitchCase."Case ID", EmptyGuid);
            ReadCondition(SwitchCase."Case ID", EmptyGuid, SwitchCase."Condition ID", JToken.AsObject());
        end;

        if JObject.Get('Sequence', JToken) then
            SwitchCase.Sequence := JToken.AsValue().AsInteger();

        case ActionType of
            ActionType::Lookup:
                begin
                    if not JObject.get('Lookup', JToken) then
                        exit;
                    SwitchCase."Action Type" := ActionType;
                    ReadLookup(SwitchCase."Case ID", EmptyGuid, SwitchCase."Action ID", JToken.AsObject());
                end;
            ActionType::Relation:
                begin
                    if not JObject.get('Relation', JToken) then
                        exit;
                    SwitchCase."Action Type" := ActionType;
                    SwitchCase."Action ID" := JsonEntityMgmt.CreateTableRelation(SwitchCase."Case ID");
                    ReadTaxTableRelation(SwitchCase."Case ID", SwitchCase."Action ID", JToken.AsObject());
                end;
            ActionType::"Insert Record":
                begin
                    if not JObject.get('InsertRecord', JToken) then
                        exit;
                    SwitchCase."Action Type" := ActionType;
                    LookupJObject := JToken.AsObject();
                    SwitchCase."Action ID" := TaxPostingHelper.CreateInsertRecord(
                        SwitchCase."Case ID",
                        GlobalUseCase."Posting Script ID");
                    ReadInsertRecord(
                        SwitchCase."Case ID",
                        GlobalUseCase."Posting Script ID",
                        SwitchCase."Action ID",
                        JToken.AsObject());
                end;
        end;
    end;

    local procedure ReadConditionBody(CaseID: Guid; ScriptID: Guid; ID: Guid; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadConditionItem(CaseID, ScriptID, ID, JToken.AsObject());
    end;

    local procedure ReadCondition(CaseID: Guid; ScriptID: Guid; ID: Guid; JObject: JsonObject)
    var
        JToken: JsonToken;
        property: Text;
    begin
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'Body':
                    ReadConditionBody(CaseID, ScriptID, ID, JToken.AsArray());
                else
                    Error(InvalidPropertyErr);
            end;

        end;
    end;

    local procedure ReadScriptVariable(CaseID: Guid; ScriptID: Guid; JObject: JsonObject)
    var
        UseCaseVariable: Record "Script Variable";
        property: Text;
        VariableName: Text[30];
        DataType: Enum "Symbol Data Type";
        JToken: JsonToken;
    begin
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'Name':
                    VariableName := JToken2Text30(JToken);
                'Datatype':
                    Evaluate(DataType, JToken2Text250(JToken));
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        if VariableName = '' then
            exit;
        UseCaseVariable.Init();
        UseCaseVariable."Case ID" := CaseID;
        UseCaseVariable."Script ID" := ScriptID;
        UseCaseVariable.ID := GetNextVariableID(CaseID, ScriptID);
        UseCaseVariable.Name := VariableName;
        UseCaseVariable.Datatype := DataType;
        UseCaseVariable.Insert();
    end;

    local procedure ReadAction(
        CaseID: Guid;
        ScriptID: Guid;
        ParentID: Guid;
        ContainerType: Enum "Container Action Type";
                           JObject: JsonObject)
    var
        ActionContainer: Record "Action Container";
        JToken: JsonToken;
        ActionID: Guid;
        ActionType2: Enum "Action Type";
        property: Text;
    begin
        JObject.Get('ActivityType', JToken);
        Evaluate(ActionType2, JToken2Text250(JToken));

        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'ActivityType', 'EXITLOOP', 'CONTINUE':
                    ;
                'Activity':
                    begin
                        ActionID := JsonEntityMgmt.CreateContainerItem(CaseID, ScriptID, ActionType2);
                        ActionContainer.Init();
                        ActionContainer."Case ID" := CaseID;
                        ActionContainer."Script ID" := ScriptID;
                        ActionContainer."Container Type" := ContainerType;
                        ActionContainer."Container Action ID" := ParentID;
                        ActionContainer."Line No." := GetNextContainerLineNo(CaseID, ScriptID, ParentID, ContainerType);
                        ActionContainer."Action Type" := ActionType2;
                        ActionContainer."Action ID" := ActionID;
                        ActionContainer.Insert();
                        ReadScriptAction(CaseID, ScriptID, ActionType2, ActionContainer."Action ID", JToken.AsObject());
                    end;
                else
                    Error('Invalid property');
            end;
        end;
    end;

    local procedure ReadConditionItem(CaseID: Guid; ScriptID: Guid; ID: Guid; JObject: JsonObject)
    var
        ConditionItem: Record "Tax Test Condition Item";
    begin
        ConditionItem.Init();
        ConditionItem."Case ID" := CaseID;
        ConditionItem."Condition ID" := ID;
        ConditionItem."Script ID" := ScriptID;
        ConditionItem.ID := GetNextConditionID(CaseID, ScriptID, ID);
        ReadConditionItemAttributes(ConditionItem, JObject);
        ConditionItem.Insert();
    end;

    local procedure ReadConditionItemAttributes(var ConditionItem: Record "Tax Test Condition Item"; JObject: JsonObject)
    var
        ConditionJObject: JsonObject;
        CounterJToken: JsonToken;
        JToken: JsonToken;
        ConditionProperty: Text;
        property: Text;
    begin
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'Operator':
                    ConditionItem."Logical Operator" := ScriptDataTypeMgmt.GetFieldOptionIndex(Database::"Tax Test Condition Item", ConditionItem.FieldNo("Logical Operator"), JToken2Text250(JToken));
                'LHS':
                    foreach ConditionProperty in JToken.AsObject().Keys() do
                        case ConditionProperty of
                            'Lookup':
                                begin
                                    JToken.AsObject().Get('Lookup', CounterJToken);
                                    ConditionJObject := CounterJToken.AsObject();
                                    ReadLookup(
                                        ConditionItem."Case ID",
                                        ConditionItem."Script ID",
                                        ConditionItem."LHS Lookup ID",
                                        ConditionJObject);
                                end;
                        end;
                'RHS':
                    ConstantOrLookupText(ConditionItem."Case ID", ConditionItem."Script ID", ConditionItem."RHS Type", ConditionItem."RHS Value", ConditionItem."RHS Lookup ID", JToken.AsObject());
                'ConditionType':
                    ConditionItem."Conditional Operator" := "Conditional Operator".FromInteger(ScriptDataTypeMgmt.GetFieldOptionIndex(Database::"Tax Test Condition Item", ConditionItem.FieldNo("Conditional Operator"), JToken2Text30(JToken)));
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
    end;

    local procedure ReadFieldFilter(var LookupFieldFilter: Record "Lookup Field Filter"; var JObject: JsonObject)
    var
        FieldJObject: JsonObject;
        JToken: JsonToken;
        property: Text;
    begin
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'FiterFieldName':
                    begin
                        LookupFieldFilter."Field ID" := AppObjectHelper.GetFieldID(LookupFieldFilter."Table ID", JToken2Text30(JToken));
                        LookupFieldFilter.Insert();
                    end;
                'FilterType':
                    begin
                        LookupFieldFilter."Filter Type" := "Conditional Operator".FromInteger(ScriptDataTypeMgmt.GetFieldOptionIndex(Database::"Lookup Field Filter", LookupFieldFilter.FieldNo("Filter Type"), JToken2Text30(JToken)));
                        LookupFieldFilter.Modify();
                    end;
                'FilterValue':
                    begin
                        ConstantOrLookupText(LookupFieldFilter."Case ID", LookupFieldFilter."Script ID", LookupFieldFilter."Value Type", LookupFieldFilter.Value, LookupFieldFilter."Lookup ID", JToken.AsObject());
                        LookupFieldFilter.Modify();
                    end;
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        JObject := FieldJObject
    end;

    local procedure ReadFieldSorting(var LookupFieldSorting: Record "Lookup Field Sorting"; JObject: JsonObject)
    var
        JToken: JsonToken;
        property: Text;
    begin
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'FieldName':
                    begin
                        LookupFieldSorting."Field ID" := AppObjectHelper.GetFieldID(LookupFieldSorting."Table ID", JToken2Text30(JToken));
                        LookupFieldSorting.Insert();
                    end;
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
    end;

    local procedure ReadTableFilters(CaseID: Guid; ScriptID: Guid; ID: Guid; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadTableFilter(CaseID, ScriptID, ID, JToken.AsObject());
    end;

    local procedure ReadTableSortingFields(CaseID: Guid; ScriptID: Guid; ID: Guid; JArray: JsonArray)
    var
        JToken: JsonToken;
    begin
        foreach JToken in JArray do
            ReadTableFieldSorting(CaseID, ScriptID, ID, JToken.AsObject());
    end;

    local procedure ReadTableFilter(CaseID: Guid; ScriptID: Guid; var ID: Guid; JObject: JsonObject)
    var
        LookupFieldFilter: Record "Lookup Field Filter";
        LookupTableFilter: Record "Lookup Table Filter";
        TableID: Integer;
    begin
        LookupTableFilter.Get(CaseID, ScriptID, ID);
        TableID := LookupTableFilter."Table ID";

        LookupFieldFilter."Case ID" := CaseID;
        LookupFieldFilter."Script ID" := ScriptID;
        LookupFieldFilter."Table Filter ID" := ID;
        LookupFieldFilter."Table ID" := TableID;
        ReadFieldFilter(LookupFieldFilter, JObject);
        LookupFieldFilter.Modify();
    end;

    local procedure ReadTableFieldSorting(CaseID: Guid; ScriptID: Guid; var ID: Guid; JObject: JsonObject)
    var
        LookupFieldSorting: Record "Lookup Field Sorting";
        LookupTableSorting: Record "Lookup Table Sorting";
        TableID: Integer;
    begin
        LookupTableSorting.Get(CaseID, ScriptID, ID);
        TableID := LookupTableSorting."Table ID";

        LookupFieldSorting."Case ID" := CaseID;
        LookupFieldSorting."Script ID" := ScriptID;
        LookupFieldSorting."Table Sorting ID" := ID;
        LookupFieldSorting."Table ID" := TableID;
        LookupFieldSorting."Line No." := GetNextSortingLineNo(CaseID, ScriptID);
        ReadFieldSorting(LookupFieldSorting, JObject);
    end;

    local procedure ConstantOrLookupText(CaseID: Guid; ScriptID: Guid; var ValueType: Option Constant,"Lookup"; var Value: Text[250]; var LookupID: Guid; JObject: JsonObject)
    var
        NewJObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.Get('Type', JToken);
        ValueType := TypeHelper.GetOptionNo(JToken2Text250(JToken), 'Constant,Lookup');
        if ValueType = ValueType::Constant then begin
            JObject.Get('Value', JToken);
            Value := JToken2Text250(JToken);
        end else begin
            JObject.Get('Lookup', JToken);
            NewJObject := JToken.AsObject();
            ReadLookup(CaseID, ScriptID, LookupID, NewJObject);
        end;
    end;

    local procedure ReadLookup(CaseID: Guid; ScriptID: Guid; var LookupID: Guid; JObject: JsonObject)
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        property: Text;
        JToken: JsonToken;
    begin
        LookupID := JsonEntityMgmt.CreateLookup(CaseID, ScriptID);
        ScriptSymbolLookup.Get(CaseID, ScriptID, LookupID);

        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'SourceType':
                    Evaluate(ScriptSymbolLookup."Source Type", JToken2Text250(JToken));
                'TableName', 'RecordTableName':
                    ScriptSymbolLookup."Source ID" := AppObjectHelper.GetObjectID(ObjectType::Table, JToken2Text30(JToken));
                'ComponentName':
                    begin
                        ScriptSymbolLookup."Source Field ID" := GetComponentID(GlobalUseCase."Tax Type", JToken2Text30(JToken));
                        ScriptSymbolLookup."Source ID" := GlobalUseCase."Tax Table ID";
                    end;
                'AttributeName':
                    begin
                        ScriptSymbolLookup."Source Field ID" := GetAttributeID(GlobalUseCase."Tax Type", JToken2Text30(JToken));
                        ScriptSymbolLookup."Source ID" := GlobalUseCase."Tax Table ID";
                    end;
                'TableFieldName', 'RecordFieldName', 'FieldName':
                    ScriptSymbolLookup."Source Field ID" := AppObjectHelper.GetFieldID(ScriptSymbolLookup."Source ID", JToken2Text30(JToken));
                'VariableName':
                    begin
                        ScriptSymbolLookup."Source Field ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                        ScriptSymbolLookup."Source ID" := GlobalUseCase."Tax Table ID";
                    end;
                'SystemVariableName':
                    begin
                        ScriptSymbolLookup."Source Field ID" := GetSystemSymbolID(JToken2Text30(JToken));
                        ScriptSymbolLookup."Source ID" := GlobalUseCase."Tax Table ID";
                    end;
                'DatabaseVariableName':
                    begin
                        ScriptSymbolLookup."Source Field ID" := GetDatabaseSymbolID(JToken2Text30(JToken));
                        ScriptSymbolLookup."Source ID" := GlobalUseCase."Tax Table ID";
                    end;
                'RateColumnName':
                    begin
                        ScriptSymbolLookup."Source Field ID" := GetColumnID(GlobalUseCase."Tax Type", JToken2Text30(JToken));
                        ScriptSymbolLookup."Source ID" := GlobalUseCase."Tax Table ID";
                    end;
                'PostingVariableName':
                    begin
                        ScriptSymbolLookup."Source Field ID" := GetPostingFieldSymbolID(JToken2Text30(JToken));
                        ScriptSymbolLookup."Source ID" := GlobalUseCase."Tax Table ID";
                    end;
                'Method':
                    ScriptSymbolLookup."Table Method" := ScriptDataTypeMgmt.GetFieldOptionIndex(Database::"Script Symbol Lookup", ScriptSymbolLookup.FieldNo("Table Method"), JToken2Text250(JToken));
                'TableFilters':
                    begin
                        ScriptSymbolLookup."Table Filter ID" := JsonEntityMgmt.CreateTableFilters(CaseID, ScriptID, ScriptSymbolLookup."Source ID");
                        ReadTableFilters(CaseID, ScriptID, ScriptSymbolLookup."Table Filter ID", JToken.AsArray());
                    end;
                'Sorting':
                    begin
                        ScriptSymbolLookup."Table Sorting ID" := JsonEntityMgmt.CreateTableSorting(CaseID, ScriptID, ScriptSymbolLookup."Source ID");
                        ReadTableSortingFields(CaseID, ScriptID, ScriptSymbolLookup."Table Sorting ID", JToken.AsArray());
                    end;
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ScriptSymbolLookup.Modify();
    end;

    local procedure ReadTaxTableRelation(CaseID: Guid; ID: Guid; JObject: JsonObject)
    var
        TaxTableRelation: Record "Tax Table Relation";
        JToken: JsonToken;
        property: Text;
    begin
        TaxTableRelation.get(CaseID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'TableName':
                    begin
                        TaxTableRelation."Source ID" := AppObjectHelper.GetObjectID(ObjectType::Table, JToken2Text30(JToken));
                        TaxTableRelation."Source ID" := AppObjectHelper.GetObjectID(ObjectType::Table, JToken2Text30(JToken));
                    end;
                'TableFilters':
                    begin
                        TaxTableRelation."Table Filter ID" := JsonEntityMgmt.CreateTableFilters(CaseID, EmptyGuid, TaxTableRelation."Source ID");
                        TaxTableRelation.Modify();
                        ReadTableFilters(CaseID, EmptyGuid, TaxTableRelation."Table Filter ID", JToken.AsArray());
                    end;
                'IsCurrentRecord':
                    TaxTableRelation."Is Current Record" := JToken.AsValue().AsBoolean();
            end;
        end;
        TaxTableRelation.Modify();
    end;

    local procedure ReadJsonProperty(var ParentJObject: JsonObject; PropertyName: Text; Value: Variant)
    var
        JObject: JsonObject;
        JArray: JsonArray;
        TextValue: Text;
        IntegerValue: Integer;
        BigIntegerValue: BigInteger;
        BooleanValue: Boolean;
        DecimalValue: Decimal;
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
        end;
    end;

    local procedure ReadComment(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionComment: Record "Action Comment";
        JToken: JsonToken;
        property: Text;
    begin
        ActionComment.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'Comment':
                    ActionComment.Text := JToken2Text250(JToken);
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionComment.Modify();
    end;

    local procedure ReadNumberCalculation(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionNumberCalculation: Record "Action Number Calculation";
        LookupJObject: JsonObject;
        JToken: JsonToken;
        property: Text;
    begin
        ActionNumberCalculation.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'OutputVariableName':
                    ActionNumberCalculation."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'LHS':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, ActionNumberCalculation."LHS Type", ActionNumberCalculation."LHS Value", ActionNumberCalculation."LHS Lookup ID", LookupJObject);
                    end;
                'RHS':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, ActionNumberCalculation."RHS Type", ActionNumberCalculation."RHS Value", ActionNumberCalculation."RHS Lookup ID", LookupJObject);
                    end;
                'Operator':
                    ActionNumberCalculation."Arithmetic Operator" := "Arithmetic Operator".FromInteger(ScriptDataTypeMgmt.GetFieldOptionIndex(Database::"Action Number Calculation", ActionNumberCalculation.FieldNo("Arithmetic Operator"), JToken2Text250(JToken)));
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionNumberCalculation.Modify();
    end;

    local procedure ReadExtractSubstrFromPos(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionExtSubstrFromPos: Record "Action Ext. Substr. From Pos.";
        LookupJObject: JsonObject;
        JToken: JsonToken;
        property: Text;
    begin
        ActionExtSubstrFromPos.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'Output':
                    ActionExtSubstrFromPos."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'String':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, ActionExtSubstrFromPos."String Value Type", ActionExtSubstrFromPos."String Value", ActionExtSubstrFromPos."String Lookup ID", LookupJObject);
                    end;
                'Length':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, ActionExtSubstrFromPos."Length Value Type", ActionExtSubstrFromPos."Length Value", ActionExtSubstrFromPos."Length Lookup ID", LookupJObject);
                    end;
                'Position':
                    ActionExtSubstrFromPos.Position := ScriptDataTypeMgmt.GetFieldOptionIndex(Database::"Action Ext. Substr. From Pos.", ActionExtSubstrFromPos.FieldNo(Position), JToken2Text250(JToken));
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionExtSubstrFromPos.Modify();
    end;

    local procedure ReadFindDateInterval(CaseID: Guid; ScriptID: Guid; ID: Guid; JObject: JsonObject)
    var
        ActionFindDateInterval: Record "Action Find Date Interval";
        LookupJObject: JsonObject;
        JToken: JsonToken;
        property: Text;
    begin
        ActionFindDateInterval.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'Output':
                    ActionFindDateInterval."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'FromDate':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, ActionFindDateInterval."Date1 Value Type", ActionFindDateInterval."Date1 Value", ActionFindDateInterval."Date1 Lookup ID", LookupJObject);
                    end;
                'ToDate':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, ActionFindDateInterval."Date2 Value Type", ActionFindDateInterval."Date2 Value", ActionFindDateInterval."Date2 Lookup ID", LookupJObject);
                    end;
                'Interval':
                    ActionFindDateInterval.Inverval := ScriptDataTypeMgmt.GetFieldOptionIndex(Database::"Action Find Date Interval", ActionFindDateInterval.FieldNo(Inverval), JToken2Text250(JToken));
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionFindDateInterval.Modify();
    end;

    local procedure ReadSetVariable(CaseID: Guid; ScriptID: Guid; ID: Guid; JObject: JsonObject)
    var
        SetVariable: Record "Action Set Variable";
        LookupJObject: JsonObject;
        JToken: JsonToken;
        property: Text;
    begin
        SetVariable.Get(CaseID, ScriptID, ID);

        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'OutputVariableName':
                    SetVariable."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'OutputValue':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, SetVariable."Value Type", SetVariable.Value, SetVariable."Lookup ID", LookupJObject);
                    end;
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        SetVariable.Modify();
    end;

    local procedure ReadConcatenate(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        Concatenate: Record "Action Concatenate";
        JToken: JsonToken;
        property: Text;
    begin
        Concatenate.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'OutputVariableName':
                    Concatenate."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'Concatenate':
                    ReadConcatenateLines(Concatenate, JToken.AsArray());
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        Concatenate.Modify();
    end;

    local procedure ReadConcatenateLine(Concatenate: Record "Action Concatenate"; JObject: JsonObject)
    var
        ConcatenateLine: Record "Action Concatenate Line";
        LookupJObject: JsonObject;
        JToken: JsonToken;
        property: Text;
    begin
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'Value':
                    begin
                        ConcatenateLine.Init();
                        ConcatenateLine."Case ID" := Concatenate."Case ID";
                        ConcatenateLine."Script ID" := Concatenate."Script ID";
                        ConcatenateLine."Concatenate ID" := Concatenate.ID;
                        ConcatenateLine.Insert();
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(ConcatenateLine."Case ID", ConcatenateLine."Script ID", ConcatenateLine."Value Type", ConcatenateLine.Value, ConcatenateLine."Lookup ID", LookupJObject);
                    end;
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ConcatenateLine.Modify();
    end;

    local procedure ReadFindSubstring(CaseID: Guid; ScriptID: Guid; ID: Guid; JObject: JsonObject)
    var
        ActionFindSubstring: Record "Action Find Substring";
        LookupJObject: JsonObject;
        JToken: JsonToken;
        property: Text;
    begin
        ActionFindSubstring.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'OutputVariableName':
                    ActionFindSubstring."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'SubstrinText':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, ActionFindSubstring."Substring Value Type", ActionFindSubstring."Substring Value", ActionFindSubstring."Substring Lookup ID", LookupJObject);
                    end;
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionFindSubstring.Modify();
    end;

    local procedure ReadRepaceSubstring(CaseID: Guid; ScriptID: Guid; ID: Guid; JObject: JsonObject)
    var
        ActionReplaceSubstring: Record "Action Replace Substring";
        LookupJObject: JsonObject;
        JToken: JsonToken;
        property: Text;
    begin

        ActionReplaceSubstring.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'OutputVariableName':
                    ActionReplaceSubstring."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'SubstringText':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, ActionReplaceSubstring."Substring Value Type", ActionReplaceSubstring."Substring Value", ActionReplaceSubstring."Substring Lookup ID", LookupJObject);
                    end;
                'StringText':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, ActionReplaceSubstring."String Value Type", ActionReplaceSubstring."String Value", ActionReplaceSubstring."String Lookup ID", LookupJObject);
                    end;
                'NewStringText':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, ActionReplaceSubstring."New String Value Type", ActionReplaceSubstring."New String Value", ActionReplaceSubstring."New String Lookup ID", LookupJObject);
                    end;
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionReplaceSubstring.Modify();
    end;

    local procedure ReadExtractSubstringFromIndex(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ExtSubstrFromIndex: Record "Action Ext. Substr. From Index";
        LookupJObject: JsonObject;
        JToken: JsonToken;
        property: Text;
    begin
        ExtSubstrFromIndex.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'OutputVariableName':
                    ExtSubstrFromIndex."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'StringText':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, ExtSubstrFromIndex."String Value Type", ExtSubstrFromIndex."String Value", ExtSubstrFromIndex."String Lookup ID", LookupJObject);
                    end;
                'IndexText':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, ExtSubstrFromIndex."Index Value Type", ExtSubstrFromIndex."Index Value", ExtSubstrFromIndex."Index Lookup ID", LookupJObject);
                    end;
                'LengthText':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, ExtSubstrFromIndex."Length Value Type", ExtSubstrFromIndex."Length Value", ExtSubstrFromIndex."Length Lookup ID", LookupJObject);
                    end;
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ExtSubstrFromIndex.Modify();
    end;

    local procedure ReadDateCalculation(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        DateCalculation: Record "Action Date Calculation";
        LookupJObject: JsonObject;
        JToken: JsonToken;
        property: Text;
    begin
        DateCalculation.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'OutputVariableName':
                    DateCalculation."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'StringText':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, DateCalculation."Date Value Type", DateCalculation."Date Value", DateCalculation."Date Lookup ID", LookupJObject);
                    end;
                'NumberText':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(CaseID, ScriptID, DateCalculation."Number Value Type", DateCalculation."Number Value", DateCalculation."Number Lookup ID", LookupJObject);
                    end;
                'OperatorText':
                    DateCalculation."Arithmetic operators" := ScriptDataTypeMgmt.GetFieldOptionIndex(Database::"Action Date Calculation", DateCalculation.FieldNo("Arithmetic operators"), JToken2Text250(JToken));
                'PeriodText':
                    DateCalculation.Duration := ScriptDataTypeMgmt.GetFieldOptionIndex(Database::"Action Date Calculation", DateCalculation.FieldNo(Duration), JToken2Text250(JToken));
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        DateCalculation.Modify();
    end;

    local procedure ReadDateToDateTime(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionDateToDateTime: Record "Action Date To DateTime";
        LookupJObject: JsonObject;
        JToken: JsonToken;
        property: Text;
    begin
        ActionDateToDateTime.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'OutputVariableName':
                    ActionDateToDateTime."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'DateText':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(
                            CaseID,
                            ScriptID,
                            ActionDateToDateTime."Date Value Type",
                            ActionDateToDateTime."Date Value",
                            ActionDateToDateTime."Date Lookup ID",
                            LookupJObject);
                    end;
                'TimeText':
                    begin
                        LookupJObject := JToken.AsObject();
                        ConstantOrLookupText(
                            CaseID,
                            ScriptID,
                            ActionDateToDateTime."Time Value Type",
                            ActionDateToDateTime."Time Value",
                            ActionDateToDateTime."Time Lookup ID",
                            LookupJObject);
                    end;
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionDateToDateTime.Modify();
    end;

    local procedure ReadMessage(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionMessage: Record "Action Message";
        property: Text;
        JToken: JsonToken;
    begin
        ActionMessage.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'MessageText':
                    ConstantOrLookupText(CaseID, ScriptID, ActionMessage."Value Type", ActionMessage.Value, ActionMessage."Lookup ID", JToken.AsObject());
                'ThrowError':
                    ActionMessage."Throw Error" := JToken.AsValue().AsBoolean();
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionMessage.Modify();
    end;

    local procedure ReadExtractDatePart(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionExtractDatePart: Record "Action Extract Date Part";
        JToken: JsonToken;
        property: Text;
    begin
        ActionExtractDatePart.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'OutputVariableName':
                    ActionExtractDatePart."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'DateLookup':
                    ConstantOrLookupText(CaseID, ScriptID, ActionExtractDatePart."Value Type", ActionExtractDatePart.Value, ActionExtractDatePart."Lookup ID", JToken.AsObject());
                'PartText':
                    ActionExtractDatePart."Date Part" := ScriptDataTypeMgmt.GetFieldOptionIndex(
                        Database::"Action Extract Date Part",
                        ActionExtractDatePart.FieldNo("Date Part"),
                        JToken2Text250(JToken));
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionExtractDatePart.Modify();
    end;

    local procedure ReadExtractDateTimePart(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionExtractDateTimePart: Record "Action Extract DateTime Part";
        JToken: JsonToken;
        property: Text;
    begin
        ActionExtractDateTimePart.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'OutputVariableName':
                    ActionExtractDateTimePart."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'DateLookup':
                    ConstantOrLookupText(CaseID, ScriptID, ActionExtractDateTimePart."Value Type", ActionExtractDateTimePart.Value, ActionExtractDateTimePart."Lookup ID", JToken.AsObject());
                'PartText':
                    ActionExtractDateTimePart."Part Type" := ScriptDataTypeMgmt.GetFieldOptionIndex(
                        Database::"Action Extract DateTime Part",
                        ActionExtractDateTimePart.FieldNo("Part Type"),
                        JToken2Text250(JToken));
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionExtractDateTimePart.Modify();
    end;

    local procedure ReadLengthOfString(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionLengthOfString: Record "Action Length Of String";
        JToken: JsonToken;
        property: Text;
    begin
        ActionLengthOfString.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'OutputVariableName':
                    ActionLengthOfString."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'LookupVariableName':
                    ConstantOrLookupText(CaseID, ScriptID, ActionLengthOfString."Value Type", ActionLengthOfString.Value, ActionLengthOfString."Lookup ID", JToken.AsObject());
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionLengthOfString.Modify();
    end;

    local procedure ReadConvertCase(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionConvertCase: Record "Action Convert Case";
        JToken: JsonToken;
        property: Text;
    begin
        ActionConvertCase.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'OutputVariableName':
                    ActionConvertCase."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'LookupVariableName':
                    ConstantOrLookupText(CaseID, ScriptID, ActionConvertCase."Value Type", ActionConvertCase.Value, ActionConvertCase."Lookup ID", JToken.AsObject());
                'ConvertToCase':
                    ActionConvertCase."Convert To Case" := ScriptDataTypeMgmt.GetFieldOptionIndex(
                        Database::"Action Convert Case",
                        ActionConvertCase.FieldNo("Convert To Case"),
                        JToken2Text250(JToken));
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionConvertCase.Modify();
    end;

    local procedure ReadRoundNumber(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionRoundNumber: Record "Action Round Number";
        JToken: JsonToken;
        property: Text;
    begin
        ActionRoundNumber.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'OutputVariableName':
                    ActionRoundNumber."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'NumberLookupVariableName':
                    ConstantOrLookupText(ActionRoundNumber."Case ID", ActionRoundNumber."Script ID", ActionRoundNumber."Number Value Type", ActionRoundNumber."Number Value", ActionRoundNumber."Number Lookup ID", JToken.AsObject());
                'PrecisionLookupVariableName':
                    ConstantOrLookupText(ActionRoundNumber."Case ID", ActionRoundNumber."Script ID", ActionRoundNumber."Precision Value Type", ActionRoundNumber."Precision Value", ActionRoundNumber."Precision Lookup ID", JToken.AsObject());
                'Direction':
                    ActionRoundNumber.Direction := ScriptDataTypeMgmt.GetFieldOptionIndex(
                        Database::"Action Round Number",
                        ActionRoundNumber.FieldNo(Direction),
                        JToken2Text250(JToken));
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionRoundNumber.Modify();
    end;

    local procedure ReadComponentFormulaExpression(TaxType: Code[20]; ID: Guid; JObject: JsonObject)
    var
        TaxComponentFormula: Record "Tax Component Formula";
        JToken: JsonToken;
        property: Text;
    begin
        TaxComponentFormula.Get(ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'ComponentName':
                    TaxComponentFormula."Component ID" := GetComponentID(TaxType, JToken2Text30(JToken));
                'Expression':
                    TaxComponentFormula.Expression := JToken2Text250(JToken);
                'Token':
                    ReadComponentExprTokens(TaxType, ID, JToken.AsArray());
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        TaxComponentFormula.Modify();
    end;

    local procedure ReadStringExpression(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionStringExpression: Record "Action String Expression";
        JToken: JsonToken;
        property: Text;
    begin
        ActionStringExpression.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'OutputVariableName':
                    ActionStringExpression."Variable ID" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                'Expression':
                    ActionStringExpression.Expression := JToken2Text250(JToken);
                'Token':
                    ReadStringExprTokens(ActionStringExpression."Case ID", ActionStringExpression."Script ID", ActionStringExpression.ID, JToken.AsArray());
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionStringExpression.Modify();
    end;

    local procedure ReadComponentFormulaExprToken(TaxType: Code[20]; ID: Guid; JObject: JsonObject)
    var
        TaxComponentFormulaToken: Record "Tax Component Formula Token";
        JToken: JsonToken;
        property: Text;
    begin
        TaxComponentFormulaToken.Init();
        TaxComponentFormulaToken."Tax Type" := TaxType;
        TaxComponentFormulaToken."Formula Expr. ID" := ID;

        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'ValueType':
                    TaxComponentFormulaToken."Value Type" := ScriptDataTypeMgmt.GetFieldOptionIndex(
                        Database::"Tax Component Formula Token", TaxComponentFormulaToken.FieldNo("Value Type"), JToken.AsValue().AsText());
                'TokenName':
                    begin
                        TaxComponentFormulaToken.Token := JToken2Text250(JToken);
                        TaxComponentFormulaToken.Insert();
                    end;
                'Value':
                    if TaxComponentFormulaToken."Value Type" = TaxComponentFormulaToken."Value Type"::Constant then
                        TaxComponentFormulaToken.Value := JToken2Text250(JToken)
                    else
                        TaxComponentFormulaToken."Component ID" := GetComponentID(TaxType, JToken2Text30(JToken));
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        TaxComponentFormulaToken.Modify();
    end;

    local procedure ReadStringExprToken(CaseID: Guid; ScriptID: Guid; ID: Guid; JObject: JsonObject)
    var
        ActionStringExprToken: Record "Action String Expr. Token";
        JToken: JsonToken;
        property: Text;
    begin
        ActionStringExprToken.Init();
        ActionStringExprToken."Case ID" := CaseID;
        ActionStringExprToken."Script ID" := ScriptID;
        ActionStringExprToken."String Expr. ID" := ID;

        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'LookupVariableName':
                    ConstantOrLookupText(
                        CaseID,
                        ScriptID,
                        ActionStringExprToken."Value Type",
                        ActionStringExprToken.Value,
                        ActionStringExprToken."Lookup ID",
                        JToken.AsObject());
                'TokenName':
                    begin
                        ActionStringExprToken.Token := JToken2Text250(JToken);
                        ActionStringExprToken.Insert();
                    end;
                'FormatString':
                    ActionStringExprToken."Format String" := JToken2Text50(JToken);
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionStringExprToken.Modify();
    end;

    local procedure ReadIfStatement(CaseID: Guid; ScriptID: Guid; ID: Guid; JObject: JsonObject)
    var
        ActionIfStatement: Record "Action If Statement";
        JToken: JsonToken;
        property: Text;
    begin
        ActionIfStatement.Get(CaseID, ScriptID, ID);

        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'Condition':
                    begin
                        ActionIfStatement."Condition ID" := JsonEntityMgmt.CreateCondition(CaseID, ScriptID);
                        ReadCondition(CaseID, ScriptID, ActionIfStatement."Condition ID", JToken.AsObject());
                    end;
                'Body':
                    ReadActionContainer(CaseID, ScriptID, ActionIfStatement.ID, "Container Action Type"::IFSTATEMENT, JToken.AsArray());
                'ElseIf':
                    begin
                        ActionIfStatement."Else If Block ID" := JsonEntityMgmt.AddAndGetElseIfStatement(CaseID, ScriptID, ActionIfStatement.ID);
                        ReadIfStatement(CaseID, ScriptID, ActionIfStatement."Else If Block ID", JToken.AsObject());
                    end;
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionIfStatement.Modify();
    end;

    local procedure ReadLoopNTimes(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionLoopNTimes: Record "Action Loop N Times";
        JToken: JsonToken;
        property: Text;
    begin
        ActionLoopNTimes.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'NValue':
                    ConstantOrLookupText(CaseID, ScriptID, ActionLoopNTimes."Value Type", ActionLoopNTimes.Value, ActionLoopNTimes."Lookup ID", JToken.AsObject());
                'Body':
                    ReadActionContainer(CaseID, ScriptID, ActionLoopNTimes.ID, "Container Action Type"::LOOPNTIMES, JToken.AsArray());
                'IndexVariable':
                    ActionLoopNTimes."Index Variable" := GetVariableID(CaseID, ScriptID, JToken2Text30(JToken));
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionLoopNTimes.Modify();
    end;

    local procedure ReadLoopWithCondition(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionLoopWithCondition: Record "Action Loop With Condition";
        JToken: JsonToken;
        property: Text;
    begin
        ActionLoopWithCondition.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'Condition':
                    begin
                        ActionLoopWithCondition."Condition ID" := JsonEntityMgmt.CreateCondition(CaseID, ScriptID);
                        ReadCondition(CaseID, ActionLoopWithCondition."Script ID", ActionLoopWithCondition."Condition ID", JToken.AsObject());
                    end;
                'Body':
                    ReadActionContainer(CaseID, ScriptID, ActionLoopWithCondition.ID, "Container Action Type"::LOOPWITHCONDITION, JToken.AsArray());
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionLoopWithCondition.Modify();
    end;

    local procedure ReadLoopThroughRecords(CaseID: Guid; ScriptID: Guid; ID: Guid; var JObject: JsonObject)
    var
        ActionLoopThroughRecords: Record "Action Loop Through Records";
        JToken: JsonToken;
        property: Text;
    begin
        ActionLoopThroughRecords.Get(CaseID, ScriptID, ID);
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'TableName':
                    ActionLoopThroughRecords."Table ID" := AppObjectHelper.GetObjectID(
                        ObjectType::Table,
                        JToken2Text30(JToken));
                'RecordVariableName':
                    ;
                'TableFilters':
                    begin
                        ActionLoopThroughRecords."Table Filter ID" :=
                            JsonEntityMgmt.CreateTableFilters(
                                CaseID,
                                ActionLoopThroughRecords."Script ID",
                                ActionLoopThroughRecords."Table ID");
                        ActionLoopThroughRecords.Modify();
                        ReadTableFilters(
                            GlobalUseCase.ID,
                            ActionLoopThroughRecords."Script ID",
                            ActionLoopThroughRecords."Table Filter ID",
                            JToken.AsArray());
                    end;
                'LoopThroughRecordFields':
                    ReadLoopThroughRecordFields(ActionLoopThroughRecords, JToken.AsArray());
                'Body':
                    ReadActionContainer(
                        CaseID,
                        ScriptID,
                        ActionLoopThroughRecords.ID,
                        "Container Action Type"::LOOPTHROUGHRECORDS,
                        JToken.AsArray());
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionLoopThroughRecords.Modify();

    end;

    local procedure ReadLoopThroughRecordsField(
        ActionLoopThroughRecords: Record "Action Loop Through Records"; JObject: JsonObject)
    var
        ActionLoopThroughRecField: Record "Action Loop Through Rec. Field";
        JToken: JsonToken;
        property: Text;
    begin
        ActionLoopThroughRecField.Init();
        ActionLoopThroughRecField."Case ID" := ActionLoopThroughRecords."Case ID";
        ActionLoopThroughRecField."Script ID" := ActionLoopThroughRecords."Script ID";
        ActionLoopThroughRecField."Loop ID" := ActionLoopThroughRecords.ID;
        ActionLoopThroughRecField."Table ID" := ActionLoopThroughRecords."Table ID";
        foreach property in JObject.Keys() do begin
            JObject.Get(property, JToken);
            case property of
                'FieldName':
                    begin
                        ActionLoopThroughRecField."Field ID" := AppObjectHelper.GetFieldID(
                            ActionLoopThroughRecords."Table ID",
                            JToken2Text30(JToken));
                        ActionLoopThroughRecField.Insert();
                    end;
                'VariableName':
                    ActionLoopThroughRecField."Variable ID" := GetVariableID(
                        ActionLoopThroughRecords."Case ID",
                        ActionLoopThroughRecords."Script ID",
                        JToken2Text30(JToken));
                else
                    Error(CannotReadPropertyErr, property);
            end;
        end;
        ActionLoopThroughRecField.Modify();
    end;

    local procedure ReadScriptAction(
        CaseID: Guid;
        ScriptID: Guid;
        ActionType: Enum "Action Type";
        var ActionID: Guid;
        JObject: JsonObject)
    var
        ActionJObject: JsonObject;
        AcitionNames: List of [Text];
    begin
        ActionJObject := JObject;
        AcitionNames := ActionType.Names();
        case ActionType of
            ActionType::IFSTATEMENT:
                ReadIfStatement(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::LOOPNTIMES:
                ReadLoopNTimes(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::LOOPWITHCONDITION:
                ReadLoopWithCondition(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::LOOPTHROUGHRECORDS:
                ReadLoopThroughRecords(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::COMMENT:
                ReadComment(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::NUMBERCALCULATION:
                ReadNumberCalculation(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::EXTRACTSUBSTRINGFROMPOSITION:
                ReadExtractSubstrFromPos(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::FINDINTERVALBETWEENDATES:
                ReadFindDateInterval(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::SETVARIABLE:
                ReadSetVariable(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::CONCATENATE:
                ReadConcatenate(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::FINDSUBSTRINGINSTRING:
                ReadFindSubstring(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::REPLACESUBSTRINGINSTRING:
                ReadRepaceSubstring(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::EXTRACTSUBSTRINGFROMINDEXOFSTRING:
                ReadExtractSubstringFromIndex(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::DATECALCULATION:
                ReadDateCalculation(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::DATETODATETIME:
                ReadDateToDateTime(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::ALERTMESSAGE:
                ReadMessage(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::EXTRACTDATEPART:
                ReadExtractDatePart(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::EXTRACTDATETIMEPART:
                ReadExtractDateTimePart(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::LENGTHOFSTRING:
                ReadLengthOfString(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::CONVERTCASEOFSTRING:
                ReadConvertCase(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::ROUNDNUMBER:
                ReadRoundNumber(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::NUMERICEXPRESSION:
                ReadNumberExpression(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::STRINGEXPRESSION:
                ReadStringExpression(CaseID, ScriptID, ActionID, ActionJObject);
            ActionType::EXITLOOP:
                ReadJsonProperty(JObject, Format(ActionType), '');
            ActionType::CONTINUE:
                ReadJsonProperty(JObject, Format(ActionType), '');
        end;
    end;

    local procedure ReadComponentCalculation(CaseID: Guid; ScriptID: Guid; JObject: JsonObject)
    var
        UseCaseComponentCalculation: Record "Use Case Component Calculation";
        TaxComponentExpression: Record "Tax Component Expression";
        JToken: JsonToken;
        FormulaJToken: JsonToken;
    begin
        UseCaseComponentCalculation.get(CaseID, UseCaseEntityMgmt.CreateComponentCalculation(CaseID));
        JObject.Get('ComponentName', JToken);
        UseCaseComponentCalculation."Component ID" := GetComponentID(GlobalUseCase."Tax Type", JToken2Text30(JToken));
        UseCaseComponentCalculation."Formula ID" := UseCaseEntityMgmt.CreateComponentExpression(
            CaseID,
            UseCaseComponentCalculation."Component ID");
        JObject.Get('Sequence', JToken);
        UseCaseComponentCalculation.Sequence := JToken.AsValue().AsInteger();
        JObject.Get('Formula', FormulaJToken);
        if FormulaJToken.AsObject().Get('Expression', JToken) then begin
            TaxComponentExpression.Get(CaseID, UseCaseComponentCalculation."Formula ID");
            TaxComponentExpression.Expression := JToken2Text250(JToken);
            TaxComponentExpression.Modify();
        end;

        if FormulaJToken.AsObject().Get('Tokens', JToken) then
            ReadComponentExprToken(
                CaseID,
                ScriptID,
                UseCaseComponentCalculation."Formula ID",
                JToken.AsArray());
        UseCaseComponentCalculation.Modify();
    end;

    local procedure GetNextVariableID(CaseID: Guid; ScriptID: Guid): Integer
    var
        Variables: Record "Script Variable";
    begin
        Variables.SetRange("Script ID", CaseID);
        Variables.SetRange("Script ID", ScriptID);
        if Variables.FindLast() then
            exit(Variables.ID + 10000);

        exit(10000)
    end;

    local procedure GetNextSortingLineNo(CaseID: Guid; ScriptID: Guid): Integer
    var
        LookupFieldSorting: Record "Lookup Field Sorting";
    begin
        LookupFieldSorting.SetRange("Script ID", CaseID);
        LookupFieldSorting.SetRange("Script ID", ScriptID);
        if LookupFieldSorting.FindLast() then
            exit(LookupFieldSorting."Line No." + 10000);

        exit(10000)
    end;

    local procedure GetNextConditionID(CaseID: Guid; ScriptID: Guid; ConditionID: Guid): Integer
    var
        ConditionItem: Record "Tax Test Condition Item";
    begin
        ConditionItem.SetRange("Case ID", CaseID);
        ConditionItem.SetRange("Script ID", ScriptID);
        ConditionItem.SetRange("Condition ID", ConditionID);
        if ConditionItem.FindLast() then
            exit(ConditionItem.ID + 10000);

        exit(10000)
    end;

    local procedure GetNextContainerLineNo(
        CaseID: Guid;
        ScriptID: Guid;
        ParentID: Guid;
        ParentType: Enum "Container Action Type"): Integer
    var
        ActionContainer: Record "Action Container";
    begin
        ActionContainer.SetRange("Case ID", CaseID);
        ActionContainer.SetRange("Script ID", ScriptID);
        ActionContainer.SetRange("Container Action ID", ParentID);
        ActionContainer.SetRange("Container Type", ParentType);
        if ActionContainer.FindLast() then
            exit(ActionContainer."Line No." + 10000);

        exit(10000)
    end;

    local procedure JToken2Text80(JToken: JsonToken): Text[80]
    begin
        exit(CopyStr(JToken2Text(JToken), 1, 80));
    end;

    local procedure JToken2Text50(JToken: JsonToken): Text[50]
    begin
        exit(CopyStr(JToken2Text(JToken), 1, 50));
    end;

    local procedure JToken2Text30(JToken: JsonToken): Text[30]
    begin
        exit(CopyStr(JToken2Text(JToken), 1, 30));
    end;

    local procedure JToken2Text20(JToken: JsonToken): Text[20]
    begin
        exit(CopyStr(JToken2Text(JToken), 1, 20));
    end;

    local procedure JToken2Text10(JToken: JsonToken): Text[10]
    begin
        exit(CopyStr(JToken2Text(JToken), 1, 10));
    end;

    local procedure JToken2Text100(JToken: JsonToken): Text[100]
    begin
        exit(CopyStr(JToken2Text(JToken), 1, 100));
    end;

    local procedure JToken2Text250(JToken: JsonToken): Text[250]
    begin
        exit(CopyStr(JToken2Text(JToken), 1, 250));
    end;

    local procedure JToken2Text(JToken: JsonToken): Text
    begin
        exit(JToken.AsValue().AsText());
    end;

    local procedure GetComponentID(TaxType: Code[20]): Integer
    var
        TaxComponent: Record "Tax Component";
    begin
        TaxComponent.SetCurrentKey(ID);
        TaxComponent.SetRange("Tax Type", TaxType);
        if TaxComponent.FindLast() then
            exit(TaxComponent.ID + 1);

        exit(1);
    end;

    local procedure GetText30PropertyValue(JObject: JsonObject; Name: Text): Text[30]
    var
        JToken: JsonToken;
    begin
        JObject.Get(Name, JToken);
        exit(JToken2Text30(JToken));
    end;

    local procedure GetCode20PropertyValue(JObject: JsonObject; Name: Text): Code[20]
    var
        JToken: JsonToken;
    begin
        JObject.Get(Name, JToken);
        exit(JToken2Text20(JToken));
    end;

    local procedure GetText250PropertyValue(JObject: JsonObject; Name: Text): Text[250]
    var
        JToken: JsonToken;
    begin
        JObject.Get(Name, JToken);
        exit(JToken2Text250(JToken));
    end;

    local procedure GetIntPropertyValue(JObject: JsonObject; Name: Text): Integer
    var
        JToken: JsonToken;
    begin
        if JObject.Get(Name, JToken) then
            exit(JToken.AsValue().AsInteger());
    end;

    local procedure GetGuidPropertyValue(JObject: JsonObject; Name: Text): Guid
    var
        JToken: JsonToken;
    begin
        if JObject.Get(Name, JToken) then
            exit(JToken.AsValue().AsText());
    end;

    local procedure GetDecimalPropertyValue(JObject: JsonObject; Name: Text): Decimal
    var
        JToken: JsonToken;
    begin
        if JObject.Get(Name, JToken) then
            exit(JToken.AsValue().AsDecimal());
    end;

    local procedure GetComponentID(TaxType: Code[20]; Name: Text[30]): Integer
    var
        TaxComponent: Record "Tax Component";
    begin
        if Name = '' then
            exit;
        TaxComponent.SetRange("Tax Type", TaxType);
        TaxComponent.SetRange(Name, Name);
        TaxComponent.FindFirst();
        exit(TaxComponent.ID);
    end;

    local procedure GetAttributeID(TaxType: Code[20]; Name: Text[30]): Integer
    var
        TaxAttribute: Record "Tax Attribute";
    begin
        if Name = '' then
            exit;
        TaxAttribute.SetFilter("Tax Type", '%1|%2', TaxType, '');
        TaxAttribute.SetRange(Name, Name);
        TaxAttribute.FindFirst();
        exit(TaxAttribute.ID);
    end;

    local procedure GetVariableID(CaseID: Guid; ScriptID: Guid; Name: Text[30]): Integer
    var
        UseCaseVariable: Record "Script Variable";
    begin
        if Name = '' then
            exit;
        UseCaseVariable.SetRange("Case ID", CaseID);
        UseCaseVariable.SetRange("Script ID", ScriptID);
        UseCaseVariable.SetRange(Name, Name);
        UseCaseVariable.FindFirst();
        exit(UseCaseVariable.ID);
    end;

    local procedure GetColumnID(TaxType: Code[20]; Name: Text[30]): Integer
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        if Name = '' then
            exit;
        TaxRateColumnSetup.SetFilter("Tax Type", TaxType);
        TaxRateColumnSetup.SetRange("Column Name", Name);
        TaxRateColumnSetup.FindFirst();
        exit(TaxRateColumnSetup."Column ID");
    end;

    local procedure GetDatabaseSymbolID(Name: Text[30]): Integer
    begin
        case Name of
            'UserId':
                exit("Database Symbol"::UserId.AsInteger());
            'COMPANYNAME':
                exit("Database Symbol"::COMPANYNAME.AsInteger());
            'SERIALNUMBER':
                exit("Database Symbol"::SERIALNUMBER.AsInteger());
            'TENANTID':
                exit("Database Symbol"::TENANTID.AsInteger());
            'SESSIONID':
                exit("Database Symbol"::SESSIONID.AsInteger());
            'SERVICEINSTANCEID':
                exit("Database Symbol"::SERVICEINSTANCEID.AsInteger());
        end;
    end;

    local procedure GetSystemSymbolID(Name: Text[30]): Integer
    begin
        case Name of
            'Today':
                exit("System Symbol"::Today.AsInteger());
            'TIME':
                exit("System Symbol"::TIME.AsInteger());
            'WorkDate':
                exit("System Symbol"::WorkDate.AsInteger());
            'CURRENTDATETIME':
                exit("System Symbol"::CURRENTDATETIME.AsInteger());
        end;
    end;

    local procedure GetPostingFieldSymbolID(Name: Text[30]): Integer
    begin
        case Name of
            'Gen. Bus. Posting Group':
                exit("Posting Field Symbol"::"Gen. Bus. Posting Group".AsInteger());
            'Gen. Prod. Posting Group':
                exit("Posting Field Symbol"::"Gen. Prod. Posting Group".AsInteger());
            'Dimension Set ID':
                exit("Posting Field Symbol"::"Dimension Set ID".AsInteger());
            'Posted Document No.':
                exit("Posting Field Symbol"::"Posted Document No.".AsInteger());
            'Posted Document Line No.':
                exit("Posting Field Symbol"::"Posted Document Line No.".AsInteger());
            'G/L Entry No.':
                exit("Posting Field Symbol"::"G/L Entry No.".AsInteger());
            'G/L Entry Transaction No.':
                exit("Posting Field Symbol"::"G/L Entry Transaction No.".AsInteger());
        end;
    end;

    procedure InitTaxTypeProgressWindow()
    begin
        if (not GuiAllowed()) or GlobalHideDialog then
            exit;

        TaxTypeDialog.Open(
             ImportingLbl +
             ValueLbl +
             TaxTypeImportStageLbl);
    end;

    local procedure UpdateTaxTypeProgressWindow(TaxType: Code[20]; Stage: Text)
    begin
        if (not GuiAllowed()) or GlobalHideDialog then
            exit;
        TaxTypeDialog.Update(1, TaxTypesLbl);
        TaxTypeDialog.Update(2, TaxType);
        TaxTypeDialog.Update(3, Stage);
    end;

    local procedure CloseTaxTypeProgressWindow()
    begin
        if (not GuiAllowed()) or GlobalHideDialog then
            exit;
        TaxTypeDialog.close();
    end;

    procedure InitUseCaseProgressWindow()
    begin
        if (not GuiAllowed()) or GlobalHideDialog then
            exit;

        UseCaseDialog.Open(
             ImportingLbl +
             SpaceLbl +
             ValueLbl +
             SpaceLbl +
             UseCaseNameLbl +
             SpaceLbl +
             UseCaseImportStageLbl);
    end;

    local procedure UpdateUseCaseProgressWindow(Stage: Text)
    begin
        if (not GuiAllowed()) or GlobalHideDialog then
            exit;
        UseCaseDialog.Update(1, UseCasesLbl);
        UseCaseDialog.Update(2, GlobalUseCase."Tax Type");
        UseCaseDialog.Update(3, GlobalUseCase.Description);
        UseCaseDialog.Update(4, Stage);
    end;

    local procedure CloseUseCaseProgressWindow()
    begin
        if (not GuiAllowed()) or GlobalHideDialog then
            exit;
        UseCaseDialog.close();
    end;

    local procedure LogTaxTypeUpgradeTelemetry(TaxType: Code[20]; VersionTxt: Text)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add('TaxType', TaxType);
        Dimensions.Add('Version', VersionTxt);

        Session.LogMessage(
            'TE-TAXTYPE-UPGRADE',
            TaxTypeUpgradedTxt,
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            Dimensions);
    end;

    local procedure LogTaxTypeImportTelemetry(TaxType: Code[20]; VersionTxt: Text)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add('TaxType', TaxType);
        Dimensions.Add('Version', VersionTxt);

        Session.LogMessage(
            'TE-TAXTYPE-IMPORT',
            TaxTypeImportedTxt,
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            Dimensions);
    end;

    local procedure LogUseCaseUpgradedTelemetry(CaseId: Guid; VersionTxt: Text)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add('CaseID', CaseId);
        Dimensions.Add('Version', VersionTxt);

        Session.LogMessage(
            'TE-USECASE-UPGRADE',
            UseCaseUpgradedTxt,
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            Dimensions);
    end;

    local procedure LogUseCaseImportTelemetry(CaseId: Guid; VersionTxt: Text)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add('CaseID', CaseId);
        Dimensions.Add('Version', VersionTxt);

        Session.LogMessage(
            'TE-USECASE-IMPORT',
            UseCaseImportedTxt,
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            Dimensions);
    end;

    local procedure GetVersionText(Major: Integer; Minor: Integer): Text
    begin
        exit(StrSubstNo(VersionLbl, Major, Minor));
    end;

    var
        GlobalUseCase: Record "Tax Use Case";
        UseCaseMgmt: Codeunit "Use Case Mgmt.";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TypeHelper: Codeunit "Type Helper";
        JsonEntityMgmt: Codeunit "Json Entity Mgmt.";
        TaxPostingHelper: Codeunit "Tax Posting Helper";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        SwitchStatementHelper: Codeunit "Switch Statement Helper";
        AppObjectHelper: Codeunit "App Object Helper";
        TaxTypeDialog: Dialog;
        UseCaseDialog: Dialog;
        EmptyGuid: Guid;
        GlobalCaseId: Guid;
        CanImportUseCases: Boolean;
        GlobalHideDialog: Boolean;
        GlobalSkipIndentation: Boolean;
        GlobalSkipVersionCheck: Boolean;
        VersionLbl: Label '%1.%2', Comment = '%1 - Major Version, %2 - Minor Version';
        TaxTypeImportedTxt: Label 'Tax Type Imported.', Locked = true;
        TaxTypeUpgradedTxt: Label 'Tax Type Upgraded.', Locked = true;
        UseCaseImportedTxt: Label 'Use Case Imported.', Locked = true;
        UseCaseUpgradedTxt: Label 'Use Case Upgraded.', Locked = true;
        CannotReadPropertyErr: Label 'Cannot read property %1.', Comment = '%1 = Property name.';
        InvalidPropertyErr: Label 'Invalid Property';
        ColumnNameNotFoundErr: Label 'Column name %1 doest not exist for Tax Type : %2 and Use Case :%3.', Comment = '%1 = Column Name,%2 = Tax Type, %3 = use case name';
        TaxTypesLbl: Label 'Tax Types';
        UseCasesLbl: Label 'Use Cases';
        SpaceLbl: Label '              #######\';
        ImportingLbl: Label 'Importing              #1######\', Comment = 'Tax Type or Use Cases';
        ValueLbl: Label 'Tax Type              #2######\', Comment = 'Tax Type';
        UseCaseNameLbl: Label 'Name              #3######\', Comment = 'Use Case Description';
        TaxTypeImportStageLbl: Label 'Stage      #3######\', Comment = 'Stage of Import for Tax Type';
        UseCaseImportStageLbl: Label 'Stage      #4######\', Comment = 'Stage of Import for Use Case';
}