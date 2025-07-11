// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18028 "GST Ledger Source Type"
{
    value(0; Customer)
    {
        Caption = 'Customer';
    }
    value(1; Vendor)
    {
        Caption = 'Vendor';
    }
    value(2; "G/L Account")
    {
        Caption = 'G/L Account';
    }
    value(3; Transfer)
    {
        Caption = 'Transfer';
    }
    value(4; "Bank Account")
    {
        Caption = 'Bank Account';
    }
    value(5; Party)
    {
        Caption = 'Party';
    }
}
