// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Report Shpfy Sync Payments (ID 30105).
/// </summary>
report 30105 "Shpfy Sync Payments"
{
    ApplicationArea = All;
    Caption = 'Shopify Sync Payouts';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Shop; "Shpfy Shop")
        {
            RequestFilterFields = Code;

            trigger OnAfterGetRecord()
            var
                Payments: Codeunit "Shpfy Payments";
            begin
                Payments.SetShop(Shop);
                Payments.SyncPaymentTransactions();
            end;
        }
    }
}
