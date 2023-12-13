// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Reconciliation;

pageextension 31141 "Inventory Report Entry CZL" extends "Inventory Report Entry"
{
    layout
    {
        addlast(Control1)
        {
            field("Consumption CZL"; Rec."Consumption CZL")
            {
                ApplicationArea = Manufacturing;
                ToolTip = 'Specifies the consumption value.';

                trigger OnDrillDown()
                begin
                    GetInvReportHandler.DrillDownConsumptionCZL(Rec);
                end;
            }
            field("Change In Inv.Of WIP CZL"; Rec."Change In Inv.Of WIP CZL")
            {
                ApplicationArea = Manufacturing;
                ToolTip = 'Specifies the change in inventory for the work in process (WIP) value.';

                trigger OnDrillDown()
                begin
                    GetInvReportHandler.DrillDownChInvWipCZL(Rec);
                end;
            }
            field("Change In Inv.Of Product CZL"; Rec."Change In Inv.Of Product CZL")
            {
                ApplicationArea = Manufacturing;
                ToolTip = 'Specifies the change in the inventory product value.';

                trigger OnDrillDown()
                begin
                    GetInvReportHandler.DrillDownChInvProdCZL(Rec);
                end;
            }
            field("Inv. Rounding Adj. CZL"; Rec."Inv. Rounding Adj. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the inventory rounding adjustment value.';

                trigger OnDrillDown()
                begin
                    GetInvReportHandler.DrillDownInvAdjmtRndCZL(Rec);
                end;
            }
        }
    }
    var
        GetInvReportHandler: Codeunit "Get Inv. Report Handler CZL";
}
