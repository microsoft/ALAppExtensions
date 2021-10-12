// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#if not CLEAN18
permissionset 11710 "GL-VIES DEC."
{
    Access = Public;
    Assignable = true;
    Caption = 'GL-Vies declaration read';

#if CLEAN17
    Permissions = tabledata "Company Information" = R;
#else
    Permissions = tabledata "VIES Declaration Header" = R,
                  tabledata "VIES Declaration Line" = R;
#endif
    ObsoleteState = Pending;
    ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
    ObsoleteTag = '18.0';
}
#endif