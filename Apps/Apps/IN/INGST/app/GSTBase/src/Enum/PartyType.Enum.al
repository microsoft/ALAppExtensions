// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18039 "Party Type"
{
    value(0; Vendor)
    {
        Caption = 'Vendor';
    }
    value(1; Customer)
    {
        Caption = 'Customer';
    }
}
