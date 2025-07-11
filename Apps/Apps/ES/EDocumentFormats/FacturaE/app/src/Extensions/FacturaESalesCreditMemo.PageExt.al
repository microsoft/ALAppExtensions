// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Format;

using Microsoft.Sales.Document;

pageextension 10772 "Factura-E Sales Credit Memo" extends "Sales Credit Memo"
{
    layout
    {
        addafter("Shipment Date")
        {
            field("Factura-E Reason Code"; Rec."Factura-E Reason Code")
            {
                ApplicationArea = Basic, Suite;
                Importance = Additional;
                ToolTip = 'Specifies the Factura-E reason code for the credit memo.';
            }
        }
    }
}