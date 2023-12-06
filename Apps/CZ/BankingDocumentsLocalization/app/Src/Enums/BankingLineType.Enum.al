// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

enum 31254 "Banking Line Type CZB"
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
    value(3; "Bank Account")
    {
        Caption = 'Bank Account';
    }
    value(4; Employee)
    {
        Caption = 'Employee';
    }
}
