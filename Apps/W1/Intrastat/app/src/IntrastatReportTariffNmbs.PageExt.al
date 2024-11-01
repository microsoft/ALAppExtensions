// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 4823 "Intrastat Report Tariff Nmbs." extends "Tariff Numbers"
{
    layout
    {
        addafter("Supplementary Units")
        {
            field("Suppl. Conversion Factor"; Rec."Suppl. Conversion Factor")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the conversion factor for the tariff number.';
            }
            field("Suppl. Unit of Measure"; Rec."Suppl. Unit of Measure")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the unit of measure for the tariff number.';
            }
        }
    }
}