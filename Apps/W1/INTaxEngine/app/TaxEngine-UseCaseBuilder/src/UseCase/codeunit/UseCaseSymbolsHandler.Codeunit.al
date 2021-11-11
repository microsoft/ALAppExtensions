codeunit 20297 "Use Case Symbols Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbols Mgmt.", 'OnInitScriptSymbols', '', false, false)]
    procedure OnInitScriptSymbols(
        var sender: Codeunit "Script Symbols Mgmt.";
        TaxType: Code[20];
        ScriptID: Guid;
        var Symbols: Record "Script Symbol" temporary);
    begin
        if TaxType <> '' then begin
            InsertTaxAttributes(sender, TaxType);
            InsertTaxComponents(sender, TaxType);
            InsertTaxRateColumns(sender, TaxType);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbol Store", 'OnInitSymbols', '', false, false)]
    local procedure OnInitSymbols(sender: Codeunit "Script Symbol Store"; CaseID: Guid; ScriptID: Guid; var Symbols: Record "Script Symbol Value")
    begin
        InitTaxAttributes(sender, CaseID, Symbols);
        InitTaxComponent(sender, CaseID, Symbols);
        InitTaxColumn(sender, CaseID, Symbols);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbol Store", 'OnGetLookupValue', '', false, false)]
    local procedure OnGetLookupValue(sender: Codeunit "Script Symbol Store"; var SourceRecordRef: RecordRef; ScriptSymbolLookup: Record "Script Symbol Lookup"; var IsHandled: Boolean; var Value: Variant)
    begin
        case ScriptSymbolLookup."Source Type" of
            ScriptSymbolLookup."Source Type"::"Tax Attributes",
            ScriptSymbolLookup."Source Type"::Component,
            ScriptSymbolLookup."Source Type"::"Component Amount (LCY)",
            ScriptSymbolLookup."Source Type"::Column,
            ScriptSymbolLookup."Source Type"::"Component Percent",
            ScriptSymbolLookup."Source Type"::"Attribute Code",
            ScriptSymbolLookup."Source Type"::"Attribute Name",
            ScriptSymbolLookup."Source Type"::"Component Code",
            ScriptSymbolLookup."Source Type"::"Component Name":
                begin
                    sender.GetSymbolOfType(
                        ScriptSymbolLookup."Source Type",
                        ScriptSymbolLookup."Source Field ID",
                        Value);
                    IsHandled := true;
                end;
            ScriptSymbolLookup."Source Type"::"Attribute Table":
                begin
                    GetTableAttributeValue(sender, SourceRecordRef, ScriptSymbolLookup, Value);
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Lookup Mgmt.", 'OnGetSymbolDataType', '', false, false)]
    local procedure OnGetSymbolDataType(ScriptSymbolLookup: Record "Script Symbol Lookup"; var Datatype: Enum "Symbol Data Type")
    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
    begin
        ScriptSymbolsMgmt.SetContext(ScriptSymbolLookup."Case ID", ScriptSymbolLookup."Script ID");
        case ScriptSymbolLookup."Source Type" of
            ScriptSymbolLookup."Source Type"::"Tax Attributes", ScriptSymbolLookup."Source Type"::"Attribute Table":
                Datatype := ScriptSymbolsMgmt.GetSymbolDataType(
                        ScriptSymbolLookup."Source Type"::"Tax Attributes",
                        ScriptSymbolLookup."Source Field ID");
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Script Symbol Lookup Dialog", 'OnIsSourceTypeSymbolType', '', false, false)]
    local procedure OnIsSourceTypeSymbolType(SymbolType: Enum "Symbol Type"; var IsHandled: Boolean; var IsSymbol: Boolean)
    begin
        case SymbolType of
            SymbolType::"Tax Attributes",
           SymbolType::"Component Percent",
           SymbolType::"Component Amount (LCY)",
           SymbolType::"Component Code",
           SymbolType::"Component Name",
           SymbolType::"Attribute Code",
           SymbolType::"Attribute Name",
           SymbolType::Component,
           SymbolType::Column:
                begin
                    IsHandled := true;
                    IsSymbol := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Script Symbols Mgmt.", 'OnGetTaxType', '', false, false)]
    local procedure OnGetTaxType(CaseID: Guid; var TaxType: Code[20]; var Handled: Boolean; var NotFound: Boolean)
    var
        UseCase: Record "Tax Use Case";
    begin
        if IsNullGuid(CaseID) or Handled then
            exit;

        Handled := true;

        if TaxType = '' then begin
            if not UseCase.Get(CaseID) then
                NotFound := true;

            TaxType := UseCase."Tax Type";
        end;
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Tax Use Case", 'OnAfterInsertEvent', '', false, false)]
    procedure OnAfterInsertTaxUseCase(RunTrigger: Boolean; var Rec: Record "Tax Use Case")
    begin
        if Rec.IsTemporary() then
            exit;

        if not RunTrigger then
            exit;

        BuildUseCaseTree(rec."Tax Type");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Lookup Mgmt.", 'OnGetLookupSourceTableID', '', false, false)]
    local procedure OnGetLookupSourceTableID(CaseID: Guid; var TableID: Integer; var Handled: Boolean)
    var
        UseCase: Record "Tax Use Case";
    begin
        if not UseCase.Get(CaseID) then
            exit;
        TableID := UseCase."Tax Table ID";
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, database::"Tax Attribute", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeTaxAttribtueDeleteEvent(var Rec: Record "Tax Attribute"; RunTrigger: Boolean)
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        UseCaseAttributeMapping: Record "Use Case Attribute Mapping";
        ArchivalSingleInstance: Codeunit "Archival Single Instance";
    begin
        if Rec.IsTemporary() then
            exit;

        if not RunTrigger then
            exit;

        if ArchivalSingleInstance.GetSkipTaxAttribute() then
            exit;

        ScriptSymbolLookup.SetFilter("Source Type", '%1|%2', ScriptSymbolLookup."Source Type"::"Attribute Table", ScriptSymbolLookup."Source Type"::"Tax Attributes");
        ScriptSymbolLookup.SetRange("Source Field ID", Rec.ID);
        if ScriptSymbolLookup.FindFirst() then
            ThrowAttributeInUseError(Rec."Tax Type", Rec.Name, ScriptSymbolLookup."Case ID");

        UseCaseAttributeMapping.SetRange("Attribtue ID", Rec.ID);
        if UseCaseAttributeMapping.FindFirst() then
            ThrowAttributeInUseError(Rec."Tax Type", Rec.Name, UseCaseAttributeMapping."Case ID");
    end;

    [EventSubscriber(ObjectType::Table, database::"Tax Component", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeTaxComponentDeleteEvent(var Rec: Record "Tax Component"; RunTrigger: Boolean)
    var
        UseCaseComponentCalculation: Record "Use Case Component Calculation";
        ScriptSymbolLookup: Record "Script Symbol Lookup";
        ArchivalSingleInstance: Codeunit "Archival Single Instance";
    begin
        if Rec.IsTemporary() then
            exit;

        if not RunTrigger then
            exit;

        if ArchivalSingleInstance.GetSkipTaxComponent() then
            exit;

        ScriptSymbolLookup.SetFilter("Source Type", '%1|%2', ScriptSymbolLookup."Source Type"::Component, ScriptSymbolLookup."Source Type"::"Component Percent");
        ScriptSymbolLookup.SetRange("Source Field ID", Rec.ID);
        if ScriptSymbolLookup.FindFirst() then
            ThrowComponentInUseError(Rec."Tax Type", Rec.Name, ScriptSymbolLookup."Case ID");

        UseCaseComponentCalculation.SetRange("Component ID", Rec.ID);
        if UseCaseComponentCalculation.FindFirst() then
            ThrowComponentInUseError(Rec."Tax Type", Rec.Name, UseCaseComponentCalculation."Case ID");
        ScriptSymbolLookup.SetFilter("Source Type", '%1|%2', ScriptSymbolLookup."Source Type"::Component, ScriptSymbolLookup."Source Type"::"Component Percent");
        ScriptSymbolLookup.SetRange("Source Field ID", Rec.ID);
        if ScriptSymbolLookup.FindFirst() then
            ThrowComponentInUseError(Rec."Tax Type", Rec.Name, ScriptSymbolLookup."Case ID");

        UseCaseComponentCalculation.SetRange("Component ID", Rec.ID);
        if UseCaseComponentCalculation.FindFirst() then
            ThrowComponentInUseError(Rec."Tax Type", Rec.Name, UseCaseComponentCalculation."Case ID");
    end;


    local procedure InsertTaxAttributes(
            var sender: Codeunit "Script Symbols Mgmt.";
            TaxType: Code[20]);
    var
        TaxAttribute: Record "Tax Attribute";
    begin
        TaxAttribute.reset();
        TaxAttribute.SetFilter("Tax Type", '%1|%2', TaxType, '');
        if TaxAttribute.FindSet() then
            repeat
                sender.InsertScriptSymbol(
                    "Symbol Type"::"Tax Attributes",
                    TaxAttribute.ID,
                    TaxAttribute.Name,
                    DataTypeMgmg.GetAttributeDataTypeToVariableDataType(TaxAttribute.Type));

                sender.InsertScriptSymbol(
                    "Symbol Type"::"Attribute Code",
                    TaxAttribute.ID,
                    TaxAttribute.Name,
                    "Symbol Data Type"::Number);

                sender.InsertScriptSymbol(
                    "Symbol Type"::"Attribute Name",
                    TaxAttribute.ID,
                    TaxAttribute.Name,
                    "Symbol Data Type"::String);
            until TaxAttribute.Next() = 0;
    end;

    local procedure InsertTaxComponents(
        var sender: Codeunit "Script Symbols Mgmt.";
        TaxType: Code[20]);
    var
        TaxComponent: Record "Tax Component";
    begin
        TaxComponent.reset();
        TaxComponent.SetFilter("Tax Type", '%1|%2', TaxType, '');
        if TaxComponent.FindSet() then
            repeat
                sender.InsertScriptSymbol(
                    "Symbol Type"::Component,
                    TaxComponent.ID,
                    TaxComponent.Name,
                    "Symbol Data Type"::Number,
                    TaxComponent."Formula ID");

                sender.InsertScriptSymbol(
                    "Symbol Type"::"Component Percent",
                    TaxComponent.ID,
                    TaxComponent.Name,
                    "Symbol Data Type"::Number);

                sender.InsertScriptSymbol(
                    "Symbol Type"::"Component Code",
                    TaxComponent.ID,
                    TaxComponent.Name,
                    "Symbol Data Type"::Number);

                sender.InsertScriptSymbol(
                    "Symbol Type"::"Component Name",
                    TaxComponent.ID,
                    TaxComponent.Name,
                    "Symbol Data Type"::String);

                sender.InsertScriptSymbol(
                    "Symbol Type"::"Component Amount (LCY)",
                    TaxComponent.ID,
                    TaxComponent.Name,
                    "Symbol Data Type"::Number,
                    TaxComponent."Formula ID");
            until TaxComponent.Next() = 0;
    end;

    local procedure InsertTaxRateColumns(
        var sender: Codeunit "Script Symbols Mgmt.";
        TaxType: Code[20]);
    var
        TaxRateSetup: Record "Tax Rate Column Setup";
    begin
        TaxRateSetup.Reset();
        TaxRateSetup.SetRange("Tax Type", TaxType);
        TaxRateSetup.SetFilter("Column Type", '%1|%2|%3|%4|%5',
            TaxRateSetup."Column Type"::Value,
            TaxRateSetup."Column Type"::"Output Information",
            TaxRateSetup."Column Type"::"Range From",
            TaxRateSetup."Column Type"::"Range To",
            TaxRateSetup."Column Type"::"Range From and Range To");
        if TaxRateSetup.FindSet() then
            repeat
                sender.InsertScriptSymbol(
                    "Symbol Type"::Column,
                    TaxRateSetup."Column ID",
                    TaxRateSetup."Column Name",
                    DataTypeMgmg.GetAttributeDataTypeToVariableDataType(TaxRateSetup.Type));
            until TaxRateSetup.Next() = 0;
    end;

    local procedure InitTaxAttributes(sender: Codeunit "Script Symbol Store"; CaseID: Guid; var Symbols: Record "Script Symbol Value");
    var
        UseCase: Record "Tax Use Case";
        TaxAttribute: Record "Tax Attribute";
        Value: Variant;
    begin
        if not UseCase.Get(CaseID) then
            exit;
        TaxAttribute.Reset();
        TaxAttribute.SetFilter("Tax Type", '%1|%2', UseCase."Tax Type", '');
        if TaxAttribute.FindSet() then
            repeat
                Symbols.SetRange("Symbol ID", TaxAttribute.ID);
                Symbols.SetRange(Type, Symbols.Type::"Tax Attributes");
                if Symbols.FindFirst() then begin
                    sender.GetSymbolValue(Symbols, Value);
                    sender.InsertSymbolValue("Symbol Type"::"Tax Attributes", UseCaseDataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxAttribute.Type), TaxAttribute.ID, Value);
                end else
                    sender.InsertSymbolValue("Symbol Type"::"Tax Attributes", UseCaseDataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxAttribute.Type), TaxAttribute.ID);

                Symbols.SetRange("Symbol ID", TaxAttribute.ID);
                Symbols.SetRange(Type, Symbols.Type::"Attribute Code");
                if Symbols.FindFirst() then begin
                    sender.GetSymbolValue(Symbols, Value);
                    sender.InsertSymbolValue("Symbol Type"::"Attribute Code", "Symbol Data Type"::Number, TaxAttribute.ID, Value);
                end else
                    sender.InsertSymbolValue("Symbol Type"::"Attribute Code", "Symbol Data Type"::Number, TaxAttribute.ID, TaxAttribute.ID);

                Symbols.SetRange("Symbol ID", TaxAttribute.ID);
                Symbols.SetRange(Type, Symbols.Type::"Attribute Name");
                if Symbols.FindFirst() then begin
                    sender.GetSymbolValue(Symbols, Value);
                    sender.InsertSymbolValue("Symbol Type"::"Attribute Name", "Symbol Data Type"::String, TaxAttribute.ID, Value);
                end else
                    sender.InsertSymbolValue("Symbol Type"::"Attribute Name", "Symbol Data Type"::String, TaxAttribute.ID, TaxAttribute.Name);
            until TaxAttribute.Next() = 0;
    end;

    local procedure InitTaxComponent(sender: Codeunit "Script Symbol Store"; CaseID: Guid; var Symbols: Record "Script Symbol Value");
    var
        TaxComponent: Record "Tax Component";
        UseCase: Record "Tax Use Case";
        Value: Variant;
    begin
        if not UseCase.Get(CaseID) then
            exit;
        TaxComponent.Reset();
        TaxComponent.SetRange("Tax Type", UseCase."Tax Type");
        if TaxComponent.FindSet() then
            repeat
                Symbols.SetRange("Symbol ID", TaxComponent.ID);
                Symbols.SetRange(Type, Symbols.Type::Component);
                if Symbols.FindFirst() then begin
                    sender.GetSymbolValue(Symbols, Value);
                    sender.InsertSymbolValue("Symbol Type"::Component, "Symbol Data Type"::Number, TaxComponent.ID, Value);
                end else
                    sender.InsertSymbolValue("Symbol Type"::Component, "Symbol Data Type"::Number, TaxComponent.ID);

                Symbols.SetRange("Symbol ID", TaxComponent.ID);
                Symbols.SetRange(Type, Symbols.Type::"Component Amount (LCY)");
                if Symbols.FindFirst() then begin
                    sender.GetSymbolValue(Symbols, Value);
                    sender.InsertSymbolValue("Symbol Type"::"Component Amount (LCY)", "Symbol Data Type"::Number, TaxComponent.ID, Value);
                end else
                    sender.InsertSymbolValue("Symbol Type"::"Component Amount (LCY)", "Symbol Data Type"::Number, TaxComponent.ID);

                Symbols.SetRange("Symbol ID", TaxComponent.ID);
                Symbols.SetRange(Type, Symbols.Type::"Component Code");
                if Symbols.FindFirst() then begin
                    sender.GetSymbolValue(Symbols, Value);
                    sender.InsertSymbolValue("Symbol Type"::"Component Code", "Symbol Data Type"::Number, TaxComponent.ID, Value);
                end else
                    sender.InsertSymbolValue("Symbol Type"::"Component Code", "Symbol Data Type"::Number, TaxComponent.ID, TaxComponent.ID);

                Symbols.SetRange("Symbol ID", TaxComponent.ID);
                Symbols.SetRange(Type, Symbols.Type::"Component Name");
                if Symbols.FindFirst() then begin
                    sender.GetSymbolValue(Symbols, Value);
                    sender.InsertSymbolValue("Symbol Type"::"Component Name", "Symbol Data Type"::String, TaxComponent.ID, Value);
                end else
                    sender.InsertSymbolValue("Symbol Type"::"Component Name", "Symbol Data Type"::String, TaxComponent.ID, TaxComponent.Name);

                Symbols.SetRange("Symbol ID", TaxComponent.ID);
                Symbols.SetRange(Type, Symbols.Type::"Component Percent");
                if Symbols.FindFirst() then begin
                    sender.GetSymbolValue(Symbols, Value);
                    sender.InsertSymbolValue("Symbol Type"::"Component Percent", "Symbol Data Type"::Number, TaxComponent.ID, Value);
                end else
                    sender.InsertSymbolValue("Symbol Type"::"Component Percent", "Symbol Data Type"::Number, TaxComponent.ID);
            until TaxComponent.Next() = 0;
    end;

    local procedure InitTaxColumn(sender: Codeunit "Script Symbol Store"; CaseID: Guid; var Symbols: Record "Script Symbol Value");
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        UseCase: Record "Tax Use Case";
        Value: Variant;
    begin
        if not UseCase.Get(CaseID) then
            exit;
        TaxRateColumnSetup.Reset();
        TaxRateColumnSetup.Setfilter("Tax Type", '%1|%2', UseCase."Tax Type", '');
        TaxRateColumnSetup.SetFilter("Column Type", '%1|%2|%3|%4|%5', TaxRateColumnSetup."Column Type"::"Range From and Range To", TaxRateColumnSetup."Column Type"::Value, TaxRateColumnSetup."Column Type"::"Range From", TaxRateColumnSetup."Column Type"::"Range To", TaxRateColumnSetup."Column Type"::"Output Information");
        if TaxRateColumnSetup.FindSet() then
            repeat
                Symbols.SetRange("Symbol ID", TaxRateColumnSetup."Column ID");
                Symbols.SetRange(Type, Symbols.Type::Column);
                if Symbols.FindFirst() then begin
                    sender.GetSymbolValue(Symbols, Value);

                    sender.InsertSymbolValue(
                        "Symbol Type"::Column,
                        UseCaseDataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxRateColumnSetup.Type),
                        TaxRateColumnSetup."Column ID",
                        Value);
                end else
                    sender.InsertSymbolValue(
                        "Symbol Type"::Column,
                        UseCaseDataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxRateColumnSetup.Type),
                        TaxRateColumnSetup."Column ID");

            until TaxRateColumnSetup.Next() = 0;
    end;

    local procedure GetTableAttributeValue(var Sender: Codeunit "Script Symbol Store"; SourceRecRef: RecordRef; var ScriptSymbolLookup: Record "Script Symbol Lookup"; var Value: Variant);
    var
        RecRef: RecordRef;
    begin
        if ScriptSymbolLookup."Source ID" = 0 then
            exit;

        Clear(Value);

        RecRef.OPEN(ScriptSymbolLookup."Source ID");
        Sender.ApplyTableFilters(SourceRecRef, ScriptSymbolLookup."Case ID", ScriptSymbolLookup."Script ID", RecRef, ScriptSymbolLookup."Table Filter ID");
        if RecRef.FindFirst() then
            UseCaseVariableMgmt.GetTaxAttributeValue(ScriptSymbolLookup."Case ID", RecRef, ScriptSymbolLookup."Source Field ID", Value);

        RecRef.Close();
    end;

    local procedure AppendChildUseCases(TaxType: Code[20]; ParentCaseID: Guid; var PresentationOrder: Integer; Indent: Integer)
    var
        UseCase: Record "Tax Use Case";
    begin
        UseCase.SetRange("Tax Type", TaxType);
        UseCase.SetRange("Parent Use Case ID", ParentCaseID);
        if UseCase.FindSet() then
            repeat
                PresentationOrder += 1;
                UseCase."Indentation Level" := Indent;
                UseCase."Presentation Order" := PresentationOrder;
                UseCase.Modify();
                AppendChildUseCases(UseCase."Tax Type", UseCase.ID, PresentationOrder, Indent + 1);
            until UseCase.Next() = 0;
    end;

    local procedure ThrowAttributeInUseError(TaxType: Code[20]; AttributeName: Text; CaseID: Guid)
    var
        UseCase: Record "Tax Use Case";
    begin
        if not UseCase.Get(CaseID) then
            exit;
        if TaxType = UseCase."Tax Type" then
            Error(AttributeUsedInUseCaseErr, AttributeName, UseCase.Description);
    end;

    local procedure BuildUseCaseTree(TaxType: Code[20])
    var
        PresentationOrder: Integer;
    begin
        AppendChildUseCases(TaxType, EmptyGuid, PresentationOrder, 0);
    end;

    local procedure ThrowComponentInUseError(TaxType: Code[20]; ComponentName: Text; CaseID: Guid)
    var
        UseCase: Record "Tax Use Case";
    begin
        if not UseCase.Get(CaseID) then
            exit;
        if UseCase."Tax Type" = TaxType then
            error(ComponentUsedInUseCaseErr, ComponentName, UseCase.Description);
    end;

    var
        DataTypeMgmg: Codeunit "Use Case Data Type Mgmt.";
        UseCaseDataTypeMgmt: Codeunit "Use Case Data Type Mgmt.";
        UseCaseVariableMgmt: Codeunit "Use Case Variables Mgmt.";
        AttributeUsedInUseCaseErr: Label 'You cannot delete Attribute %1 as it is in use on Use Case : %2.',
            Comment = '%1 = Attribute Name, %2 = Use Case Name.';
        ComponentUsedInUseCaseErr: Label 'You cannot delete Component %1 as it is in use on Use Case : %2.',
            Comment = '%1 = Component Name, %2 = Use Case Name.';
        EmptyGuid: Guid;
}