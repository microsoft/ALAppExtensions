// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Interface "Shpfy IBulkOperation."
/// </summary>
interface "Shpfy IBulk Operation"
{
    Access = Internal;

    /// <summary>
    /// Provides the GraphQL query for the bulk operation.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetGraphQL(): Text;

    /// <summary>
    /// Provides the request input for the bulk operation.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetInput(): Text;

    /// <summary>
    /// Provides the name of the bulk operation.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetName(): Text[250];

    /// <summary>
    /// GetType.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure GetType(): Text;

    /// <summary>
    /// Reverts the failed requests for the bulk operation.
    /// </summary>
    /// <param name="BulkOperation">The bulk operation record.</param>
    procedure RevertFailedRequests(var BulkOperation: Record "Shpfy Bulk Operation");

    /// <summary>
    /// Reverts all requests for the bulk operation.
    /// </summary>
    /// <param name="BulkOperation">The bulk operation record.</param>
    procedure RevertAllRequests(var BulkOperation: Record "Shpfy Bulk Operation");
}