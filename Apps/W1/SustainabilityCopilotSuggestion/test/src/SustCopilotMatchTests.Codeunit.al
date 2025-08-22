// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using System.TestTools.AITestToolkit;

codeunit 139796 "Sust. Copilot Match Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestType = AITest;

    var
        LibrarySustainabilityCopilot: Codeunit "Library Sustainability Copilot";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        // [FEATURE] [Sustainability]
    end;

    [Test]
    procedure SustainabilityFormulaAccuracyTest()
    var
        SustainEmissionSuggestion: Record "Sustain. Emission Suggestion";
        ExpectedSourceCO2EmissionBuffer, ActualSourceCO2EmissionBuffer : Record "Source CO2 Emission Buffer";
        SustainabilityAI: Codeunit "Sustainability AI";
        AITContext: Codeunit "AIT Test Context";
        SustainabilityEmissionSource: Codeunit "Sustainability Emission Source";
        JsonContent: JsonObject;
        InputJsonToken, InputFileJsonToken : JsonToken;
        ExpectedCategoryList: Text;
    begin
        // [SCENARIO 561175] Sustainability formula that is returned from Copilot has correct format

        Initialize();

        JsonContent.ReadFrom(AITContext.GetInput().ToText());
        JsonContent.Get('input', InputJsonToken);
        // [GIVEN] Get data input from JSON
        // [GIVEN] Load source file if it is not loaded yet
        JsonContent.Get('InputFile', InputFileJsonToken);
        LoadSourceFiles(InputFileJsonToken.AsValue().AsText());
        // [GIVEN] Generate sustainability journal lines from JSON
        // [GIVEN] Convert sustainability journal line to sustainability emission suggestion
        LibrarySustainabilityCopilot.GetUserInputFromJson(SustainEmissionSuggestion, InputJsonToken.AsObject());

        GetExpectedResultSource(ExpectedSourceCO2EmissionBuffer, ExpectedCategoryList, JsonContent);

        // [WHEN] Generate chat completion and keep only relevant source suggestions
        SustainabilityAI.MatchCategoryToInput(SustainEmissionSuggestion, ActualSourceCO2EmissionBuffer);
        SustainabilityEmissionSource.KeepRelevantSourceCO2EmissionBuffer(SustainEmissionSuggestion, ActualSourceCO2EmissionBuffer);

        // [THEN] Verify that the formula is correct
        VerifyMatch(ActualSourceCO2EmissionBuffer, ExpectedSourceCO2EmissionBuffer, ExpectedCategoryList);
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

    local procedure GetExpectedResultSource(var ExpectedSourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer"; var ExpectedCategoryList: Text; ExpectedResultJObject: JsonObject)
    var
        LineNo: Integer;
        ExpectedResultsToken, ExpectedResultToken, ExpectedValueToken : JsonToken;
    begin
        ExpectedResultJObject.Get('expected_match', ExpectedResultsToken);
        foreach ExpectedResultToken in ExpectedResultsToken.AsArray() do begin
            LineNo += 1;
            ExpectedSourceCO2EmissionBuffer."Line No." := LineNo;
            ExpectedResultToken.AsObject().Get('category', ExpectedValueToken);
            ExpectedSourceCO2EmissionBuffer.Description := CopyStr(ExpectedValueToken.AsValue().AsText(), 1, MaxStrLen(ExpectedSourceCO2EmissionBuffer.Description));
            ExpectedResultToken.AsObject().Get('sourcefile', ExpectedValueToken);
            ExpectedSourceCO2EmissionBuffer."Source Description" := CopyStr(ExpectedValueToken.AsValue().AsText(), 1, MaxStrLen(ExpectedSourceCO2EmissionBuffer.Description));
            ExpectedResultToken.AsObject().Get('conversion_factor', ExpectedValueToken);
            ExpectedSourceCO2EmissionBuffer."Conversion Factor" := ExpectedValueToken.AsValue().AsDecimal();
            ExpectedSourceCO2EmissionBuffer.Insert();
            if ExpectedCategoryList <> '' then
                ExpectedCategoryList += ', ';
            ExpectedCategoryList += ExpectedSourceCO2EmissionBuffer.Description;
        end;
    end;

    local procedure AddPublicInformationSourceIfActualResultIsEmpty(var ActualSourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer")
    begin
        if not ActualSourceCO2EmissionBuffer.IsEmpty() then
            exit;
        ActualSourceCO2EmissionBuffer.Description := '-';
        ActualSourceCO2EmissionBuffer."Source Description" := 'Public information';
        ActualSourceCO2EmissionBuffer.Insert();
    end;

    local procedure VerifyMatch(var ActualSourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer"; var ExpectedSourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer"; ExpectedCategoryList: Text)
    var
        ErrorMessage: Text;
    begin
        AddPublicInformationSourceIfActualResultIsEmpty(ActualSourceCO2EmissionBuffer);
        Assert.IsTrue(ActualSourceCO2EmissionBuffer.FindSet(), 'No results from Copilot');
        repeat
            ExpectedSourceCO2EmissionBuffer.SetRange(Description, ActualSourceCO2EmissionBuffer.Description);
            Assert.IsTrue(ExpectedSourceCO2EmissionBuffer.FindFirst(), 'Actual category ' + ActualSourceCO2EmissionBuffer.Description + ' is not found in the list of expected: ' + ExpectedCategoryList);
            ExpectedSourceCO2EmissionBuffer.TestField("Source Description", ActualSourceCO2EmissionBuffer."Source Description");
            ExpectedSourceCO2EmissionBuffer.TestField("Conversion Factor", ActualSourceCO2EmissionBuffer."Conversion Factor");
            ExpectedSourceCO2EmissionBuffer.Delete();
        until ActualSourceCO2EmissionBuffer.Next() = 0;
        ExpectedCategoryList := '';
        if ExpectedSourceCO2EmissionBuffer.FindSet() then begin
            repeat
                ExpectedCategoryList += ExpectedSourceCO2EmissionBuffer.Description + ', ';
            until ExpectedSourceCO2EmissionBuffer.Next() = 0;
            ErrorMessage := 'Expected categories are not found in the list of actual: ' + ExpectedCategoryList;
            Error(ErrorMessage);
        end;
    end;

    local procedure LoadSourceFiles(FileName: Text)
    var
        EmissionSourceSetup: Record "Emission Source Setup";
        ResInStream: InStream;
        JsonContent: JsonObject;
        FilesJsonToken, LineJsonToken, ValueJsonToken : JsonToken;
        SourceFileResName: Text;
        ResourceNameParts: List of [Text];
        CountryCode: Code[10];
    begin
        EmissionSourceSetup.SetRange(Description, FileName);
        if EmissionSourceSetup.FindFirst() then
            exit;
        EmissionSourceSetup.SetRange(Description);
        EmissionSourceSetup.DeleteAll(true);

        SourceFileResName := 'sourcefiles/' + FileName;
        NavApp.GetResource('sourcefiles/SourceFileCountrySetup.json', ResInStream);
        JsonContent.ReadFrom(ResInStream);
        JsonContent.Get('sourceFiles', FilesJsonToken);
        foreach LineJsonToken in FilesJsonToken.AsArray() do begin
            LineJsonToken.AsObject().Get('fileName', ValueJsonToken);
            if (ValueJsonToken.AsValue().AsText() = FileName) then begin
                LineJsonToken.AsObject().Get('CountryRegionCode', ValueJsonToken);
                CountryCode := CopyStr(ValueJsonToken.AsValue().AsText(), 1, MaxStrLen(CountryCode));
                break;
            end;
        end;

        Clear(ResInStream);
        NavApp.GetResource(SourceFileResName, ResInStream);
        ResourceNameParts := SourceFileResName.Split('/');
        EmissionSourceSetup."Country/Region Code" := CountryCode;
        EmissionSourceSetup.Description := CopyStr(ResourceNameParts.Get(ResourceNameParts.Count()), 1, MaxStrLen(EmissionSourceSetup.Description));
        EmissionSourceSetup.Insert();
        EmissionSourceSetup.ImportExcelSheet(ResInStream);
        Commit();
    end;
}