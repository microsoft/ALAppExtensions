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

    Permissions = tabledata "Logiq Connection Setup" = r,
                tabledata "Logiq Connection User Setup" = r;
}