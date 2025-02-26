// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.B2Brouter;

permissionset 71107793 "B2Brouter Edit"
{
    Assignable = true;
    IncludedPermissionSets = "B2Brouter Read";
    Permissions =
        tabledata "B2Brouter Setup" = imd;
}