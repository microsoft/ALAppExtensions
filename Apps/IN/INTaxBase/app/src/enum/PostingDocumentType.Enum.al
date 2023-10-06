// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

enum 18550 "Posting Document Type"
{
    value(0; Sales)
    {
        Caption = 'Sales';
    }
    value(1; "Sales Shipment Header")
    {
        Caption = 'Posted Sales Shipment';
    }
    value(2; "Sales Invoice Header")
    {
        Caption = 'Posted Sales Invoice';
    }
    value(3; "Sales Cr.Memo Header")
    {
        Caption = 'Posted Sales Credit Memo';
    }
    value(4; "Sales Return Receipt No.")
    {
        Caption = 'Sales Return Receipt No.';
    }
    value(5; Purchase)
    {
        Caption = 'Purchase';
    }
    value(6; "Purch. Rcpt. Header")
    {
        Caption = 'Posted Purchase Receipt';
    }
    value(7; "Purch. Inv. Header")
    {
        Caption = 'Posted Purchase Invoice';
    }
    value(8; "Purch. Cr. Memo Hdr.")
    {
        Caption = 'Posted Purchase Credit Memo';
    }
    value(9; "Purchase Return Shipment No.")
    {
        Caption = 'Purchase Return Shipment No.';
    }
    value(10; Transfer)
    {
        Caption = 'Transfer';
    }
    value(11; "Transfer Shipment Header")
    {
        Caption = 'Transfer Shipment';
    }
    value(12; "Transfer Receipt Header")
    {
        Caption = 'Transfer Receipt';
    }
    value(13; "GST Distribution")
    {
        Caption = 'GST Distribution';
    }
    value(14; "Gen. Journals")
    {
        Caption = 'Gen. Journals';
    }
    value(15; "Service")
    {
        Caption = 'Service';
    }
    value(16; "Service Transfer Shipment")
    {
        Caption = 'Service Tranfer Shipment';
    }
    value(17; "Service Transfer Receipt")
    {
        Caption = 'Service Tranfer Receipt';
    }
    value(18; "Gate Entry")
    {
        Caption = 'Gate Entry';
    }
    value(19; "Service Shipment Header")
    {
        Caption = 'Posted Service Shipment';
    }
    value(20; "Service Invoice Header")
    {
        Caption = 'Posted Service Invoice';
    }
    value(21; "Service Cr.Memo Header")
    {
        Caption = 'Posted Service Credit Memo';
    }

}
