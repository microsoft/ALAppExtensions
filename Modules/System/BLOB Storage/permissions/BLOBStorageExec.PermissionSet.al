// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Utilities;

permissionset 4101 "BLOB Storage - Exec"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata "Persistent Blob" = rimd;
}
