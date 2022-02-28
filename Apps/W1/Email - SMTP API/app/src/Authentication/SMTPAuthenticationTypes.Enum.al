// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The SMTP authentication types
/// </summary>
enum 4611 "SMTP Authentication Types" implements "SMTP Auth"
{
    Access = Public;
    Extensible = false;
    DefaultImplementation = "SMTP Auth" = "Basic SMTP Auth";

    /// <summary>
    /// Anonymous SMTP authentication.
    /// </summary>
    value(1; Anonymous)
    {
        Implementation = "SMTP Auth" = "Anonymous SMTP Auth";
    }

    /// <summary>
    /// Basic SMTP authentication.
    /// </summary>
    value(3; Basic)
    {
        Implementation = "SMTP Auth" = "Basic SMTP Auth";
    }

    /// <summary>
    /// OAuth 2.0 SMTP authentication.
    /// </summary>
    value(4; "OAuth 2.0")
    {
        Implementation = "SMTP Auth" = "OAuth2 SMTP Auth";
    }

    /// <summary>
    /// NTLM SMTP authentication.
    /// </summary>
    value(5; NTLM)
    {
        Implementation = "SMTP Auth" = "NTLM SMTP Auth";
    }
}