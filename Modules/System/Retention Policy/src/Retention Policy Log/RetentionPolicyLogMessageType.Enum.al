// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the type of log message. 
/// </summary>
#pragma warning disable AL0659
enum 3902 "Retention Policy Log Message Type"
#pragma warning restore
{
    Extensible = false;

    /// <summary>Message type used for creating log entries of type Error</summary>
    value(0; Error)
    {
    }

    /// <summary>Message type used for creating log entries of type Warning</summary>
    value(1; Warning)
    {
    }

    /// <summary>Message type used for creating log entries of type Info</summary>
    value(2; Info)
    {
    }
}