#if not CLEAN18
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11703 "CASH-DOCUMENT"
{
    Access = Public;
    Assignable = true;
    Caption = 'Cash documents read';

    ObsoleteState = Pending;
    ObsoleteReason = 'Moved to Cash Desk Localization for Czech.';
    ObsoleteTag = '18.0';

    Permissions = tabledata "Company Information" = R;
}
#endif