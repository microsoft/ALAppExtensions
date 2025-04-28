// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

/// <summary>
/// Interface for E-Document Status
/// </summary>
interface IEDocumentStatus
{

    /// <summary>
    /// Get E-Document Status
    /// </summary>
    procedure GetEDocumentStatus(): Enum "E-Document Status";

}