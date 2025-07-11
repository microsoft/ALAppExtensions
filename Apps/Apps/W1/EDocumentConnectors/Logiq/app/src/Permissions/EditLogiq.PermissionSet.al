// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

permissionset 6433 "Edit - Logiq"
{
    Access = Public;
    Assignable = true;
    Caption = 'Logiq Connector - Edit';
    IncludedPermissionSets = "Read - Logiq";

    Permissions = tabledata "Logiq Connection Setup" = im,
                tabledata "Logiq Connection User Setup" = im;
}