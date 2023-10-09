// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

entitlement "D365 Business Central Infrastructure"
{
    Type = Application;
    Id = '996def3d-b36c-4153-8607-a6fd3c01b89f';

#pragma warning disable AL0684
    ObjectEntitlements = "Application Objects - Exec",
                         "System Application - Basic";
#pragma warning restore
}
