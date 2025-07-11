// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace System.Visualization;

permissionset 19149 "EssentialHeadlines - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'Essential Business Headlines - Edit';

    IncludedPermissionSets = "EssentialHeadlines - Read";

    Permissions = tabledata "Ess. Business Headline Per Usr" = IMD,
                    tabledata "Headline Details Per User" = IMD;
}
