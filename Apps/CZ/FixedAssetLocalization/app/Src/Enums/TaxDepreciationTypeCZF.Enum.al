// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

enum 31240 "Tax Depreciation Type CZF"
{
    Extensible = true;

    value(0; "Straight-line")
    {
        Caption = 'Straight-Line';
    }
    value(1; "Declining-Balance")
    {
        Caption = 'Declining-Balance';
    }
    value(2; "Straight-Line Intangible")
    {
        Caption = 'Straight-Line Intangible';
    }
}
