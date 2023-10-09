// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 148124 "Intrastat Report Setup Wzrd IT" extends "Intrastat Report Setup Wizard"
{
    layout
    {
        modify("Report Receipts")
        {
            Visible = false;
            Editable = false;
            Enabled = false;
        }
        modify("Report Shipments")
        {
            Visible = false;
            Editable = false;
            Enabled = false;
        }
        addlast(Step4)
        {
            field("Data Exch. Def. Code NPM"; Rec."Data Exch. Def. Code NPM")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition code to generate the intrastat file for normal purchase monthly reporting.';
            }
            field("Data Exch. Def. Name NPM"; Rec."Data Exch. Def. Name NPM")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition name to generate the intrastat file for normal purchase monthly reporting.';
            }
            field("Data Exch. Def. Code NSM"; Rec."Data Exch. Def. Code NSM")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition code to generate the intrastat file for normal sale monthly reporting.';
            }
            field("Data Exch. Def. Name NSM"; Rec."Data Exch. Def. Name NSM")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition name to generate the intrastat file for normal sale monthly reporting.';
            }
            field("Data Exch. Def. Code NPQ"; Rec."Data Exch. Def. Code NPQ")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition code to generate the intrastat file for normal purchase quarterly reporting.';
            }
            field("Data Exch. Def. Name NPQ"; Rec."Data Exch. Def. Name NPQ")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition name to generate the intrastat file for normal purchase quarterly reporting.';
            }
            field("Data Exch. Def. Code NSQ"; Rec."Data Exch. Def. Code NSQ")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition code to generate the intrastat file for normal sale quarterly reporting.';
            }
            field("Data Exch. Def. Name NSQ"; Rec."Data Exch. Def. Name NSQ")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition name to generate the intrastat file for normal sale quarterly reporting.';
            }
            field("Data Exch. Def. Code CPM"; Rec."Data Exch. Def. Code CPM")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition code to generate the intrastat file for purchase correction monthly reporting.';
            }
            field("Data Exch. Def. Name CPM"; Rec."Data Exch. Def. Name CPM")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition name to generate the intrastat file for purchase correction monthly reporting.';
            }
            field("Data Exch. Def. Code CSM"; Rec."Data Exch. Def. Code CSM")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition code to generate the intrastat file for sales correction monthly reporting.';
            }
            field("Data Exch. Def. Name CSM"; Rec."Data Exch. Def. Name CSM")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition name to generate the intrastat file for sales correction monthly reporting.';
            }
            field("Data Exch. Def. Code CPQ"; Rec."Data Exch. Def. Code CPQ")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition code to generate the intrastat file for purchase correction quarterly reporting.';
            }
            field("Data Exch. Def. Name CPQ"; Rec."Data Exch. Def. Name CPQ")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition name to generate the intrastat file for purchase correction quarterly reporting.';
            }
            field("Data Exch. Def. Code CSQ"; Rec."Data Exch. Def. Code CSQ")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition code to generate the intrastat file for sales correction quarterly reporting.';
            }
            field("Data Exch. Def. Name CSQ"; Rec."Data Exch. Def. Name CSQ")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition name to generate the intrastat file for sales correction quarterly reporting.';
            }
        }
        modify("Data Exch. Def. Code")
        {
            Visible = false;
        }
        modify("Data Exch. Def. Name")
        {
            Visible = false;
        }
        modify("Data Exch. Def. Code - Receipt")
        {
            Visible = false;
        }
        modify("Data Exch. Def. Name - Receipt")
        {
            Visible = false;
        }
        modify("Data Exch. Def. Code - Shpt.")
        {
            Visible = false;
        }
        modify("Data Exch. Def. Name - Shpt.")
        {
            Visible = false;
        }
        modify("Split Files")
        {
            Visible = false;
        }
    }
}