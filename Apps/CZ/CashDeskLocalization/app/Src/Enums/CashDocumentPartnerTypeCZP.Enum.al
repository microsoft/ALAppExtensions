// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

enum 11734 "Cash Document Partner Type CZP"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; Customer)
    {
        Caption = 'Customer';
    }
    value(2; Vendor)
    {
        Caption = 'Vendor';
    }
    value(3; Contact)
    {
        Caption = 'Contact';
    }
    value(4; "Salesperson/Purchaser")
    {
        Caption = 'Salesperson/Purchaser';
    }
    value(5; Employee)
    {
        Caption = 'Employee';
    }
}
