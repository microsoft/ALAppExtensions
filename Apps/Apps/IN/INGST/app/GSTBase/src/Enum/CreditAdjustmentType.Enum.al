// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18008 "Credit Adjustment Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Credit Reversal")
    {
        Caption = 'Credit Reversal';
    }
    value(2; "Credit Re-Availment")
    {
        Caption = 'Credit Re-Availment';
    }
    value(3; "Permanent Reversal")
    {
        Caption = 'Permanent Reversal';
    }
    value(4; "Credit Availment")
    {
        Caption = 'Credit Availment';
    }
    value(5; "Reversal of Availment")
    {
        Caption = 'Reversal of Availment';
    }
}
