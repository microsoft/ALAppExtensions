// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

enum 30153 "Shpfy Dispute Reason"
{
    Caption = 'Shopify Dispute Reason';
    Extensible = false;

    value(0; Unknown)
    {
        Caption = 'Unknown';
    }
#pragma warning disable AS0082
#pragma warning disable AS0125
    value(1; "Bank Cannot Process")
    {
        Caption = 'Bank Cannot Process';
    }
#pragma warning restore AS0125
#pragma warning restore AS0082
    value(2; "Credit Not Processed")
    {
        Caption = 'Credit Not Processed';
    }
    value(3; "Customer Initiated")
    {
        Caption = 'Customer Initiated';
    }
    value(4; "Debit Not Authorized")
    {
        Caption = 'Debit Not Authorized';
    }
    value(5; Duplicate)
    {
        Caption = 'Duplicate';
    }
    value(6; Fraudulent)
    {
        Caption = 'Fraudulent';
    }
    value(7; General)
    {
        Caption = 'General';
    }
    value(8; "Incorrect Account Details")
    {
        Caption = 'Incorrect Account Details';
    }
    value(9; "Insufficient Funds")
    {
        Caption = 'Insufficient Funds';
    }
    value(10; "Product Not Received")
    {
        Caption = 'Product Not Received';
    }
    value(11; "Product Unacceptable")
    {
        Caption = 'Product Unacceptable';
    }
#pragma warning disable AS0082
#pragma warning disable AS0125
    value(12; "Subscription Cancelled")
    {
        Caption = 'Subscription Cancelled';
    }
#pragma warning restore AS0125
#pragma warning restore AS0082
    value(13; Unrecognized)
    {
        Caption = 'Unrecognized';
    }
}