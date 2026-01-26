// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Format;

using Microsoft.Sales.History;

pageextension 10773 "Factura-E Posted S. Cr. Memo" extends "Posted Sales Credit Memo"
{
    layout
    {
        addafter("Customer Posting Group")
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