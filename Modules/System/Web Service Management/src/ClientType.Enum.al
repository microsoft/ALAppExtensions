// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum has the web service client types.
/// </summary>
enum 9751 "Client Type"
{
    Extensible = false;

    /// <summary>
    /// Specifies that the client type is SOAP.
    /// </summary>
    value(0; SOAP) { }

    /// <summary>
    /// Specifies that the client type is OData V3.
    /// </summary>
    value(1; ODataV3) { }

    /// <summary>
    /// Specifies that the client type is OData V4.
    /// </summary>
    value(2; ODataV4) { }
}