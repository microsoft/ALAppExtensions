// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

permissionset 47202 "SL Migration US - Objects"
{
    Assignable = false;
    Access = Public;
    Caption = 'SL Migration - Objects';

    Permissions =
        table "SL 1099 Box Mapping" = X,
        table "SL 1099 Migration Log" = X,
        table "SL Supported Tax Year" = X,
        codeunit "SL Cloud Migration US" = X,
        codeunit "SL Populate Vendor 1099 Data" = X,
        codeunit "SL Vendor 1099 Mapping Helpers" = X,
        page "SL 1099 Migration Log List" = X;
}