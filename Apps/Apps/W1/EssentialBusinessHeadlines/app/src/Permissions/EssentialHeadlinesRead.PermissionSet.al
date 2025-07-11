// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace System.Visualization;

permissionset 19151 "EssentialHeadlines - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'Essential Business Headlines - Read';

    IncludedPermissionSets = "EssentialHeadlines - Objects";

    Permissions = tabledata "Ess. Business Headline Per Usr" = R,
                    tabledata "Headline Details Per User" = R;
}
