// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Payout Status (ID 30128).
/// Represented by shopify.dev/docs/api/admin-graphql/latest/enums/ShopifyPaymentsPayoutStatus
/// </summary>
enum 30128 "Shpfy Payout Status"
{
    Caption = 'Payout Status';
    Extensible = false;

    value(0; Unknown)
    {
        Caption = ' ';
    }
    value(1; Scheduled)
    {
        Caption = 'Scheduled';
    }
    value(2; "In Transit")
    {
        Caption = 'In Transit';
    }
    value(3; Paid)
    {
        Caption = 'Paid';
    }
    value(4; Failed)
    {
        Caption = 'Failed';
    }
    value(5; Canceled)
    {
        Caption = 'Canceled';
    }

}
