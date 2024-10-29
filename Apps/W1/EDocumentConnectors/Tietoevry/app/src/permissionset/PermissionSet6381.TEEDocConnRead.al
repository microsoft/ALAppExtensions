// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

permissionset 6381 "TE EDocConn. - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "TE EDoc. Conn. Objects";

    Permissions = tabledata "Connection Setup" = R;
}