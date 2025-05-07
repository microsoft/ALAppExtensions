#if not CLEAN26
#pragma warning disable AS0072 // Obsolete permission set
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;


permissionset 6372 Edit
{
    Access = Public;
    Assignable = true;
    IncludedPermissionSets = "Avalara Read";
    Caption = 'Avalara E-Document Connector - Edit';
    ObsoleteReason = 'This permission set is obsolete. Use Avalara Edit permission set instead.';
    ObsoleteState = Pending;
    ObsoleteTag = '26.0';

    Permissions = tabledata "Connection Setup" = imd;
}

#pragma warning restore AS0072 // Obsolete permission set
#endif