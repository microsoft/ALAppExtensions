// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.FixedAssets.FixedAsset;

pageextension 4811 "Intrastat Report FA Card" extends "Fixed Asset Card"
{
    layout
    {
        addafter(Maintenance)
        {
            group(Intrastat)
            {
                Caption = 'Intrastat';
                field("Tariff No."; Rec."Tariff No.")
                {
                    ApplicationArea = All;
                }
                field("Country/Region of Origin Code"; Rec."Country/Region of Origin Code")
                {
                    ApplicationArea = All;
                }
                field("Exclude from Intrastat Report"; Rec."Exclude from Intrastat Report")
                {
                    ApplicationArea = All;
                }
                field("Net Weight"; Rec."Net Weight")
                {
                    ApplicationArea = All;
                }
                field("Gross Weight"; Rec."Gross Weight")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Supplementary Unit of Measure"; Rec."Supplementary Unit of Measure")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}