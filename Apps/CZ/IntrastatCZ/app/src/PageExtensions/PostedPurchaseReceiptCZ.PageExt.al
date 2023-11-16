// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Purchases.History;

pageextension 31381 "Posted Purchase Receipt CZ" extends "Posted Purchase Receipt"
{
    layout
    {
#if not CLEAN22
#pragma warning disable AL0432
        modify("Intrastat Exclude CZL")
#pragma warning restore AL0432
        {
            Enabled = not IntrastatEnabled;
            Visible = not IntrastatEnabled;
        }
#endif
        addlast(Shipping)
        {
            field("Intrastat Exclude CZ"; Rec."Intrastat Exclude CZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Exclude';
                Editable = false;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
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