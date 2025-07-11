// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Purchase;

enum 18081 "GST Party Type"
{
    Extensible = true;
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Vendor)
    {
        Caption = 'Vendor';
    }
    value(2; Customer)
    {
        Caption = 'Customer';
    }
}
