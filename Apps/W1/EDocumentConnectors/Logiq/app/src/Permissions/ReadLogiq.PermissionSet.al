// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

permissionset 6434 "Read - Logiq"
{
    Access = Public;
    Assignable = true;
    Caption = 'Logiq Connector - Read';
    IncludedPermissionSets = "Objects - Logiq";

    Permissions = tabledata "Connection Setup" = r,
                tabledata "Connection User Setup" = r;
}