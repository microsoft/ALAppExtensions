// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 148122 "Intrastat Report Subform IT" extends "Intrastat Report Subform"
{
    layout
    {
        addafter(Type)
        {
            field("Reference Period"; Rec."Reference Period")
            {
                ApplicationArea = BasicEU;
                Editable = false;
                ToolTip = 'Specifies the reference period.';
            }
            field("EU 3d-Party Trade"; Rec."EU 3d-Party Trade")
            {
                ApplicationArea = BasicEU;
                Editable = false;
                ToolTip = 'Specifies if the document is EU 3-Party Trade.';
            }
        }
        addafter("Item Description")
        {
            field("Corrected Intrastat Report No."; Rec."Corrected Intrastat Report No.")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the number of the corrected Intrastat report that is associated with the Intrastat Report line.';
            }
            field("Corrected Document No."; Rec."Corrected Document No.")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the document number of the corrected Intrastat Report.';
            }
            field("Company/Representative VAT No."; Rec."Company/Representative VAT No.")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the Company''s or representative''s VAT Number.';
                Visible = false;
            }
            field("File Disk No."; Rec."File Disk No.")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the floppy disk number if you are creating a reporting disk.';
                Visible = false;
            }
        }
        addafter("Transport Method")
        {
            field("Group Code"; Rec."Group Code")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the group code that corresponds with the Intrastat Report.';
            }
        }
        addafter("Net Weight")
        {
            field("Currency Code"; Rec."Currency Code")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the currency code that is associated with the Intrastat Report line.';
            }
        }
        addafter("Total Weight")
        {
            field("Source Currency Amount"; Rec."Source Currency Amount")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the amount in the currency of the source of the transaction.';
            }
        }
        modify("Indirect Cost")
        {
            Visible = true;
        }
        modify("Area")
        {
            Visible = true;
        }
        modify("Source Entry No.")
        {
            Editable = true;
        }
        modify("Entry/Exit Point")
        {
            Visible = true;
        }
        modify("Transaction Specification")
        {
            Visible = true;
        }
    }
}