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

    Permissions = tabledata "Connection Setup" = IM,
                  tabledata Participation = imd,
                  tabledata "Activated Net. Prof." = imd,
                  tabledata "Network Identifier" = imd,
                  tabledata "Network Profile" = imd,
                  tabledata "E-Doc. Service Net Prof. Sel." = imd;
}