// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 4426 "EXCEL EXPORT ACTION"
{
    Access = Public;
    Assignable = true;
    Caption = 'D365 Excel Export Action';

    Permissions = system "Allow Action Export To Excel" = X;
}
