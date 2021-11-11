// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 810 "Web Service Management - Obj."
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Web Service Management Impl." = X,
                  Codeunit "Web Service Management" = X,
                  Table "Tenant Web Service Columns" = X,
                  Table "Tenant Web Service Filter" = X,
                  Table "Tenant Web Service OData" = X,
                  Table "Web Service Aggregate" = X;
}
