// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V1;

using Microsoft.Sustainability.Account;

page 6229 "Sust. Acc. Subcategory"
{
    APIGroup = 'sustainability';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    EntityCaption = 'Sustainability Account Subcategory';
    EntitySetCaption = 'Sustainability Account Subcategories';
    PageType = API;
    DelayedInsert = true;
    EntityName = 'sustainabilityAccountSubcategory';
    EntitySetName = 'sustainabilityAccountSubcategories';
    ODataKeyFields = SystemId;
    SourceTable = "Sustain. Account Subcategory";
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
                field(category; Rec."Category Code")
                {
                    Caption = 'Category';
                }
                field(emmissionFactorCO2; Rec."Emission Factor CO2")
                {
                    Caption = 'EF (CO2)';
                }
                field(emmissionFactorCH4; Rec."Emission Factor CH4")
                {
                    Caption = 'EF (CH4)';
                }
                field(emmissionFactorN2O; Rec."Emission Factor N2O")
                {
                    Caption = 'EF (N2O)';
                }
                field(renewableEnergy; Rec."Renewable Energy")
                {
                    Caption = 'Renewable Energy';
                }
            }
        }
    }
}