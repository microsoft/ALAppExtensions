// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1994 "Guided Experience - Objects"
{
    Assignable = false;

    Permissions = Codeunit "Checklist" = X,
                  Codeunit "Guided Experience" = X,
                  Codeunit "Spotlight Tour" = X,
                  Codeunit "Spotlight Tour Impl." = X,
#if not CLEAN18
#pragma warning disable AL0432
                  Codeunit "Assisted Setup" = X,
                  Codeunit "Manual Setup" = X,
#pragma warning restore
#endif
                  Page "Assisted Setup" = X,
                  Page "Checklist Administration" = X,
                  Page "Checklist Banner" = X,
                  Page "Checklist Item Roles" = X,
                  Page "Checklist Item Users" = X,
                  Page "Checklist Resurfacing" = X,
                  Page "Guided Experience Item List" = X,
                  Page "Manual Setup" = X,
                  Page Checklist = X,
                  Page "App Setup List" = X;
}
