// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

permissionset 6391 ContEDocConnRead
{
    Access = Public;
    Assignable = true;
    Caption = 'Continia E-Document Connector - Read';
    IncludedPermissionSets = ContEDocConnObjects;

    Permissions = tabledata "Continia Connection Setup" = R,
                  tabledata "Continia Participation" = R,
                  tabledata "Continia Activated Net. Prof." = R,
                  tabledata "Continia Network Identifier" = R,
                  tabledata "Continia Network Profile" = R,
                  tabledata "Con. E-Doc. Serv. Prof. Sel." = R;
}