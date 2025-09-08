// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V1;

using Microsoft.Sustainability.Scorecard;

page 6337 "Sustainability Goal"
{
    APIGroup = 'sustainability';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    EntityCaption = 'Sustainability Goal';
    EntitySetCaption = 'Sustainability Goals';
    PageType = API;
    DelayedInsert = true;
    EntityName = 'sustainabilityGoal';
    EntitySetName = 'sustainabilityGoals';
    ODataKeyFields = SystemId;
    SourceTable = "Sustainability Goal";
    Extensible = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(scorecardNo; Rec."Scorecard No.")
                {
                    Caption = 'Scorecard No.';
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line No.';
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(owner; Rec.Owner)
                {
                    Caption = 'Owner';
                }
                field(responsibilityCenter; Rec."Responsibility Center")
                {
                    Caption = 'Responsibility Center';
                }
                field(countryRegionCode; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code';
                }
                field(unitOfMeasure; Rec."Unit of Measure")
                {
                    Caption = 'Unit of Measure';
                }
                field(startDate; Rec."Start Date")
                {
                    Caption = 'Start Date';
                }
                field(endDate; Rec."End Date")
                {
                    Caption = 'End Date';
                }
                field(baselineStartDate; Rec."Baseline Start Date")
                {
                    Caption = 'Baseline Start Date';
                }
                field(baselineEndDate; Rec."Baseline End Date")
                {
                    Caption = 'Baseline End Date';
                }
                field(baselineForCO2; Rec."Baseline for CO2")
                {
                    Caption = 'Baseline for CO2';
                }
                field(baselineForCH4; Rec."Baseline for CH4")
                {
                    Caption = 'Baseline for CH4';
                }
                field(baselineForN2O; Rec."Baseline for N2O")
                {
                    Caption = 'Baseline for N2O';
                }
                field(baselineForWasteIntensity; Rec."Baseline for Waste Intensity")
                {
                    Caption = 'Baseline for Waste Intensity';
                }
                field(baselineForWaterIntensity; Rec."Baseline for Water Intensity")
                {
                    Caption = 'Baseline for Water Intensity';
                }
                field(currentValueForCO2; Rec."Current Value for CO2")
                {
                    Caption = 'Current Value for CO2';
                }
                field(currentValueForCH4; Rec."Current Value for CH4")
                {
                    Caption = 'Current Value for CH4';
                }
                field(currentValueForN2O; Rec."Current Value for N2O")
                {
                    Caption = 'Current Value for N2O';
                }
                field(currentValueForWasteInt; Rec."Current Value for Waste Int.")
                {
                    Caption = 'Current Value for Waste Intensity';
                }
                field(currentValueForWaterInt; Rec."Current Value for Water Int.")
                {
                    Caption = 'Current Value for Water Intensity';
                }
                field(mainGoal; Rec."Main Goal")
                {
                    Caption = 'Main Goal';
                }
                field(targetValueForCH4; Rec."Target Value for CH4")
                {
                    Caption = 'Target Value for CH4';
                }
                field(targetValueForCO2; Rec."Target Value for CO2")
                {
                    Caption = 'Target Value for CO2';
                }
                field(targetValueForN2O; Rec."Target Value for N2O")
                {
                    Caption = 'Target Value for N2O';
                }
                field(targetValueForWasteInt; Rec."Target Value for Waste Int.")
                {
                    Caption = 'Target Value for Waste Intensity';
                }
                field(targetValueForWaterInt; Rec."Target Value for Water Int.")
                {
                    Caption = 'Target Value for Water Intensity';
                }
            }
        }
    }
}