table 20306 "Tax Use Case"
{
    Caption = 'Use Case';
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = true;
    fields
    {
        field(1; ID; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
        }
        field(2; "Tax Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Tax Table ID';
        }
        field(4; "Description"; Text[2000])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(5; Enable; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable';
            trigger OnValidate()
            begin
                if Rec.IsTemporary then
                    exit;

                if Enable then
                    if Status <> Status::Released then
                        Error(UseCaseStatusLbl, Status);
            end;
        }
        field(6; "Tax Type"; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Tax Type';
            TableRelation = "Tax Type".Code;
        }
        field(7; "Parent Use Case ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Parent Use Case ID';
            TableRelation = "Tax Use Case".ID;
        }
        field(8; "Presentation Order"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Presentation Order';
        }
        field(9; "Indentation Level"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Indentation Level';
        }
        field(10; "Condition ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Condition ID';
        }
        field(16; "Computation Script ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Computation Script ID';
        }
        field(18; Code; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Code';
        }
        field(20; "Major Version"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Major Version';
        }
        field(21; "Minor Version"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Minor Version';
        }
        field(22; "Effective From"; DateTime)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Effective From';
        }
        field(23; "Status"; Enum "Use Case Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Use Case Status';
        }
        field(24; "Changed By"; Text[80])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Changed By';
        }
        field(20335; "Posting Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Posting Table ID';
        }
        field(20336; "Posting Table Filter ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Posting Table Filter ID';
        }
        field(20337; "Posting Script ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Posting Script ID';
        }
    }
    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
        key(PresentationOrder; "Presentation Order") { }
        key(Enable; Enable) { }
    }

    trigger OnInsert()
    var
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
    begin
        if IsNullGuid(ID) then
            id := CreateGuid();

        "Computation Script ID" := ScriptEntityMgmt.CreateScriptContext(ID);
        "Posting Script ID" := ScriptEntityMgmt.CreateScriptContext(ID);
        TestField("Tax Type");
    end;

    trigger OnDelete()
    begin
        ClearCaseIDOnUseCaseTree(ID);
        DeleteAttributeMapping();
        DeleteColumnMapping();
        DeleteScript(ID, "Computation Script ID");
        DeleteScriptVariable("Computation Script ID");
        DeleteSwitchCases(ID);
        DeleteUseCaseCondition(ID, "Condition ID");
        DeleteUseCaseComponentCalculate(ID);
        DeleteUseCaseSymbolLookup(ID, "Computation Script ID");
    end;

    procedure SkipTreeOnDelete(Skip: Boolean)
    begin
        SkipTreeDeletion := true;
    end;

    local procedure DeleteAttributeMapping()
    var
        UseCaseAttributeMapping: Record "Use Case Attribute Mapping";
    begin
        UseCaseAttributeMapping.SetRange("Case ID", ID);
        if not UseCaseAttributeMapping.IsEmpty() then
            UseCaseAttributeMapping.DeleteAll(true);
    end;

    local procedure DeleteColumnMapping()
    var
        UseCaseRateColumnRelation: Record "Use Case Rate Column Relation";
    begin
        UseCaseRateColumnRelation.SetRange("Case ID", ID);
        if not UseCaseRateColumnRelation.IsEmpty() then
            UseCaseRateColumnRelation.DeleteAll(true);
    end;

    local procedure DeleteScript(CaseId: Guid; ScriptId: Guid)
    var
        ActionContainer: Record "Action Container";
    begin
        ActionContainer.SetRange("Script ID", ScriptId);
        ActionContainer.SetRange("Container Type", "Container Action Type"::USECASE);
        ActionContainer.SetRange("Container Action ID", CaseId);
        if not ActionContainer.IsEmpty() then
            ActionContainer.DeleteAll(true);
    end;

    local procedure DeleteScriptVariable(ScriptID: Guid)
    var
        ScriptVariable: Record "Script Variable";
    begin
        ScriptVariable.SetRange("Script ID", ScriptID);
        if not ScriptVariable.IsEmpty() then
            ScriptVariable.DeleteAll(true);
    end;

    local procedure DeleteSwitchCases(CaseId: Guid)
    var
        SwitchCase: Record "Switch Case";
    begin
        SwitchCase.SetRange("Case ID", CaseId);
        SwitchCase.SetRange("Switch Statement ID", CaseId);
        if not SwitchCase.IsEmpty() then
            SwitchCase.DeleteAll(true);
    end;

    local procedure DeleteUseCaseCondition(CaseId: Guid; ConditionID: Guid)
    var
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
    begin
        if not IsNullGuid(ConditionID) then
            ScriptEntityMgmt.DeleteCondition(CaseId, EmptyGuid, ConditionID);
    end;

    local procedure DeleteUseCaseSymbolLookup(CaseId: Guid; ScriptId: Guid)
    var
        ScriptSymbolLookup: Record "Script Symbol Lookup";
    begin
        ScriptSymbolLookup.SetRange("Case ID", CaseId);
        ScriptSymbolLookup.SetRange("Script ID", ScriptId);
        if not ScriptSymbolLookup.IsEmpty() then
            ScriptSymbolLookup.DeleteAll(true);
    end;

    local procedure DeleteUseCaseComponentCalculate(CaseID: Guid)
    var
        UseCaseComponentCalculation: Record "Use Case Component Calculation";
    begin
        UseCaseComponentCalculation.SetRange("Case ID", CaseID);
        if UseCaseComponentCalculation.FindSet() then
            repeat
                UseCaseComponentCalculation.Delete(true);
            until UseCaseComponentCalculation.Next() = 0;
    end;

    local procedure ClearCaseIDOnUseCaseTree(CaseID: Guid)
    var
        UseCaseTreeNode: Record "Use Case Tree Node";
    begin
        //This will be true only if the delete of use case is called from Desrialization which should not clear caseId
        //Use cases deleted from desrialization are only for upgrading use cases
        if SkipTreeDeletion then
            exit;

        if CaseID = EmptyGuid then
            exit;

        UseCaseTreeNode.SetRange("Use Case ID", CaseID);
        if not UseCaseTreeNode.IsEmpty() then
            UseCaseTreeNode.ModifyAll("Use Case ID", EmptyGuid);
    end;

    var
        EmptyGuid: Guid;
        SkipTreeDeletion: Boolean;
        UseCaseStatusLbl: Label 'You cannot enable a use case with status %1', Comment = '%1 = Status';
}