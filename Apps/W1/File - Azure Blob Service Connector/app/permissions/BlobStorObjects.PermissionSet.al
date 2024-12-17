// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

permissionset 80100 "Blob Stor. - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Blob Storage - Objects';

    Permissions =
        table "Blob Storage Account" = X,
        codeunit "Blob Storage Connector Impl." = X,
        page "Blob Storage Account Wizard" = X,
        page "Blob Storage Container Lookup" = X,
        page "Blob Storage Account" = X;
}
