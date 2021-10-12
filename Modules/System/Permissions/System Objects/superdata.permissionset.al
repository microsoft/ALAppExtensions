// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 7368 "SUPER (DATA)"
{
    Access = Public;
    Assignable = true;
    Caption = 'Superuser of data';

    Permissions = tabledata * = RIMD;
}
