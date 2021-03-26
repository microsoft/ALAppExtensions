codeunit 20284 "Switch Statement Helper"
{
    procedure OpenSwitchStatements(CaseID: Guid; ID: Guid; SwitchCaseActionType: Enum "Switch Case Action Type");
    var
        SwitchStatement: Record "Switch Statement";
        SwitchStatements: Page "Switch Statements";
    begin
        SwitchStatement.GET(CaseID, ID);
        SwitchStatements.SetCurrentRecord(SwitchStatement, SwitchCaseActionType);
        Commit();
        SwitchStatements.RunModal();
    end;

    procedure CreateSwitchStatement(CaseID: Guid): Guid;
    var
        SwitchStatement: Record "Switch Statement";
    begin
        SwitchStatement.Init();
        SwitchStatement."Case ID" := CaseID;
        SwitchStatement.ID := CreateGuid();
        SwitchStatement.Insert();

        exit(SwitchStatement.ID);
    end;

    procedure DeleteSwitchStatement(CaseID: Guid; ID: Guid);
    var
        SwitchStatement: Record "Switch Statement";
    begin
        if IsNullGuid(ID) then
            Exit;

        SwitchStatement.GET(CaseID, ID);
        SwitchStatement.Delete(true);
    end;
}