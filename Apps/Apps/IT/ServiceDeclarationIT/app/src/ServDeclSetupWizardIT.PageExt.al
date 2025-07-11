// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

pageextension 12215 "Serv. Decl. Setup Wizard IT" extends "Serv. Decl. Setup Wizard"
{
    layout
    {
        modify("Enable VAT Registration No.")
        {
            Visible = false;
        }
        modify("Def. Customer/Vendor VAT No.")
        {
            Visible = true;
        }
        modify("Def. Private Person VAT No.")
        {
            Visible = true;
        }
        modify("Data Exch. Def. Code")
        {
            Enabled = false;
            Visible = true;
        }
        addafter("Data Exch. Def. Code")
        {
            field("Data Exch. Def. Purch. Code"; Rec."Data Exch. Def. Purch. Code")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition code to generate the Service Declaration file for purchase reporting.';
            }
            field("Data Exch. Def. Purch. Name"; Rec."Data Exch. Def. Purch. Name")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition name to generate the Service Declaration file for purchase reporting.';
            }
            field("Data Exch. Def. Sale Code"; Rec."Data Exch. Def. Sale Code")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition code to generate the Service Decaration file for sale reporting.';
            }
            field("Data Exch. Def. Sale Name"; Rec."Data Exch. Def. Sale Name")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition name to generate the Service Declaration file for sale reporting.';
            }
            field("Data Exch. Def. P. Corr. Code"; Rec."Data Exch. Def. P. Corr. Code")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition code to generate the Service Declaration file for purchase correction reporting.';
            }
            field("Data Exch. Def. P. Corr. Name"; Rec."Data Exch. Def. P. Corr. Name")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition name to generate the Service Declaration file for purchase correction reporting.';
            }
            field("Data Exch. Def. S. Corr. Code"; Rec."Data Exch. Def. S. Corr. Code")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition code to generate the Service Declaration file for sales correction reporting.';
            }
            field("Data Exch. Def. S. Corr. Name"; Rec."Data Exch. Def. S. Corr. Name")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the data exchange definition name to generate the Service Declaration file for sales correction reporting.';
            }
        }
    }
}
