// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

permissionset 686 "Paym. Prac. Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Paym. Prac. Objects";

    Permissions =
        tabledata "Payment Period" = R,
        tabledata "Payment Practice Data" = R,
        tabledata "Payment Practice Line" = R,
        tabledata "Payment Practice Header" = R;

}
