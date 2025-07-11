// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 31300 "Intrastat Report Subform CZ" extends "Intrastat Report Subform"
{
    layout
    {
        addafter("Tariff No.")
        {
            field("Statistic Indication CZ"; Rec."Statistic Indication CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Statistic indication of the Intrastat report line.';
            }
            field("Specific Movement CZ"; Rec."Specific Movement CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Specific movement code of the Intrastat report line.';
            }
        }
        addafter("Shpt. Method Code")
        {
            field("Intrastat Delivery Group CZ"; Rec."Intrastat Delivery Group CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Intrastat Delivery Group of the Intrastat report line.';
                Visible = false;
            }
        }
        addlast(Control1)
        {
            field("Internal Note 1 CZ"; Rec."Internal Note 1 CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the internal note 1 of the Intrastat report line.';
            }
            field("Internal Note 2 CZ"; Rec."Internal Note 2 CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the internal note 2 code of the Intrastat report line.';
                Visible = false;
            }
            field(CompletelyInvoicedCZ; Rec.CompletelyInvoiced())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Completely Invoiced';
                ToolTip = 'Specifies if the entry has been fully invoiced or if more posted invoices are expected.';
                Visible = false;
            }
        }
    }
}