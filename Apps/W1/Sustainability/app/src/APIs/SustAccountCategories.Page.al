// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V1;

using Microsoft.Sustainability.Account;

page 6228 "Sust. Account Categories"
{
    APIGroup = 'sustainability';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    EntityCaption = 'Sustainability Account Category';
    EntitySetCaption = 'Sustainability Account Categories';
    PageType = API;
    DelayedInsert = true;
    EntityName = 'sustainabilityAccountCategory';
    EntitySetName = 'sustainabilityAccountCategories';
    ODataKeyFields = SystemId;
    SourceTable = "Sustain. Account Category";
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
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(emmisionScope; Rec."Emission Scope")
                {
                    Caption = 'Scope type';
                }
                field(registerCO2; Rec.CO2)
                {
                    Caption = 'CO2';
                }
                field(registerCH4; Rec.CH4)
                {
                    Caption = 'CH4';
                }
                field(registerN20; Rec.N2O)
                {
                    Caption = 'N2O';
                }
                field(calculationFoundationType; Rec."Calculation Foundation")
                {
                    Caption = 'Calculation Foundation';
                }
                field(emissionCalculationCustomValue; Rec."Custom Value")
                {
                    Caption = 'Custom Value';
                }
            }
        }
    }
}