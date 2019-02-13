// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13616 PurchaseInvoice extends "Purchase Invoice"
{
    layout
    {
        addafter("Creditor No.")
        {
            field("Giro Acc. No."; GiroAccNo)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the vendor''s giro account.';
            }
        }
    }
}