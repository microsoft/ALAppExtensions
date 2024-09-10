// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

permissionset 96362 "TE EDocConn. - Read"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "TE EDoc. Conn. Objects";

    Permissions = tabledata "Tietoevry Connection Setup" = R;
}