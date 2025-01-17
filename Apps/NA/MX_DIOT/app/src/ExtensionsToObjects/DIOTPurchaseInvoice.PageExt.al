// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

pageextension 27033 "DIOT Purchase Invoice" extends "Purchase Invoice"
{
    layout
    {
        addafter("Purchaser Code")
        {
            field("DIOT Type of Operation"; "DIOT Type of Operation")
            {
                ApplicationArea = BasicMX;
                Caption = 'DIOT Type of Operation';
                ToolTip = 'Specifies the DIOT operation type for this document.';
            }
        }
    }
}
