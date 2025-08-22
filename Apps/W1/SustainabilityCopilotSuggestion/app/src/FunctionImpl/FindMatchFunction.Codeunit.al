// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using System.AI;
using System.Telemetry;

codeunit 6330 "Find Match Function" implements "AOAI Function"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";

        FunctionNameLbl: Label 'find_matches', Locked = true;

    [NonDebuggable]
    procedure GetPrompt(): JsonObject
    var
        Prompts: Codeunit "Sustainability Prompts";
        PromptJson: JsonObject;
    begin
        PromptJson.ReadFrom(Prompts.GetMatchCategoryToInputFunction().Unwrap());
        exit(PromptJson);
    end;

    [NonDebuggable]
    procedure Execute(Arguments: JsonObject): Variant
    var
        EmissionSourceSetup: Record "Emission Source Setup";
        TempSourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer" temporary;
        SourceCO2Emission: Record "Source CO2 Emission";
        ResultsToken, ResultToken, ValueToken : JsonToken;
        ResultsArray: JsonArray;
    begin
        if not Arguments.Get('results', ResultsToken) then begin
            FeatureTelemetry.LogError('0000PWE', FunctionNameLbl, 'Sustainability Emission Info', 'results not found in tools object.');
            exit(TempSourceCO2EmissionBuffer);
        end;
        ResultsArray := ResultsToken.AsArray();
        foreach ResultToken in ResultsArray do begin
            ResultToken.AsObject().Get('categoryID', ValueToken);
            SourceCO2Emission.Get(ValueToken.AsValue().AsInteger());
            TempSourceCO2EmissionBuffer."Source CO2 Emission Id" := SourceCO2Emission.Id;
            TempSourceCO2EmissionBuffer."Emission Source ID" := SourceCO2Emission."Emission Source ID";
            TempSourceCO2EmissionBuffer.Description := SourceCO2Emission.Description;
            TempSourceCO2EmissionBuffer."Emission Factor CO2" := SourceCO2Emission."Emission Factor CO2";
            ResultToken.AsObject().Get('inputLineNo', ValueToken);
            TempSourceCO2EmissionBuffer."Line No." := ValueToken.AsValue().AsInteger();
            ResultToken.AsObject().Get('similarity_score', ValueToken);
            TempSourceCO2EmissionBuffer.Validate("Confidence Value", ValueToken.AsValue().AsDecimal());
            EmissionSourceSetup.Get(TempSourceCO2EmissionBuffer."Emission Source ID");
            TempSourceCO2EmissionBuffer."Country/Region Code" := EmissionSourceSetup."Country/Region Code";
            TempSourceCO2EmissionBuffer."Source Description" := EmissionSourceSetup.Description;
            ResultToken.AsObject().Get('conversion_factor', ValueToken);
            TempSourceCO2EmissionBuffer.Validate("Conversion Factor", ValueToken.AsValue().AsDecimal());
            TempSourceCO2EmissionBuffer.Insert();
        end;
        exit(TempSourceCO2EmissionBuffer);
    end;

    procedure GetName(): Text
    begin
        exit(FunctionNameLbl);
    end;
}