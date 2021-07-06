codeunit 20344 "Tax Posting Execution"
{
    Permissions = tabledata "VAT Entry" = i;

    procedure ExecutePosting(
        var UseCase: Record "Tax Use Case";
        var SourceRecord: Variant;
        var Symbols: Record "Script Symbol Value" Temporary;
        ComponentID: Integer;
        GroupingType: Integer);
    var
        SymbolStore: Codeunit "Script Symbol Store";
        ScriptActionExecution: Codeunit "Script Action Execution";
        SourceRecordRef: RecordRef;
    begin
        RecRefHelper.VariantToRecRef(SourceRecord, SourceRecordRef);
        SymbolStore.InitSymbols(UseCase.ID, UseCase."Posting Script ID", Symbols);
        ScriptActionExecution.ExecuteScript(
            SymbolStore,
            SourceRecordRef,
            UseCase.ID,
            UseCase."Posting Script ID");

        ExecuteUseCaseOutput(
            SymbolStore,
            SourceRecordRef,
            UseCase.ID,
            UseCase."Posting Script ID",
            ComponentID,
            GroupingType);
    end;

    procedure ExecuteGetTaxPostingSetup(
        ComponentID: Integer;
        Var SourceRecRef: RecordRef;
        var UseCase: Record "Tax Use Case";
        Symbols: Record "Script Symbol Value" Temporary;
        var GlAccNo: Code[20];
        var PostingImpact: Option;
        var ReverseCharge: Boolean;
        var ReversaleGlAcc: Code[20]);
    begin
        ExecuteGetTaxPostingSetupTree(
            UseCase.ID,
            ComponentID,
            SourceRecRef,
            Symbols,
            GlAccNo,
            PostingImpact,
            ReverseCharge,
            ReversaleGlAcc);
    end;

    local procedure ExecuteUseCaseOutput(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        ScriptID: Guid;
        ComponentID: Integer;
        GroupingType: Integer);
    var
        InsertRecord: Record "Tax Insert Record";
        TaxPostingSetup: Record "Tax Posting Setup";
        SwitchCase: Record "Switch Case";
        RecordRef: RecordRef;
        ConditionOk: Boolean;
    begin
        TaxPostingSetup.SetRange("Case ID", CaseID);
        TaxPostingSetup.SetRange("Component ID", ComponentID);

        if TaxPostingSetup.FindSet() then
            repeat
                SwitchCase.Reset();
                SwitchCase.SetCurrentKey(Sequence);
                SwitchCase.SetRange("Case ID", CaseID);
                SwitchCase.SetRange("Switch Statement ID", TaxPostingSetup."Switch Statement ID");
                if SwitchCase.FindSet() then
                    repeat
                        ConditionOk := false;
                        if not IsNullGuid(SwitchCase."Condition ID") then
                            ConditionOk := ConditionMgmt.CheckCondition(
                                SymbolStore,
                                SourceRecRef,
                                CaseID,
                                EmptyGuid,
                                SwitchCase."Condition ID")
                        else
                            ConditionOk := true;

                        if ConditionOk then begin
                            InsertRecord.GET(CaseID, ScriptID, SwitchCase."Action ID");
                            if InsertRecord."Sub Ledger Group By" = GroupingType then begin
                                RecordRef.OPEN(InsertRecord."Table ID");
                                SetInsertRecordField(
                                    SymbolStore,
                                    SourceRecRef,
                                    InsertRecord."Case ID",
                                    InsertRecord.ID,
                                    RecordRef,
                                    InsertRecord."Run Trigger");
                                RecordRef.CLOSE();
                            end;
                        end;
                    until SwitchCase.Next() = 0;
            until TaxPostingSetup.Next() = 0;
    end;

    local procedure ExecuteGetTaxPostingSetupTree(
        UseCaseID: Guid;
        ComponentID: Integer;
        var SourceRecordRef: RecordRef;
        var Symbols: Record "Script Symbol Value" temporary;
        var GlAccNo: Code[20];
        var PostingImpact: Option;
        var ReverseCharge: Boolean;
        var ReversaleGlAcc: Code[20]);
    var
        UseCase: Record "Tax Use Case";
    begin
        UseCase.Get(UseCaseID);
        if UseCase."Posting Table ID" = 0 then begin
            if UseCase."Parent Use Case ID" = EmptyGuid then
                Error(PostingNotConfiguredErr, UseCase.Description);

            ExecuteGetTaxPostingSetupTree(
                UseCase."Parent Use Case ID",
                ComponentID,
                SourceRecordRef,
                Symbols,
                GlAccNo,
                PostingImpact,
                ReverseCharge,
                ReversaleGlAcc)
        end else
            ExecutePostingSetupWithRecord(
                UseCase,
                ComponentID,
                SourceRecordRef,
                Symbols,
                GlAccNo,
                PostingImpact,
                ReverseCharge,
                ReversaleGlAcc);
    end;

    local procedure SetInsertRecordField(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        UseCaseID: Guid;
        ActivityID: Guid;
        var RecordRef: RecordRef;
        RunTrigger: Boolean);
    var
        InsertRecordField2: Record "Tax Insert Record Field";
        FieldRef: FieldRef;
        FieldValue: Variant;
        DecimalValue: Decimal;
    begin
        InsertRecordField2.Reset();
        InsertRecordField2.SetCurrentKey("Sequence No.", InsertRecordField2."Field ID");
        InsertRecordField2.SetRange("Case ID", UseCaseID);
        InsertRecordField2.SetRange("Insert Record ID", ActivityID);
        if InsertRecordField2.FindSet() then
            repeat
                SymbolStore.GetConstantOrLookupValue(
                    SourceRecRef,
                    InsertRecordField2."Case ID",
                    InsertRecordField2."Script ID",
                    InsertRecordField2."Value Type",
                    InsertRecordField2.Value,
                    InsertRecordField2."Lookup ID",
                    FieldValue);

                if InsertRecordField2."Reverse Sign" then begin
                    DecimalValue := FieldValue;
                    DecimalValue := -DecimalValue;
                    FieldValue := DecimalValue;
                end;

                RecRefHelper.SetFieldValue(RecordRef, InsertRecordField2."Field ID", FieldValue);

                if InsertRecordField2."Run Validate" then begin
                    FieldRef := RecordRef.Field(InsertRecordField2."Field ID");
                    FieldRef.Validate();
                end;
            until InsertRecordField2.Next() = 0;
        RecordRef.Insert(RunTrigger)

    end;

    local procedure ExecutePostingSetupWithRecord(
        var UseCase: Record "Tax Use Case";
        ComponentID: Integer;
        var SourceRecordRef: RecordRef;
        var Symbols: Record "Script Symbol Value" Temporary;
        var GlAccNo: Code[20];
        var PostingImpact: Option;
        var ReverseCharge: Boolean;
        var ReverseGlAcc: Code[20]);
    var
        SymbolStore: Codeunit "Script Symbol Store";
        SourceRecord: Variant;
    begin
        SourceRecord := SourceRecordRef;

        SymbolStore.InitSymbols(UseCase.ID, UseCase."Posting Script ID", Symbols);
        GetTaxPostingSetup(
            SymbolStore,
            SourceRecordRef,
            UseCase,
            ComponentID,
            GlAccNo,
            PostingImpact,
            ReverseCharge,
            ReverseGlAcc);
    end;

    procedure GetTaxPostingSetup(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        UseCase: Record "Tax Use Case";
        ComponentID: Integer;
        var GlAccNo: Code[20];
        var PostingImpact: Option;
        var ReverseCharge: Boolean;
        var ReverseGlAcc: Code[20])
    var
        TaxPostingSetup: Record "Tax Posting Setup";
        RecRef: RecordRef;
        AccountNoVariant: Variant;
    begin
        ReverseCharge := false;
        if UseCase."Posting Table ID" = 0 then
            exit;

        RecRef.Open(UseCase."Posting Table ID");
        if not IsNullGuid(UseCase."Posting Table Filter ID") then
            SymbolStore.ApplyTableFilters(
                SourceRecRef,
                UseCase.ID,
                EmptyGuid,
                RecRef,
                UseCase."Posting Table Filter ID");

        if not RecRef.FindFirst() then
            Error(TaxPostingSetupDoesNotExistErr, UseCase.Description, RecRef.Caption(), RecRef.GetFilters());

        TaxPostingSetup.SetRange("Case ID", UseCase.ID);
        TaxPostingSetup.SetRange("Component ID", ComponentID);
        TaxPostingSetup.FindFirst();
        if not IsNullGuid(TaxPostingSetup."Table Filter ID") then
            SymbolStore.ApplyTableFilters(
                SourceRecRef,
                UseCase.ID,
                EmptyGuid,
                RecRef,
                TaxPostingSetup."Table Filter ID");

        if not RecRef.FindFirst() then
            Error(TaxPostingSetupDoesNotExistErr, UseCase.Description, RecRef.Caption(), RecRef.GetFilters());

        PostingImpact := TaxPostingSetup."Accounting Impact";
        if TaxPostingSetup."Account Source Type" = TaxPostingSetup."Account Source Type"::Field then begin
            TaxPostingSetup.TestField("Field ID");
            RecRef.Field(TaxPostingSetup."Field ID").TestField();
            GlAccNo := RecRef.Field(TaxPostingSetup."Field ID").Value();
        end else begin
            SymbolStore.GetLookupValue(
                SourceRecRef,
                UseCase.ID,
                EmptyGuid,
                TaxPostingSetup."Account Lookup ID",
                AccountNoVariant);

            GlAccNo := AccountNoVariant;
        end;

        if TaxPostingSetup."Reverse Charge" then begin
            ReverseCharge := true;
            if TaxPostingSetup."Reversal Account Source Type" = TaxPostingSetup."Reversal Account Source Type"::Field then begin
                TaxPostingSetup.TestField("Reverse Charge Field ID");
                RecRef.Field(TaxPostingSetup."Reverse Charge Field ID").TestField();
                ReverseGlAcc := RecRef.Field(TaxPostingSetup."Reverse Charge Field ID").Value();
            end else begin
                SymbolStore.GetLookupValue(
                                SourceRecRef,
                                UseCase.ID,
                                EmptyGuid,
                                TaxPostingSetup."Reversal Account Lookup ID",
                                AccountNoVariant);

                ReverseGlAcc := AccountNoVariant;
            end;
        end;
    end;

    var
        ConditionMgmt: Codeunit "Condition Mgmt.";
        RecRefHelper: Codeunit "RecRef Handler";
        EmptyGuid: Guid;
        TaxPostingSetupDoesNotExistErr: Label 'Tax Posting Setup does not exist for Use Case: %1 in Table: %2 with Filters: %3', Comment = '%1 = Use Case, %2= TableName, %3= Filters';
        PostingNotConfiguredErr: Label 'Tax Posting is not configured for Use Case : %1', Comment = '%1 = Use Case Description';
}