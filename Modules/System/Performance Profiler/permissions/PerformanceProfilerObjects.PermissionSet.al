// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1921 "Performance Profiler - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Profiling Data Processor" = X,
                  Codeunit "Sampling Performance Profiler" = X,
                  Page "Performance Profiler" = X,
                  Page "Profiling Call Tree" = X,
                  Page "Profiling Self Time Chart" = X,
                  Page "Profiling Full Time Chart" = X,
                  Page "Profiling Duration By Method" = X,
                  Page "Profiling Duration By Object" = X;
}
