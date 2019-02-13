// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 13614 PurchaseQuote extends "Purchase Quote"
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