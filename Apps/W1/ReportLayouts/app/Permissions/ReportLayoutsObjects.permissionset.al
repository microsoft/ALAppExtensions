// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
permissionset 9660 "Report Layouts - Objects"
{
    Assignable = false;
    Access = Public;

    Permissions =
        Page "Report Layouts" = X,
        Page "Report Layout Edit Dialog" = X,
        Page "Report Layout New Dialog" = X,
        codeunit "Report Layouts Impl." = X;
}