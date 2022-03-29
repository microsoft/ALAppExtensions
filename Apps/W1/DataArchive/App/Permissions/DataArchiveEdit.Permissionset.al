#if not CLEAN20
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
permissionset 631 "Data Archive - Edit"
{
    Access = Public;
    Assignable = true;
    Caption = '(Obsolete) Data Archive - Edit';

    ObsoleteState = Pending;
    ObsoleteReason = 'Same as Data Archive View';
    ObsoleteTag = '20.0';

    IncludedPermissionSets = "Data Archive - View";
}
#endif