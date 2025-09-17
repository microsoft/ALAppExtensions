// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;
using System.Telemetry;
using System.AI;

codeunit 6328 "Raw Formula Function" implements "AOAI Function"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var

        FunctionNameLbl: Label 'formula_function', Locked = true;

    [NonDebuggable]
    procedure GetPrompt(): JsonObject
    var
        Prompts: Codeunit "Sustainability Prompts";
        PromptJson: JsonObject;
    begin
        PromptJson.ReadFrom(Prompts.GetRawFormulaFunction().Unwrap());
        exit(PromptJson);
    end;

    procedure Execute(Arguments: JsonObject): Variant
    var
        TempSustainEmissionSuggestion: Record "Sustain. Emission Suggestion" temporary;
        Telemetry: Codeunit "Telemetry";
        FormulasToken, SustainabilityToken : JsonToken;
        SustainabilityArray: JsonArray;
        ValueToken: JsonToken;
        RawFormula: Text;
        RawFormulaExceededMaxLengthLbl: Label 'Raw formula exceeds maximum length: %1', Comment = '%1 = line number', Locked = true;
    begin
        if not Arguments.Get('results', FormulasToken) then begin
            Telemetry.LogMessage('0000PWF', 'No results for the function', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher);
            exit(TempSustainEmissionSuggestion);
        end;
        if not FormulasToken.IsArray() then
            exit(TempSustainEmissionSuggestion);
        SustainabilityArray := FormulasToken.AsArray();
        foreach SustainabilityToken in SustainabilityArray do begin
            TempSustainEmissionSuggestion.Init();
            if not SustainabilityToken.AsObject().Get('LineNo', ValueToken) then
                exit(TempSustainEmissionSuggestion);
            TempSustainEmissionSuggestion."Line No." := ValueToken.AsValue().AsInteger();
            if not SustainabilityToken.AsObject().Get('Formula', ValueToken) then
                exit(TempSustainEmissionSuggestion);
            RawFormula := ValueToken.AsValue().AsText();
            if StrLen(RawFormula) > MaxStrLen(TempSustainEmissionSuggestion."Raw Formula") then begin
                Telemetry.LogMessage('0000PWG', StrSubstNo(RawFormulaExceededMaxLengthLbl, TempSustainEmissionSuggestion."Line No."), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher);
                exit(TempSustainEmissionSuggestion);
            end;
            TempSustainEmissionSuggestion."Raw Formula" := CopyStr(RawFormula, 1, MaxStrLen(TempSustainEmissionSuggestion."Raw Formula"));
            TempSustainEmissionSuggestion.Insert();
        end;
        exit(TempSustainEmissionSuggestion);
    end;

    procedure GetName(): Text
    begin
        exit(FunctionNameLbl);
    end;
}