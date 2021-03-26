codeunit 20283 "Switch Statement Execution"
{
    procedure GetActionID(
        var SymbolStore: Codeunit "Script Symbol Store";
        var SourceRecRef: RecordRef;
        CaseID: Guid;
        SwitchStatementID: Guid): Guid
    var
        SwitchCase: Record "Switch Case";
        ConditionOk: Boolean;
    begin
        SwitchCase.SetCurrentKey(Sequence);
        SwitchCase.SetRange("Case ID", CaseID);
        SwitchCase.SetRange("Switch Statement ID", SwitchStatementID);
        if SwitchCase.FindSet() then
            repeat
                ConditionOk := false;
                if not IsNullGuid(SwitchCase."Condition ID") then
                    ConditionOk := ConditionMgmt.CheckCondition(
                        SymbolStore,
                        SourceRecRef,
                        CaseID,
                        EmptyGUID,
                        SwitchCase."Condition ID")
                else
                    ConditionOk := true;

                if ConditionOk then
                    exit(SwitchCase."Action ID");
            until SwitchCase.Next() = 0;
    end;

    var
        ConditionMgmt: Codeunit "Condition Mgmt.";
        EmptyGUID: Guid;
}