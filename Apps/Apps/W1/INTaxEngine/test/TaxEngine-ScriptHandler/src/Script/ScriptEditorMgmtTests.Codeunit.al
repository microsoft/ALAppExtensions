codeunit 136753 "Script Editor Mgmt Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Script Editor Mgmt] [UT]
    end;

    var
        Assert: Codeunit Assert;

    procedure TestInitActions()
    var
        ScriptAction: Record "Script Action";
        ScriptEditorMgmt: Codeunit "Script Editor Mgmt.";
    begin
        // [SCENARIO] To check if the Actions are getting craeted in ScriptAction table.

        // [GIVEN] ScriptAction table is empty.
        ScriptAction.DeleteAll();

        // [WHEN] The function InitActions is called.
        ScriptEditorMgmt.InitActions();

        // [THEN] it should create record in ScriptActionTable for all Actions.
        Assert.RecordIsNotEmpty(ScriptAction);
    end;

    [Test]
    procedure BuildEditorLines()
    var
        ScriptContext: Record "Script Context";
        ScriptEditorLine: Record "Script Editor Line";
        ScriptEditorMgmt: Codeunit "Script Editor Mgmt.";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ActionID, ContainerActionID : Guid;
    begin
        // [SCENARIO] To check if Script Editor Lines are getting updated from Action Container.

        // [GIVEN] There should be a Script Context and container for the script.
        CaseID := CreateGuid();
        ActionID := CreateGuid();
        ContainerActionID := CreateGuid();
        ScriptID := ScriptEntityMgmt.CreateScriptContext(CaseID);
        ScriptContext.Get(ScriptID);
        LibraryScriptTests.CreateActivityContianer(CaseID, ScriptID, "Container Action Type"::USECASE, ContainerActionID, "Action Type"::ALERTMESSAGE, ActionID);

        // [WHEN] The function BuildEditorLines is called
        ScriptEditorMgmt.BuildEditorLines(ScriptContext, ScriptEditorLine);

        // [THEN] ScriptEditorLine record should be updated with the values passed in the function.
        Assert.AreEqual(CaseID, ScriptEditorLine."Case ID", 'Case ID should be equal');
        Assert.AreEqual(ScriptID, ScriptEditorLine."Script ID", 'Script ID should be equal');
    end;

    [Test]
    procedure TestSearchActionType()
    var
        ScriptEditorMgmt: Codeunit "Script Editor Mgmt.";
        ActionType: Enum "Action Type";
        ActionText: Text;
    begin
        // [SCENARIO] To check if the Actions is available in the ScriptAction Table.

        // [GIVEN] Script Action table should not be empty
        ScriptEditorMgmt.InitActions();
        ActionText := 'Message';

        // [WHEN] The function SearchActionType is called with Text as Message.
        ScriptEditorMgmt.SearchActionType(ActionText, ActionType);

        // [THEN] It should return the action type from Script Action to ActionType enum variable
        Assert.AreEqual("Action Type"::ALERTMESSAGE, ActionType, 'Action Type should be message');
    end;

    [Test]
    [HandlerFunctions('ScriptActionPageHandler')]
    procedure TestSearchActionTypeWithPage()
    var
        ScriptEditorMgmt: Codeunit "Script Editor Mgmt.";
        ActionType: Enum "Action Type";
        ActionText: Text;
    begin
        // [SCENARIO] To check if the Actions is available in the ScriptAction Table.

        // [GIVEN] Script Action table should not be empty
        ScriptEditorMgmt.InitActions();

        // [WHEN] The function SearchActionType is called with Text as Message.
        ScriptEditorMgmt.SearchActionType(ActionText, ActionType);

        // [THEN] It should return the action type from Script Action to ActionType enum variable
        Assert.AreEqual("Action Type"::ALERTMESSAGE, ActionType, 'Action Type should be message');
    end;

    [Test]
    procedure TestUpdateDraftRow()
    var
        ScriptContext: Record "Script Context";
        ScriptEditorLine: Record "Script Editor Line";
        ScriptEditorMgmt: Codeunit "Script Editor Mgmt.";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ActionID, ContainerActionID : Guid;
        ActionText: Text;
    begin
        // [SCENARIO] To check if DRAFTROW is updated with an action

        // [GIVEN] There should be a DRAFT ROW available in action container
        CaseID := CreateGuid();
        ActionID := CreateGuid();
        ContainerActionID := CreateGuid();
        ScriptID := ScriptEntityMgmt.CreateScriptContext(CaseID);
        ScriptContext.Get(ScriptID);
        LibraryScriptTests.CreateActivityContianer(CaseID, ScriptID, "Container Action Type"::USECASE, caseId, "Action Type"::DRAFTROW, ActionID);
        //LibraryScriptTests.CreateScriptEditorLine(CaseID, ScriptID, "Action Type"::DRAFTROW, ActionID);
        ScriptEditorLine."Case ID" := CaseID;
        ScriptEditorLine."Script ID" := ScriptID;
        ScriptEditorLine."Container Type" := "Container Action Type"::USECASE;
        ScriptEditorLine."Container Action ID" := CaseID;
        ScriptEditorLine."Action Type" := "Action Type"::DRAFTROW;
        ScriptEditorMgmt.InitActions();

        // [WHEN] The function UpdateDraftRow is called
        ActionText := 'Message';
        ScriptEditorMgmt.UpdateDraftRow(ScriptEditorLine, ActionText);

        // [THEN] ScriptEditorLine record should be updated with the Action Type of Message.
        Assert.AreEqual("Action Type"::ALERTMESSAGE, ScriptEditorLine."Action Type", 'Action type should be equal');
    end;


    [Test]
    procedure TestDeleteItemFromContainer()
    var
        ScriptEditorLine: Record "Script Editor Line";
        ActionContainer: Record "Action Container";
        ScriptEditorMgmt: Codeunit "Script Editor Mgmt.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        CaseID, ScriptID, ActionID, ContainerActionID : Guid;
    begin
        // [SCENARIO] To check if the Action Item is deleted from the Action container table.

        // [GIVEN] There should be a record Script Editor Line Table.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ActionID := ScriptEntityMgmt.CreateAlertMessage(CaseID, ScriptID);
        ContainerActionID := CreateGuid();
        LibraryScriptTests.CreateScriptEditorLine(CaseID, ScriptID, "Action Type"::ALERTMESSAGE, ActionID);
        LibraryScriptTests.CreateActivityContianer(CaseID, ScriptID, "Container Action Type"::USECASE, ContainerActionID, "Action Type"::ALERTMESSAGE, ActionID);
        ScriptEditorLine.Get(CaseID, ScriptID, 0);

        // [WHEN] The function DeleteItemFromContainer is called
        ScriptEditorMgmt.SetEditorRootAction("Container Action Type"::USECASE, ContainerActionID);
        ScriptEditorMgmt.DeleteItemFromContainer(ScriptEditorLine);

        // [THEN] Action Container should not have a record with those case
        ActionContainer.SetRange("Case ID", CaseID);
        ActionContainer.SetRange("Script ID", ScriptID);
        ActionContainer.SetRange("Action Type", "Action Type"::ALERTMESSAGE);
        ActionContainer.SetRange("Action ID", ActionID);
        Assert.RecordIsEmpty(ActionContainer);
    end;

    [Test]
    procedure TestAddContainerItemsToEditorLinesForUSECASE()
    var
        ScriptEditorLine: Record "Script Editor Line";
        ScriptEditorMgmt: Codeunit "Script Editor Mgmt.";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ActionID, ContainerActionID : Guid;
        LineNo, Indent : integer;
    begin
        // [SCENARIO] To check if the Action Item is added to Action container table.

        // [GIVEN] Item should be added for the root container activity
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ActionID := ScriptEntityMgmt.CreateAlertMessage(CaseID, ScriptID);
        ContainerActionID := CreateGuid();
        LibraryScriptTests.CreateActivityContianer(CaseID, ScriptID, "Container Action Type"::USECASE, ContainerActionID, "Action Type"::ALERTMESSAGE, ActionID);
        ScriptEditorLine."Case ID" := CaseID;
        ScriptEditorLine."Script ID" := ScriptID;
        ScriptEditorLine."Action ID" := ActionID;
        // [WHEN] The function AddContainerItemsToEditorLines is called
        ScriptEditorMgmt.AddContainerItemsToEditorLines(ScriptEditorLine, "Container Action Type"::USECASE, ContainerActionID, LineNo, Indent);

        // [THEN] A record should be created in Script Editor Line table with input values
        Assert.AreEqual(CaseID, ScriptEditorLine."Case ID", 'Case ID should not be different');
        Assert.AreEqual(ScriptID, ScriptEditorLine."Script ID", 'Script ID should not be different');
        Assert.AreEqual(ActionID, ScriptEditorLine."Action ID", 'Action ID should not be different');
        Assert.AreEqual(ContainerActionID, ScriptEditorLine."Container Action ID", 'Container Action ID should not be different');
    end;

    [Test]
    procedure TestAddContainerItemsToEditorLinesForIFSTATEMENT()
    var
        ScriptEditorLine: Record "Script Editor Line";
        ActionIfStatement: Record "Action If Statement";
        ScriptEditorMgmt: Codeunit "Script Editor Mgmt.";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ActionID, ContainerActionID, EmptyGuid, ElseIfID, ParentIfID : Guid;
        LineNo, Indent : integer;
    begin
        // [SCENARIO] To check if the Action Item is added to Action container table.

        // [GIVEN] Item should be added for the root container activity
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ParentIfID := ScriptEntityMgmt.CreateIfCondition(CaseID, ScriptID, EmptyGuid);
        ElseIfID := ScriptEntityMgmt.CreateIfCondition(CaseID, ScriptID, EmptyGuid);
        ActionID := ScriptEntityMgmt.CreateIfCondition(CaseID, ScriptID, EmptyGuid);
        ActionIfStatement.Get(CaseID, ScriptID, ActionID);
        ActionIfStatement."Else If Block ID" := ElseIfID;
        ActionIfStatement.Modify();
        ContainerActionID := CreateGuid();

        LibraryScriptTests.CreateActivityContianer(CaseID, ScriptID, "Container Action Type"::IFSTATEMENT, ContainerActionID, "Action Type"::IFSTATEMENT, ActionID);
        ScriptEditorLine."Case ID" := CaseID;
        ScriptEditorLine."Script ID" := ScriptID;
        ScriptEditorLine."Action ID" := ActionID;

        // [WHEN] The function AddContainerItemsToEditorLines is called
        ScriptEditorMgmt.AddContainerItemsToEditorLines(ScriptEditorLine, "Container Action Type"::IFSTATEMENT, ContainerActionID, LineNo, Indent);

        // [THEN] A record should be created in Script Editor Line table with all group types of IFSTATEMENT
        ScriptEditorLine.SetRange("Case ID", CaseID);
        ScriptEditorLine.SetRange("Script ID", ScriptID);

        ScriptEditorLine.SetRange("Group Type", "Action Group Type"::"If Statement");
        Assert.RecordIsNotEmpty(ScriptEditorLine);
    end;

    [Test]
    procedure TestAddContainerItemsToEditorLinesForLOOPNTIMES()
    var
        ScriptEditorLine: Record "Script Editor Line";
        ScriptEditorMgmt: Codeunit "Script Editor Mgmt.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        CaseID, ScriptID, ActionID, ContainerActionID : Guid;
        LineNo, Indent : integer;
    begin
        // [SCENARIO] To check if the Action Item is added to Action container table.

        // [GIVEN] Item should be added for the root container activity
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ContainerActionID := CreateGuid();
        ActionID := ScriptEntityMgmt.CreateLoopNTimes(CaseID, ScriptID);
        LibraryScriptTests.CreateActivityContianer(CaseID, ScriptID, "Container Action Type"::USECASE, ContainerActionID, "Action Type"::LOOPNTIMES, ActionID);
        ScriptEditorLine."Case ID" := CaseID;
        ScriptEditorLine."Script ID" := ScriptID;
        ScriptEditorLine."Action ID" := ActionID;

        // [WHEN] The function AddContainerItemsToEditorLines is called
        ScriptEditorMgmt.AddContainerItemsToEditorLines(ScriptEditorLine, "Container Action Type"::USECASE, ContainerActionID, LineNo, Indent);

        // [THEN] A record should be created in Script Editor Line table with all group types of LOOPNTIMES
        ScriptEditorLine.SetRange("Case ID", CaseID);
        ScriptEditorLine.SetRange("Script ID", ScriptID);

        ScriptEditorLine.SetRange("Group Type", "Action Group Type"::"Loop N Times");
        Assert.RecordIsNotEmpty(ScriptEditorLine);
        ScriptEditorLine.SetRange("Group Type");

        ScriptEditorLine.SetRange("Group Type", "Action Group Type"::"End Loop N Times");
        Assert.RecordIsNotEmpty(ScriptEditorLine);
        ScriptEditorLine.SetRange("Group Type");
    end;

    [Test]
    procedure TestAddContainerItemsToEditorLinesForLOOPTHROUGHRECORDS()
    var
        ScriptEditorLine: Record "Script Editor Line";
        ScriptEditorMgmt: Codeunit "Script Editor Mgmt.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        CaseID, ScriptID, ActionID, ContainerActionID : Guid;
        LineNo, Indent : integer;
    begin
        // [SCENARIO] To check if the Action Item is added to Action container table.

        // [GIVEN] Item should be added for the root container activity
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ContainerActionID := CreateGuid();
        ActionID := ScriptEntityMgmt.CreateLoopThroughRecords(CaseID, ScriptID);
        LibraryScriptTests.CreateActivityContianer(CaseID, ScriptID, "Container Action Type"::USECASE, ContainerActionID, "Action Type"::LOOPTHROUGHRECORDS, ActionID);
        ScriptEditorLine."Case ID" := CaseID;
        ScriptEditorLine."Script ID" := ScriptID;
        ScriptEditorLine."Action ID" := ActionID;

        // [WHEN] The function AddContainerItemsToEditorLines is called
        ScriptEditorMgmt.AddContainerItemsToEditorLines(ScriptEditorLine, "Container Action Type"::USECASE, ContainerActionID, LineNo, Indent);

        // [THEN] A record should be created in Script Editor Line table with all group types of LOOPTHROUGHRECORDS
        ScriptEditorLine.SetRange("Case ID", CaseID);
        ScriptEditorLine.SetRange("Script ID", ScriptID);

        ScriptEditorLine.SetRange("Group Type", "Action Group Type"::"Loop Through Records");
        Assert.RecordIsNotEmpty(ScriptEditorLine);
        ScriptEditorLine.SetRange("Group Type");

        ScriptEditorLine.SetRange("Group Type", "Action Group Type"::"End Loop Through Records");
        Assert.RecordIsNotEmpty(ScriptEditorLine);
        ScriptEditorLine.SetRange("Group Type");
    end;

    [Test]
    procedure TestAddContainerItemsToEditorLinesForLOOPWITHCONDITION()
    var
        ScriptEditorLine: Record "Script Editor Line";
        ScriptEditorMgmt: Codeunit "Script Editor Mgmt.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        LibraryScriptTests: Codeunit "Library - Script Tests";
        CaseID, ScriptID, ActionID, ContainerActionID : Guid;
        LineNo, Indent : integer;
    begin
        // [SCENARIO] To check if the Action Item is added to Action container table.

        // [GIVEN] Item should be added for the root container activity
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ContainerActionID := CreateGuid();
        ActionID := ScriptEntityMgmt.CreateLoopWithCondition(CaseID, ScriptID);
        LibraryScriptTests.CreateActivityContianer(CaseID, ScriptID, "Container Action Type"::USECASE, ContainerActionID, "Action Type"::LOOPWITHCONDITION, ActionID);
        ScriptEditorLine."Case ID" := CaseID;
        ScriptEditorLine."Script ID" := ScriptID;
        ScriptEditorLine."Action ID" := ActionID;

        // [WHEN] The function AddContainerItemsToEditorLines is called
        ScriptEditorMgmt.AddContainerItemsToEditorLines(ScriptEditorLine, "Container Action Type"::USECASE, ContainerActionID, LineNo, Indent);

        // [THEN] A record should be created in Script Editor Line table with all group types of LOOPWITHCONDITION
        ScriptEditorLine.SetRange("Case ID", CaseID);
        ScriptEditorLine.SetRange("Script ID", ScriptID);

        ScriptEditorLine.SetRange("Group Type", "Action Group Type"::"Loop with Condition");
        Assert.RecordIsNotEmpty(ScriptEditorLine);
        ScriptEditorLine.SetRange("Group Type");

        ScriptEditorLine.SetRange("Group Type", "Action Group Type"::"End Loop with Condition");
        Assert.RecordIsNotEmpty(ScriptEditorLine);
        ScriptEditorLine.SetRange("Group Type");
    end;

    [Test]
    procedure TestRefreshEditorLines()
    var
        TempScriptEditorLine: Record "Script Editor Line" temporary;
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        ScriptEditormgmt: Codeunit "Script Editor Mgmt.";
        LibraryScriptTest: Codeunit "Library - Script Tests";
        CaseID, ScriptID, ActionID, ContainerActionID : Guid;
    begin
        // [SCENARIO] To check if Script Editor Line is getting refreshed.

        // [GIVEN] There is script context and and action ID
        CaseID := CreateGuid();
        ScriptID := ScriptEntityMgmt.CreateScriptContext(CaseID);
        ActionID := CreateGuid();
        ContainerActionID := CreateGuid();
        LibraryScriptTest.CreateActivityContianer(CaseID, ScriptID, "Container Action Type"::USECASE, CaseId, "Action Type"::DRAFTROW, ActionID);

        // [WHEN] The function RefreshEditorLines is called
        TempScriptEditorLine."Case ID" := CaseID;
        TempScriptEditorLine."Script ID" := ScriptID;
        TempScriptEditorLine."Action Type" := "Action Type"::DRAFTROW;
        TempScriptEditorLine."Action ID" := ActionID;
        TempScriptEditorLine."Container Type" := "Container Action Type"::USECASE;
        TempScriptEditorLine."Container Action ID" := CaseID;
        ScriptEditormgmt.RefreshEditorLines(TempScriptEditorLine);

        // [THEN] Action ID on Script Editor Line should be equal ot ActionID variable
        TempScriptEditorLine.SetRange("Action ID", ActionID);
        Assert.RecordIsNotEmpty(TempScriptEditorLine);
    end;

    [ModalPageHandler]
    procedure ScriptActionPageHandler(var ScriptActions: TestPage "Script Actions")
    begin
        ScriptActions.Filter.SetFilter(Text, 'Message');
        ScriptActions.OK().Invoke();
    end;

}