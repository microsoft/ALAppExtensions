// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using System.TestTools.AITestToolkit;

codeunit 139797 "Sust. Copilot Emiss. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestType = AITest;

    var
        LibrarySustainabilityCopilot: Codeunit "Library Sustainability Copilot";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        IncorrectEmissionFactorErr: Label 'Incorrect emission factor. Expected between %1 and %2. Actual %3.', Comment = '%1 = minExpectedResult, %2 = maxExpectedResult, %3 = actualEmissionFactor';

    trigger OnRun()
    begin
        // [FEATURE] [Sustainability]
    end;

    [Test]
    procedure SustainabilityEmissionAccuracyTest()
    var
        SustainEmissionSuggestion: Record "Sustain. Emission Suggestion";
        SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer";
        SustainabilityAI: Codeunit "Sustainability AI";
        AITContext: Codeunit "AIT Test Context";
        JsonContent: JsonObject;
        JsonToken: JsonToken;
    begin
        // [SCENARIO 561175] Sustainability emission factor that is returned from Copilot is correct

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
        VerifyEmission(SustainEmissionSuggestion, JsonContent);
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


    local procedure VerifyEmission(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; ExpectedResultsJObject: JsonObject)
    var
        ExpectedValueToken: JsonToken;
        MinExpectedResult, MaxExpectedResult : Decimal;
    begin
        ExpectedResultsJObject.Get('minExpectedResult', ExpectedValueToken);
        MinExpectedResult := ExpectedValueToken.AsValue().AsDecimal();
        ExpectedResultsJObject.Get('maxExpectedResult', ExpectedValueToken);
        MaxExpectedResult := ExpectedValueToken.AsValue().AsDecimal();
        Assert.IsTrue(
            SustainEmissionSuggestion."Emission Factor CO2" in [MinExpectedResult .. MaxExpectedResult],
            StrSubstNo(IncorrectEmissionFactorErr, MinExpectedResult, MaxExpectedResult, SustainEmissionSuggestion."Emission Factor CO2"));
    end;
}