codeunit 139730 "APIV1 - GLEntries E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [G/L Entry]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryERM: Codeunit "Library - ERM";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'generalLedgerEntries';

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryApplicationArea: Codeunit "Library - Application Area";
    begin
        LibraryApplicationArea.EnableFoundationSetup();
        IF IsInitialized THEN
            EXIT;

        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateVATPostingSetup();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();

        IsInitialized := TRUE;
        COMMIT();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler,GeneralJournalTemplateHandler')]
    procedure TestGetGLEntries()
    var
        GLEntry: Record "G/L Entry";
        GeneralJournal: TestPage "General Journal";
        LastGLEntryNo: Integer;
        TargetURL: Text;
        ResponseText: Text;
        GLEntryId: Text;
    begin
        // [SCENARIO] Create entries and use a GET method to retrieve them
        // [GIVEN] 2 entries in the G/L Entry Table with positive balance
        Initialize();

        // [WHEN] Create and Post a General Journal Line1
        LastGLEntryNo := GetLastGLEntryNumber();
        CreateAndPostGeneralJournalLineByPage(GeneralJournal);

        // [THEN] A new G/L Entry has been created
        GLEntry.RESET();
        GLEntry.SETFILTER("Entry No.", '>%1', LastGLEntryNo);
        Assert.IsTrue(GLEntry.FINDFIRST(), 'The G/L Entry should exist in the table.');
        GLEntryId := FORMAT(GLEntry."Entry No.");

        // [WHEN] we GET all the entry from the web service
        CLEARLASTERROR();
        TargetURL := LibraryGraphMgt.CreateTargetURL(GLEntryId, PAGE::"APIV1 - G/L Entries", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] entry should exist in the response
        IF GETLASTERRORTEXT() <> '' THEN
            Assert.ExpectedError('Request failed with error: ' + GETLASTERRORTEXT());

        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', GLEntryId),
          'Could not find sales credit memo number');
    end;

    [HandlerFunctions('ConfirmHandlerTrue,MessageHandler,GeneralJournalTemplateHandler')]
    local procedure CreateAndPostGeneralJournalLineByPage(var GeneralJournal: TestPage "General Journal")
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);

        // Find General Journal Template and Create General Journal Batch.
        CreateGeneralJournalBatch(GenJournalBatch);

        // Create General Journal Line.
        LibraryVariableStorage.Enqueue(GenJournalBatch."Journal Template Name");
        GeneralJournal.TRAP();
        GeneralJournal.OPENEDIT();
        GeneralJournal."Account Type".SETVALUE(GenJournalLine."Account Type"::"G/L Account");
        GeneralJournal."Account No.".SETVALUE(GLAccount."No.");
        UpdateAmountOnGenJournalLine(GenJournalBatch, GeneralJournal);
        GeneralJournal."Document No.".SETVALUE(GenJournalBatch.Name);

        // Find G/L Account No for Bal. Account No.
        GLAccount.SETFILTER("No.", '<>%1', GLAccount."No.");
        LibraryERM.CreateGLAccount(GLAccount);
        GeneralJournal."Bal. Account Type".SETVALUE(GenJournalLine."Account Type"::"G/L Account");
        GeneralJournal."Bal. Account No.".SETVALUE(GLAccount."No.");

        // Post General Journal Line.
        GeneralJournal.Post.INVOKE();
    end;

    local procedure CreateGeneralJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.VALIDATE("Bal. Account No.", LibraryERM.CreateGLAccountNo());
        GenJournalBatch.MODIFY(TRUE);
    end;

    local procedure UpdateAmountOnGenJournalLine(GenJournalBatch: Record "Gen. Journal Batch"; var GeneralJournal: TestPage "General Journal")
    begin
        LibraryVariableStorage.Enqueue(GenJournalBatch."Journal Template Name");
        LibraryERM.UpdateAmountOnGenJournalLine(GenJournalBatch, GeneralJournal);
    end;

    local procedure GetLastGLEntryNumber(): Integer
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.FINDLAST();
        EXIT(GLEntry."Entry No.");
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerTrue(QuestionText: Text[1024]; var Relpy: Boolean)
    begin
        Relpy := TRUE;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [ModalPageHandler]
    procedure GeneralJournalTemplateHandler(var GeneralJournalTemplateHandler: TestPage 250)
    begin
        GeneralJournalTemplateHandler.FILTER.SETFILTER(Name, LibraryVariableStorage.DequeueText());
        GeneralJournalTemplateHandler.OK().INVOKE();
    end;
}















