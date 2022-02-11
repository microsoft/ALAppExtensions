codeunit 20293 "Use Case Execution"
{
    procedure ExecuteUseCase(var UseCase: Record "Tax Use Case"; var SourceRecordRef: RecordRef; var Symbols: Record "Script Symbol Value" Temporary; CurrencyCode: Code[20]; CurrencyFactor: Decimal)
    begin
        if not IsEnabled(UseCase) then
            exit;

        SymbolStore.InitSymbols(UseCase.ID, UseCase."Computation Script ID", Symbols);
        TaxRateComputation.GetTaxAttributes(SymbolStore, SourceRecordRef, UseCase.ID);
        TaxRateComputation.GetTaxColumns(SymbolStore, SourceRecordRef, UseCase.ID);

        if IsLeafUseCase(UseCase.ID) then begin
            TransactionValueHelper.UpdateCaseID(SourceRecordRef, UseCase."Tax Type", UseCase.ID);
            InsertTempTaxType(UseCase."Tax Type");
            TaxRateComputation.UpdateComponentPercentages(SymbolStore, SourceRecordRef, UseCase.ID);
            ScriptActionExecution.ExecuteScript(
                SymbolStore,
                SourceRecordRef,
                UseCase.ID,
                UseCase."Computation Script ID");
            TaxRateComputation.CalculateTaxComponent(SymbolStore, SourceRecordRef, UseCase.ID, CurrencyCode, CurrencyFactor);

            LogExecutionTelemetry(
                UseCase.ID,
                GetVersionText(UseCase."Major Version", UseCase."Minor Version"),
                SourceRecordRef.RecordId);
        end;

        SymbolStore.CopySymbols(Symbols);
    end;

    procedure ExecuteUseCaseWithRecord(var UseCase: Record "Tax Use Case"; var SourceRecord: Variant; var Symbols: Record "Script Symbol Value" Temporary; var PostingSetupRecID: RecordId; CurrencyCode: Code[20]; CurrencyFactor: Decimal);
    var
        SourceRecordRef: RecordRef;
    begin
        RecRefHelper.VariantToRecRef(SourceRecord, SourceRecordRef);
        ExecuteUseCase(UseCase, SourceRecordRef, Symbols, CurrencyCode, CurrencyFactor);
    end;

    procedure ExecuteUseCaseTree(UseCaseID: Guid; var CurrentRecord: Variant; var Symbols: Record "Script Symbol Value" temporary; var PostingSetupRecID: RecordId; CurrencyCode: Code[20]; CurrencyFactor: Decimal)
    var
        UseCase: Record "Tax Use Case";
        UseCaseExecution: Codeunit "Use Case Execution";
    begin
        if not UseCase.Get(UseCaseID) then begin
            OnImportUseCaseOnDemand('', UseCaseID);
            UseCase.Get(UseCaseID);
        end else
            UpdateUseCaseRecord(UseCase);

        if IsChildUseCase(UseCase) then
            ExecuteUseCaseTree(UseCase."Parent Use Case ID", CurrentRecord, Symbols, PostingSetupRecID, CurrencyCode, CurrencyFactor);

        UseCaseExecution.ExecuteUseCaseWithRecord(UseCase, CurrentRecord, Symbols, PostingSetupRecID, CurrencyCode, CurrencyFactor);
    end;

    procedure IsLeafUseCase(UseCaseID: Guid): Boolean
    var
        UseCase: Record "Tax Use Case";
    begin
        UseCase.SetRange("Parent Use Case ID", UseCaseID);
        exit(UseCase.IsEmpty());
    end;

    procedure HandleEvent(EventName: Text; Record: Variant; CurrencyCode: Code[20]; CurrencyFactor: Decimal)
    var
        RecRef: RecordRef;
    begin
        GetRecRefFromRecord(Record, RecRef);

        if RecRef.IsTemporary() then
            exit;

        ExecuteUseCaseTree(RecRef, CurrencyCode, CurrencyFactor);
    end;

    procedure ExecuteUseCaseTree(Record: Variant; CurrencyCode: Code[20]; CurrencyFactor: Decimal)
    var
        UseCaseTreeNode: Record "Use Case Tree Node";
        TaxType: Record "Tax Type";
        RecRef: RecordRef;
    begin
        if UseCaseTreeNode.IsEmpty() then
            exit;

        GetRecRefFromRecord(Record, RecRef);

        if RecRef.IsTemporary() then
            Exit;

        UseCaseTreeNode.SetRange("Is Tax Type Root", true);
        if UseCaseTreeNode.FindSet() then
            repeat
                UseCaseTreeNode.TestField("Tax Type");
                TaxType.Get(UseCaseTreeNode."Tax Type");
                UpdateTaxTypeRecord(TaxType);

                ClearTransactionValues(TaxType.Code, RecRef);
                if TaxType.Enabled then
                    InternalExecuteUseCaseTree(UseCaseTreeNode, RecRef, CurrencyCode, CurrencyFactor);
            until UseCaseTreeNode.Next() = 0;
    end;

    local procedure ClearTransactionValues(TaxType: Code[20]; RecRef: RecordRef)
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.SetRange("Tax Type", TaxType);
        TaxTransactionValue.SetRange("Tax Record ID", RecRef.RecordId());
        if not TaxTransactionValue.IsEmpty() then
            TaxTransactionValue.DeleteAll(true);
    end;

    local procedure InternalExecuteUseCaseTree(
        UseCaseTreeNode: Record "Use Case Tree Node";
        RecRef: RecordRef;
        CurrencyCode: Code[20];
        CurrencyFactor: Decimal): Boolean
    var
        UseCaseTreeNode2: Record "Use Case Tree Node";
        EndCode: Code[20];
        Handled: Boolean;
    begin
        UseCaseTreeNode2 := UseCaseTreeNode;

        case UseCaseTreeNode."Node Type" of
            UseCaseTreeNode."Node Type"::"Begin":
                begin
                    if not IsValidTreeNodeToExecute(UseCaseTreeNode, RecRef) then
                        exit;

                    UseCaseTreeNode2.SetFilter(Code, '>%1', UseCaseTreeNode.Code);
                    UseCaseTreeNode2.SetRange(Indentation, UseCaseTreeNode.Indentation);
                    if UseCaseTreeNode2.Next() <> 0 then
                        EndCode := UseCaseTreeNode2.Code;

                    UseCaseTreeNode2.SetFilter(Code, '%1..%2', UseCaseTreeNode.Code, EndCode);
                    UseCaseTreeNode2.SetRange(Indentation, UseCaseTreeNode.Indentation + 1);
                    if UseCaseTreeNode2.FindSet() then
                        repeat
                            if InternalExecuteUseCaseTree(UseCaseTreeNode2, RecRef, CurrencyCode, CurrencyFactor) then
                                exit(true);
                        until UseCaseTreeNode2.Next() = 0;
                end;
            UseCaseTreeNode."Node Type"::"Use Case":
                begin
                    CheckUseCaseForExecution(UseCaseTreeNode."Use Case ID", RecRef, CurrencyCode, CurrencyFactor, Handled);
                    if Handled then
                        exit(true);
                end;
            UseCaseTreeNode."Node Type"::"End",
            UseCaseTreeNode."Node Type"::Heading:
                ;
        end;
    end;


    local procedure CheckUseCaseForExecution(CaseID: Guid; RecRef: RecordRef; CurrencyCode: Code[20]; CurrencyFactor: Decimal; var Handled: Boolean)
    var
        UseCase: Record "Tax Use Case";
    begin
        if not UseCase.Get(CaseID) then begin
            OnImportUseCaseOnDemand('', CaseID);
            UseCase.Get(CaseID)
        end else
            UpdateUseCaseRecord(UseCase);

        if (not TaxTypeAlreadyExecuted(UseCase."Tax Type")) and (UseCase.Enable) then
            ExecuteUseCase(RecRef, UseCase, CurrencyCode, CurrencyFactor, Handled);
    end;

    local procedure UpdateUseCaseRecord(var UseCase: Record "Tax Use Case")
    var
        UseCaseUpdated: Boolean;
    begin
        OnUpdateUseCaseRecord(UseCase."Tax Type", UseCase.ID, UseCase."Major Version", UseCaseUpdated);

        if UseCaseUpdated then
            UseCase.Get(UseCase.ID);
    end;

    local procedure UpdateTaxTypeRecord(var TaxType: Record "Tax Type")
    var
        TaxTypeUpdated: Boolean;
    begin
        OnUpdateTaxTypeRecord(TaxType.Code, TaxType."Major Version", TaxTypeUpdated);

        if TaxTypeUpdated then
            TaxType.Get(TaxType.Code);
    end;

    local procedure IsValidTreeNodeToExecute(var UseCaseTreeNode: Record "Use Case Tree Node"; RecRef: RecordRef): Boolean
    var
        Filers: Text;
    begin
        if UseCaseTreeNode."Table ID" = 0 then
            exit(true);

        if UseCaseTreeNode."Table ID" <> RecRef.Number then
            exit;

        UseCaseTreeNode.CalcFields(Condition);
        if not UseCaseTreeNode.Condition.HasValue() then
            exit(true);

        Filers := GetRecordView(UseCaseTreeNode);
        if Filers = '' then
            exit(true);

        if RecordViewFound(RecRef, Filers) then
            exit(true);
    end;

    local procedure GetRecordView(var UseCaseTreeNode2: Record "Use Case Tree Node") Filters: Text;
    var
        ConditionInStream: InStream;
    Begin
        UseCaseTreeNode2.calcfields(Condition);
        UseCaseTreeNode2.Condition.CREATEINSTREAM(ConditionInStream);
        ConditionInStream.READ(Filters);
    End;

    local procedure RecordViewFound(RecRef: RecordRef; Filters: Text): Boolean;
    var
        TempRecRef: RecordRef;
    Begin
        if Filters = '' then
            exit;

        TempRecRef.Open(RecRef.NUMBER(), true);
        TempRecRef.Copy(RecRef, false);
        TempRecRef.INSERT();

        TempRecRef.SetView(Filters);
        exit(TempRecRef.FindFirst());
    End;

    local procedure GetRecRefFromRecord(var Record: Variant; var RecRef: RecordRef)
    begin
        if not Record.IsRecordRef() then
            RecRef.GETTABLE(Record)
        else
            RecRef := Record;
    end;

    local procedure ExecuteUseCase(Var CaseRecRef: RecordRef; var UseCase: Record "Tax Use Case"; CurrencyCode: Code[20]; CurrencyFactor: Decimal; var Handled: Boolean)
    var
        TempSymbols: Record "Script Symbol Value" Temporary;
        UseCaseExecution: Codeunit "Use Case Execution";
        PostingSetupRecID: RecordId;
        Record: Variant;
    begin
        Record := CaseRecRef;

        if CanExecuteUseCase(UseCase, CaseRecRef) then begin
            UseCaseExecution.ExecuteUseCaseTree(UseCase.ID, Record, TempSymbols, PostingSetupRecID, CurrencyCode, CurrencyFactor);
            Handled := true;
        end;
    end;

    local procedure CanExecuteUseCase(UseCase: Record "Tax Use Case"; Var CaseRecRef: RecordRef) CanExecute: Boolean
    begin
        if not IsNullGuid(UseCase."Condition ID") then
            CanExecute := ConditionMgmt.CheckCondition(SymbolStore, CaseRecRef, UseCase.ID, EmptyGUID, UseCase."Condition ID")
        else
            CanExecute := true;
    end;

    local procedure IsChildUseCase(UseCase: Record "Tax Use Case"): Boolean
    begin
        exit(not IsNullGuid(UseCase."Parent Use Case ID"));
    end;

    local procedure InsertTempTaxType(TaxType: Code[20])
    begin
        TempTaxType.Init();
        TempTaxType.Code := TaxType;
        TempTaxType.Insert();
    end;

    local procedure TaxTypeAlreadyExecuted(TaxType: Code[20]): Boolean
    begin
        exit(TempTaxType.get(TaxType));
    end;

    local procedure IsEnabled(UseCase: Record "Tax Use Case") Enabled: Boolean
    var
        TaxType: Record "Tax Type";
    begin
        Enabled := true;

        TaxType.Get(UseCase."Tax Type");
        Enabled := TaxType.Enabled;
        if not Enabled then
            exit;

        Enabled := UseCase.Enable;
    end;

    local procedure LogExecutionTelemetry(CaseId: Guid; VersionTxt: Text; RecId: RecordId)
    var
        Dimensions: Dictionary of [Text, Text];
    begin
        Dimensions.Add('CaseID', CaseId);
        Dimensions.Add('Version', VersionTxt);
        Dimensions.Add('Record', Format(RecId, 0, 1));

        Session.LogMessage(
            'TE-USECASE-EXECUTED',
            UseCaseExcutedTxt,
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            Dimensions);
    end;

    local procedure GetVersionText(Major: Integer; Minor: Integer): Text
    begin
        exit(StrSubstNo(VersionLbl, Major, Minor));
    end;

    [IntegrationEvent(false, false)]
    procedure OnImportUseCaseOnDemand(TaxType: Code[20]; CaseID: Guid)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateUseCaseRecord(TaxType: Code[20]; CaseID: Guid; MajorVersion: Integer; var UseCaseUpdated: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateTaxTypeRecord(TaxType: Code[20]; MajorVersion: Integer; var TaxTypeUpdated: Boolean)
    begin
    end;

    var
        TempTaxType: Record "Tax Type" Temporary;
        SymbolStore: Codeunit "Script Symbol Store";
        ScriptActionExecution: Codeunit "Script Action Execution";
        ConditionMgmt: Codeunit "Condition Mgmt.";
        TaxRateComputation: Codeunit "Tax Rate Computation";
        TransactionValueHelper: Codeunit "Transaction Value Helper";
        RecRefHelper: Codeunit "RecRef Handler";
        EmptyGUID: Guid;
        UseCaseExcutedTxt: Label 'Use Case executed on record.', Locked = true;
        VersionLbl: Label '%1.%2', Comment = '%1 - Major Version, %2 - Minor Version';
}