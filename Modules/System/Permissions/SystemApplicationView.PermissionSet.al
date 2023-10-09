// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Environment.Configuration;
using System.Azure.Identity;
using System.Visualization;
using System.Text;
using System.Globalization;
using System.DataAdministration;
using System.Feedback;
using System.Privacy;
using System.Utilities;
using System.Security.User;
using System.Integration;
using System.Apps;

permissionset 75 "System Application - View"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "System Application - Read",
                             "Advanced Settings - View",
                             "Guided Experience - View",
                             "Azure AD Plan - View",
                             "Azure AD User - View",
                             "Cues and KPIs - View",
                             "Default Role Center - View",
                             "Entity Text - View",
                             "Extension Management - View",
                             "Feature Key - View",
                             "Language - View",
                             "Retention Policy - View",
                             "Satisfaction Survey - View",
                             "Media - View",
                             "Priv. Notice - View",
                             "Record Link Management - View",
                             "Table Information - View",
                             "User Permissions - View",
                             "User Settings - View",
                             "Web Service Management - View";
}
