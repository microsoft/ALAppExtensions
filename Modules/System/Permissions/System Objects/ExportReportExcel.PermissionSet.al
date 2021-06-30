// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 415 "Export Report Excel"
{
    Access = Public;
    Assignable = true;
    Caption = 'Export Report DataSet to Excel';

    Permissions = system "Allow Action Export Report Dataset To Excel" = X;
}
