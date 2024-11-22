// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

permissionset 6361 "EDocConnector - Edit"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "EDocConnector - Read";

    Permissions = tabledata "E-Doc. Ext. Connection Setup" = IM;
}