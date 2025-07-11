// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4560 "Ext. Blob Stor. - Objects"
{
    Access = Public;
    Assignable = false;
    Caption = 'Blob Storage - Objects';

    Permissions =
        table "Ext. Blob Storage Account" = X,
        page "Ext. Blob Stor. Account Wizard" = X,
        page "Ext. Blob Sto Container Lookup" = X,
        page "Ext. Blob Storage Account" = X;
}
