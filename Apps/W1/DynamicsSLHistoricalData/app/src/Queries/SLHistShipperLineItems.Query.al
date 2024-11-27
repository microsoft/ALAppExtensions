// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

query 42812 "SL Hist. ShipperLineItems"
{
    QueryType = Normal;
    OrderBy = ascending(ShipperID);
    QueryCategory = 'Customer List', 'Sales Order List';
    Caption = 'Dynamics SL Shipper Line Items';
    elements
    {
        dataitem(SL_SOShipLineHist; "SL Hist. SOShipLine")
        {
            column(CpnyID; CpnyID)
            {
                Caption = 'Company ID';
            }
            column(ShipperID; ShipperID)
            {
                Caption = 'Shipper ID';
            }
            column(OrdNbr; OrdNbr)
            {
                Caption = 'Order Number';
            }
            dataitem(SL_SOShipHeaderHist; "SL Hist. SOShipHeader")
            {
                DataItemLink = CpnyID = SL_SOShipLineHist.CpnyID,
                ShipperID = SL_SOShipLineHist.ShipperID;
                SqlJoinType = LeftOuterJoin;
                column(CustID; CustID)
                {
                    Caption = 'Customer Number';
                }
                column(ShipperStatus; Status)
                {
                    Caption = 'Shipper Status';
                }
                column(DropShip; DropShip)
                {
                    Caption = 'Drop Ship';
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
            column(TotInvc; TotInvc)
            {
                Caption = 'Total Invoiced';
            }
            column(LineStatus; Status)
            {
                Caption = 'Line Status';
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