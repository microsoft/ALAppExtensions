// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;
using System.Telemetry;
using System.AI;

codeunit 6298 "Formula Breakdown Function" implements "AOAI Function"
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
        PromptJson.ReadFrom(Prompts.GetFormulaBreakdownFunction().Unwrap());
        exit(PromptJson);
    end;

    [NonDebuggable]
    procedure Execute(Arguments: JsonObject): Variant
    var
        TempSustainEmissionSuggestion: Record "Sustain. Emission Suggestion" temporary;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        LinesToken, ValueToken : JsonToken;
        LinesArray: JsonArray;
        LineNo: Integer;
        FormulaOutStr: OutStream;
    begin
        if not Arguments.Get('lines', LinesToken) then begin
            FeatureTelemetry.LogError('0000N33', FunctionNameLbl, 'Sustainability Emission Info', 'results not found in tools object.');
            exit(TempSustainEmissionSuggestion);
        end;
        LinesArray := LinesToken.AsArray();
        foreach LinesToken in LinesArray do begin
            LinesToken.AsObject().Get('line_no', ValueToken);
            LineNo := ValueToken.AsValue().AsInteger();
            TempSustainEmissionSuggestion."Line No." := LineNo;
            TempSustainEmissionSuggestion."Emission Formula Json".CreateOutStream(FormulaOutStr, TextEncoding::UTF8);
            LinesToken.WriteTo(FormulaOutStr);
            TempSustainEmissionSuggestion.Insert();
        end;
        exit(TempSustainEmissionSuggestion);
    end;

    procedure GetName(): Text
    begin
        exit(FunctionNameLbl);
    end;
}