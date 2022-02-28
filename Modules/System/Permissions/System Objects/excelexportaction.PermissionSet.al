// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#if not CLEAN19
permissionset 4426 "EXCEL EXPORT ACTION"
{
    Access = Public;
    Assignable = true;
    Caption = 'D365 Excel Export Action';

    ObsoleteState = Pending;
    ObsoleteReason = 'This permissionset is being replaced by "Edit in Excel - View".';
    ObsoleteTag = '19.0';

    Permissions = system "Allow Action Export To Excel" = X;
}
#endif
