codeunit 136851 "Switch Statement Helper Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Switch Statement Helper] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    [HandlerFunctions('SwitchCaseModalHandler')]
    procedure TestOpenSwitchStatements()
    var
        SwitchStatementHelper: Codeunit "Switch Statement Helper";
        CaseID, SwitchID : guid;
    begin
        // [SCENARIO] check if Switch statement Dialog is openinig

        // [GIVEN] Switch Statement should be already created
        CaseID := CreateGuid();
        SwitchID := SwitchStatementHelper.CreateSwitchStatement(CaseID);
        // [WHEN] function OpenSwitchStatements is called 
        SwitchStatementHelper.OpenSwitchStatements(CaseID, SwitchID, "Switch Case Action Type"::Relation);

        // [THEN] it should open Switch statements dialog
    end;

    [Test]
    procedure TestCreateSwitchStatement()
    var
        SwitchStatament: Record "Switch Statement";
        SwitchStatementHelper: Codeunit "Switch Statement Helper";
        CaseID, SwitchID : guid;
    begin
        // [SCENARIO] check if Switch statement is created

        // [GIVEN] There should be a use case
        CaseID := CreateGuid();

        // [WHEN] function CreateSwitchStatement is called 
        SwitchID := SwitchStatementHelper.CreateSwitchStatement(CaseID);

        // [THEN] Record Switch Statement should not be emtpy for the CaseID
        SwitchStatament.SetRange("Case ID", CaseID);
        SwitchStatament.SetRange(ID, SwitchID);
        Assert.RecordIsNotEmpty(SwitchStatament);
    end;

    [Test]
    procedure TestDeleteSwitchStatement()
    var
        SwitchStatament: Record "Switch Statement";
        SwitchStatementHelper: Codeunit "Switch Statement Helper";
        CaseID, SwitchID : guid;
    begin
        // [SCENARIO] check if Switch statement is getting delete

        // [GIVEN] There should be a Switch statement
        CaseID := CreateGuid();
        SwitchID := SwitchStatementHelper.CreateSwitchStatement(CaseID);

        // [WHEN] function DeleteSwitchStatement is called 
        SwitchStatementHelper.DeleteSwitchStatement(CaseID, SwitchID);

        // [THEN] Record Switch Statement should be emtpy for the CaseID
        SwitchStatament.SetRange("Case ID", CaseID);
        SwitchStatament.SetRange(ID, SwitchID);
        Assert.RecordIsEmpty(SwitchStatament);
    end;


    [ModalPageHandler]
    procedure SwitchCaseModalHandler(var SwitchStatements: TestPage "Switch Statements")
    begin
        SwitchStatements.OK().Invoke();
    end;
}