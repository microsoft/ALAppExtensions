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

codeunit 133719 "EDoc Line Match Def Grnd"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;
    Access = Internal;

    internal procedure Initialize()
    var
        EDocument: Record "E-Document";
        DeferralTemplate: Record "Deferral Template";
    begin
        // ToDo: check if them appearing in history messes up the test
        DeferralTemplate.DeleteAll(false);
        if EDocument.FindSet() then
            repeat
                EDocument.CleanupDocument();
                EDocument.Delete(false);
            until EDocument.Next() = 0;
    end;

    [Test]
    procedure TestGrounding_LineMatching_Deferrals()
    var
        EDocument: Record "E-Document";
        TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary;
        Output: Text;
        ResponseGrounded: Boolean;
    begin
        Initialize();
        // [GIVEN] A set of Deferral Templates
        SetupMasterData();
        // [GIVEN] An E-Document with a set of lines
        CreateEDocumentPurchaseLines(EDocument);

        // [WHEN] The lines are processed
        RunMatchingAlgorithm(EDocument, TempEDocLineMatchBuffer);

        // [THEN] The lines are matched with the Deferral Templates, not with something else
        ResponseGrounded := VerifyMatchingResults(EDocument, TempEDocLineMatchBuffer, Output);
        WriteTestOutput(ResponseGrounded, Output);
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

    internal procedure VerifyMatchingResults(var EDocument: Record "E-Document"; var EDocLineMatchBuffer: Record "EDoc Line Match Buffer"; var Output: Text): Boolean
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        DeferralTemplate: Record "Deferral Template";
        ResponseUnGrounded: Boolean;
    begin
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocLineMatchBuffer.SetRange("E-Document Entry No.", EDocument."Entry No");
        if EDocLineMatchBuffer.FindSet() then
            repeat
                if Output = '' then
                    Output := '(' + Format(EDocLineMatchBuffer."Line No.") + ',' + Format(EDocLineMatchBuffer."Deferral Code") + ')'
                else
                    Output += (',' + '(' + Format(EDocLineMatchBuffer."Line No.") + ',' + Format(EDocLineMatchBuffer."Deferral Code") + ')');
                EDocumentPurchaseLine.SetRange("Line No.", EDocLineMatchBuffer."Line No.");
                if EDocumentPurchaseLine.IsEmpty() then
                    ResponseUnGrounded := true;
                DeferralTemplate.SetRange("Deferral Code", EDocLineMatchBuffer."Deferral Code");
                if DeferralTemplate.IsEmpty() then
                    ResponseUnGrounded := true;
            until EDocLineMatchBuffer.Next() = 0;
        exit(not ResponseUnGrounded);
    end;

    internal procedure WriteTestOutput(DataCreatedSuccessfully: Boolean; Output: Text)
    var
        ContextJson: JsonObject;
        ContextText: Text;
        QuestionText: Text;
    begin
        // [GIVEN] A set of Deferral Templates and an E-Document with a set of lines
        ContextJson.Add('Given Deferral Templates', GetTestSetup().Element('deferralTemplatesToCreate').AsJsonToken());
        ContextJson.Add('Given E-Document Lines', AITTestContext.GetInput().Element('line_items').AsJsonToken());
        ContextJson.WriteTo(ContextText);

        QuestionText := AITTestContext.GetQuestion().ToText();

        AITTestContext.SetTestOutput(ContextText, QuestionText, Output);
        Assert.IsTrue(DataCreatedSuccessfully, Output);
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
