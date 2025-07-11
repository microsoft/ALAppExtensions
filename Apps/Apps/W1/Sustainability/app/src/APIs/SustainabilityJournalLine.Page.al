// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V1;

using Microsoft.Sustainability.Journal;

page 6230 "Sustainability Journal Line"
{
    APIGroup = 'sustainability';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    EntityCaption = 'Sustainability Journal Line';
    EntitySetCaption = 'Sustainability Journal Lines';
    PageType = API;
    DelayedInsert = true;
    EntityName = 'sustainabilityJournalLine';
    EntitySetName = 'sustainabilityJournalLines';
    ODataKeyFields = SystemId;
    SourceTable = "Sustainability Jnl. Line";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {

                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(journalTemplateName; Rec."Journal Template Name")
                {
                    Caption = 'Journal Template';
                }
                field(journalBatchName; Rec."Journal Batch Name")
                {
                    Caption = 'Journal Batch';
                }
                field(lineNumber; Rec."Line No.")
                {
                    Caption = 'Line No.';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'Posting Date';
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                }
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'Document No.';
                }
                field(accountNumber; Rec."Account No.")
                {
                    Caption = 'Emission Account No.';
                }
                field(manualInput; Rec."Manual Input")
                {
                    Caption = 'Manual Input';
                }
                field(unitOfMeasure; Rec."Unit of Measure")
                {
                    Caption = 'Unit of Measure';
                }
                field(fuelOrElectricity; Rec."Fuel/Electricity")
                {
                    Caption = 'Fuel/Electricity';
                }
                field(distance; Rec.Distance)
                {
                    Caption = 'Distance';
                }
                field(customAmount; Rec."Custom Amount")
                {
                    Caption = 'Custom';
                }
                field(installationMultiplier; Rec."Installation Multiplier")
                {
                    Caption = 'Installation Multiplier';
                }
                field(timeFactor; Rec."Time Factor")
                {
                    Caption = 'Time Factor';
                }
                field(emissionCO2; Rec."Emission CO2")
                {
                    Caption = 'Emission CO2';
                }
                field(emissionCH4; Rec."Emission CH4")
                {
                    Caption = 'Emission CH4';
                }
                field(emissionN2O; Rec."Emission N2O")
                {
                    Caption = 'Emission N2O';
                }
                field(countryRegion; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code';
                }
                field(responsibilityCenter; Rec."Responsibility Center")
                {
                    Caption = 'Responsibility Center';
                }
                field(sourceCode; Rec."Source Code")
                {
                    Caption = 'Source Code';
                }
                field(reasonCode; Rec."Reason Code")
                {
                    Caption = 'Reason Code';
                }
            }
        }
    }
}