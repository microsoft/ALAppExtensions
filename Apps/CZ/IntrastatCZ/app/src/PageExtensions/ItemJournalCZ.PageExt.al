// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Journal;

pageextension 31303 "Item Journal CZ" extends "Item Journal"
{
    layout
    {
#if not CLEAN22
#pragma warning disable AL0432
        modify("Statistic Indication CZL")
#pragma warning restore AL0432
        {
            Enabled = not IntrastatEnabled;
        }
#pragma warning disable AL0432
        modify("Physical Transfer CZL")
#pragma warning restore AL0432
        {
            Enabled = not IntrastatEnabled;
        }
#endif
        addlast(Control1)
        {
            field("Statistic Indication CZ"; Rec."Statistic Indication CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Statistic indication for Intrastat reporting purposes.';
#if not CLEAN22
                Enabled = IntrastatEnabled;
#endif
                Visible = false;
            }
            field("Physical Transfer CZ"; Rec."Physical Transfer CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if there is physical transfer of the item.';
#if not CLEAN22
                Enabled = IntrastatEnabled;
#endif
                Visible = false;
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
