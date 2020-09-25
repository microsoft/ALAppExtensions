codeunit 139827 "APIV2 - Journals E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Journal]
    end;

    var
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryAPIGeneralJournal: Codeunit "Library API - General Journal";
        Assert: Codeunit "Assert";
        TypeHelper: Codeunit "Type Helper";
        GraphMgtJournal: Codeunit "Graph Mgt - Journal";
        IsInitialized: Boolean;
        ServiceNameTxt: Label 'journals';
        JournalNameTxt: Label 'code';
        JournalDescriptionNameTxt: Label 'displayName';
        JournalBalAccountIdTxt: Label 'balancingAccountId';
        JournalBalAccountNoTxt: Label 'balancingAccountNumber';
        ActionPostTxt: Label 'Microsoft.NAV.post', Locked = true;
        NotEmptyResponseErr: Label 'Response body should be empty.';
        GenJournalLineNotPostedErr: Label 'The general journal line was not correctly posted. The resulting Customer Ledger Entry is missing.';

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestCreateJournal()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        JournalName: Code[10];
        JournalDescription: Text[50];
        JournalJSON: Text;
        JournalBalAccountNo: Code[20];
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create a Journal through a POST method and check if it was created
        // [GIVEN] a journal batch json
        Initialize();

        JournalJSON := CreateJournalJSON(JournalName, JournalDescription, JournalBalAccountNo);
        Commit();

        // [WHEN] we POST the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Journals", ServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, JournalJSON, ResponseText);

        // [THEN] the response text should contain the journal information and the journal should exist
        LibraryGraphMgt.VerifyIDInJson(ResponseText);
        VerifyJSONContainsJournalValues(ResponseText, JournalName, JournalDescription, JournalBalAccountNo);

        GenJournalBatch.SetRange("Journal Template Name", GraphMgtJournal.GetDefaultJournalLinesTemplateName());
        GenJournalBatch.SetRange(Name, JournalName);
        Assert.IsFalse(GenJournalBatch.IsEmpty(), 'The journal batch should exist in the table.');
    end;

    [Test]
    procedure TestGetJournals()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        JournalNames: array[2] of Code[10];
        JournalJSON: array[2] of Text;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create journal batches and use a GET method to retrieve them
        // [GIVEN] 2 journal batches in the table
        Initialize();

        JournalNames[1] := LibraryUtility.GenerateRandomCode(GenJournalBatch.FieldNo(Name), Database::"Gen. Journal Batch");
        JournalNames[2] := LibraryUtility.GenerateRandomCode(GenJournalBatch.FieldNo(Name), Database::"Gen. Journal Batch");

        LibraryAPIGeneralJournal.EnsureGenJnlBatchExists(GraphMgtJournal.GetDefaultJournalLinesTemplateName(), JournalNames[1]);
        LibraryAPIGeneralJournal.EnsureGenJnlBatchExists(GraphMgtJournal.GetDefaultJournalLinesTemplateName(), JournalNames[2]);

        Commit();

        // [WHEN] we POST the JSON to the web service
        ResponseText := '';
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Journals", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 lines should exist in the response
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(
            ResponseText, JournalNameTxt, JournalNames[1], JournalNames[2], JournalJSON[1], JournalJSON[2]),
          'Could not find the lines in JSON');
    end;

    [Test]
    procedure TestModifyJournal()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        JournalNames: array[2] of Code[10];
        JournalDescription: Text[50];
        JournalGUID: Guid;
        JournalJSON: Text;
        ResponseText: Text;
        TargetURL: Text;
        JournalBalAccountNo: Code[20];
    begin
        // [SCENARIO] Create a Journal, use a PATCH method to change it and then verify the changes
        // [GIVEN] a journal batch the table
        Initialize();

        JournalNames[1] := LibraryUtility.GenerateRandomCode(GenJournalBatch.FieldNo(Name), Database::"Gen. Journal Batch");
        LibraryAPIGeneralJournal.EnsureGenJnlBatchExists(GraphMgtJournal.GetDefaultJournalLinesTemplateName(), JournalNames[1]);
        GenJournalBatch.Get(GraphMgtJournal.GetDefaultJournalLinesTemplateName(), JournalNames[1]);
        JournalGUID := GenJournalBatch.SystemId;

        // [GIVEN] a journal json
        JournalJSON := CreateJournalJSON(JournalNames[2], JournalDescription, JournalBalAccountNo);
        Commit();

        // [WHEN] we PATCH the JSON to the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(JournalGUID, Page::"APIV2 - Journals", ServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, JournalJSON, ResponseText);

        // [THEN] the journal in the table should have the values that were given and the old name should not exist
        Assert.AreNotEqual('', ResponseText, 'JSON Should not be blank');
        LibraryGraphMgt.VerifyIDInJson(ResponseText);

        VerifyJSONContainsJournalValues(ResponseText, JournalNames[2], JournalDescription, JournalBalAccountNo);

        GenJournalBatch.SetRange("Journal Template Name", GraphMgtJournal.GetDefaultJournalLinesTemplateName());
        GenJournalBatch.SetRange(Name, JournalNames[1]);
        Assert.IsTrue(GenJournalBatch.IsEmpty(), 'The old journal name should not exist in the table');
    end;

    [Test]
    procedure TestDeleteJournal()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        JournalName: Code[10];
        JournalGUID: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] Create a Journal, use a DELETE method to remove it and then verify the deletion
        // [GIVEN] a journal batch in the table
        Initialize();

        JournalName := LibraryUtility.GenerateRandomCode(GenJournalBatch.FieldNo(Name), Database::"Gen. Journal Batch");
        LibraryAPIGeneralJournal.EnsureGenJnlBatchExists(GraphMgtJournal.GetDefaultJournalLinesTemplateName(), JournalName);
        GenJournalBatch.Get(GraphMgtJournal.GetDefaultJournalLinesTemplateName(), JournalName);
        JournalGUID := GenJournalBatch.SystemId;

        // [WHEN] we DELETE the journal line from the web service
        TargetURL := LibraryGraphMgt.CreateTargetURL(JournalGUID, Page::"APIV2 - Journals", ServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] the Journal batch shouldn't exist in the table
        GenJournalBatch.SetRange("Journal Template Name", GraphMgtJournal.GetDefaultJournalLinesTemplateName());
        GenJournalBatch.SetRange(Name, JournalName);
        Assert.IsTrue(GenJournalBatch.IsEmpty(), 'The journal batch should not exist in the table');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestActionPostGenJournalBatch()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        BalAccountNo: Code[20];
        CustomerNo: Code[20];
        Customer2No: Code[20];
        BalAccountType: Enum "Sales Document Type";
        Amount: Decimal;
        Amount2: Decimal;
        GenJournalBatchId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [GIVEN] A general journal batch with a general journal line
        BalAccountNo := LibraryERM.CreateGLAccountNoWithDirectPosting();
        BalAccountType := GenJournalLine."Bal. Account Type"::"G/L Account";
        CustomerNo := LibrarySales.CreateCustomerNo();
        Customer2No := LibrarySales.CreateCustomerNo();
        Amount := LibraryRandom.RandDecInRange(10000, 50000, 2);
        Amount2 := LibraryRandom.RandDecInRange(10000, 50000, 2);
        CreateGeneralJournalBatch(GenJournalBatch, BalAccountType, BalAccountNo);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Customer, CustomerNo, Amount);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine2, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Customer, Customer2No, Amount2);
        GenJournalBatchId := GenJournalBatch.SystemId;
        Commit();

        // [WHEN] A POST request is made to the API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(GenJournalBatchId, Page::"APIV2 - Journals", ServiceNameTxt, ActionPostTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] Response should be empty
        Assert.AreEqual('', ResponseText, NotEmptyResponseErr);

        // [THEN] The general journal line is posted
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetRange(Amount, Amount);
        Assert.IsFalse(CustLedgerEntry.IsEmpty(), GenJournalLineNotPostedErr);
        CustLedgerEntry.SetRange("Customer No.", Customer2No);
        CustLedgerEntry.SetRange(Amount, Amount2);
        Assert.IsFalse(CustLedgerEntry.IsEmpty(), GenJournalLineNotPostedErr);
    end;

    local procedure CreateJournalJSON(var JournalName: Code[10]; var JournalDescription: Text[50]; var JournalBalAccountNo: Code[20]): Text
    var
        GLAccount: Record "G/L Account";
        GenJournalBatch: Record "Gen. Journal Batch";
        JournalJSON: Text;
    begin
        JournalName := LibraryUtility.GenerateRandomCode(GenJournalBatch.FieldNo(Name), Database::"Gen. Journal Batch");
        JournalDescription := LibraryUtility.GenerateGUID();
        JournalBalAccountNo := LibraryERM.CreateGLAccountNoWithDirectPosting();
        GLAccount.Get(JournalBalAccountNo);
        JournalJSON := LibraryGraphMgt.AddPropertytoJSON('', JournalNameTxt, JournalName);
        JournalJSON := LibraryGraphMgt.AddPropertytoJSON(JournalJSON, JournalDescriptionNameTxt, JournalDescription);
        JournalJSON := LibraryGraphMgt.AddPropertytoJSON(JournalJSON, JournalBalAccountIdTxt, TypeHelper.GetGuidAsString(GLAccount.SystemId));

        exit(JournalJSON);
    end;

    local procedure VerifyJSONContainsJournalValues(JSONTxt: Text; ExpectedJournalName: Text; ExpectedJournalDescription: Text; ExpectedJournalBalAccountNo: Code[20])
    var
        JournalNameValue: Text;
        JournalDecriptionValue: Text;
        JournalBalAccountNo: Text;
    begin
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectIDFromJSON(JSONTxt, JournalNameTxt, JournalNameValue), 'Could not find journal name.');
        Assert.AreEqual(ExpectedJournalName, JournalNameValue, 'Journal name does not match.');

        if ExpectedJournalDescription <> '' then begin
            Assert.IsTrue(
              LibraryGraphMgt.GetObjectIDFromJSON(JSONTxt, JournalDescriptionNameTxt, JournalDecriptionValue),
              'Could not find journal description.');
            Assert.AreEqual(ExpectedJournalDescription, JournalDecriptionValue, 'Journal description does not match.');
        end;

        if ExpectedJournalBalAccountNo <> '' then begin
            Assert.IsTrue(
              LibraryGraphMgt.GetObjectIDFromJSON(JSONTxt, JournalBalAccountNoTxt, JournalBalAccountNo),
              'Could not find journal description.');
            Assert.AreEqual(ExpectedJournalBalAccountNo, JournalBalAccountNo, 'Journal balancing account number does not match.');
        end;
    end;

    procedure CreateGeneralJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch"; BalAccountType: Enum "Sales Document Type"; BalAccountNo: Code[20])
    begin
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate());
        GenJournalBatch.Validate("Bal. Account Type", BalAccountType);
        GenJournalBatch.Validate("Bal. Account No.", BalAccountNo);
        GenJournalBatch.Modify(true);
    end;
}

