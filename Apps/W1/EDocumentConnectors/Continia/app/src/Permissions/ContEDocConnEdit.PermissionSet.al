// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Continia;

permissionset 6392 ContEDocConnEdit
{
    Access = Public;
    Assignable = true;
    Caption = 'Continia E-Document Connector - Edit';
    IncludedPermissionSets = ContEDocConnRead;

    Permissions = tabledata "Continia Connection Setup" = IM,
                  tabledata "Continia Participation" = imd,
                  tabledata "Continia Activated Net. Prof." = imd,
                  tabledata "Continia Network Identifier" = imd,
                  tabledata "Continia Network Profile" = imd,
                  tabledata "Con. E-Doc. Serv. Prof. Sel." = imd;
}