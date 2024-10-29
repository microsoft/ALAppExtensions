// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

permissionset 6380 "TE EDocConn. - Edit"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "TE EDocConn. - Read";

    Permissions = tabledata "Connection Setup" = IM;
}