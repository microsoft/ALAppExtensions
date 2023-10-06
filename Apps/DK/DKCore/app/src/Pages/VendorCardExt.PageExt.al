// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.Core;

using Microsoft.Purchases.Vendor;

pageextension 13605 VendorCardExt extends "Vendor Card"
{
    layout
    {

        modify("EORI Number")
        {
            Visible = true;
        }
    }
}
