// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Common interface for different authorization options.
/// </summary>
interface "Storage Service Authorization"
{
    /// <summary>
    /// Authorizes an HTTP request by providing the needed authorization information to it.
    /// </summary>
    /// <param name="HttpRequest">The HTTP request to authorize.</param>
    /// <param name="StorageAccount">The name of the storage account to authorize against.</param>
    procedure Authorize(var HttpRequest: HttpRequestMessage; StorageAccount: Text);
}