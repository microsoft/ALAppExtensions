// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The Retention Policy Log Category is used to categorize log entries by area.
/// </summary>
enum 3901 "Retention Policy Log Category"
{
    Extensible = true;

    /// <summary>Category used for creating log entries concerning allowed tables.</summary>
    value(0; "Retention Policy - Allowed Tables")
    {
    }

    /// <summary>Category used for creating log entries concerning retention period.</summary>
    value(1; "Retention Policy - Period")
    {
    }

    /// <summary>Category used for creating log entries concerning retention policy setup.</summary>
    value(2; "Retention Policy - Setup")
    {
    }

    /// <summary>Category used for creating log entries concerning applying retention policies.</summary>
    value(3; "Retention Policy - Apply")
    {
    }
}