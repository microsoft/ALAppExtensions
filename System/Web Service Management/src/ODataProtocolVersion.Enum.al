// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum has the OData protocol versions.
/// </summary>
enum 9750 "OData Protocol Version"
{
    Extensible = true;

    /// <summary>
    /// Specifies that the OData protocol version is V3.
    /// </summary>
    value(0; V3) { }

    /// <summary>
    /// Specifies that the OData protocol version is V4.
    /// </summary>
    value(1; V4) { }
}