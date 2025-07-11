// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18046 "Source Type"
{
    value(0; " ")
    {
        Caption = ' ';
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
    value(4; Party)
    {
        Caption = 'Party';
    }
}
