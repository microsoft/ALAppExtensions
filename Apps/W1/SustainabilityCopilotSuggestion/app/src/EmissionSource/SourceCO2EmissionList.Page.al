// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

page 6332 "Source CO2 Emission List"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "Source CO2 Emission Buffer";
    Editable = false;
    SourceTableView = sorting("Confidence Value") order(descending);
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(GroupRepeater)
            {
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Source Description"; Rec."Source Description")
                {
                    ApplicationArea = All;
                }
                field(Confidence; Rec.Confidence)
                {
                    ApplicationArea = All;
                }
                field("Emission Factor CO2"; Rec."Emission Factor CO2")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    internal procedure Load(var SourceCO2EmissionBuffer: Record "Source CO2 Emission Buffer")
    begin
        if not SourceCO2EmissionBuffer.FindSet() then
            exit;
        repeat
            Rec := SourceCO2EmissionBuffer;
            Rec.Insert();
        until SourceCO2EmissionBuffer.Next() = 0;
    end;
}