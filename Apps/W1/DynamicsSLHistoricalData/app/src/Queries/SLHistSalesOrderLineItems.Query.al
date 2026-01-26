// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

query 42808 "SL Hist. SalesOrderLineItems"
{
    QueryType = Normal;
    OrderBy = ascending(OrdNbr);
    QueryCategory = 'Customer List', 'Sales Order List';
    Caption = 'Dynamics SL Sales Order Line Items';
    elements
    {
        dataitem(SL_SOLineHist; "SL Hist. SOLine")
        {
            column(CpnyID; CpnyID)
            {
                Caption = 'Company ID';
            }
            column(OrdNbr; OrdNbr)
            {
                Caption = 'Order Number';
            }
            dataitem(SL_SOHeaderHist; "SL Hist. SOHeader")
            {
                DataItemLink = CpnyID = SL_SOLineHist.CpnyID,
                OrdNbr = SL_SOLineHist.OrdNbr;
                SqlJoinType = InnerJoin;
                column(CustID; CustID)
                {
                    Caption = 'Customer Number';
                }
                column(CustOrdNbr; CustOrdNbr)
                {
                    Caption = 'Customer PO Number';
                }
                column(OrdDate; OrdDate)
                {
                    Caption = 'Order Date';
                }
                column(SOTypeID; SOTypeID)
                {
                    Caption = 'Order Type';
                }
                column(OrdStatus; Status)
                {
                    Caption = 'Order Status';
                }
            }
            column(LineRef; LineRef)
            {
                Caption = 'Line Reference Number';
            }
            column(InvtID; InvtID)
            {
                Caption = 'Item Number';
            }
            column(SiteID; SiteID)
            {
                Caption = 'Location';
            }
            column(QtyOrd; QtyOrd)
            {
                Caption = 'Quantity Ordered';
            }
            column(QtyShip; QtyShip)
            {
                Caption = 'Quantity Shipped';
            }
            column(QtyBO; QtyBO)
            {
                Caption = 'Quantity Backordered';
            }
            column(UnitDesc; UnitDesc)
            {
                Caption = 'Unit of Measure';
            }
            column(Cost; Cost)
            {
                Caption = 'Unit Cost';
            }
            column(TotCost; TotCost)
            {
                Caption = 'Total Cost';
            }
            column(SlsPrice; SlsPrice)
            {
                Caption = 'Unit Price';
            }
            column(TotOrd; TotOrd)
            {
                Caption = 'Total Ordered';
            }
            column(LineStatus; Status)
            {
                Caption = 'Line Status';
            }
            column(DropShip; DropShip)
            {
                Caption = 'Drop Ship';
            }
            column(ReqDate; ReqDate)
            {
                Caption = 'Requested Date';
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