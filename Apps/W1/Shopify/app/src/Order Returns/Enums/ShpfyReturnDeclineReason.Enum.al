// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

enum 30137 "Shpfy Return Decline Reason"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Final Sale")
    {
        Caption = 'Final Sale';
    }
    value(2; Other)
    {
        Caption = 'Other';
    }
    value(3; "Return Period Ended")
    {
        Caption = 'Return Period Ended';
    }
}