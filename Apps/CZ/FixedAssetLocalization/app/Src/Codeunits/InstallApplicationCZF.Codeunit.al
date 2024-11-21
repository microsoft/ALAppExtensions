// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Setup;

#pragma warning disable AL0432,AL0603
codeunit 31240 "Install Application CZF"
{
    Subtype = Install;
    Permissions = tabledata "Classification Code CZF" = im,
                  tabledata "Tax Depreciation Group CZF" = im,
                  tabledata "FA Extended Posting Group CZF" = im,
                  tabledata "FA History Entry CZF" = im,
                  tabledata "FA Setup" = m,
                  tabledata "Fixed Asset" = m,
                  tabledata "Depreciation Book" = m,
                  tabledata "FA Posting Group" = m,
                  tabledata "FA Allocation" = m;

}
