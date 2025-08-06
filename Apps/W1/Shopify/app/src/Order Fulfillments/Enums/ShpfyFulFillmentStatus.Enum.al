// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy FulFillment Status (ID 30112).
/// Represented by shopify.dev/docs/api/admin-graphql/latest/enums/FulfillmentStatus
/// </summary>
enum 30112 "Shpfy Fulfillment Status"
{
    Access = Internal;
    Caption = 'Shopify Fulfillment Status';
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Pending)
    {
        Caption = 'Pending';
    }
    value(2; Open)
    {
        Caption = 'Open';
    }
    value(3; Success)
    {
        Caption = 'Success';
    }
    value(4; Cancelled)
    {
        Caption = 'Cancelled';
    }
    value(5; Error)
    {
        Caption = 'Error';
    }
    value(6; Failure)
    {
        Caption = 'Failure';
    }

}
