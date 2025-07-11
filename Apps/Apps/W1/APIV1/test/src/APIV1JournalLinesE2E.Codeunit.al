codeunit 139745 "APIV1 - Journal Lines E2E"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [JournalLines]
    end;

    var
        IsInitialized: Boolean;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;
        IsInitialized := true;
        Commit();
    end;

    [Test]
    procedure TestCreateJournalLineWithOverridenDefaultDimension()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        DefaultDimensionValue: Record "Dimension Value";
        DifferentDimensionValue: Record "Dimension Value";
        AccountNo: Code[20];
        TargetURL: Text;
        JournalLineJSON: Text;
        DimensionJSON: Text;
        Response: Text;
        "Newtonsoft.Json.Linq.JArray": Dotnet JArray;
        FoundInResponse: Boolean;
        CurrentIndex: Integer;
    begin
        // [BEGIN] A journal line is added through the API with a different dimension value than the one from a default dimension for that account. The Dimension Value should be overriden.
        Initialize();

        // [GIVEN] A GL Account with a journal batch and default dimensions added to that account.
        CreateAccountWithDefaultDimensions(AccountNo, GenJournalBatch, DefaultDimensionValue);
        // [GIVEN] A different value for that dimension.
        LibraryDimension.CreateDimensionValue(DifferentDimensionValue, DefaultDimensionValue."Dimension Code");
        Commit();

        // [WHEN] A journal line is created through the API for that journal batch with the different dimension value.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(GenJournalBatch.SystemId, Page::"APIV1 - Journals", 'journals', 'journalLines');
        JournalLineJSON := LibraryGraphMgt.AddPropertytoJSON('', 'accountType', 'G/L Account');
        JournalLineJSON := LibraryGraphMgt.AddPropertytoJSON(JournalLineJSON, 'accountNumber', AccountNo);
        JournalLineJSON := LibraryGraphMgt.AddPropertytoJSON(JournalLineJSON, 'amount', LibraryRandom.RandDecInRange(10000, 50000, 2));
        DimensionJSON := LibraryGraphMgt.AddPropertytoJSON('', 'code', DefaultDimensionValue."Dimension Code");
        DimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DimensionJSON, 'valueCode', DifferentDimensionValue.Code);
        JournalLineJSON := LibraryGraphMgt.AddComplexTypetoJSON(JournalLineJSON, 'dimensions', '[' + DimensionJSON + ']');

        LibraryGraphMgt.PostToWebService(TargetURL, JournalLineJSON, Response);

        // [THEN] The dimension on the journal line should have the overriden dimension value.
        GetDimensionsFromJSONText(Response, "Newtonsoft.Json.Linq.JArray");

        FoundInResponse := false;
        for CurrentIndex := 0 to "Newtonsoft.Json.Linq.JArray".Count() - 1 do
            if JObjectMatchesDimension("Newtonsoft.Json.Linq.JArray".Item(CurrentIndex), DifferentDimensionValue) then
                FoundInResponse := true;

        Assert.IsTrue(FoundInResponse, 'The overwritten dimension value was not found on the response.');
    end;

    [Test]
    procedure TestCreateJournalLineWithDimensionsOnAccountWithDimensionSetup()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        DefaultDimensionValue: Record "Dimension Value";
        ExtraDimensionValue: Record "Dimension Value";
        AccountNo: Code[20];
        TargetURL: Text;
        JournalLineJSON: Text;
        DimensionJSON: Text;
        Response: Text;
        FoundDefault: Boolean;
        FoundExtra: Boolean;
        "Newtonsoft.Json.Linq.JArray": Dotnet JArray;
        CurrentIndex: Integer;
    begin
        // [SCENARIO] A journal line is added through the API on an account with default dimension, when specifying a different dimension on its creation it should have the default dimension added on top of the specified.
        Initialize();

        // [GIVEN] A GL Account with a journal batch and default dimensions added to that account.
        CreateAccountWithDefaultDimensions(AccountNo, GenJournalBatch, DefaultDimensionValue);

        // [GIVEN] A different dimension we want on our journal line.
        LibraryDimension.CreateDimWithDimValue(ExtraDimensionValue);
        Commit();

        // [WHEN] A journal line is created through the API for that journal batch with the different dimension on the payload.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(GenJournalBatch.SystemId, Page::"APIV1 - Journals", 'journals', 'journalLines');
        JournalLineJSON := LibraryGraphMgt.AddPropertytoJSON('', 'accountType', 'G/L Account');
        JournalLineJSON := LibraryGraphMgt.AddPropertytoJSON(JournalLineJSON, 'accountNumber', AccountNo);
        JournalLineJSON := LibraryGraphMgt.AddPropertytoJSON(JournalLineJSON, 'amount', LibraryRandom.RandDecInRange(10000, 50000, 2));
        DimensionJSON := LibraryGraphMgt.AddPropertytoJSON('', 'code', ExtraDimensionValue."Dimension Code");
        DimensionJSON := LibraryGraphMgt.AddPropertytoJSON(DimensionJSON, 'valueCode', ExtraDimensionValue.Code);
        JournalLineJSON := LibraryGraphMgt.AddComplexTypetoJSON(JournalLineJSON, 'dimensions', '[' + DimensionJSON + ']');

        LibraryGraphMgt.PostToWebService(TargetURL, JournalLineJSON, Response);
        GetDimensionsFromJSONText(Response, "Newtonsoft.Json.Linq.JArray");

        // [THEN] The response should include both the default and the specified dimension.
        FoundDefault := false;
        FoundExtra := false;
        for CurrentIndex := 0 to "Newtonsoft.Json.Linq.JArray".Count() - 1 do begin
            if JObjectMatchesDimension("Newtonsoft.Json.Linq.JArray".Item(CurrentIndex), DefaultDimensionValue) then
                FoundDefault := true;
            if JObjectMatchesDimension("Newtonsoft.Json.Linq.JArray".Item(CurrentIndex), ExtraDimensionValue) then
                FoundExtra := true;
        end;

        Assert.IsTrue(FoundDefault and FoundExtra, 'Default and specified dimensions not found on the response.');
    end;

    [Test]
    procedure TestCreateJournalLineWithoutDimensionsOnAccountWithDimensionSetup()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        DimensionValue: Record "Dimension Value";
        AccountNo: Code[20];
        TargetURL: Text;
        JournalLineJSON: Text;
        Response: Text;
        CurrentIndex: Integer;
        FoundInResponse: Boolean;
        "Newtonsoft.Json.Linq.JArray": Dotnet JArray;
    begin
        // [SCENARIO] A journal line is added through the API on an account with default dimension, without specifying dimension on its creation it should have the default dimensions added.
        Initialize();

        // [GIVEN] A GL Account with a journal batch and default dimensions added to that account.
        CreateAccountWithDefaultDimensions(AccountNo, GenJournalBatch, DimensionValue);
        Commit();

        // [WHEN] A journal line is created through the API for that journal batch.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(GenJournalBatch.SystemId, Page::"APIV1 - Journals", 'journals', 'journalLines');
        JournalLineJSON := LibraryGraphMgt.AddPropertytoJSON('', 'accountType', 'G/L Account');
        JournalLineJSON := LibraryGraphMgt.AddPropertytoJSON(JournalLineJSON, 'accountNumber', AccountNo);
        JournalLineJSON := LibraryGraphMgt.AddPropertytoJSON(JournalLineJSON, 'amount', LibraryRandom.RandDecInRange(10000, 50000, 2));

        LibraryGraphMgt.PostToWebService(TargetURL, JournalLineJSON, Response);

        // [THEN] The response should include the default dimension from the account on the journal line.
        GetDimensionsFromJSONText(Response, "Newtonsoft.Json.Linq.JArray");

        FoundInResponse := false;
        for CurrentIndex := 0 to "Newtonsoft.Json.Linq.JArray".Count() - 1 do
            if JObjectMatchesDimension("Newtonsoft.Json.Linq.JArray".Item(CurrentIndex), DimensionValue) then
                FoundInResponse := true;

        Assert.IsTrue(FoundInResponse, 'The default dimension and dimension value was not found on the response.');
    end;

    [Test]
    procedure TestCreateJournalLineWithDisabledCopyVATSetup()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        AccountType: Enum "Sales Document Type";
        Response: Text;
    begin
        // [SCENARIO 557128] VAT posting group filled in General Journal created by standard API.
        Initialize();

        // [GIVEN] Create new VAT Product Posting Group
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);

        // [GIVEN] Create new G/L Account and assign VAT Prod. Posting Group
        CreateGLAccountWithVATProdPostingGroup(GLAccount, VATProductPostingGroup.Code);

        // [GIVEN] Create new General Journal Batch and disable Copy VAT Setup to Jnl. Lines in Journal Batch
        CreateGeneralJournalBatchWithCopyVATSetupJnlLines(GenJournalBatch, AccountType, GLAccount."No.");

        // [WHEN] A journal line is created through the API for that journal batch.
        CreateAndPostJournalLineJson(GenJournalBatch, GLAccount."No.", Response);

        // [THEN] Verify VAT Product Posting Group should be blank in journal line.
        VerifyJournalLineVATProdPostingGroup(GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GetLineNoFromJSONText(Response));
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibraryRandom: Codeunit "Library - Random";
        JSONManagement: Codeunit "JSON Management";
        Assert: Codeunit "Assert";
        VATProdPostingGroupBlankMsg: Label 'VAT Prod. Posting Group must be blank';

    procedure JObjectMatchesDimension("Newtonsoft.Json.Linq.JObject": Dotnet JObject; DimensionValue: Record "Dimension Value"): Boolean
    var
        Dimension: Text;
    begin
        JSONManagement.GetStringPropertyValueFromJObjectByPath("Newtonsoft.Json.Linq.JObject", 'code', Dimension);
        if Dimension = DimensionValue."Dimension Code" then begin
            JSONManagement.GetStringPropertyValueFromJObjectByPath("Newtonsoft.Json.Linq.JObject", 'valueCode', Dimension);
            Assert.AreEqual(Dimension, DimensionValue.Code, 'Dimension has required code but different value code');
            exit(true);
        end;
        exit(false);
    end;

    procedure GetDimensionsFromJSONText(Response: Text; var "Newtonsoft.Json.Linq.JArray": Dotnet JArray)
    var
        "Newtonsoft.Json.Linq.JObject": Dotnet JObject;
    begin
        JSONManagement.InitializeObject(Response);
        JSONManagement.GetJSONObject("Newtonsoft.Json.Linq.JObject");
        JSONManagement.GetArrayPropertyValueFromJObjectByName("Newtonsoft.Json.Linq.JObject", 'dimensions', "Newtonsoft.Json.Linq.JArray");
    end;

    procedure CreateGeneralJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch"; BalAccountType: Enum "Sales Document Type"; BalAccountNo: Code[20])
    begin
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate());
        GenJournalBatch.Validate("Bal. Account Type", BalAccountType);
        GenJournalBatch.Validate("Bal. Account No.", BalAccountNo);
        GenJournalBatch.Modify(true);
    end;

    procedure CreateAccountWithDefaultDimensions(var AccountNo: Code[20]; var GenJournalBatch: Record "Gen. Journal Batch"; var DimensionValue: Record "Dimension Value")
    var
        DefaultDimension: Record "Default Dimension";
        AccountType: Enum "Sales Document Type";
    begin
        AccountNo := LibraryERM.CreateGLAccountNo();
        CreateGeneralJournalBatch(GenJournalBatch, AccountType, AccountNo);

        LibraryDimension.CreateDimWithDimValue(DimensionValue);
        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::"G/L Account", AccountNo, DimensionValue."Dimension Code", DimensionValue.Code);
    end;

    local procedure CreateAndPostJournalLineJson(GenJournalBatch: Record "Gen. Journal Batch"; GLAccountNo: Code[20]; var Response: Text)
    var
        JournalLineJSON: Text;
        TargetURL: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(GenJournalBatch.SystemId, Page::"APIV1 - Journals", 'journals', 'journalLines');
        JournalLineJSON := LibraryGraphMgt.AddPropertytoJSON(JournalLineJSON, 'documentNumber', LibraryRandom.RandText(5));
        JournalLineJSON := LibraryGraphMgt.AddPropertytoJSON(JournalLineJSON, 'accountType', 'G/L Account');
        JournalLineJSON := LibraryGraphMgt.AddPropertytoJSON(JournalLineJSON, 'accountNumber', GLAccountNo);
        JournalLineJSON := LibraryGraphMgt.AddPropertytoJSON(JournalLineJSON, 'amount', LibraryRandom.RandDecInRange(10000, 50000, 2));

        LibraryGraphMgt.PostToWebService(TargetURL, JournalLineJSON, Response);
    end;

    local procedure CreateGeneralJournalBatchWithCopyVATSetupJnlLines(var GenJournalBatch: Record "Gen. Journal Batch"; BalAccountType: Enum "Sales Document Type"; BalAccountNo: Code[20])
    begin
        CreateGeneralJournalBatch(GenJournalBatch, BalAccountType, BalAccountNo);
        GenJournalBatch.Validate("Copy VAT Setup to Jnl. Lines", false);
        GenJournalBatch.Modify(true);
    end;

    local procedure CreateGLAccountWithVATProdPostingGroup(var GLAccount: Record "G/L Account"; VATProductPostingGroupCode: Code[20])
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("VAT Prod. Posting Group", VATProductPostingGroupCode);
        GLAccount.Modify(true);
    end;

    local procedure GetLineNoFromJSONText(Response: Text): Integer
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(Response);
        JObject.Get('lineNumber', JToken);
        exit(JToken.AsValue().AsInteger());
    end;

    local procedure VerifyJournalLineVATProdPostingGroup(JournalTemplateName: Code[10]; JournalBatchName: code[10]; LineNo: Integer)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Get(JournalTemplateName, JournalBatchName, LineNo);
        Assert.AreEqual(GenJournalLine."VAT Prod. Posting Group", '', VATProdPostingGroupBlankMsg);
    end;
}