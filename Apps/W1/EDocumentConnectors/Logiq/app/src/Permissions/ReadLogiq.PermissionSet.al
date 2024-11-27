// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

permissionset 6433 "Read - Logiq"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Objects - Logiq";

    Permissions = tabledata "Connection Setup" = R,
                tabledata "Connection User Setup" = R;
}