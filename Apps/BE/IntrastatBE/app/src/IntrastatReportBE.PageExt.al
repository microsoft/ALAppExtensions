// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 11346 "Intrastat Report BE" extends "Intrastat Report"
{
    layout
    {
        modify(Reported)
        {
            Enabled = false;
            Visible = false;
        }
        addafter("Statistics Period")
        {
            field("Arrivals Reported"; Rec."Arrivals Reported")
            {
                Caption = 'System 19 reported';
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies whether the entry has already been reported to the tax authorities via system 19 (receipt).';
            }
            field("Dispatches Reported"; Rec."Dispatches Reported")
            {
                Caption = 'System 29 reported';
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies whether the entry has already been reported to the tax authorities via system 29 (shipment).';
            }
        }
        addafter(General)
        {
            group(ExportParamenters)
            {
                Caption = 'Export Parameters';
                field("Nihil Declaration"; Rec."Nihil Declaration")
                {
                    ApplicationArea = BasicEU;
                    Caption = 'Nihil Declaration';
                    ToolTip = 'Specifies if you do not have any trade transactions with European Union (EU) countries/regions and want to send an empty declaration.';
                }
                field("Enterprise No./VAT Reg. No."; Rec."Enterprise No./VAT Reg. No.")
                {
                    ApplicationArea = BasicEU;
                    Caption = 'Enterprise No./VAT Reg. No.';
                    ToolTip = 'Specifies the enterprise or VAT registration number.';
                }
            }
        }
    }
}