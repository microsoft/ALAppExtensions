// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 11707 "EET - USER"
{
    Access = Public;
    Assignable = true;
    Caption = 'EET - User';

    Permissions = tabledata "Isolated Certificate" = R;
}
