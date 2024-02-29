// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

permissionset 80200 "File Share - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'File Share - Objects';

    Permissions =
        table "File Share Account" = X,
        codeunit "File Share Connector Impl." = X,
        page "File Share Account Wizard" = X,
        page "File Share Account" = X;
}
