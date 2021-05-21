codeunit 136754 "Script Entity Mgmt. Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Script Entity Mgmt] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestCreateComment()
    var
        ActionComment: Record "Action Comment";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Comment Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateComment is called.
        ID := ScriptEntityMgmt.CreateComment(CaseID, ScriptID, 'Sample Comment');

        // [THEN] it should create record in Action Comment table for CaseID and ScriptID.
        ActionComment.SetRange("Case ID", CaseID);
        ActionComment.SetRange("Script ID", ScriptID);
        ActionComment.SetRange("ID", ID);
        Assert.RecordIsNotEmpty(ActionComment);
    end;

    [Test]
    procedure TestDeleteComment()
    var
        ActionComment: Record "Action Comment";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Comment Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateComment(CaseID, ScriptID, 'Sample Comment');

        // [WHEN] The function CreateComment is called.
        ScriptEntityMgmt.DeleteComment(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Action Comment table for CaseID and ScriptID.
        ActionComment.SetRange("Case ID", CaseID);
        ActionComment.SetRange("Script ID", ScriptID);
        ActionComment.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionComment);
    end;

    [Test]
    procedure TestUpdateComment()
    var
        ActionComment: Record "Action Comment";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Comment Action is Updated.

        // [GIVEN] There should be a Action Comment created.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateComment(CaseID, ScriptID, 'Sample Comment');

        // [WHEN] The function CreateComment is called.
        ScriptEntityMgmt.UpdateComment(CaseID, ScriptID, ID, 'Updated Comment');

        // [THEN] it should update record in Action Comment table for CaseID and ScriptID.
        ActionComment.Get(CaseID, ScriptID, ID);
        Assert.AreEqual('Updated Comment', ActionComment.Text, 'Comment should be Updated Comment');
    end;

    [Test]
    procedure TestCreateNumberCalculation()
    var
        ActionNumberCalculation: Record "Action Number Calculation";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Number Calculation Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateNumberCalculation is called.
        ID := ScriptEntityMgmt.CreateNumberCalculation(CaseID, ScriptID);

        // [THEN] it should create record in Action Number Calculation table for CaseID and ScriptID.
        ActionNumberCalculation.SetRange("Case ID", CaseID);
        ActionNumberCalculation.SetRange("Script ID", ScriptID);
        ActionNumberCalculation.SetRange("ID", ID);
        Assert.RecordIsNotEmpty(ActionNumberCalculation);
    end;
    //procedure DeleteNumberCalculation(CaseID: Guid; ScriptID: Guid; ID: Guid)
    [Test]
    procedure TestDeleteNumberCalculation()
    var
        ActionNumberCalculation: Record "Action Number Calculation";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Number Calculation Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateNumberCalculation(CaseID, ScriptID);

        // [WHEN] The function DeleteNumberCalculation is called.
        ScriptEntityMgmt.DeleteNumberCalculation(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Action Number Calculation table for CaseID and ScriptID.
        ActionNumberCalculation.SetRange("Case ID", CaseID);
        ActionNumberCalculation.SetRange("Script ID", ScriptID);
        ActionNumberCalculation.SetRange("ID", ID);
        Assert.RecordIsEmpty(ActionNumberCalculation);
    end;

    [Test]
    procedure TestCreateCondition()
    var
        Condition: Record "Tax Test Condition";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Condition Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateCondition is called.
        ID := ScriptEntityMgmt.CreateCondition(CaseID, ScriptID);

        // [THEN] it should create record in Condition table for CaseID and ScriptID.
        Condition.SetRange("Case ID", CaseID);
        Condition.SetRange("Script ID", ScriptID);
        Condition.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(Condition);
    end;

    [Test]
    procedure TestDeleteCondition()
    var
        Condition: Record "Tax Test Condition";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Condition Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateCondition(CaseID, ScriptID);

        // [WHEN] The function DeleteCondition is called.
        ScriptEntityMgmt.DeleteCondition(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Condition table for CaseID and ScriptID.
        Condition.SetRange("Case ID", CaseID);
        Condition.SetRange("Script ID", ScriptID);
        Condition.SetRange("ID", ID);

        Assert.RecordIsEmpty(Condition);
    end;

    [Test]
    procedure TestCreateLoopNTimes()
    var
        ActionLoopNTimes: Record "Action Loop N Times";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Loop N Times Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateLoopNTimes is called.
        ID := ScriptEntityMgmt.CreateLoopNTimes(CaseID, ScriptID);

        // [THEN] it should create record in Loop N Times Action table for CaseID and ScriptID.
        ActionLoopNTimes.SetRange("Case ID", CaseID);
        ActionLoopNTimes.SetRange("Script ID", ScriptID);
        ActionLoopNTimes.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionLoopNTimes);
    end;

    [Test]
    procedure TestDeleteLoopNTimes()
    var
        ActionLoopNTimes: Record "Action Loop N Times";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Loop N Times Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateLoopNTimes(CaseID, ScriptID);

        // [WHEN] The function DeleteLoopNTimes is called.
        ScriptEntityMgmt.DeleteLoopNTimes(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Loop N Times table for CaseID and ScriptID.
        ActionLoopNTimes.SetRange("Case ID", CaseID);
        ActionLoopNTimes.SetRange("Script ID", ScriptID);
        ActionLoopNTimes.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionLoopNTimes);
    end;

    [Test]
    procedure TestCreateLoopWithCondition()
    var
        ActionLoopWithCondition: Record "Action Loop With Condition";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Loop With Condition Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateLoopWithCondition is called.
        ID := ScriptEntityMgmt.CreateLoopWithCondition(CaseID, ScriptID);

        // [THEN] it should create record in Loop With Condition table for CaseID and ScriptID.
        ActionLoopWithCondition.SetRange("Case ID", CaseID);
        ActionLoopWithCondition.SetRange("Script ID", ScriptID);
        ActionLoopWithCondition.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionLoopWithCondition);
    end;

    [Test]
    procedure TestDeleteLoopWithCondition()
    var
        ActionLoopWithCondition: Record "Action Loop With Condition";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Loop With Condition Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateLoopWithCondition(CaseID, ScriptID);

        // [WHEN] The function DeleteLoopWithCondition is called.
        ScriptEntityMgmt.DeleteLoopWithCondition(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Loop With Condition table for CaseID and ScriptID.
        ActionLoopWithCondition.SetRange("Case ID", CaseID);
        ActionLoopWithCondition.SetRange("Script ID", ScriptID);
        ActionLoopWithCondition.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionLoopWithCondition);
    end;

    [Test]
    procedure TestCreateScriptContext()
    var
        ScriptContext: Record "Script Context";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID : Guid;
    begin
        // [SCENARIO] To check if the Script Context is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();

        // [WHEN] The function CreateScriptContext is called.
        ScriptID := ScriptEntityMgmt.CreateScriptContext(CaseID);

        // [THEN] it should create record in Loop With Condition table for CaseID and ScriptID.
        ScriptContext.SetRange(ID, ScriptID);
        ScriptContext.SetRange("Case ID", CaseID);

        Assert.RecordIsNotEmpty(ScriptContext);
    end;

    [Test]
    procedure TestDeleteScriptContext()
    var
        ScriptContext: Record "Script Context";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID : Guid;
    begin
        // [SCENARIO] To check if the Script Context is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := ScriptEntityMgmt.CreateScriptContext(CaseID);

        // [WHEN] The function DeleteScriptContext is called.
        ScriptEntityMgmt.DeleteScriptContext(CaseID, ScriptID);

        // [THEN] it should delete record in Script Context table for CaseID and ScriptID.
        ScriptContext.SetRange("Case ID", CaseID);
        ScriptContext.SetRange(ID, ScriptID);

        Assert.RecordIsEmpty(ScriptContext);
    end;

    [Test]
    procedure TestCreateFindDateInterval()
    var
        ActionFindDateInterval: Record "Action Find Date Interval";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Find Date Interval Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateFindDateInterval is called.
        ID := ScriptEntityMgmt.CreateFindDateInterval(CaseID, ScriptID);

        // [THEN] it should create record in Find Date Interval table for CaseID and ScriptID.
        ActionFindDateInterval.SetRange("Case ID", CaseID);
        ActionFindDateInterval.SetRange("Script ID", ScriptID);
        ActionFindDateInterval.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionFindDateInterval);
    end;

    [Test]
    procedure TestDeleteFindDateInterval()
    var
        ActionFindDateInterval: Record "Action Find Date Interval";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Loop With Condition Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateFindDateInterval(CaseID, ScriptID);

        // [WHEN] The function DeleteLoopWithCondition is called.
        ScriptEntityMgmt.DeleteFindDateInterval(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Loop With Condition table for CaseID and ScriptID.
        ActionFindDateInterval.SetRange("Case ID", CaseID);
        ActionFindDateInterval.SetRange("Script ID", ScriptID);
        ActionFindDateInterval.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionFindDateInterval);
    end;

    [Test]
    procedure TestCreateSetVariable()
    var
        ActionSetVariable: Record "Action Set Variable";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Set Variable Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateSetVariable is called.
        ID := ScriptEntityMgmt.CreateSetVariable(CaseID, ScriptID);

        // [THEN] it should create record in Set Variable table for CaseID and ScriptID.
        ActionSetVariable.SetRange("Case ID", CaseID);
        ActionSetVariable.SetRange("Script ID", ScriptID);
        ActionSetVariable.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionSetVariable);
    end;

    [Test]
    procedure TestDeleteSetVariable()
    var
        ActionSetVariable: Record "Action Set Variable";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Set Variable Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateSetVariable(CaseID, ScriptID);

        // [WHEN] The function DeleteSetVariable is called.
        ScriptEntityMgmt.DeleteSetVariable(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Set Variable table for CaseID and ScriptID.
        ActionSetVariable.SetRange("Case ID", CaseID);
        ActionSetVariable.SetRange("Script ID", ScriptID);
        ActionSetVariable.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionSetVariable);
    end;

    [Test]
    procedure TestCreateConcatenate()
    var
        ActionConcatenate: Record "Action Concatenate";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Concatenate Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateConcatenate is called.
        ID := ScriptEntityMgmt.CreateConcatenate(CaseID, ScriptID);

        // [THEN] it should create record in Concatenate table for CaseID and ScriptID.
        ActionConcatenate.SetRange("Case ID", CaseID);
        ActionConcatenate.SetRange("Script ID", ScriptID);
        ActionConcatenate.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionConcatenate);
    end;

    [Test]
    procedure TestDeleteConcatenate()
    var
        ActionConcatenate: Record "Action Concatenate";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Concatenate Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateConcatenate(CaseID, ScriptID);

        // [WHEN] The function DeleteConcatenate is called.
        ScriptEntityMgmt.DeleteConcatenate(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Concatenate table for CaseID and ScriptID.
        ActionConcatenate.SetRange("Case ID", CaseID);
        ActionConcatenate.SetRange("Script ID", ScriptID);
        ActionConcatenate.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionConcatenate);
    end;

    [Test]
    procedure TestCreateFindSubstrInString()
    var
        ActionFindSubString: Record "Action Find Substring";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Find SubString Action is created.    

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateFindSubstrInString is called.
        ID := ScriptEntityMgmt.CreateFindSubstrInString(CaseID, ScriptID);

        // [THEN] it should create record in Find SubString table for CaseID and ScriptID.
        ActionFindSubString.SetRange("Case ID", CaseID);
        ActionFindSubString.SetRange("Script ID", ScriptID);
        ActionFindSubString.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionFindSubString);
    end;

    [Test]
    procedure TestDeleteFindSubString()
    var
        ActionFindSubstring: Record "Action Find Substring";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Find SubString Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateFindSubstrInString(CaseID, ScriptID);

        // [WHEN] The function DeleteFindSubString is called.
        ScriptEntityMgmt.DeleteFindSubstrInString(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Find SubString table for CaseID and ScriptID.
        ActionFindSubstring.SetRange("Case ID", CaseID);
        ActionFindSubstring.SetRange("Script ID", ScriptID);
        ActionFindSubstring.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionFindSubstring);
    end;

    [Test]
    procedure TestCreateReplaceSubstring()
    var
        ActionReplaceSubString: Record "Action Replace Substring";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Replace SubString Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateReplaceSubstrInString is called.
        ID := ScriptEntityMgmt.CreateReplaceSubstring(CaseID, ScriptID);

        // [THEN] it should create record in Replace SubString table for CaseID and ScriptID.
        ActionReplaceSubString.SetRange("Case ID", CaseID);
        ActionReplaceSubString.SetRange("Script ID", ScriptID);
        ActionReplaceSubString.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionReplaceSubString);
    end;

    [Test]
    procedure TestDeleteReplaceSubstring()
    var
        ActionReplaceSubstring: Record "Action Replace Substring";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Replace SubString Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateReplaceSubstring(CaseID, ScriptID);

        // [WHEN] The function DeleteReplaceSubstring is called.
        ScriptEntityMgmt.DeleteReplaceSubstring(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Replace SubString table for CaseID and ScriptID.
        ActionReplaceSubstring.SetRange("Case ID", CaseID);
        ActionReplaceSubstring.SetRange("Script ID", ScriptID);
        ActionReplaceSubstring.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionReplaceSubstring);
    end;

    [Test]
    procedure TestCreateExtSubstrFromIndex()
    var
        ActionReplaceSubString: Record "Action Replace Substring";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Replace SubString Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateReplaceSubstrInString is called.
        ID := ScriptEntityMgmt.CreateReplaceSubstring(CaseID, ScriptID);

        // [THEN] it should create record in Replace SubString table for CaseID and ScriptID.
        ActionReplaceSubString.SetRange("Case ID", CaseID);
        ActionReplaceSubString.SetRange("Script ID", ScriptID);
        ActionReplaceSubString.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionReplaceSubString);
    end;

    [Test]
    procedure TestDeleteExtSubstrFromIndex()
    var
        ActionExtSubstrFromIndex: Record "Action Ext. Substr. From Index";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Replace SubString Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateExtSubstrFromIndex(CaseID, ScriptID);

        // [WHEN] The function DeleteExtSubstrFromIndex is called.
        ScriptEntityMgmt.DeleteExtSubstrFromIndex(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Replace SubString table for CaseID and ScriptID.
        ActionExtSubstrFromIndex.SetRange("Case ID", CaseID);
        ActionExtSubstrFromIndex.SetRange("Script ID", ScriptID);
        ActionExtSubstrFromIndex.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionExtSubstrFromIndex);
    end;

    [Test]
    procedure TestCreateExtSubstrFromPos()
    var
        ActionExtSubstrFromPos: Record "Action Ext. Substr. From Pos.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Extract Substr from Pos Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateReplaceSubstrInString is called.
        ID := ScriptEntityMgmt.CreateExtSubstrFromPos(CaseID, ScriptID);

        // [THEN] it should create record in Extract Substr From Pos table for CaseID and ScriptID.
        ActionExtSubstrFromPos.SetRange("Case ID", CaseID);
        ActionExtSubstrFromPos.SetRange("Script ID", ScriptID);
        ActionExtSubstrFromPos.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionExtSubstrFromPos);
    end;

    [Test]
    procedure TestDeleteExtSubstrFromPos()
    var
        ActionExtSubstrFromPos: Record "Action Ext. Substr. From Pos.";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Ext SubString From Pos Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateExtSubstrFromPos(CaseID, ScriptID);

        // [WHEN] The function DeleteExtSubstrFromPos is called.
        ScriptEntityMgmt.DeleteExtSubstrFromPos(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Ext SubString From Pos table for CaseID and ScriptID.
        ActionExtSubstrFromPos.SetRange("Case ID", CaseID);
        ActionExtSubstrFromPos.SetRange("Script ID", ScriptID);
        ActionExtSubstrFromPos.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionExtSubstrFromPos);
    end;

    [Test]
    procedure TestCreateDateCalculation()
    var
        ActionDateCalculation: Record "Action Date Calculation";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Date Calculation Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateDateCalculation is called.
        ID := ScriptEntityMgmt.CreateDateCalculation(CaseID, ScriptID);

        // [THEN] it should create record in Date Calculation table for CaseID and ScriptID.
        ActionDateCalculation.SetRange("Case ID", CaseID);
        ActionDateCalculation.SetRange("Script ID", ScriptID);
        ActionDateCalculation.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionDateCalculation);
    end;

    [Test]
    procedure TestDeleteDateCalculation()
    var
        ActionDateCalculation: Record "Action Date Calculation";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Date Calculation Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateDateCalculation(CaseID, ScriptID);

        // [WHEN] The function DeleteDateCalculation is called.
        ScriptEntityMgmt.DeleteDateCalculation(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Date Calculation table for CaseID and ScriptID.
        ActionDateCalculation.SetRange("Case ID", CaseID);
        ActionDateCalculation.SetRange("Script ID", ScriptID);
        ActionDateCalculation.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionDateCalculation);
    end;

    [Test]
    procedure TestCreateDateToDateTime()
    var
        ActionDateToDateTime: Record "Action Date To DateTime";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Date To DateTime Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateDateToDateTime is called.
        ID := ScriptEntityMgmt.CreateDateToDateTime(CaseID, ScriptID);

        // [THEN] it should create record in Date To Date To DateTime table for CaseID and ScriptID.
        ActionDateToDateTime.SetRange("Case ID", CaseID);
        ActionDateToDateTime.SetRange("Script ID", ScriptID);
        ActionDateToDateTime.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionDateToDateTime);
    end;

    [Test]
    procedure TestDeleteDateCalculation2()
    var
        ActionDateCalculation: Record "Action Date Calculation";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Date Calculation Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateDateCalculation(CaseID, ScriptID);

        // [WHEN] The function DeleteDateCalculation is called.
        ScriptEntityMgmt.DeleteDateCalculation(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Date Calculation table for CaseID and ScriptID.
        ActionDateCalculation.SetRange("Case ID", CaseID);
        ActionDateCalculation.SetRange("Script ID", ScriptID);
        ActionDateCalculation.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionDateCalculation);
    end;

    [Test]
    procedure TestCreateAlertMessage()
    var
        ActionMessage: Record "Action Message";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Alert Message Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateAlertMessage is called.
        ID := ScriptEntityMgmt.CreateAlertMessage(CaseID, ScriptID);

        // [THEN] it should create record in Get Record table for CaseID and ScriptID.
        ActionMessage.SetRange("Case ID", CaseID);
        ActionMessage.SetRange("Script ID", ScriptID);
        ActionMessage.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionMessage);
    end;

    [Test]
    procedure TestDeleteAlertMessage()
    var
        ActionMessage: Record "Action Message";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Alert Message Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateAlertMessage(CaseID, ScriptID);

        // [WHEN] The function DeleteAlertMessage is called.
        ScriptEntityMgmt.DeleteAlertMessage(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Alert Message table for CaseID and ScriptID.
        ActionMessage.SetRange("Case ID", CaseID);
        ActionMessage.SetRange("Script ID", ScriptID);
        ActionMessage.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionMessage);
    end;

    [Test]
    procedure TestCreateLoopThruRecord()
    var
        ActionLoopThroughRecords: Record "Action Loop Through Records";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Loop Through Record Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateLoopThroughRecord is called.
        ID := ScriptEntityMgmt.CreateLoopThroughRecords(CaseID, ScriptID);

        // [THEN] it should create record in Action Loop Through Record table for CaseID and ScriptID.
        ActionLoopThroughRecords.SetRange("Case ID", CaseID);
        ActionLoopThroughRecords.SetRange("Script ID", ScriptID);
        ActionLoopThroughRecords.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionLoopThroughRecords);
    end;

    [Test]
    procedure TestDeleteLoopThroughRecord()
    var
        ActionLoopThroughRecords: Record "Action Loop Through Records";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Loop Through Record Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateLoopThroughRecords(CaseID, ScriptID);

        // [WHEN] The function DeleteLoopThroughRecord is called.
        ScriptEntityMgmt.DeleteLoopThroughRecords(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Loop Through Record table for CaseID and ScriptID.
        ActionLoopThroughRecords.SetRange("Case ID", CaseID);
        ActionLoopThroughRecords.SetRange("Script ID", ScriptID);
        ActionLoopThroughRecords.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionLoopThroughRecords);
    end;

    [Test]
    procedure TestCreateExtractDatePart()
    var
        ActionExtractDatePart: Record "Action Extract Date Part";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Extract Date Part Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateExtractDatePart is called.
        ID := ScriptEntityMgmt.CreateExtractDatePart(CaseID, ScriptID);

        // [THEN] it should create record in Action Extract Date Part Record table for CaseID and ScriptID.
        ActionExtractDatePart.SetRange("Case ID", CaseID);
        ActionExtractDatePart.SetRange("Script ID", ScriptID);
        ActionExtractDatePart.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionExtractDatePart);
    end;

    [Test]
    procedure TestDeleteExtractDatePart()
    var
        ActionExtractDatePart: Record "Action Extract Date Part";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Extract Date Part Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateExtractDatePart(CaseID, ScriptID);

        // [WHEN] The function DeleteExtractDatePart is called.
        ScriptEntityMgmt.DeleteExtractDatePart(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Extract Date Part table for CaseID and ScriptID.
        ActionExtractDatePart.SetRange("Case ID", CaseID);
        ActionExtractDatePart.SetRange("Script ID", ScriptID);
        ActionExtractDatePart.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionExtractDatePart);
    end;

    [Test]
    procedure TestCreateExtractDateTimePart()
    var
        ActionExtractDateTimePart: Record "Action Extract DateTime Part";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Extract Date Time Part Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateExtractDateTimePart is called.
        ID := ScriptEntityMgmt.CreateExtractDateTimePart(CaseID, ScriptID);

        // [THEN] it should create record in Action Extract Date Time Part Record table for CaseID and ScriptID.
        ActionExtractDateTimePart.SetRange("Case ID", CaseID);
        ActionExtractDateTimePart.SetRange("Script ID", ScriptID);
        ActionExtractDateTimePart.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionExtractDateTimePart);
    end;

    [Test]
    procedure TestDeleteExtractDateTimePart()
    var
        ActionExtractDateTimePart: Record "Action Extract DateTime Part";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Extract Date Time Part Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateExtractDateTimePart(CaseID, ScriptID);

        // [WHEN] The function DeleteExtractDateTimePart is called.
        ScriptEntityMgmt.DeleteExtractDateTimePart(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Extract Date Time Part table for CaseID and ScriptID.
        ActionExtractDateTimePart.SetRange("Case ID", CaseID);
        ActionExtractDateTimePart.SetRange("Script ID", ScriptID);
        ActionExtractDateTimePart.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionExtractDateTimePart);
    end;

    [Test]
    procedure TestCreateLengthOfString()
    var
        ActionLengthOfString: Record "Action Length Of String";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Length Of String Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateLengthOfString is called.
        ID := ScriptEntityMgmt.CreateLengthOfString(CaseID, ScriptID);

        // [THEN] it should create record in Action Length Of String Record table for CaseID and ScriptID.
        ActionLengthOfString.SetRange("Case ID", CaseID);
        ActionLengthOfString.SetRange("Script ID", ScriptID);
        ActionLengthOfString.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionLengthOfString);
    end;

    [Test]
    procedure TestDeleteLengthOfString()
    var
        ActionLengthOfString: Record "Action Length Of String";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Length Of String Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateLengthOfString(CaseID, ScriptID);

        // [WHEN] The function DeleteLengthOsString is called.
        ScriptEntityMgmt.DeleteLengthOfString(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Length Of String table for CaseID and ScriptID.
        ActionLengthOfString.SetRange("Case ID", CaseID);
        ActionLengthOfString.SetRange("Script ID", ScriptID);
        ActionLengthOfString.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionLengthOfString);
    end;

    [Test]
    procedure TestCreateConvertCaseOfString()
    var
        ActionConvertCase: Record "Action Convert Case";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Convert Case To String Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateConvertCaseOfString is called.
        ID := ScriptEntityMgmt.CreateConvertCaseOfString(CaseID, ScriptID);

        // [THEN] it should create record in Action Convert Case Of String Record table for CaseID and ScriptID.
        ActionConvertCase.SetRange("Case ID", CaseID);
        ActionConvertCase.SetRange("Script ID", ScriptID);
        ActionConvertCase.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionConvertCase);
    end;

    [Test]
    procedure TestDeleteConvertCaseOfString()
    var
        ActionConvertCase: Record "Action Convert Case";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Convert Case Of String Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateConvertCaseOfString(CaseID, ScriptID);

        // [WHEN] The function DeleteLengthOfString is called.
        ScriptEntityMgmt.DeleteConvertCaseOfString(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Length Of String table for CaseID and ScriptID.
        ActionConvertCase.SetRange("Case ID", CaseID);
        ActionConvertCase.SetRange("Script ID", ScriptID);
        ActionConvertCase.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionConvertCase);
    end;

    [Test]
    procedure TestCreateRoundNumber()
    var
        ActionRoundNumber: Record "Action Round Number";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Round Number Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateRoundNumber is called.
        ID := ScriptEntityMgmt.CreateRoundNumber(CaseID, ScriptID);

        // [THEN] it should create record in Action Round Number Record table for CaseID and ScriptID.
        ActionRoundNumber.SetRange("Case ID", CaseID);
        ActionRoundNumber.SetRange("Script ID", ScriptID);
        ActionRoundNumber.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionRoundNumber);
    end;

    [Test]
    procedure TestDeleteRoundNumber()
    var
        ActionRoundNumber: Record "Action Round Number";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Round Number Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateRoundNumber(CaseID, ScriptID);

        // [WHEN] The function DeleteRoundNumber is called.
        ScriptEntityMgmt.DeleteRoundNumber(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Length Of String table for CaseID and ScriptID.
        ActionRoundNumber.SetRange("Case ID", CaseID);
        ActionRoundNumber.SetRange("Script ID", ScriptID);
        ActionRoundNumber.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionRoundNumber);
    end;

    [Test]
    procedure TestCreateNumericExpression()
    var
        ActionNumericExpression: Record "Action Number Expression";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Numeric Expression Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateNumericExpression is called.
        ID := ScriptEntityMgmt.CreateNumericExpression(CaseID, ScriptID);

        // [THEN] it should create record in Action Numeric Expression Record table for CaseID and ScriptID.
        ActionNumericExpression.SetRange("Case ID", CaseID);
        ActionNumericExpression.SetRange("Script ID", ScriptID);
        ActionNumericExpression.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionNumericExpression);
    end;

    [Test]
    procedure TestDeleteNumericExpression()
    var
        ActionNumericExpression: Record "Action Number Expression";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the Numeric Expression Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateNumericExpression(CaseID, ScriptID);

        // [WHEN] The function DeleteNumericExpression is called.
        ScriptEntityMgmt.DeleteNumericExpression(CaseID, ScriptID, ID);

        // [THEN] it should delete record in Length Of String table for CaseID and ScriptID.
        ActionNumericExpression.SetRange("Case ID", CaseID);
        ActionNumericExpression.SetRange("Script ID", ScriptID);
        ActionNumericExpression.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionNumericExpression);
    end;

    [Test]
    procedure TestCreateStringExpression()
    var
        ActionStringExpression: Record "Action String Expression";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the String Expression Action is created.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();

        // [WHEN] The function CreateStringExpression is called.
        ID := ScriptEntityMgmt.CreateStringExpression(CaseID, ScriptID);

        // [THEN] it should create record in Action String Expression Record table for CaseID and ScriptID.
        ActionStringExpression.SetRange("Case ID", CaseID);
        ActionStringExpression.SetRange("Script ID", ScriptID);
        ActionStringExpression.SetRange("ID", ID);

        Assert.RecordIsNotEmpty(ActionStringExpression);
    end;

    [Test]
    procedure TestDeleteStringExpression()
    var
        ActionStringExpression: Record "Action String Expression";
        ScriptEntityMgmt: Codeunit "Script Entity Mgmt.";
        CaseID, ScriptID, ID : Guid;
    begin
        // [SCENARIO] To check if the String Expression Action is deleted.

        // [GIVEN] There should be a CaseID and Script created to pass through the function.
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        ID := ScriptEntityMgmt.CreateStringExpression(CaseID, ScriptID);

        // [WHEN] The function DeleteStringExpression is called.
        ScriptEntityMgmt.DeleteStringExpression(CaseID, ScriptID, ID);

        // [THEN] it should delete record in String Expression table for CaseID and ScriptID.
        ActionStringExpression.SetRange("Case ID", CaseID);
        ActionStringExpression.SetRange("Script ID", ScriptID);
        ActionStringExpression.SetRange("ID", ID);

        Assert.RecordIsEmpty(ActionStringExpression);
    end;
}