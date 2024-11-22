// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

permissionset 6362 "EDocConnector - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "EDoc. Connector Objects";

    Permissions = tabledata "E-Doc. Ext. Connection Setup" = R;
}