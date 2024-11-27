// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

permissionset 6432 "Edit - Logiq"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Read - Logiq";

    Permissions = tabledata "Connection Setup" = IM,
                tabledata "Connection User Setup" = IM;
}