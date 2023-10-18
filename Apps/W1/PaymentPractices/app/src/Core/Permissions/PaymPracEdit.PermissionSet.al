// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

permissionset 687 "Paym. Prac. Edit"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Paym. Prac. Read";

    Permissions =
        tabledata "Payment Period" = IMD,
        tabledata "Payment Practice Data" = IMD,
        tabledata "Payment Practice Line" = IMD,
        tabledata "Payment Practice Header" = IMD;

}
