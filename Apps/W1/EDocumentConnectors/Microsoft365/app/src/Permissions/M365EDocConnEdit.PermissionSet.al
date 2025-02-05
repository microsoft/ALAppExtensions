// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

permissionset 6381 M365EDocConnEdit
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = M365EDocConnRead;
    Caption = 'Microsoft 365 E-Document Connector - Edit';

    Permissions = tabledata "OneDrive Setup" = imd,
                  tabledata "Sharepoint Setup" = imd,
                  tabledata "Outlook Setup" = imd;
}