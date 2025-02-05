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

    Permissions = tabledata "Connection Setup" = R,
                  tabledata Participation = R,
                  tabledata "Activated Net. Prof." = R,
                  tabledata "Network Identifier" = R,
                  tabledata "Network Profile" = R,
                  tabledata "E-Doc. Service Net Prof. Sel." = R;
}