#if not CLEAN26
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Transfer;

pageextension 31128 "Transfer Order CZL" extends "Transfer Order"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'The declaration of the fields are moved to Intrastat CZ extension.';
    ObsoleteTag = '26.0';

    layout
    {
        addfirst("Foreign Trade")
        {
            field(IsIntrastatTransactionCZL; Rec.IsIntrastatTransactionCZL())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Transaction';
                Editable = false;
                ToolTip = 'Specifies if the entry is an Intrastat transaction.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'The declaration of the field is moved to Intrastat CZ extension.';
                ObsoleteTag = '26.0';
            }
        }
    }
}

#endif