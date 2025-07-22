// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.EDocuments;

using Microsoft.eServices.EDocument;
using System.TestTools.AITestToolkit;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument.Processing.Import;
using System.TestLibraries.AdversarialSimulation;
using System.TestTools.TestRunner;
using Microsoft.Finance.Deferral;

codeunit 133721 "EDoc Line Match Deferral Harm"
{
    Subtype = Test;
    TestType = Uncategorized;
    SingleInstance = true;
    TestPermissions = Disabled;
    Access = Internal;

    var
        AdversarialSimulation: Codeunit "Adversarial Simulation";
        Initialized: Boolean;


    internal procedure Initialize()
    var
        EDocument: Record "E-Document";
        DeferralTemplate: Record "Deferral Template";
        AttackTypeInput: Codeunit "Test Input Json";
        AttackTypeInputExists: Boolean;
    begin
        DeferralTemplate.DeleteAll(false);
        if EDocument.FindSet() then
            repeat
                EDocument.CleanupDocument();
                EDocument.Delete(false);
            until EDocument.Next() = 0;

        if Initialized then
            exit;

        AttackTypeInput := AITTestContext.GetInput().ElementExists('attack_type', AttackTypeInputExists);
        if not AttackTypeInputExists then
            Error('Test input for attack type is missing.');

        Clear(AdversarialSimulation);
        AdversarialSimulation.SetSeed(1996);

        case AttackTypeInput.ValueAsText() of
            'Harms':
                AdversarialSimulation.Start();
            'XPIA':
                AdversarialSimulation.StartXPIA();
            else
                Error('Unknown attack type: %1', AttackTypeInput.ValueAsText());
        end;

        Initialized := true;
    end;

    [Test]
    procedure TestAccuracy_LineMatching_Deferrals_Harm()
    var
        EDocument: Record "E-Document";
        TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary;
        OutputJson: JsonObject;
        DataCreatedSuccessfully: Boolean;
        Harm: Text;
    begin
        Initialize();
        // [GIVEN] A set of Deferral Templates
        EDocLineMatchingDeferral.SetupMasterData();
        // [GIVEN] An E-Document with a harmfull line
        Harm := CreateEDocumentPurchaseLines(EDocument);

        // [WHEN] The lines are processed
        EDocLineMatchingDeferral.RunMatchingAlgorithm(EDocument, TempEDocLineMatchBuffer);

        // [THEN] The line is not matched and no harmfull data is created
        // Note: AI Foundry automated harms validation is run on the output
        DataCreatedSuccessfully := EDocLineMatchingDeferral.VerifyMatchingResults(TempEDocLineMatchBuffer, OutputJson);
        WriteTestOutput(DataCreatedSuccessfully, OutputJson, Harm);
    end;

    internal procedure CreateEDocumentPurchaseLines(var EDocument: Record "E-Document") Harm: Text
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        AttackTypeInput: Codeunit "Test Input Json";
        AttackTypeInputExists: Boolean;
    begin
        EDocument.Insert(true);
        EDocumentPurchaseLine.Init();
        EDocumentPurchaseLine.Validate("E-Document Entry No.", EDocument."Entry No");
        EDocumentPurchaseLine.Validate("Line No.", 10000);

        AttackTypeInput := AITTestContext.GetInput().ElementExists('attack_type', AttackTypeInputExists);
        if not AttackTypeInputExists then
            Error('Test input for attack type is missing.');

        case AttackTypeInput.ValueAsText() of
            'Harms':
                Harm := AdversarialSimulation.GetHarm();
            'XPIA':
                AdversarialSimulation.GetHarmWithXPIA(Harm);
            else
                Error('Unknown attack type: %1', AttackTypeInput.ValueAsText());
        end;
        RemoveChars(Harm);

        EDocumentPurchaseLine.Validate(Description, CopyStr(Harm, 1, MaxStrLen(EDocumentPurchaseLine.Description)));
        EDocumentPurchaseLine.Insert();
    end;

    internal procedure WriteTestOutput(DataCreatedSuccessfully: Boolean; OutputJson: JsonObject; Harm: Text)
    var
        ContextJson, AnswerJson, GeneratedLine : JsonObject;
        ContextText: Text;
        QuestionText: Text;
        AnswerText: Text;
    begin
        // [GIVEN] A set of Deferral Templates
        ContextJson.Add('Given Deferral Templates', EDocLineMatchingDeferral.GetTestSetup().Element('deferralTemplatesToCreate').AsJsonToken());
        // [GIVEN] An E-Document with a harmfull line
        GeneratedLine.Add('line_id', 10000);
        GeneratedLine.Add('description', Harm);
        ContextJson.Add('Given E-Document Line', GeneratedLine);
        ContextJson.WriteTo(ContextText);

        QuestionText := AITTestContext.GetQuestion().ToText();

        AnswerJson.Add('Expected matches', AITTestContext.GetExpectedData().AsJsonToken());
        AnswerJson.Add('Actual matches', OutputJson);
        AnswerJson.WriteTo(AnswerText);

        AITTestContext.SetTestOutput(ContextText, QuestionText, AnswerText);
    end;

    local procedure RemoveChars(var Harm: Text)
    begin
        // Remove all special characters from the string
        Harm := Harm.Replace('"', '');
        Harm := Harm.Replace('#', '');
        Harm := Harm.Replace('$', '');
        Harm := Harm.Replace('%', '');
        Harm := Harm.Replace('&', '');
        Harm := Harm.Replace('`', '');
        Harm := Harm.Replace('(', '');
        Harm := Harm.Replace('_', ' ');
        Harm := Harm.Replace('-', ' ');
        Harm := Harm.Replace('\n', ' ');
        Harm := Harm.Replace('\t', ' ');
    end;

    var
        EDocLineMatchingDeferral: Codeunit "EDoc Line Matching - Deferral";
        AITTestContext: Codeunit "AIT Test Context";
}
