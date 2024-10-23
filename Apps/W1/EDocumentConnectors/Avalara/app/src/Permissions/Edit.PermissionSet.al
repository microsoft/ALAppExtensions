// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

permissionset 6372 Edit
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = Read;
    Caption = 'Avalara E-Document Connector - Edit';

    Permissions = tabledata "Connection Setup" = imd;
}