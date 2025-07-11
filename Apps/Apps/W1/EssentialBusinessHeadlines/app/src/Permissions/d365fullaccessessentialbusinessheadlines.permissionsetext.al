// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace System.Visualization;

using System.Security.AccessControl;

permissionsetextension 19147 "D365 FULL ACCESS - Essential Business Headlines" extends "D365 FULL ACCESS"
{
    Permissions = tabledata "Ess. Business Headline Per Usr" = RIMD,
                  tabledata "Headline Details Per User" = RIMD;
}
