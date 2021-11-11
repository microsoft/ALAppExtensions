#if not CLEAN18
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 8903 "EMAIL USAGE"
{
    Access = Public;
    Assignable = true;
    Caption = '(Obsolete) Email Usage';

    ObsoleteState = Pending;
    ObsoleteReason = 'This permission set is included in mandatory permission set System App - Basic';
    ObsoleteTag = '18.0';

    IncludedPermissionSets = "Email - Edit";
}
#endif
