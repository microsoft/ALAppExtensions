// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets.Reports;

permissionset 10801 "FA Reports FR - Objects"
{
    Access = Internal;

    Assignable = false;
    Permissions = report "FA-Proj. Value (Derogatory) FR" = X,
                  report "Fixed Asset-Professional TaxFR" = X;
}