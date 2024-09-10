// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

permissionset 96361 "TE EDocConn. - Edit"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "TE EDocConn. - Read";

    Permissions = tabledata "Tietoevry Connection Setup" = IM;
}