// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The SMTP authentication types
/// </summary>
enum 4511 "SMTP Authentication" implements "SMTP Authentication"
{
    Extensible = false;
    DefaultImplementation = "SMTP Authentication" = "Basic SMTP Authentication";

    /// <summary>
    /// Anonymous SMTP authentication.
    /// </summary>
    value(1; Anonymous)
    {
        Implementation = "SMTP Authentication" = "Anonymous SMTP Authentication";
    }

    /// <summary>
    /// Basic SMTP authentication.
    /// </summary>
    value(3; Basic)
    {
        Implementation = "SMTP Authentication" = "Basic SMTP Authentication";
    }

    /// <summary>
    /// OAuth 2.0 SMTP authentication.
    /// </summary>
    value(4; "OAuth 2.0")
    {
        Implementation = "SMTP Authentication" = "OAuth2 SMTP Authentication";
    }
}