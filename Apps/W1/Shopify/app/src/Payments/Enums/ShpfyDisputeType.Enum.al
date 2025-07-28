// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

enum 30155 "Shpfy Dispute Type"
{
    Caption = 'Shopify Dispute Type';
    Extensible = false;

    value(0; Unknown)
    {
        Caption = ' ';
    }
    value(1; Inquiry)
    {
        Caption = 'Inquiry';
    }
    value(2; Chargeback)
    {
        Caption = 'Chargeback';
    }
}