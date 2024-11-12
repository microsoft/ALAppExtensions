// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

using Microsoft.Inventory.Item;

query 42801 "SL Hist. InventoryTransactions"
{
    QueryType = Normal;
    OrderBy = ascending(BatNbr);
    QueryCategory = 'Item List';
    Caption = 'Dynamics SL Inventory Transactions';
    elements
    {
        dataitem(SL_INTransactionsAmountsHist; "SL Hist. INTran")
        {
            column(CpnyID; CpnyID)
            {
                Caption = 'Company ID';
            }
            column(BatNbr; BatNbr)
            {
                Caption = 'Batch Number';
            }
            column(LineRef; LineRef)
            {
                Caption = 'Line Reference Number';
            }
            column(RefNbr; Refnbr)
            {
                Caption = 'Reference Number';
            }
            column(TranType; TranType)
            {
                Caption = 'Transaction Type';
            }
            column(JrnlType; JrnlType)
            {
                Caption = 'Journal Type';
            }
            column(InvtID; InvtID)
            {
                Caption = 'Item Number';
            }
            dataitem(BCItem; Item)
            {
                DataItemLink = "No." = SL_INTransactionsAmountsHist.InvtID;
                SqlJoinType = LeftOuterJoin;
                column(Description; Description)
                {
                    Caption = 'Description';
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
            column(SpecificCostID; SpecificCostID)
            {
                Caption = 'Specific Cost ID';
            }
            column(RcptNbr; RcptNbr)
            {
                Caption = 'Receipt Number';
            }
            column(RcptDate; RcptDate)
            {
                Caption = 'Receipt Date';
            }
            column(TranDate; TranDate)
            {
                Caption = 'Transaction Date';
            }
            column(Qty; Qty)
            {
                Caption = 'Quantity';
            }
            column(UnitDesc; UnitDesc)
            {
                Caption = 'Unit of Measure';
            }
            column(UnitCost; UnitCost)
            {
                Caption = 'Unit Cost';
            }
            column(UnitPrice; UnitPrice)
            {
                Caption = 'Unit Price';
            }
            column(ExtCost; ExtCost)
            {
                Caption = 'Extended Cost';
            }
            column(TranAmt; TranAmt)
            {
                Caption = 'Extended Price';
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