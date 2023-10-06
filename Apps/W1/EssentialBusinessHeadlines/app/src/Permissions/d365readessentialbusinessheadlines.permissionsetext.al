// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace System.Visualization;

using System.Security.AccessControl;

permissionsetextension 19759 "D365 READ - Essential Business Headlines" extends "D365 READ"
{
    Permissions = tabledata "Ess. Business Headline Per Usr" = R,
                  tabledata "Headline Details Per User" = R;
}
