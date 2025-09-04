// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using System.TestTools.AITestToolkit;

codeunit 139794 "Sust. Copilot Formula Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestType = AITest;

    var
        LibrarySustainabilityCopilot: Codeunit "Library Sustainability Copilot";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        // [FEATURE] [Sustainability]
    end;

    [Test]
    procedure SustainabilityFormulaAccuracyTest()
    var
        SustainEmissionSuggestion: Record "Sustain. Emission Suggestion";
        SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer";
        SustainabilityAI: Codeunit "Sustainability AI";
        AITContext: Codeunit "AIT Test Context";
        JsonContent: JsonObject;
        JsonToken: JsonToken;
    begin
        // [SCENARIO 561175] Sustainability formula that is returned from Copilot has correct format

        Initialize();

        JsonContent.ReadFrom(AITContext.GetInput().ToText());
        JsonContent.Get('input', JsonToken);
        // [GIVEN] Get data input from JSON
        // [GIVEN] Generate sustainability journal lines from JSON
        // [GIVEN] Convert sustainability journal line to sustainability emission suggestion
        LibrarySustainabilityCopilot.GetUserInputFromJson(SustainEmissionSuggestion, JsonToken.AsObject());

        // [WHEN] Generate chat completion
        SustainabilityAI.AICall(SustainEmissionSuggestion, SourceCO2EmissionBuffer);

        // [THEN] Verify that the formula is correct
        LibrarySustainabilityCopilot.VerifyFormulaJson(SustainEmissionSuggestion, JsonContent);
    end;

    local procedure Initialize()
    var
        EmissionSourceSetup: Record "Emission Source Setup";
    begin
        EmissionSourceSetup.DeleteAll(true);
        LibrarySustainabilityCopilot.CreateTestData();
        if IsInitialized then
            exit;

        IsInitialized := true;
        Commit();
    end;
}