// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Foundation.Shipping;

pageextension 31339 "Shipment Methods CZ" extends "Shipment Methods"
{
    layout
    {
#if not CLEAN22
#pragma warning disable AL0432
        modify("Intrastat Deliv. Grp. Code CZL")
#pragma warning restore AL0432
        {
            Enabled = not IntrastatEnabled;
            Visible = not IntrastatEnabled;
        }
#pragma warning disable AL0432
        modify("Incl. Item Charges (Amt.) CZL")
#pragma warning restore AL0432
        {
            Enabled = not IntrastatEnabled;
        }
#pragma warning disable AL0432
        modify("Incl. Item Charges (S.Val) CZL")
#pragma warning restore AL0432
        {
            Enabled = not IntrastatEnabled;
            Visible = not IntrastatEnabled;
        }
#pragma warning disable AL0432
        modify("Adjustment % CZL")
#pragma warning restore AL0432
        {
            Enabled = not IntrastatEnabled;
            Visible = not IntrastatEnabled;
        }
#endif
        addafter(Description)
        {
            field("Intrastat Deliv. Grp. Code CZ"; Rec."Intrastat Deliv. Grp. Code CZ")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies the Intrastat Delivery Group Code.';
#if not CLEAN22
                Enabled = IntrastatEnabled;
                Visible = IntrastatEnabled;
#endif
            }
            field("Incl. Item Charges (Amt.) CZ"; Rec."Incl. Item Charges (Amt.) CZ")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies whether additional cost of the item should be included in the Intrastat amount.';
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