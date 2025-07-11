// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 6099 "OSYNCHUSER"
{
    Access = Public;
    Assignable = true;
    Caption = 'Outlook Synch. common user';

    IncludedPermissionSets = "Outlook Sync. - View";
}
