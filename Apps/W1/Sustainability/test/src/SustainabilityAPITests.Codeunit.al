namespace Microsoft.Test.Sustainability;

using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Posting;
using Microsoft.API.V1;

codeunit 148185 "Sustainability API Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Sustainability] [API] [UI]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryUtility: Codeunit "Library - Utility";
        IsInitialized: Boolean;
        CodeLbl: Label 'code', Locked = true;
        NumberLbl: Label 'number', Locked = true;
        LineNumberLbl: Label 'lineNumber', Locked = true;
        AccountCodeLbl: Label 'AccountCode%1', Locked = true, Comment = '%1 = Number';
        CategoryCodeLbl: Label 'CategoryCode%1', Locked = true, Comment = '%1 = Number';
        SubcategoryCodeLbl: Label 'SubcategoryCode%1', Locked = true, Comment = '%1 = Number';
        SustainabilityAccountCategoriesServiceNameLbl: Label 'sustainabilityAccountCategories', Locked = true;
        SustainabilityAccountSubcategoriesServiceNameLbl: Label 'sustainabilityAccountSubcategories', Locked = true;
        SustainabilityAccountsServiceNameLbl: Label 'sustainabilityAccounts', Locked = true;
        SustainabilityJournalLinesServiceNameLbl: Label 'sustainabilityJournalLines', Locked = true;
        CreateRecordErr: Label 'The record hasn''t been created.', Locked = true;

    #region GET methods
    [Test]
    procedure TestGetSustainabilityCategory()
    var
        CategoryCode: array[2] of Code[20];
        ResponseText: Text;
        i: Integer;
    begin
        // [SCENARIO 521279] Create two Sustainability Account Categories and use GET method to retrieve them

        Initialize();

        // [GIVEN] Sustainability Account Category X
        // [GIVEN] Sustainability Account Category Y
        for i := 1 to ArrayLen(CategoryCode) do
            CreateSustainabilityCategory(CategoryCode[i], i);
        Commit();

        // [WHEN] GET request is made to the Sustainability Account Categories API
        LibraryGraphMgt.GetFromWebService(ResponseText, LibraryGraphMgt.CreateTargetURL('', Page::"Sust. Account Categories", SustainabilityAccountCategoriesServiceNameLbl));

        // [THEN] Two Sustainability Account Category Codes have been found in the response
        GetAndVerifyIDFromJSON(ResponseText, CategoryCode[1], CategoryCode[2], CodeLbl);
    end;

    [Test]
    procedure TestGetSustainabilitySubcategory()
    var
        CategoryCode: array[2] of Code[20];
        SubcategoryCode: array[2] of Code[20];
        ResponseText: Text;
        i: Integer;
    begin
        // [SCENARIO 521279] Create two Sustainability Account Subcategories and use GET method to retrieve them
        Initialize();

        // [GIVEN] Sustainability Account Subcategory X, Sustainability Account Category X
        // [GIVEN] Sustainability Account Subcategory Y, Sustainability Account Category Y
        for i := 1 to ArrayLen(SubcategoryCode) do
            CreateSustainabilitySubcategory(CategoryCode[i], SubcategoryCode[i], i + 2);
        Commit();

        // [WHEN] GET request is made to the Sustainability Account Subcategories API
        LibraryGraphMgt.GetFromWebService(ResponseText, LibraryGraphMgt.CreateTargetURL('', Page::"Sust. Acc. Subcategory", SustainabilityAccountSubcategoriesServiceNameLbl));

        // [THEN] Two Sustainability Account Subcategory Codes have been found in the response
        GetAndVerifyIDFromJSON(ResponseText, SubcategoryCode[1], SubcategoryCode[2], CodeLbl);
    end;

    [Test]
    procedure TestGetSustainabilityAccounts()
    var
        CategoryCode: array[2] of Code[20];
        SubcategoryCode: array[2] of Code[20];
        AccountCode: array[2] of Code[20];
        ResponseText: Text;
        i: Integer;
    begin
        // [SCENARIO 521279] Create two Sustainability Accounts and use GET method to retrieve them

        Initialize();

        // [GIVEN] Sustainability Account X, Sustainability Account Subcategory X, Sustainability Account Category X
        // [GIVEN] Sustainability Account Y, Sustainability Account Subcategory Y, Sustainability Account Category Y
        for i := 1 to ArrayLen(AccountCode) do
            CreateSustainabilityAccount(AccountCode[i], CategoryCode[i], SubcategoryCode[i], i + 4);
        Commit();

        // [WHEN] GET request is made to the Sustainability Accounts API
        LibraryGraphMgt.GetFromWebService(ResponseText, LibraryGraphMgt.CreateTargetURL('', Page::"Sustainability Accounts", SustainabilityAccountsServiceNameLbl));

        // [THEN] Two Sustainability Account Codes have been found in the response
        GetAndVerifyIDFromJSON(ResponseText, AccountCode[1], AccountCode[2], NumberLbl);
    end;

    [Test]
    procedure TestGetSustainabilityJournalLines()
    var
        SustainabilityAccount: array[2] of Record "Sustainability Account";
        SustainabilityJournalLine: array[2] of Record "Sustainability Jnl. Line";
        CategoryCode: array[2] of Code[20];
        SubcategoryCode: array[2] of Code[20];
        AccountCode: array[2] of Code[20];
        ResponseText: Text;
        i: Integer;
    begin
        // [SCENARIO 521279] Create two Sustainability Journal Lines and use GET method to retrieve them

        Initialize();

        // [GIVEN] Sustainability Journal Line 1, Sustainability Account X, Sustainability Account Subcategory X, Sustainability Account Category X
        // [GIVEN] Sustainability Journal Line 2, Sustainability Account Y, Sustainability Account Subcategory Y, Sustainability Account Category Y
        for i := 1 to ArrayLen(SustainabilityJournalLine) do begin
            SustainabilityAccount[i] := CreateSustainabilityAccount(AccountCode[i], CategoryCode[i], SubcategoryCode[i], i + 6);
            SustainabilityJournalLine[i] := CreateSustainabilityJnlLine(SustainabilityAccount[i]);
        end;
        Commit();

        // [WHEN] GET request is made to the Sustainability Journal Lines API
        LibraryGraphMgt.GetFromWebService(ResponseText, LibraryGraphMgt.CreateTargetURL('', Page::"Sustainability Journal Line", SustainabilityJournalLinesServiceNameLbl));

        // [THEN] Two Sustainability Journal Line Numbers have been found in the response
        GetAndVerifyIDFromJSON(ResponseText, Format(SustainabilityJournalLine[1]."Line No."), Format(SustainabilityJournalLine[2]."Line No."), LineNumberLbl);
    end;

    [Test]
    procedure TestGetSustainabilityEntries()
    var
        SustainabilityAccount: array[2] of Record "Sustainability Account";
        SustainabilityJournalLine: array[2] of Record "Sustainability Jnl. Line";
        CategoryCode: array[2] of Code[20];
        SubcategoryCode: array[2] of Code[20];
        AccountCode: array[2] of Code[20];
        ResponseText: Text;
        LedgerEntryNo: array[2] of Integer;
        i: Integer;
        SustainabilityEntriesServiceNameLbl: Label 'sustainabilityLedgerEntries', Locked = true;
        EntryNumberLbl: Label 'entryNumber', Locked = true;
    begin
        // [SCENARIO 521279] Create two Sustainability Entries and use GET method to retrieve them
        Initialize();

        // [GIVEN] Sustainability Lendger Entry 1, Sustainability Account X, Sustainability Account Subcategory X, Sustainability Account Category X
        // [GIVEN] Sustainability Lendger Entry 2, Sustainability Account Y, Sustainability Account Subcategory Y, Sustainability Account Category Y       
        for i := 1 to ArrayLen(LedgerEntryNo) do begin
            SustainabilityAccount[i] := CreateSustainabilityAccount(AccountCode[i], CategoryCode[i], SubcategoryCode[i], i + 8);
            SustainabilityJournalLine[i] := CreateSustainabilityJnlLine(SustainabilityAccount[i]);
            LedgerEntryNo[i] := CreateSustainabilityEntries(SustainabilityJournalLine[i]);
        end;
        Commit();

        // [WHEN] GET request is made to the Sustainability Entries API
        LibraryGraphMgt.GetFromWebService(ResponseText, LibraryGraphMgt.CreateTargetURL('', Page::"Sustainability Ledg. Entries", SustainabilityEntriesServiceNameLbl));

        // [THEN] Two Sustainability Entries have been found in the response
        GetAndVerifyIDFromJSON(ResponseText, Format(LedgerEntryNo[1]), Format(LedgerEntryNo[2]), EntryNumberLbl);
    end;

    #endregion GET methods

    #region POST methods
    [Test]
    procedure TestPostSustainabilityCategory()
    var
        SustainAccountCategory: Record "Sustain. Account Category";
        SustainAccountCategoryJSON: Text;
        ResponseText: Text;
    begin
        // [SCENARIO 521279] Create Sustainability Account Category using POST method 
        Initialize();

        // [GIVEN] Create JSON file with the data for a new Sustainability Account Category Z
        SustainAccountCategoryJSON := CreateSustainabilityJSON(CodeLbl, StrSubstNo(CategoryCodeLbl, 'X'));

        // [WHEN] POST request is made to the Sustainability Account Categories API
        LibraryGraphMgt.PostToWebService(LibraryGraphMgt.CreateTargetURL('', Page::"Sust. Account Categories", SustainabilityAccountCategoriesServiceNameLbl), SustainAccountCategoryJSON, ResponseText);

        // [THEN] New Sustainability Account Category Z has been created
        Assert.IsTrue(SustainAccountCategory.Get(StrSubstNo(CategoryCodeLbl, 'X')), CreateRecordErr);
    end;

    [Test]
    procedure TestPostSustainabilitySubcategory()
    var
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        CategoryCode: Code[20];
        SustainAccountSubcategoryJSON: Text;
        ResponseText: Text;
        CategoryLbl: Label 'category', Locked = true;
    begin
        // [SCENARIO 521279] Create Sustainability Account Subcategory using POST method 
        Initialize();

        // [GIVEN] Create Sustainability Account Category Y
        CreateSustainabilityCategory(CategoryCode, 99);

        // [GIVEN] Create JSON file with the data for a new Sustainability Account Subcategory Z
        SustainAccountSubcategoryJSON := CreateSustainabilitySubCategoryJSON(CodeLbl, StrSubstNo(SubcategoryCodeLbl, 'Y'), CategoryLbl, CategoryCode);
        Commit();
        // [WHEN] POST request is made to the Sustainability Account Subcategory API
        LibraryGraphMgt.PostToWebService(LibraryGraphMgt.CreateTargetURL('', Page::"Sust. Acc. Subcategory", SustainabilityAccountSubcategoriesServiceNameLbl), SustainAccountSubcategoryJSON, ResponseText);

        // [THEN] New Sustainability Account Subcategory Z has been created
        Assert.IsTrue(SustainAccountSubcategory.Get(CategoryCode, StrSubstNo(SubcategoryCodeLbl, 'Y')), CreateRecordErr);
    end;

    [Test]
    procedure TestPostSustainabilityAccount()
    var
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityAccountJSON: Text;
        ResponseText: Text;
    begin
        // [SCENARIO 521279] Create Sustainability Account using POST method 
        Initialize();

        // [GIVEN] Create JSON file with the data for a new Sustainability Account Z
        SustainabilityAccountJSON := CreateSustainabilityJSON(NumberLbl, StrSubstNo(AccountCodeLbl, 'Z'));
        Commit();

        // [WHEN] POST request is made to the Sustainability Account API
        LibraryGraphMgt.PostToWebService(LibraryGraphMgt.CreateTargetURL('', Page::"Sustainability Accounts", SustainabilityAccountsServiceNameLbl), SustainabilityAccountJSON, ResponseText);

        // [THEN] New Sustainability Account Z has been created
        Assert.IsTrue(SustainabilityAccount.Get(StrSubstNo(AccountCodeLbl, 'Z')), CreateRecordErr);
    end;

    [Test]
    procedure TestPostSustainabilityJournalLine()
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJournalLineJSON: Text;
        ResponseText: Text;
        LineNo: Integer;
    begin
        // [SCENARIO 521279] Create Sustainability Jnl. Line using POST method 
        Initialize();

        // [GIVEN] Create JSON file with the data for a new Sustainability Jnl. Line
        SustainabilityJournalLineJSON := CreateSustainabilityJnlLineJSON(SustainabilityJnlBatch, LineNo);
        Commit();

        // [WHEN] POST request is made to the Sustainability Jnl. Line API
        LibraryGraphMgt.PostToWebService(LibraryGraphMgt.CreateTargetURL('', Page::"Sustainability Journal Line", SustainabilityJournalLinesServiceNameLbl), SustainabilityJournalLineJSON, ResponseText);

        // [THEN] New Sustainability Jnl. Line has been created
        Assert.IsTrue(SustainabilityJnlLine.Get(SustainabilityJnlBatch."Journal Template Name", SustainabilityJnlBatch.Name, LineNo), CreateRecordErr);
    end;
    #endregion POST methods

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Sustainability API Tests");

        if IsInitialized then
            exit;

        LibrarySustainability.CleanUpBeforeTesting();

        IsInitialized := true;

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Sustainability API Tests");
    end;

    local procedure CreateSustainabilityCategory(var CategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        LibrarySustainability.InsertAccountCategory(
                 CategoryCode, CategoryCode, Enum::"Emission Scope"::"Scope 1", Enum::"Calculation Foundation"::"Fuel/Electricity",
                 true, true, true, '', false);
    end;

    local procedure CreateSustainabilitySubcategory(var CategoryCode: Code[20]; var SubcategoryCode: Code[20]; i: Integer)
    begin
        CategoryCode := StrSubstNo(CategoryCodeLbl, i);
        CreateSustainabilityCategory(CategoryCode, i);

        SubcategoryCode := StrSubstNo(SubcategoryCodeLbl, i);
        LibrarySustainability.InsertAccountSubcategory(CategoryCode, SubcategoryCode, SubcategoryCode, 1, 2, 3, false);
    end;

    local procedure CreateSustainabilityAccount(var AccountCode: Code[20]; CategoryCode: Code[20]; SubcategoryCode: Code[20]; i: Integer): Record "Sustainability Account"
    begin
        CreateSustainabilitySubcategory(CategoryCode, SubcategoryCode, i);
        AccountCode := StrSubstNo(AccountCodeLbl, i);
        exit(LibrarySustainability.InsertSustainabilityAccount(
          AccountCode, '', CategoryCode, SubcategoryCode, Enum::"Sustainability Account Type"::Posting, '', true));
    end;

    local procedure CreateSustainabilityJnlLine(SustainabilityAccount: Record "Sustainability Account") SustainabilityJournalLine: Record "Sustainability Jnl. Line";
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
    begin
        SetSustainabilityJournalLine(SustainabilityJournalLine, SustainabilityJnlBatch);
        exit(
            LibrarySustainability.InsertSustainabilityJournalLine(
                SustainabilityJnlBatch, SustainabilityAccount, GetLastLineNo(SustainabilityJournalLine)));
    end;

    local procedure CreateSustainabilityEntries(SustainabilityJournalLine: Record "Sustainability Jnl. Line"): Integer
    var
        SustainabilityLedgerEntry: Record "Sustainability Ledger Entry";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
    begin
        SustainabilityPostMgt.InsertLedgerEntry(SustainabilityJournalLine);
        SustainabilityLedgerEntry.FindLast();
        exit(SustainabilityLedgerEntry."Entry No.");
    end;

    local procedure SetSustainabilityJournalLine(var SustainabilityJournalLine: Record "Sustainability Jnl. Line"; var SustainabilityJnlBatch: Record "Sustainability Jnl. Batch")
    var
        SustainabilityJournalMgt: Codeunit "Sustainability Journal Mgt.";
    begin
        SustainabilityJnlBatch := SustainabilityJournalMgt.GetASustainabilityJournalBatch(false);
        SustainabilityJournalLine."Journal Template Name" := SustainabilityJnlBatch."Journal Template Name";
        SustainabilityJournalLine."Journal Batch Name" := SustainabilityJnlBatch.Name;
    end;

    local procedure GetLastLineNo(var SustainabilityJournalLine: Record "Sustainability Jnl. Line"): Integer
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(SustainabilityJournalLine);
        exit(LibraryUtility.GetNewLineNo(RecordRef, SustainabilityJournalLine.FieldNo("Line No.")));
    end;

    local procedure GetAndVerifyIDFromJSON(ResponseText: Text; Code1: Code[20]; Code2: Code[20]; ObjectIDFieldName: Text)
    var
        JSONText: array[2] of Text;
        DataNonExistErr: Label 'Could not find the data in JSON', Locked = true;
    begin
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(ResponseText, ObjectIDFieldName, Code1, Code2, JSONText[1], JSONText[2]), DataNonExistErr);
        LibraryGraphMgt.VerifyIDInJson(JSONText[1]);
        LibraryGraphMgt.VerifyIDInJson(JSONText[2]);
    end;

    local procedure CreateSustainabilityJSON(PropertyName: Text; PropertyValue: Variant): Text
    var
        LineJSON: Text;
    begin
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', 'id', CreateGuid());
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, PropertyName, PropertyValue);
        exit(LineJSON);
    end;

    local procedure CreateSustainabilitySubCategoryJSON(PropertyName: Text; PropertyValue: Variant; PropertyName2: Text; PropertyValue2: Variant): Text
    var
        LineJSON: Text;
    begin
        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', 'id', CreateGuid());
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, PropertyName, PropertyValue);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, PropertyName2, PropertyValue2);
        exit(LineJSON);
    end;

    local procedure CreateSustainabilityJnlLineJSON(var SustainabilityJnlBatch: Record "Sustainability Jnl. Batch"; var LineNo: Integer): Text
    var
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        LineJSON: Text;
        JournalTemplateNameLbl: Label 'journalTemplateName', Locked = true;
        JournalBatchNameLbl: Label 'journalBatchName', Locked = true;
    begin
        SetSustainabilityJournalLine(SustainabilityJournalLine, SustainabilityJnlBatch);

        LineNo := GetLastLineNo(SustainabilityJournalLine);

        LineJSON := LibraryGraphMgt.AddPropertytoJSON('', 'id', CreateGuid());
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, JournalTemplateNameLbl, SustainabilityJnlBatch."Journal Template Name");
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, JournalBatchNameLbl, SustainabilityJnlBatch.Name);
        LineJSON := LibraryGraphMgt.AddPropertytoJSON(LineJSON, LineNumberLbl, LineNo);
        exit(LineJSON);
    end;
}
