// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 13406 "Intrastat Report Setup Wzrd FI" extends "Intrastat Report Setup Wizard"
{
    layout
    {
        addlast(Step2)
        {
            group(FileSetup)
            {
                Caption = 'File Setup';
                field("Custom Code"; Rec."Custom Code")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies a custom code for the Intrastat file setup information.';
                }
                field("Company Serial No."; Rec."Company Serial No.")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies a company serial number for the Intrastat file setup information.';
                }
                field("Last Transfer Date"; Rec."Last Transfer Date")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies a last transfer date for the Intrastat file setup information.';
                }
                field("File No."; Rec."File No.")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies a file number for the Intrastat file setup information.';
                }
            }
        }
    }
}