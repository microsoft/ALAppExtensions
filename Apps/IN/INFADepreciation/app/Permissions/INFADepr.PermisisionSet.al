// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.FADepreciation;

permissionset 18631 INFADepr
{
    Access = Public;
    Assignable = true;

    Permissions = tabledata "FA Accounting Period Inc. Tax" = RIMD,
                  tabledata "Fixed Asset Block" = RIMD,
                  tabledata "Fixed Asset Shift" = RIMD;

}
