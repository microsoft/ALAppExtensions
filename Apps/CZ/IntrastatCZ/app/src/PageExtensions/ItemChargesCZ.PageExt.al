// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Inventory.Item;

pageextension 31338 "Item Charges CZ" extends "Item Charges"
{
    layout
    {
#if not CLEAN22
#pragma warning disable AL0432
        modify("Incl. in Intrastat Amount CZL")
#pragma warning restore AL0432
        {
            Enabled = not IntrastatEnabled;
            Visible = not IntrastatEnabled;
        }
#pragma warning disable AL0432
        modify("Incl. in Intrastat S.Value CZL")
#pragma warning restore AL0432
        {
            Enabled = not IntrastatEnabled;
            Visible = not IntrastatEnabled;
        }
#endif
        addlast(Control1)
        {
            field("Incl. in Intrastat Amount CZ"; Rec."Incl. in Intrastat Amount CZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether additional cost of the item should be included in the Intrastat amount.';
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