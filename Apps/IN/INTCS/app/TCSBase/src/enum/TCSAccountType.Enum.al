// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

enum 18809 "TCS Account Type"
{
    Extensible = true;

    value(0; "G/L Account")
    {
        Caption = 'G/L Account';
    }
    value(1; Customer)
    {
        Caption = 'Customer';
    }
}
