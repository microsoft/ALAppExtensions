// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum is used to determine the implementation codeunit called when filtering a table for expired records when applying a retention policy.
/// </summary>

enum 3903 "Reten. Pol. Filtering" implements "Reten. Pol. Filtering"
{
    Extensible = true;

    /// <summary>
    /// The default implementation.
    /// </summary>
    value(0; Default)
    {
        Implementation = "Reten. Pol. Filtering" = "Reten. Pol. Filtering Impl.";
    }
}