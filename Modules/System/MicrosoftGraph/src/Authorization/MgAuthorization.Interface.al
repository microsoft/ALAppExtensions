// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Integration.Microsoft.Graph.Authorization;
using System.RestClient;

/// <summary>
/// Common interface for different authorization options.
/// </summary>
interface "Mg Authorization"
{
    /// <summary>
    /// Returns an Http Authentication Instance
    /// </summary> 
    procedure GetHttpAuthorization(): Interface "Http Authentication"
}