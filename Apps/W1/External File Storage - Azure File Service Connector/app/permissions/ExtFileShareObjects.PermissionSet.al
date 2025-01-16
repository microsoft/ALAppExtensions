// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4570 "Ext. File Share - Objects"
{
    Access = Public;
    Assignable = false;
    Caption = 'File Share - Objects';

    Permissions =
        table "Ext. File Share Account" = X,
        page "Ext. File Share Account Wizard" = X,
        page "Ext. File Share Account" = X;
}
