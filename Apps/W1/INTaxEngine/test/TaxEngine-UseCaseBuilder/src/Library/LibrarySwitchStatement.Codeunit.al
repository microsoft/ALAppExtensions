codeunit 136852 "Library - Switch Statement"
{
    procedure CreateSwitchCase(CaseID: Guid; SwitchStatementID: Guid; ActionID: Guid; ActionType: Enum "Switch Case Action Type"; ConditionID: Guid)
    var
        SwitchCase: Record "Switch Case";
    begin
        SwitchCase.Init();
        SwitchCase.Validate("Case ID", CaseID);
        SwitchCase.Validate("Switch Statement ID", SwitchStatementID);
        SwitchCase.Validate("Action ID", ActionID);
        SwitchCase.Validate("Action Type", ActionType);
        SwitchCase.Validate("Condition ID", ConditionID);
        SwitchCase.Insert(true);
    end;
}