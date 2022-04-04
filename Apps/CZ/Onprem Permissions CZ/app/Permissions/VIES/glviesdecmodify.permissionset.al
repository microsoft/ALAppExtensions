// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#if not CLEAN18
permissionset 11711 "GL-VIES DEC. MODIFY"
{
    Access = Public;
    Assignable = true;
    Caption = 'GL-Vies declaration modify';
    ObsoleteState = Pending;
    ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
    ObsoleteTag = '18.0';

    Permissions = tabledata "Company Information" = R;
}
#endif