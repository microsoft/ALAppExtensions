// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 4692 "Recurrence Schedule - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Recurrence Schedule" = X,
                  Page "Recurrence Schedule Card" = X,
                  Table "Recurrence Schedule" = X;
}
