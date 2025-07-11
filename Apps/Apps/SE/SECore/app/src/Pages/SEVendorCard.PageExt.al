// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

pageextension 11292 "SE Vendor Card" extends "Vendor Card"
{
    layout
    {
        modify("EORI Number")
        {
            Visible = true;
        }
    }
}
