// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The types of aggregation over profiling nodes.
/// </summary>
enum 1921 "Profiling Aggregation Type"
{
    Access = Internal;

    /// <summary>
    /// No aggregation.
    /// </summary>
    value(0; "None")
    {
    }

    /// <summary>
    /// Aggregate by app publisher.
    /// </summary>
    value(1; "App Publisher")
    {
    }

    /// <summary>
    /// Aggregate by app publisher and name.
    /// </summary>
    value(2; "App Name")
    {
    }

    /// <summary>
    /// Aggregate by application object.
    /// </summary>
    value(3; Object)
    {
    }

    /// <summary>
    /// Aggregate by app application object and method.
    /// </summary>
    value(4; Method)
    {
    }
}