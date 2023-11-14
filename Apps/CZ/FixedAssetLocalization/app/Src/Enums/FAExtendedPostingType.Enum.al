// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

enum 31247 "FA Extended Posting Type CZF"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; Disposal)
    {
        Caption = 'Disposal';
    }
    value(2; Maintenance)
    {
        Caption = 'Maintenance';
    }
}
