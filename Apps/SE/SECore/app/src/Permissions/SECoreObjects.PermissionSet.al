// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance;

using Microsoft.Finance.FinancialReports;

permissionset 11210 "SECore - Objects"
{
    Access = Public;
    Assignable = false;

    Permissions =
        report "SE Balance sheet" = X,
        report "SE Income statement" = X;
}