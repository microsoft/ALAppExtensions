// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// this permission set is used to easily add all the extension objects into the apps license
/// do not include this permission set in any other permission set
/// and do not change the Access and Assignable properties
/// </summary>
permissionset 2144 "Company Hub - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'Company Hub - Objects';

    Permissions = Codeunit "COHUB API Request" = X,
                  Codeunit "COHUB Comp. Url Task Manager" = X,
                  Codeunit "COHUB Core" = X,
                  Codeunit "COHUB Format Amount" = X,
                  Codeunit "COHUB Reload Companies" = X,
                  Codeunit "COHUB Url Error Handler" = X,
                  Codeunit "COHUB Url Task Manager" = X,
                  Codeunit "COHUB Group Summary Sync" = X,
                  Codeunit "COHUB Delete Activity Log" = X,
                  Codeunit "COHUB Install" = X,
                  Codeunit "COHUB Show Activity Log" = X,
                  Page "COHUB My User Tasks" = X,
                  Page "COHUB Companies Overview" = X,
                  Page "COHUB Company Short Summary" = X,
                  Page "COHUB Company Summary" = X,
                  Page "COHUB Role Center" = X,
                  Page "COHUB Group List" = X,
                  Page "COHUB Enviroment Card" = X,
                  Page "COHUB Enviroment List" = X,
                  Table "COHUB User Task" = X,
                  Table "COHUB Company Endpoint" = X,
                  Table "COHUB Company KPI" = X,
                  Table "COHUB Group" = X,
                  Table "COHUB Group Company Summary" = X,
                  Table "COHUB Enviroment" = X;
}