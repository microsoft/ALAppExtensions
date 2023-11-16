// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Posting;

enum 11718 "G/L Account Group CZL"
{
    Extensible = false;

    value(0; "Financial Accounting")
    {
        Caption = 'Financial Accounting';
    }
    value(1; "Internal Accounting")
    {
        Caption = 'Internal Accounting';
    }
    value(2; "Off-Balance Accounting")
    {
        Caption = 'Off-Balance Accounting';
    }
}
