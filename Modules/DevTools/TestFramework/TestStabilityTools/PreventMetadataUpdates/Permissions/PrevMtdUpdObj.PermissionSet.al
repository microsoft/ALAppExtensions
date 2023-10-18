// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Tooling;

permissionset 132553 "Prev. Mtd. Upd - Obj"
{
    Assignable = false;
    Caption = 'Prevent Metadata Updates - Objects';

    // Include Test Tables
    Permissions = codeunit "Block Changes to System Tables" = X;
}