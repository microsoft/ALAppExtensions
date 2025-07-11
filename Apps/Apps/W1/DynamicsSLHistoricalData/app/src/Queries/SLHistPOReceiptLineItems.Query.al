// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

using Microsoft.Inventory.Item;

query 42805 "SL Hist. POReceiptLineItems"
{
    QueryType = Normal;
    OrderBy = ascending(BatNbr);
    QueryCategory = 'Vendor List', 'Purchase Order List';
    Caption = 'Dynamics SL Purchase Order Receipt Line Items';
    elements
    {
        dataitem(SL_POTranHist; "SL Hist. POTran")
        {
            column(CpnyID; CpnyID)
            {
                Caption = 'Company ID';
            }
            column(BatNbr; BatNbr)
            {
                Caption = 'Batch Number';
            }
            column(TranType; TranType)
            {
                Caption = 'Receipt/Return';
            }
            column(RcptNbr; RcptNbr)
            {
                Caption = 'Receipt Number';
            }
            column(RcptDate; RcptDate)
            {
                Caption = 'Receipt Date';
            }
            column(PONbr; PONbr)
            {
                Caption = 'PO Number';
            }
            column(VendId; VendId)
            {
                Caption = 'Vendor ID';
            }
            column(LineRef; LineRef)
            {
                Caption = 'Line Reference Number';
            }
            column(PurchaseType; PurchaseType)
            {
                Caption = 'Purchase Type';
            }
            column(InvtID; InvtID)
            {
                Caption = 'Item Number';
            }
            dataitem(BCItem; Item)
            {
                DataItemLink = "No." = SL_POTranHist.InvtID;
                SqlJoinType = LeftOuterJoin;
                column(ItemDesc; Description)
                {
                    Caption = 'Item Description';
                }
            }
            column(SiteID; SiteID)
            {
                Caption = 'Location';
            }
            column(WhseLoc; WhseLoc)
            {
                Caption = 'Bin';
            }
            column(Qty; Qty)
            {
                Caption = 'Quantity';
            }
            column(UnitCost; UnitCost)
            {
                Caption = 'Unit Cost';
            }
            column(ExtCost; ExtCost)
            {
                Caption = 'Extended Cost';
            }
            column(QtyVouched; QtyVouched)
            {
                Caption = 'Quantity Vouchered';
            }
            column(CostVouched; CostVouched)
            {
                Caption = 'Cost Vouchered';
            }
            column(TranDesc; TranDesc)
            {
                Caption = 'Transaction Description';
            }
        }
    }

    trigger OnBeforeOpen()
    begin
        GlobalCompanyName := CopyStr(CompanyName(), 1, MaxStrLen(GlobalCompanyName));
        SetFilter(CpnyID, GlobalCompanyName);
    end;

    var
        GlobalCompanyName: Text[10];
}
