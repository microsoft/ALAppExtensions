// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.B2Brouter;

permissionset 6491 "B2Brouter Read"
{
    Assignable = true;
    Permissions =
        tabledata "B2Brouter Setup" = r;
}