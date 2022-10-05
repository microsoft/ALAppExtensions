// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 8383 "D365 BACKUP/RESTORE"
{
    Access = Public;
    Assignable = true;
    Caption = 'Backup or restore database';

    Permissions = system "Tools, Backup" = X,
                  system "Tools, Restore" = X;
}
