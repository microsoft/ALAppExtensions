// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Item;

pageextension 31301 "Item Card CZ" extends "Item Card"
{
    layout
    {
#if not CLEAN22
#pragma warning disable AL0432
        modify("Statistic Indication CZL")
        {
            Enabled = not IntrastatEnabled;
            Visible = not IntrastatEnabled;
        }
        modify("Specific Movement CZL")
        {
            Enabled = not IntrastatEnabled;
            Visible = not IntrastatEnabled;
        }
#pragma warning restore AL0432
#endif
        addafter("Country/Region of Origin Code")
        {
            field("Statistic Indication CZ"; Rec."Statistic Indication CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Statistic indication for Intrastat reporting purposes.';
#if not CLEAN22
                Enabled = IntrastatEnabled;
                Visible = IntrastatEnabled;
#endif
            }
            field("Specific Movement CZ"; Rec."Specific Movement CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Specific Movement for Intrastat reporting purposes.';
#if not CLEAN22
                Enabled = IntrastatEnabled;
                Visible = IntrastatEnabled;
#endif
            }
        }
    }
#if not CLEAN22

    trigger OnOpenPage()
    begin
        IntrastatEnabled := IntrastatReportManagement.IsFeatureEnabled();
    end;

    var
        IntrastatReportManagement: Codeunit IntrastatReportManagement;
        IntrastatEnabled: Boolean;
#endif
}
