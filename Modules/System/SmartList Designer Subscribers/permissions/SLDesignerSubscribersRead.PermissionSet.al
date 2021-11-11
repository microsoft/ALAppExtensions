#if not CLEAN19
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

PermissionSet 2888 "SL Designer Subscribers - Read"
{
    Access = Internal;
    Assignable = false;
    ObsoleteState = Pending;
    ObsoleteReason = 'The SmartList Designer is not supported in Business Central.';
    ObsoleteTag = '19.0';

    Permissions = tabledata "Query Navigation" = r,
                  tabledata "Query Navigation Validation" = R, // Needed because the record is Public
                  tabledata "SmartList Designer Handler" = R,
                  Codeunit "Query Nav Validation Impl" = X,
                  Codeunit "Query Navigation Validation" = X,
                  Codeunit "SmartList Designer Subscribers" = X,
                  Table "Query Navigation Validation" = X,
                  Table "SmartList Designer Handler" = X;
    ;
}
#endif