// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 4506 "Outlook REST API" 
{
    Assignable = false;
    Access = Internal;
    Permissions = codeunit * = X,
                  page * = X,
                  table * = X,
                  tabledata "Email - Outlook Account" = rimd;
}
