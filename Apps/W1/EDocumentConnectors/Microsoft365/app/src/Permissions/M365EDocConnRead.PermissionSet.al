// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

permissionset 6382 M365EDocConnRead
{
    Access = Public;
    Assignable = true;
    Caption = 'Microsoft 365 E-Document Connector - Read';

    Permissions = tabledata "OneDrive Setup" = R,
                  tabledata "Sharepoint Setup" = R,
                  tabledata "Outlook Setup" = R;
}