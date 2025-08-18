// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

enum 30140 "Shpfy Restock Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Cancel)
    {
        Caption = 'Cancel';
    }
    value(2; "Legacy Restock")
    {
        Caption = 'Legacy Restock';
    }
    value(3; "No Restock")
    {
        Caption = 'No Restock';
    }
    value(4; Return)
    {
        Caption = 'Return';
    }
}