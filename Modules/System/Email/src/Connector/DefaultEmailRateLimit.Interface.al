// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

/// <summary>
/// A default email rate limit interface used to limit how many e-mails per second a connector can send.
/// </summary>
interface "Default Email Rate Limit"
{
    /// <summary>
    /// Provides the default email rate limit for the connector.
    /// </summary>
    /// <returns>A default email rate limit.</returns>
    procedure GetDefaultEmailRateLimit(): Integer;
}