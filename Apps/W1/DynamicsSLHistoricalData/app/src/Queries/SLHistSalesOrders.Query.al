// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

query 42809 "SL Hist. SalesOrders"
{
    QueryType = Normal;
    OrderBy = ascending(OrdNbr);
    QueryCategory = 'Customer List', 'Sales Order List';
    Caption = 'Dynamics SL Sales Orders';
    elements
    {
        dataitem(SL_SOHeaderHist; "SL Hist. SOHeader")
        {
            column(CpnyID; CpnyID)
            {
                Caption = 'Company ID';
            }
            column(OrdNbr; OrdNbr)
            {
                Caption = 'Order Number';
            }
            column(CustOrdNbr; CustOrdNbr)
            {
                Caption = 'Customer PO Number';
            }
            column(CustID; CustID)
            {
                Caption = 'Customer Number';
            }
            column(SOTypeID; SOTypeID)
            {
                Caption = 'Order Type';
            }
            column(Status; Status)
            {
                Caption = 'Sales Order Status';
            }
            column(TotOrd; TotOrd)
            {
                Caption = 'Order Total';
            }
            column(Cancelled; Cancelled)
            {
                Caption = 'Cancelled';
            }
            column(OrdDate; OrdDate)
            {
                Caption = 'Order Date';
            }
            column(CancelDate; CancelDate)
            {
                Caption = 'Cancel By Date';
            }
            column(SlsperID; SlsperID)
            {
                Caption = 'Salesperson ID';
            }
            column(BillAttn; BillAttn)
            {
                Caption = 'Bill Attention';
            }
            column(ShipViaID; ShipViaID)
            {
                Caption = 'Shipping Method';
            }
            column(ShiptoID; ShiptoID)
            {
                Caption = 'Ship-to Address Code';
            }
            column(ShipCity; ShipCity)
            {
                Caption = 'City';
            }
            dataitem(SL_SOTypeHist; "SL Hist. SOType")
            {
                DataItemTableFilter = Behavior = filter('SO' | 'AO' | 'MO' | 'WC' | 'ASM');
                DataItemLink = CpnyID = SL_SOHeaderHist.CpnyID,
                SOTypeID = SL_SOHeaderHist.SOTypeID;
                SqlJoinType = InnerJoin;
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