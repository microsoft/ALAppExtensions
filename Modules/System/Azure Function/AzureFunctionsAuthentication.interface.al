// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Functions;

/// <summary>
/// Common interface for different authentication options.
/// </summary>
interface "Azure Functions Authentication"
{
    /// <summary>
    /// Exposes interface to authenticate request message to azure function.
    /// </summary>
    /// <param name="RequestMessage">Request message used to communicate with Azure function.</param>
    /// <returns>True if authentication was successful; otherwise - false.</returns>
    procedure Authenticate(var RequestMessage: HttpRequestMessage): Boolean
}