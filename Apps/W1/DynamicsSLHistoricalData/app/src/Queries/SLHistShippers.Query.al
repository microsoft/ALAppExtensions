// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

using Microsoft.Sales.Customer;

query 42800 "SL Hist. Shippers"
{
    QueryType = Normal;
    OrderBy = ascending(ShipperID);
    QueryCategory = 'Customer List', 'Sales Order List';
    Caption = 'Dynamics SL Shippers';
    elements
    {
        dataitem(SLHistSOShipHeader; "SL Hist. SOShipHeader")
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
                Caption = 'Sales Order Number';
            }
            column(OrdDate; OrdDate)
            {
                Caption = 'Order Date';
            }
            column(CustOrdNbr; CustOrdNbr)
            {
                Caption = 'Customer PO Number';
            }
            column(CustId; CustId)
            {
                Caption = 'Customer Number';
            }
            dataitem(BCCustomer; Customer)
            {
                DataItemLink = "No." = SLHistSOShipHeader.CustID;
                SqlJoinType = LeftOuterJoin;
                column(CustName; Name)
                {
                    Caption = 'Customer Name';
                }
            }
            column(SOTypeID; SOTypeID)
            {
                Caption = 'Order Type';
            }
            column(Status; Status)
            {
                Caption = 'Status';
            }
            column(Cancelled; Cancelled)
            {
                Caption = 'Cancelled';
            }
            column(CreditHold; CreditHold)
            {
                Caption = 'Credit Hold';
            }
            column(TotInvc; TotInvc)
            {
                Caption = 'Invoice Total';
            }
            column(BalDue; BalDue)
            {
                Caption = 'Balance Due';
            }
            column(InvcNbr; InvcNbr)
            {
                Caption = 'Invoice Number';
            }
            column(InvcDate; InvcDate)
            {
                Caption = 'Invoice Date';
            }
            column(ShipDateAct; ShipDateAct)
            {
                Caption = 'Actual Ship Date';
            }
            column(SlsperId; SlsperId)
            {
                Caption = 'Salesperson ID';
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
            column(ARBatNbr; ARBatNbr)
            {
                Caption = 'A/R Batch Number';
            }
            column(INBatNbr; INBatNbr)
            {
                Caption = 'Inventory Batch Number';
            }
            column(ShipRegisterID; ShipRegisterID)
            {
                Caption = 'Sales Journal ID';
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