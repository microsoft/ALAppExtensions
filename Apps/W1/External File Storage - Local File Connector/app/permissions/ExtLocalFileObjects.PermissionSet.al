// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 4820 "Ext. Local File - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Local File - Objects';

    Permissions =
        table "Ext. Local File Account" = X,
        page "Ext. Local File Account Wizard" = X,
        page "Ext. Local File Account" = X;
}
