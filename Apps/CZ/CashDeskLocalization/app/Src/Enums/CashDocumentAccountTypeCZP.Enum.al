// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

enum 11731 "Cash Document Account Type CZP"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; "G/L Account")
    {
        Caption = 'G/L Account';
    }
    value(2; Customer)
    {
        Caption = 'Customer';
    }
    value(3; Vendor)
    {
        Caption = 'Vendor';
    }
    value(4; "Bank Account")
    {
        Caption = 'Bank Account';
    }
    value(5; "Fixed Asset")
    {
        Caption = 'Fixed Asset';
    }
    value(6; Employee)
    {
        Caption = 'Employee';
    }
}
