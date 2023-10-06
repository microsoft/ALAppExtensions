// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

permissionset 2609 "Feature Key - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Feature Management Facade" = X,
                  Page "Feature Management" = X,
                  Page "Schedule Feature Data Update" = X,
#if not CLEAN23
#pragma warning disable AL0432
                  Page "Upcoming Changes Factbox" = X,
#pragma warning restore AL0432
#endif
                  Table "Feature Data Update Status" = X;
}
