// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

enum 31251 "Search Scope CZB"
{
    Extensible = true;

    value(0; "Account Mapping")
    {
        Caption = 'Account Mapping';
    }
    value(1; Balance)
    {
        Caption = 'Balance';
    }
    value(2; Customer)
    {
        Caption = 'Customer';
    }
    value(3; Vendor)
    {
        Caption = 'Vendor';
    }
    value(4; Employee)
    {
        Caption = 'Employee';
    }
}
