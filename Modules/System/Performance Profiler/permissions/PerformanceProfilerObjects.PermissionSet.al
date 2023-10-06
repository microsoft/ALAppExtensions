// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Tooling;

permissionset 1921 "Performance Profiler - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Sampling Performance Profiler" = X,
                  Page "Performance Profiler" = X;
}
