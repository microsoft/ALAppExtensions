// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

codeunit 6332 "Sustainability Emission Source"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure KeepRelevantSourceCO2EmissionBuffer(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer")
    begin
        SourceCO2EmissionBuffer.Reset();
        if not SourceCO2EmissionBuffer.FindSet(true) then
            exit;
        repeat
            if not (SourceCO2EmissionBuffer.Confidence in [SourceCO2EmissionBuffer.Confidence::Medium, SourceCO2EmissionBuffer.Confidence::High]) then
                SourceCO2EmissionBuffer.Delete();
            if not (SourceCO2EmissionBuffer."Country/Region Code" in [SustainEmissionSuggestion."Country/Region Code", '']) then
                SourceCO2EmissionBuffer.Delete();
        until SourceCO2EmissionBuffer.Next() = 0;
    end;
}