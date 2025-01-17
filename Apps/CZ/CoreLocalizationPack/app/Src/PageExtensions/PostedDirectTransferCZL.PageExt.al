// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

pageextension 31224 "Posted Direct Transfer CZL" extends "Posted Direct Transfer"
{
    layout
    {
        addafter("Transfer-from")
        {
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';

                field(IsIntrastatTransactionCZL; Rec.IsIntrastatTransactionCZL())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Intrastat Transaction';
                    Editable = false;
                    ToolTip = 'Specifies if the entry is an Intrastat transaction.';
                }
            }
        }
    }
}
