// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9704 "Cues and KPIs - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Cues And KPIs Impl." = X,
                  Codeunit "Cues And KPIs" = X,
                  Page "Cue Setup Administrator" = X,
                  Page "Cue Setup End User" = X,
                  Table "Cue Setup" = X;
}
