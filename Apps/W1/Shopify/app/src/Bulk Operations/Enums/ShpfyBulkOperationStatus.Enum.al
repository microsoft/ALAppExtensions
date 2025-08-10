// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

enum 30147 "Shpfy Bulk Operation Status"
{
    Access = Internal;
    Caption = 'Shopify Fulfillment Status';
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Canceled)
    {
        Caption = 'Cancelled';
    }
    value(2; Canceling)
    {
        Caption = 'Cancelling';
    }
    value(3; Completed)
    {
        Caption = 'Completed';
    }
    value(4; Created)
    {
        Caption = 'Created';
    }
    value(5; Expired)
    {
        Caption = 'Expired';
    }
    value(6; Failed)
    {
        Caption = 'Failed';
    }
    value(7; Running)
    {
        Caption = 'Running';
    }
}