codeunit 137553 "Tax Posting Helper Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Tax Posting Helper] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    [HandlerFunctions('InsertRecordDialogHandler')]
    procedure TestOpenInsertRecordDialog()
    var
        InsertRecord: Record "Tax Insert Record";
        TaxPostingHelper: Codeunit "Tax Posting Helper";
        LibraryTaxPostingHandler: Codeunit "Library - Tax Posting Handler";
        CaseID, ScriptID, ActionID : Guid;
    begin
        // [SCENARIO] Open Insert Record Dialog

        // [GIVEN] Insert Record Key Fields
        BindSubscription(LibraryTaxPostingHandler);
        LibraryTaxPostingHandler.CreateInsertRecord(CaseID, ScriptID, ActionID);

        // [WHEN] The function OpenInsertRecordDialog is called.
        TaxPostingHelper.OpenInsertRecordDialog(CaseID, ScriptID, ActionID);
        InsertRecord.Get(CaseID, ScriptID, ActionID);
        UnbindSubscription(LibraryTaxPostingHandler);

        // [THEN] Should open a Dialog Page, expected Sales Header in Table ID field.
        Assert.AreEqual(Database::"Sales Header", InsertRecord."Table ID", 'Sales Header expected');
    end;

    [Test]
    procedure TestCreateInsertRecord()
    var
        InsertRecord: Record "Tax Insert Record";
        LibraryTaxPostingHandler: Codeunit "Library - Tax Posting Handler";
        CaseID, ScriptID, ActionID : Guid;
        Created: Boolean;
    begin
        // [SCENARIO] Create a blank 'Tax Insert Record' Record

        // [GIVEN] CaseID, ScriptID fields
        // [WHEN] The function CreateInsertRecord is called.
        LibraryTaxPostingHandler.CreateInsertRecord(CaseID, ScriptID, ActionID);
        Created := InsertRecord.Get(CaseID, ScriptID, ActionID);

        // [THEN] 'Tax Insert Record' Record should be found.
        Assert.IsTrue(Created, 'Insert Record should be created');
    end;

    [Test]
    procedure TestDeleteInsertRecord()
    var
        InsertRecord: Record "Tax Insert Record";
        LibraryTaxPostingHandler: Codeunit "Library - Tax Posting Handler";
        CaseID, ScriptID, ActionID : Guid;
        Created, Deleted : Boolean;
    begin
        // [SCENARIO] Delete 'Tax Insert Record' Record

        // [GIVEN] CaseID, ScriptID, ActionID fields
        LibraryTaxPostingHandler.CreateInsertRecord(CaseID, ScriptID, ActionID);
        Created := InsertRecord.Get(CaseID, ScriptID, ActionID);

        // [WHEN] The function CreateInsertRecord is called.
        LibraryTaxPostingHandler.DeleteInsertRecord(CaseID, ScriptID, ActionID);
        Deleted := not InsertRecord.Get(CaseID, ScriptID, ActionID);

        // [THEN] 'Tax Insert Record' Record should be found.
        Assert.IsTrue(Created, 'Insert Record should be created');
        Assert.IsTrue(Deleted, 'Insert Record should be deleted');
    end;

    [Test]
    procedure TestInsertRecordToString()
    var
        SalesHeader: Record "Sales Header";
        InsertRecord: Record "Tax Insert Record";
        TaxPostingHelper: Codeunit "Tax Posting Helper";
        LibraryTaxPostingHandler: Codeunit "Library - Tax Posting Handler";
        CaseID, ScriptID, ActionID : Guid;
        Text, ExpectedText : Text;
    begin
        // [SCENARIO] Serialize 'Tax Insert Record' To String 

        // [GIVEN] Tax Insert Record Record Key fields
        LibraryTaxPostingHandler.CreateInsertRecord(CaseID, ScriptID, ActionID);
        InsertRecord.Get(CaseID, ScriptID, ActionID);
        InsertRecord."Table ID" := Database::"Sales Header";
        InsertRecord.Modify();

        LibraryTaxPostingHandler.CreateInsertRecordField(CaseID, ScriptID, ActionID, Database::"Sales Header", SalesHeader.FieldNo("Document Type"), 'Order');
        LibraryTaxPostingHandler.CreateInsertRecordField(CaseID, ScriptID, ActionID, Database::"Sales Header", SalesHeader.FieldNo("No."), 'ORD001');

        // [WHEN] The function InsertRecordToString is called.
        ExpectedText := 'Insert a record in "Sales Header" (Assign ''Order'' to Field: "Document Type", ''ORD001'' to Field: "No.")';
        Text := TaxPostingHelper.InsertRecordToString(CaseID, ScriptID, ActionID);

        // [THEN] It should convert 'Tax Insert Record' to string
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - Expected', ExpectedText));
    end;


    [ModalPageHandler]
    procedure InsertRecordDialogHandler(var InsertRecordDialog: TestPage "Tax Insert Record Dialog")
    begin
        InsertRecordDialog.InsertIntoTableName.Value('Sales Header');
        InsertRecordDialog.OK().Invoke();
    end;
}