codeunit 139701 "APIV1 - Accounts E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Account]
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        Assert: Codeunit "Assert";
        ServiceNameTxt: Label 'accounts';
        IsInitialized: Boolean;

    local procedure Initialize()
    begin
        IF IsInitialized THEN
            EXIT;

        IsInitialized := TRUE;
        COMMIT();
    end;

    [Test]
    procedure TestVerifyIDandLastDateModified()
    var
        GLAccount: Record "G/L Account";
        AccountNo: Text;
        AccountGUID: Text;
    begin
        // [SCENARIO] Create an account and verify it has Id and LastDateTimeModified
        // [GIVEN] a modified G/L Account
        Initialize();
        AccountNo := CreateAccount();
        COMMIT();

        // [WHEN] we retrieve the account from the database
        GLAccount.RESET();
        GLAccount.SETFILTER("No.", AccountNo);
        Assert.IsTrue(GLAccount.FINDFIRST(), 'The G/L Account should exist in the table.');
        AccountGUID := GLAccount.SystemId;

        // [THEN] the account should have last date time modified
        Assert.AreNotEqual(GLAccount."Last Modified Date Time", 0DT, 'Last Modified Date Time should be initialized');
    end;

    [Test]
    procedure TestGetAccounts()
    var
        AccountNo: array[2] of Text;
        AccountJSON: array[2] of Text;
        TargetURL: Text;
        ResponseText: Text;
    begin
        // [SCENARIO] Create accounts and use a GET method to retrieve them
        // [GIVEN] 2 accounts in the G/L Account Table with positive balance
        Initialize();
        AccountNo[1] := CreateAccount();
        AccountNo[2] := CreateAccount();
        COMMIT();

        // [WHEN] we GET all the accounts from the web service
        CLEARLASTERROR();
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Accounts", ServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] the 2 accounts should exist in the response
        IF GETLASTERRORTEXT() <> '' THEN
            Assert.ExpectedError('Request failed with error: ' + GETLASTERRORTEXT());

        GetAndVerifyIDFromJSON(ResponseText, AccountNo[1], AccountJSON[1]);
        GetAndVerifyIDFromJSON(ResponseText, AccountNo[2], AccountJSON[2]);
    end;

    [Normal]
    local procedure CreateAccount(): Text
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.VALIDATE("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.VALIDATE("Direct Posting", TRUE);
        GLAccount.MODIFY(TRUE);
        EXIT(GLAccount."No.");
    end;

    [Normal]
    local procedure GetAndVerifyIDFromJSON(ResponseText: Text; AccountNo: Text; var AccountJSON: Text)
    begin
        Assert.IsTrue(
          LibraryGraphMgt.GetObjectsFromJSONResponse(ResponseText, 'number', AccountNo, AccountNo, AccountJSON, AccountJSON),
          'Could not find the account in JSON');
        LibraryGraphMgt.VerifyIDInJson(AccountJSON);
    end;
}









