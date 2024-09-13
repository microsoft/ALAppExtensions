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
                    ToolTip = 'Specifies a code for the asset''s tariff number.';
                }
                field("Country/Region of Origin Code"; Rec."Country/Region of Origin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a code for the country/region where the asset was produced or processed.';
                }
                field("Exclude from Intrastat Report"; Rec."Exclude from Intrastat Report")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the asset shall be excluded from Intrastat report.';
                }
                field("Net Weight"; Rec."Net Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the net weight of the asset.';
                }
                field("Gross Weight"; Rec."Gross Weight")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the gross weight of the asset.';
                }
                field("Supplementary Unit of Measure"; Rec."Supplementary Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit of measure that is used as the supplementary unit in the Intrastat report.';
                }
            }
        }
    }
}