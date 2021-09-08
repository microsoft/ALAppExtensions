// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum is used to determine the implementation codeunit called to delete expired records when applying a retention policy.
/// </summary>
enum 3904 "Reten. Pol. Deleting" implements "Reten. Pol. Deleting"
{
    Extensible = true;

    /// <summary>
    /// The default implementation.
    /// </summary>
    value(0; Default)
    {
        Implementation = "Reten. Pol. Deleting" = "Reten. Pol. Delete. Impl.";
    }
}