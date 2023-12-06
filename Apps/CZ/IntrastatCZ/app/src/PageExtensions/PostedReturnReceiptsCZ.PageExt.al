// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Sales.History;

pageextension 31354 "Posted Return Receipts CZ" extends "Posted Return Receipts"
{
    layout
    {
#if not CLEAN22
#pragma warning disable AL0432
        modify("Physical Transfer CZL")
#pragma warning restore AL0432
        {
            Enabled = not IntrastatEnabled;
        }
#pragma warning disable AL0432
        modify("Intrastat Exclude CZL")
#pragma warning restore AL0432
        {
            Enabled = not IntrastatEnabled;
        }
#endif
        addlast(Control1)
        {
            field("Intrastat Exclude CZ"; Rec."Intrastat Exclude CZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Exclude';
                Visible = false;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
#if not CLEAN22
                Enabled = IntrastatEnabled;
#endif
            }
            field("Physical Transfer CZ"; Rec."Physical Transfer CZ")
            {
                ApplicationArea = SalesReturnOrder;
                Caption = 'Physical Transfer';
                ToolTip = 'Specifies if there is physical transfer of the item.';
                Visible = false;
#if not CLEAN22
                Enabled = IntrastatEnabled;
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