// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 8704 "Telemetry - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Telemetry Custom Dimensions" = X,
                  Codeunit "Telemetry Custom Dims Impl." = X,
                  Codeunit "Telemetry" = X,
                  Codeunit "Telemetry Impl." = X,
                  Codeunit "Telemetry Loggers" = X,
                  Codeunit "Telemetry Loggers Impl." = X,
                  Codeunit "System Telemetry Logger" = X,
                  Codeunit "Feature Telemetry" = x,
                  codeunit "Feature Telemetry Impl." = X,
                  Codeunit "Feature Uptake Status Impl." = X,
                  Table "Feature Uptake" = X;
}