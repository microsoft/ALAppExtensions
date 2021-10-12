// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11706 "EET - SETUP"
{
    Access = Public;
    Assignable = true;
    Caption = 'EET Setup';

    Permissions = tabledata "Isolated Certificate" = RIMD;
}
