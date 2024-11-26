// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

permissionset 6392 "Tietoevry Edit"
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Tietoevry Read";
    Caption = 'Tietoevry E-Document Connector - Edit';

    Permissions = tabledata "Connection Setup" = imd;
}