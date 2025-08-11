// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Order Fulfillment Status (ID 30113).
/// /// Represented by shopify.dev/docs/api/admin-graphql/latest/enums/OrderDisplayFulfillmentStatus
/// </summary>
enum 30113 "Shpfy Order Fulfill. Status"
{
    Caption = 'Shopify Order Fulfill. Status';
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(2; Fulfilled)
    {
        Caption = 'Fulfilled';
    }
#pragma warning disable AS0082
    value(3; "In Progress")
    {
        Caption = 'In Progress';
    }
#pragma warning restore AS0082
    value(4; Open)
    {
        Caption = 'Open';
    }
#pragma warning disable AS0082
    value(5; "Pending Fulfillment")
    {
        Caption = 'Pending Fulfillment';
    }
#pragma warning restore AS0082
    value(6; Restocked)
    {
        Caption = 'Restocked';
    }
#pragma warning disable AS0082
    value(7; Unfulfilled)
    {
        Caption = 'Unfulfilled';
    }
#pragma warning restore AS0082
    value(8; "Partially Fulfilled")
    {
        Caption = 'Partially Fulfilled';
    }
    value(9; "On Hold")
    {
        Caption = 'On Hold';
    }
    value(10; "Scheduled")
    {
        Caption = 'Scheduled';
    }
    value(11; "Request Declined")
    {
        Caption = 'Request Declined';
    }
}