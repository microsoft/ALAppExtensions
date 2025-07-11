// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

enum 18687 "TDS Party Type"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Party)
    {
        Caption = 'Party';
    }
    value(2; Customer)
    {
        Caption = 'Customer';
    }
    value(3; Vendor)
    {
        Caption = 'Vendor';
    }
}
