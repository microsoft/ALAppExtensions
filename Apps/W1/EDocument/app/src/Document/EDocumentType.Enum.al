// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Interfaces;

enum 6121 "E-Document Type" implements IEDocumentFinishDraft
{
    Extensible = true;
    DefaultImplementation = IEDocumentFinishDraft = "E-Doc. Unspecified Impl.";

    value(0; "None")
    {
        Caption = 'None';
    }
    value(1; "Sales Quote")
    {
        Caption = 'Sales Quote';
    }
    value(2; "Sales Order")
    {
        Caption = 'Sales Order';
    }
    value(3; "Sales Invoice")
    {
        Caption = 'Sales Invoice';
    }
    value(4; "Sales Return Order")
    {
        Caption = 'Sales Return Order';
    }
    value(5; "Sales Credit Memo")
    {
        Caption = 'Sales Credit Memo';
    }
    value(6; "Purchase Quote")
    {
        Caption = 'Purchase Quote';
    }
    value(7; "Purchase Order")
    {
        Caption = 'Purchase Order';
    }
    value(8; "Purchase Invoice")
    {
        Caption = 'Purchase Invoice';
        Implementation = IEDocumentFinishDraft = "E-Doc. Create Purchase Invoice";
    }
    value(9; "Purchase Return Order")
    {
        Caption = 'Purchase Return Order';
    }
    value(10; "Purchase Credit Memo")
    {
        Caption = 'Purchase Credit Memo';
    }
    value(11; "Service Order")
    {
        Caption = 'Service Order';
    }
    value(12; "Service Invoice")
    {
        Caption = 'Service Invoice';
    }
    value(13; "Service Credit Memo")
    {
        Caption = 'Service Credit Memo';
    }
    value(14; "Finance Charge Memo")
    {
        Caption = 'Finance Charge Memo';
    }
    value(15; "Issued Finance Charge Memo")
    {
        Caption = 'Issued Finance Charge Memo';
    }
    value(16; "Reminder")
    {
        Caption = 'Reminder';
    }
    value(17; "Issued Reminder")
    {
        Caption = 'Issued Reminder';
    }
    value(18; "General Journal")
    {
        Caption = 'General Journal';
    }
    value(19; "G/L Entry")
    {
        Caption = 'G/L Entry';
    }
    value(20; "Sales Shipment")
    {
        Caption = 'Sales Shipment';
    }
    value(21; "Transfer Shipment")
    {
        Caption = 'Transfer Shipment';
    }
}
