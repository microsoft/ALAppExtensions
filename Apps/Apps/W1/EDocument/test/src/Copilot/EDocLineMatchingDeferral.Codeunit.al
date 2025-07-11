// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.EDocuments;

using Microsoft.eServices.EDocument;
using System.TestTools.AITestToolkit;
using System.TestTools.TestRunner;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.Finance.Deferral;

codeunit 133720 "EDoc Line Matching - Deferral"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    internal procedure Initialize()
    var
        EDocument: Record "E-Document";
        DeferralTemplate: Record "Deferral Template";
    begin
        DeferralTemplate.DeleteAll(false);
        if EDocument.FindSet() then
            repeat
                EDocument.CleanupDocument();
                EDocument.Delete(false);
            until EDocument.Next() = 0;
    end;

    [Test]
    procedure TestAccuracy_LineMatching_Deferrals()
    var
        EDocument: Record "E-Document";
        TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary;
        OutputJson: JsonObject;
        DataCreatedSuccessfully: Boolean;
    begin
        Initialize();
        // [GIVEN] A set of Deferral Templates
        SetupMasterData();
        // [GIVEN] An E-Document with a set of lines
        CreateEDocumentPurchaseLines(EDocument);

        // [WHEN] The lines are processed
        RunMatchingAlgorithm(EDocument, TempEDocLineMatchBuffer);

        // [THEN] The lines are matched with the Deferral Templates
        DataCreatedSuccessfully := VerifyMatchingResults(TempEDocLineMatchBuffer, OutputJson);
        WriteTestOutput(DataCreatedSuccessfully, OutputJson);
    end;

    internal procedure SetupMasterData()
    begin
        CreateDeferralTemplatesFromTestSetup();
    end;

    internal procedure CreateEDocumentPurchaseLines(var EDocument: Record "E-Document")
    var
        LineItemsInput: Codeunit "Test Input Json";
        LineItemsInputExists: Boolean;
        LinesToCreateCount, I : Integer;
    begin
        EDocument.Insert(true);
        LineItemsInput := AITTestContext.GetInput().ElementExists('line_items', LineItemsInputExists);
        if (not LineItemsInputExists) then
            exit;

        LinesToCreateCount := LineItemsInput.GetElementCount();

        for I := 0 to LinesToCreateCount - 1 do
            CreateEDocumentLine(EDocument, LineItemsInput.ElementAt(I));
    end;

    internal procedure RunMatchingAlgorithm(var EDocument: Record "E-Document"; var TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary)
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocLineMatcherDeferral: Codeunit "E-Doc Line Matcher - Deferral";
    begin
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocumentPurchaseLine.FindSet();
        EDocLineMatcherDeferral.GetPurchaseLineMatchingProposals(EDocumentPurchaseLine);
        EDocLineMatcherDeferral.LoadEDocLineMatchBuffer(TempEDocLineMatchBuffer);
    end;

    internal procedure VerifyMatchingResults(var EDocLineMatchBuffer: Record "EDoc Line Match Buffer"; var OutputJson: JsonObject): Boolean
    var
        ExpectedMatchesInput: Codeunit "Test Input Json";
        MatchLineCount: Integer;
    begin
        ExpectedMatchesInput := AITTestContext.GetExpectedData();
        MatchLineCount := GetExpectedMatchCount(ExpectedMatchesInput, EDocLineMatchBuffer, OutputJson);

        if MatchLineCount = 0 then
            exit(ValidateNoExpectedMatches(EDocLineMatchBuffer, OutputJson))
        else
            exit(ValidateExpectedMatches(ExpectedMatchesInput, MatchLineCount, EDocLineMatchBuffer, OutputJson));
    end;

    internal procedure GetExpectedMatchCount(ExpectedMatchesInput: Codeunit "Test Input Json"; var EDocLineMatchBuffer: Record "EDoc Line Match Buffer"; var OutputJson: JsonObject) MatchLineCount: Integer
    var
        NumberOfMatchesJsonObject: JsonObject;
    begin
        if ExpectedMatchesInput.AsJsonToken().IsArray() then
            MatchLineCount := ExpectedMatchesInput.GetElementCount()
        else
            MatchLineCount := 0;
        NumberOfMatchesJsonObject.Add('Expected', MatchLineCount);
        Clear(EDocLineMatchBuffer);
        // EDocLineMatchBuffer.SetFilter("Purchase Type No.", '<> %1', '');
        NumberOfMatchesJsonObject.Add('Proposed', EDocLineMatchBuffer.Count());
        OutputJson.Add('Number of matches', NumberOfMatchesJsonObject);
    end;

    internal procedure ValidateNoExpectedMatches(var EDocLineMatchBuffer: Record "EDoc Line Match Buffer"; var OutputJson: JsonObject): Boolean
    var
        JsonObject: JsonObject;
        JsonArray: JsonArray;
    begin
        // We have no matches and we expect no matches
        if not EDocLineMatchBuffer.FindSet() then
            exit(true);

        // We have matches, but we don't expect any
        repeat
            Clear(JsonObject);
            JsonObject.Add('Line No.', EDocLineMatchBuffer."Line No.");
            JsonObject.Add('Matched Deferral Code', EDocLineMatchBuffer."Deferral Code");
            JsonArray.Add(JsonObject);
        until EDocLineMatchBuffer.Next() = 0;
        OutputJson.Add('List of unexpected matches', JsonArray);
        exit(false);
    end;

    internal procedure ValidateExpectedMatches(ExpectedMatchesInput: Codeunit "Test Input Json"; MatchLineCount: Integer; var EDocLineMatchBuffer: Record "EDoc Line Match Buffer"; var OutputJson: JsonObject): Boolean
    var
        MismatchArray, UnexpectedProposalsArray : JsonArray;
        IsValidationSuccessful: Boolean;
        I: Integer;
    begin
        for I := 0 to MatchLineCount - 1 do
            ValidateSingleExpectedMatch(ExpectedMatchesInput.ElementAt(I), EDocLineMatchBuffer, MismatchArray);

        ValidateUnexpectedProposals(EDocLineMatchBuffer, UnexpectedProposalsArray);

        IsValidationSuccessful := (MismatchArray.Count() = 0) and (UnexpectedProposalsArray.Count() = 0);

        if not IsValidationSuccessful then begin
            if MismatchArray.Count() > 0 then
                OutputJson.Add('Expected match issues', MismatchArray);
            if UnexpectedProposalsArray.Count() > 0 then
                OutputJson.Add('Unexpected proposals', UnexpectedProposalsArray);
        end;
        exit(IsValidationSuccessful);
    end;

    internal procedure ValidateSingleExpectedMatch(ExpectedMatch: Codeunit "Test Input Json"; var EDocLineMatchBuffer: Record "EDoc Line Match Buffer"; var JsonArray: JsonArray)
    var
        ExpectedMatchedFieldValue: Codeunit "Test Input Json";
        JsonObject: JsonObject;
        ExpectedMatchLineId: Integer;
        MissingExpectedMatchTok: Label 'Missing expected match', Locked = true;
        DeferralCodeMismatchTok: Label 'Deferral code mismatch', Locked = true;
    begin
        ExpectedMatchLineId := ExpectedMatch.Element('line_id').ValueAsInteger();
        EDocLineMatchBuffer.SetRange("Line No.", ExpectedMatchLineId);

        if not EDocLineMatchBuffer.FindFirst() then begin
            JsonObject.Add('Error type', MissingExpectedMatchTok);
            JsonObject.Add('Line No.', ExpectedMatchLineId);
            JsonObject.Add('Expected Deferral Code', ExpectedMatch.Element('deferral_code').ValueAsText());
            JsonArray.Add(JsonObject);
            exit;
        end;

        ExpectedMatchedFieldValue := ExpectedMatch.Element('deferral_code');
        if EDocLineMatchBuffer."Deferral Code" <> ExpectedMatchedFieldValue.ValueAsText() then begin
            JsonObject.Add('Error type', DeferralCodeMismatchTok);
            JsonObject.Add('Line No.', ExpectedMatchLineId);
            JsonObject.Add('Expected Deferral Code', ExpectedMatchedFieldValue.ValueAsText());
            JsonObject.Add('Actual Deferral Code', EDocLineMatchBuffer."Deferral Code");
            JsonArray.Add(JsonObject);
        end;

        // Remove the matched line from the buffer. This is to ensure if there are any unexpected proposals, they will be captured later.
        EDocLineMatchBuffer.Delete();
    end;

    internal procedure ValidateUnexpectedProposals(var EDocLineMatchBuffer: Record "EDoc Line Match Buffer"; var UnexpectedProposalsArray: JsonArray)
    var
        JsonObject: JsonObject;
        UnexpectedExtraProposalsTok: Label 'Unexpected extra proposal', Locked = true;
    begin
        Clear(EDocLineMatchBuffer);
        if not EDocLineMatchBuffer.FindSet() then
            exit;

        repeat
            // Proposal for a line that shouldn't have any proposal
            Clear(JsonObject);
            JsonObject.Add('Error type', UnexpectedExtraProposalsTok);
            JsonObject.Add('Line No.', EDocLineMatchBuffer."Line No.");
            JsonObject.Add('Proposed Deferral Code', EDocLineMatchBuffer."Deferral Code");
            UnexpectedProposalsArray.Add(JsonObject);
        until EDocLineMatchBuffer.Next() = 0;
    end;

    internal procedure WriteTestOutput(DataCreatedSuccessfully: Boolean; OutputJson: JsonObject)
    var
        ContextJson, AnswerJson : JsonObject;
        ContextText: Text;
        QuestionText: Text;
        AnswerText: Text;
    begin
        // [GIVEN] A set of Deferral Templates and an E-Document with a set of lines
        ContextJson.Add('Given Deferral Templates', GetTestSetup().Element('deferralTemplatesToCreate').AsJsonToken());
        ContextJson.Add('Given E-Document Lines', AITTestContext.GetInput().Element('line_items').AsJsonToken());
        ContextJson.WriteTo(ContextText);

        QuestionText := AITTestContext.GetQuestion().ToText();

        AnswerJson.Add('Expected matches', AITTestContext.GetExpectedData().AsJsonToken());
        AnswerJson.Add('Actual matches', OutputJson);
        AnswerJson.WriteTo(AnswerText);

        AITTestContext.SetTestOutput(ContextText, QuestionText, AnswerText);
        Assert.IsTrue(DataCreatedSuccessfully, AnswerText);
    end;

    internal procedure CreateDeferralTemplatesFromTestSetup()
    var
        DeferralTemplatesToCreate: Codeunit "Test Input Json";
        DeferralTemplatesToCreateCount, I : Integer;
        DeferralTemplatesInputExists: Boolean;
    begin
        DeferralTemplatesToCreate := GetTestSetup().ElementExists('deferralTemplatesToCreate', DeferralTemplatesInputExists);
        if (not DeferralTemplatesInputExists) then
            exit;

        DeferralTemplatesToCreateCount := DeferralTemplatesToCreate.GetElementCount();

        for I := 0 to DeferralTemplatesToCreateCount - 1 do
            CreateDeferralTemplate(DeferralTemplatesToCreate.ElementAt(I));
    end;

    internal procedure CreateDeferralTemplate(DeferralTemplateToCreate: Codeunit "Test Input Json")
    var
        DeferralTemplate: Record "Deferral Template";
        HasDeferralCode: Boolean;
        AutogeneratedDeferralTemplateCode: Code[10];
    begin
        DeferralTemplateToCreate.ElementExists('deferral_code', HasDeferralCode);
        if HasDeferralCode then
            if DeferralTemplate.Get(DeferralTemplateToCreate.Element('deferral_code').ValueAsText()) then
                exit; // Deferral Template already exists, no need to create it again

        AutogeneratedDeferralTemplateCode := LibraryERM.CreateDeferralTemplateCode(
            Enum::"Deferral Calculation Method"::"Straight-Line",
            Enum::"Deferral Calculation Start Date"::"Posting Date",
            DeferralTemplateToCreate.Element('number_of_periods').ValueAsInteger());

        DeferralTemplate.Get(AutogeneratedDeferralTemplateCode);
        DeferralTemplate.Rename(DeferralTemplateToCreate.Element('deferral_code').ValueAsText());
        DeferralTemplate.Validate(Description, DeferralTemplateToCreate.Element('description').ValueAsText());
        DeferralTemplate.Modify(true);
    end;

    internal procedure CreateEDocumentLine(var EDocument: Record "E-Document"; EDocumentLineToCreate: Codeunit "Test Input Json")
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        LineNumberAlreadyExistsMsg: Label 'Line No. %1 already exists for EDocument %2', Comment = '%1 = Line No., %2 = EDocument No.';
    begin
        Assert.IsFalse(EDocumentPurchaseLine.Get(EDocument."Entry No", EDocumentLineToCreate.Element('line_id').ValueAsInteger()), StrSubstNo(LineNumberAlreadyExistsMsg, EDocumentLineToCreate.Element('line_id').ValueAsInteger(), EDocument."Entry No"));
        EDocumentPurchaseLine.Init();
        EDocumentPurchaseLine.Validate("E-Document Entry No.", EDocument."Entry No");
        EDocumentPurchaseLine.Validate("Line No.", EDocumentLineToCreate.Element('line_id').ValueAsInteger());
        EDocumentPurchaseLine.Validate(Description, EDocumentLineToCreate.Element('description').ValueAsText());
        EDocumentPurchaseLine.Insert();
    end;

    internal procedure GetTestSetup() SetupTestInputJson: Codeunit "Test Input Json"
    begin
        SetupTestInputJson := AITTestContext.GetTestSetup();
        if SetupTestInputJson.AsJsonToken().IsObject() then
            exit(SetupTestInputJson);

        SetupTestInputJson.Initialize(GetTestSetupJsonObj(SetupTestInputJson.ValueAsText()));
        exit(SetupTestInputJson);
    end;

    internal procedure GetTestSetupJsonObj(SetupName: Text): JsonToken //get the setup data from the file based on the available file name
    var
        SetupInStream: InStream;
        SetupAsText: Text;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
    begin
        NavApp.GetResource(GetTestSetupPath() + SetupName, SetupInStream, TextEncoding::UTF8);
        SetupInStream.Read(SetupAsText);
        JsonObject.ReadFromYaml(SetupAsText);
        JsonObject.Get('test_setup', JsonToken);

        exit(JsonToken);
    end;

    internal procedure GetTestSetupPath(): Text
    begin
        exit('AITestSuite/CompanyData/');
    end;

    var
        Assert: Codeunit Assert;
        AITTestContext: Codeunit "AIT Test Context";
        LibraryERM: Codeunit "Library - ERM";
}