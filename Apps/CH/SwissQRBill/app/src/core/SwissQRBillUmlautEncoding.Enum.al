// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

enum 11513 "Swiss QR-Bill Umlaut Encoding"
{
    Extensible = false;
    ObsoleteReason = 'No need to convert umlauts, because encoding was changed to UTF-8.';
    ObsoleteState = Pending;
    ObsoleteTag = '23.0';

    value(0; Single)
    {
        Caption = 'Single';
    }
    value(1; Double)
    {
        Caption = 'Double';
    }
    value(2; Remove)
    {
        Caption = 'Remove';
    }
    value(3; "Western European ISO-8859-1")
    {
        Caption = 'Western European ISO-8859-1';
    }
}
