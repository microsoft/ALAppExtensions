codeunit 20342 "Tax Document Subledger Posting"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Document GL Posting", 'OnAfterPostTaxGLEntry', '', false, false)]
    procedure OnAfterPostTaxGLEntry(
        var TempTaxPostingBuffer: Record "Transaction Posting Buffer" temporary;
        var TempTransactionValue: Record "Tax Transaction Value" temporary;
        var Record: Variant)
    var
        TaxPostingKeys: Dictionary of [Text, List of [RecordID]];
        GroupKey: Text;
        RecordVariant: Variant;
    begin
        GenLineRecord := Record;
        RecordVariant := TempTransactionValue."Tax Record ID";
        GroupTaxPostingBuffer(TempTransactionValue, TaxPostingKeys);

        foreach GroupKey in TaxPostingKeys.Keys do
            CreateTaxSubledger(TempTaxPostingBuffer, TaxPostingKeys.Get(GroupKey), TempTransactionValue);
    end;

    local procedure GroupTaxPostingBuffer(var TempTransactionValue: Record "Tax Transaction Value" temporary; TaxPostingKeysBuffer: Dictionary of [Text, List of [RecordId]])
    var
        RecIDList: List of [RecordId];
        GroupKey: Text;
    begin
        TempTransactionValue.SetCurrentKey("Tax Record ID", "Value ID");
        TempTransactionValue.SetRange("Value Type", TempTransactionValue."Value Type"::ATTRIBUTE);
        if TempTransactionValue.FindSet() then
            repeat
                GroupKey := GetAttributesKey(TempTransactionValue);
                if TaxPostingKeysBuffer.ContainsKey(GroupKey) then
                    RecIDList := TaxPostingKeysBuffer.Get(GroupKey)
                else begin
                    Clear(RecIDList);
                    TaxPostingKeysBuffer.Add(GroupKey, RecIDList);
                end;
                RecIDList.Add(TempTransactionValue."Tax Record ID");
            until TempTransactionValue.Next() = 0;
    end;

    local procedure CreateTaxSubledger(
        var TempTaxPostingBuffer: Record "Transaction Posting Buffer" temporary;
        RecIDList: List of [RecordID];
        var TempTransactionValue: Record "Tax Transaction Value" temporary)
    var
        TempSymbols: Record "Script Symbol Value" temporary;
        RecRef: RecordRef;
        FirstRecID: RecordId;
        RecordVariant: Variant;
        RecIDListEmptyErr: Label 'RecordID List is empty';
    begin
        if RecIDList.Count = 0 then
            Error(RecIDListEmptyErr);

        FirstRecID := RecIDList.Get(1);

        PopulateAttributeRateColumnVariables(FirstRecID, TempTransactionValue, TempSymbols);
        PopulateComponentVariables(RecIDList, TempTransactionValue, TempSymbols);

        RecRef.Get(FirstRecID);
        if RecRef.Number = Database::"Gen. Journal Line" then
            RecordVariant := GenLineRecord
        else
            RecordVariant := FirstRecID;

        PopulatePostingFieldVariablesAndExecute(
            TempTaxPostingBuffer,
            TempSymbols,
            RecordVariant);
    end;

    local procedure PopulatePostingFieldVariablesAndExecute(
        var TempTaxPostingBuffer: Record "Transaction Posting Buffer" temporary;
        var Symbols: Record "Script Symbol Value" temporary;
        var Record: Variant);
    var
        TaxComponent: Record "Tax Component";
        UseCase: Record "Tax Use Case";
        TaxPostingExecution: Codeunit "Tax Posting Execution";
        GroupingType: Option "Component","Line / Component";
        NewCaseID: Guid;
    begin
        TaxComponent.Get(TempTaxPostingBuffer."Tax Type", TempTaxPostingBuffer."Component ID");
        if TaxComponent."Skip Posting" then
            exit;

        SymbolStore.SetDefaultSymbolValue(
            Symbols,
            Symbols.Type::"Posting Field",
            PostingFieldSymbol::"Gen. Bus. Posting Group".AsInteger(),
            TempTaxPostingBuffer."Gen. Bus. Posting Group",
            SymbolDataType::STRING);

        SymbolStore.SetDefaultSymbolValue(
            Symbols,
            Symbols.Type::"Posting Field",
            PostingFieldSymbol::"Gen. Prod. Posting Group".AsInteger(),
            TempTaxPostingBuffer."Gen. Prod. Posting Group",
            SymbolDataType::STRING);

        SymbolStore.SetDefaultSymbolValue(
            Symbols,
            Symbols.Type::"Posting Field",
            PostingFieldSymbol::"Dimension Set ID".AsInteger(),
            TempTaxPostingBuffer."Dimension Set ID",
            SymbolDataType::NUMBER);

        SymbolStore.SetDefaultSymbolValue(
            Symbols,
            Symbols.Type::"Posting Field",
            PostingFieldSymbol::"Posted Document No.".AsInteger(),
            TempTaxPostingBuffer."Posted Document No.",
            SymbolDataType::STRING);

        SymbolStore.SetDefaultSymbolValue(
            Symbols,
            Symbols.Type::"Posting Field",
            PostingFieldSymbol::"G/L Entry No.".AsInteger(),
            TempTaxPostingBuffer."G/L Entry No",
            SymbolDataType::NUMBER);

        SymbolStore.SetDefaultSymbolValue(
            Symbols,
            Symbols.Type::"Posting Field",
            PostingFieldSymbol::"G/L Entry Transaction No.".AsInteger(),
            TempTaxPostingBuffer."G/L Entry Transaction No.",
            SymbolDataType::NUMBER);

        if GetPostingUseCaseID(
            TempTaxPostingBuffer."Case ID",
            TaxComponent.ID,
            GroupingType::Component,
            NewCaseID) then begin
            UseCase.Get(NewCaseID);
            TaxPostingExecution.ExecutePosting(
                UseCase,
                Record,
                Symbols,
                TempTaxPostingBuffer."Component ID",
                GroupingType::Component);
        end;
    end;

    local procedure PopulateComponentVariables(
        RecIDList: List of [RecordId];
        var TempTransactionValue: Record "Tax Transaction Value" temporary;
        var Symbols: Record "Script Symbol Value" temporary);
    var
        TempTransactionValue2: Record "Tax Transaction Value" temporary;
    begin
        GroupByComponent(RecIDList, TempTransactionValue, TempTransactionValue2);

        TempTransactionValue2.Reset();
        if TempTransactionValue2.FindSet() then
            repeat
                SymbolStore.SetDefaultSymbolValue(
                    Symbols,
                    Symbols.Type::Component,
                    TempTransactionValue2."Value ID",
                    TempTransactionValue2.Amount,
                    SymbolDataType::NUMBER);
                SymbolStore.SetDefaultSymbolValue(
                    Symbols,
                    Symbols.Type::"Component Percent",
                    TempTransactionValue2."Value ID",
                    TempTransactionValue2.Percent,
                    SymbolDataType::NUMBER);
            until TempTransactionValue2.Next() = 0;
    end;

    local procedure GroupByComponent(
        RecIDList: List of [RecordId];
        var TempTransactionValue: Record "Tax Transaction Value";
        var TempTransactionValue2: Record "Tax Transaction Value" temporary)
    var
        TempTransactionValue3: Record "Tax Transaction Value" temporary;
        RecID: RecordId;
    begin
        foreach RecID in RecIDList do begin
            TempTransactionValue.Reset();
            TempTransactionValue.SetRange("Tax Record ID", RecID);
            TempTransactionValue.SetRange("Value Type", TempTransactionValue."Value Type"::COMPONENT);
            if TempTransactionValue.FindSet() then
                repeat
                    TempTransactionValue3.Reset();
                    TempTransactionValue3.SetRange("Tax Record ID", TempTransactionValue."Tax Record ID");
                    TempTransactionValue3.SetRange("Value ID", TempTransactionValue."Value ID");
                    if TempTransactionValue3.IsEmpty() then begin
                        TempTransactionValue2.Reset();
                        TempTransactionValue2.SetRange("Value ID", TempTransactionValue."Value ID");
                        if not TempTransactionValue2.FindFirst() then begin
                            TempTransactionValue2 := TempTransactionValue;
                            TempTransactionValue2.Insert();
                        end else begin
                            TempTransactionValue2.Amount += TempTransactionValue.Amount;
                            TempTransactionValue2.Modify();
                        end;
                        TempTransactionValue3 := TempTransactionValue;
                        TempTransactionValue3.Insert();
                    end;
                until TempTransactionValue.Next() = 0;
        end;
    end;

    local procedure PopulateAttributeRateColumnVariables(
        RecID: RecordId;
        var TempTransactionValue: Record "Tax Transaction Value" temporary;
        var Symbols: Record "Script Symbol Value" temporary);
    var
        TaxAttribute: Record "Tax Attribute";
        TaxRateColumn: Record "Tax Rate Column Setup";
        TaxAttributeMgmt: Codeunit "Tax Attribute Management";
        AttributeId: Integer;
        Value: Variant;
    begin
        TempTransactionValue.Reset();
        TempTransactionValue.SetRange("Tax Record ID", RecID);
        TempTransactionValue.SetFilter(
            "Value Type", '%1|%2',
            TempTransactionValue."Value Type"::ATTRIBUTE,
            TempTransactionValue."Value Type"::COLUMN);
        if TempTransactionValue.FindSet() then
            repeat
                case TempTransactionValue."Value Type" of
                    TempTransactionValue."Value Type"::ATTRIBUTE:
                        begin
                            TaxAttribute.SetFilter("Tax Type", '%1|%2', TempTransactionValue."Tax Type", '');
                            TaxAttribute.SetRange(ID, TempTransactionValue."Value ID");
                            TaxAttribute.FindFirst();
                            if TaxAttribute.Type = TaxAttribute.Type::Option then
                                Value := Format(TempTransactionValue."Option Index")
                            else
                                Value := TempTransactionValue."Column Value";

                            SymbolStore.SetDefaultSymbolValue(
                                Symbols,
                                Symbols.Type::"Tax Attributes",
                                TempTransactionValue."Value ID",
                                Value,
                                DataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxAttribute.Type));
                        end;
                    TempTransactionValue."Value Type"::COLUMN:
                        begin
                            TaxRateColumn.SetFilter("Tax Type", '%1|%2', TempTransactionValue."Tax Type", '');
                            TaxRateColumn.SetRange("Column ID", TempTransactionValue."Value ID");
                            if TaxRateColumn.FindFirst() then begin
                                if TaxRateColumn.Type = TaxRateColumn.Type::Option then begin
                                    if TaxRateColumn."Linked Attribute ID" <> 0 then
                                        AttributeId := TaxRateColumn."Linked Attribute ID"
                                    else
                                        AttributeId := TaxRateColumn."Attribute ID";

                                    TaxAttribute.Reset();
                                    TaxAttribute.SetFilter("Tax Type", '%1|%2',
                                        TempTransactionValue."Tax Type",
                                        '');
                                    TaxAttribute.SetRange(ID, TempTransactionValue."Value ID");
                                    TaxAttribute.FindFirst();
                                    if TaxAttribute.Type = TaxAttribute.Type::Option then
                                        Value := TaxAttributeMgmt.GetAttributeOptionIndex(
                                            TaxAttribute."Tax Type",
                                            AttributeId,
                                            copystr(TempTransactionValue."Column Value", 1, 30))
                                    else
                                        Value := TempTransactionValue."Column Value";
                                end else
                                    Value := TempTransactionValue."Column Value";

                                SymbolStore.SetDefaultSymbolValue(
                                    Symbols,
                                    Symbols.Type::Column,
                                    TempTransactionValue."Value ID",
                                    Value,
                                    DataTypeMgmt.GetAttributeDataTypeToVariableDataType(TaxRateColumn.Type));
                            end;
                        end;
                end;
            until TempTransactionValue.Next() = 0;
    end;

    local procedure GetAttributesKey(var TempTransactionValue: Record "Tax Transaction Value"): Text[2000];
    var
        TaxAttribute: Record "Tax Attribute";
        AttributesKey: Text[2000];
    begin
        AttributesKey := '';
        TempTransactionValue.SetRange("Tax Record ID", TempTransactionValue."Tax Record ID");
        repeat
            TaxAttribute.Reset();
            TaxAttribute.SetFilter("Tax Type", '%1|%2', TempTransactionValue."Tax Type", '');
            TaxAttribute.SetRange(ID, TempTransactionValue."Value ID");
            TaxAttribute.FindFirst();
            if TaxAttribute."Grouped In SubLedger" then
                AttributesKey += TempTransactionValue."Column Value";

        until TempTransactionValue.Next() = 0;

        TempTransactionValue.SetRange("Tax Record ID");
        exit(AttributesKey);
    end;

    local procedure GetPostingUseCaseID(
        CaseID: Guid;
        ComponentID: Integer;
        ExpectedType: Option;
        var NewCaseId: Guid): Boolean
    var
        UseCase: Record "Tax Use Case";
        TaxPostingSetup: Record "Tax Posting Setup";
        InsertRecord: Record "Tax Insert Record";
        SwitchCase: Record "Switch Case";
    begin
        UseCase.Get(CaseID);
        if UseCase."Posting Table ID" <> 0 then begin
            TaxPostingSetup.Reset();
            TaxPostingSetup.SetRange("Case ID", UseCase.ID);
            TaxPostingSetup.SetRange("Component ID", ComponentID);
            if TaxPostingSetup.FindFirst() then begin
                SwitchCase.SetRange("Switch Statement ID", TaxPostingSetup."Switch Statement ID");
                if SwitchCase.FindSet() then
                    repeat
                        if InsertRecord.Get(
                            SwitchCase."Case ID",
                            UseCase."Posting Script ID",
                            SwitchCase."Action ID")
                        then
                            if InsertRecord."Sub Ledger Group By" = ExpectedType then begin
                                NewCaseId := UseCase.ID;
                                exit(true);
                            end;
                    until SwitchCase.Next() = 0;
            end;

            exit(false);
        end else
            if not IsNullGuid(UseCase."Parent Use Case ID") then
                exit(GetPostingUseCaseID(
                    UseCase."Parent Use Case ID",
                    ComponentID,
                    ExpectedType,
                    NewCaseId))
            else
                exit(false);
    end;

    var
        SymbolStore: Codeunit "Script Symbol Store";
        DataTypeMgmt: Codeunit "Use Case Data Type Mgmt.";
        GenLineRecord: Variant;
        SymbolDataType: Enum "Symbol Data Type";
        PostingFieldSymbol: Enum "Posting Field Symbol";
}