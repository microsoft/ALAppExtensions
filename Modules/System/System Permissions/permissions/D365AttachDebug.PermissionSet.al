// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 7210 "D365 ATTACH DEBUG"
{
    Access = Public;
    Assignable = true;
    Caption = 'Attach Debug';

    Permissions = system "Attach debugger to other user's session." = X,
                  tabledata "Published Application" = R;
}
