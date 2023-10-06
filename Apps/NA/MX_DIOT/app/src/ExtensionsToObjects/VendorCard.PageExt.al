// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

pageextension 27031 "DIOT Vendor Card" extends "Vendor Card"
{
    layout
    {
        addafter("Responsibility Center")
        {
            field("DIOT Type of Operation"; "DIOT Type of Operation")
            {
                ApplicationArea = BasicMX;
                Caption = 'DIOT Type of Operation';
                ToolTip = 'Specifies the DIOT operation type to be used for all documents with this vendor.';
            }
        }
    }
}
