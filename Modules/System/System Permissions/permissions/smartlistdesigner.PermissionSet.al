#if not CLEAN20
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 7379 "SMARTLIST DESIGNER"
{
    Access = Public;
    Assignable = true;
    Caption = 'SmartList Designer (Obsolete)';
    ObsoleteState = Pending;
    ObsoleteReason = 'The SmartList Designer is not supported in Business Central';
    ObsoleteTag = '20.0';

    Permissions = system "SmartList Designer API" = X,
                  system "SmartList Designer Preview" = X,
                  system "SmartList Import/Export" = X,
                  system "SmartList Management" = X;
}
#endif