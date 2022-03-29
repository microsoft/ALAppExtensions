// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The SMTP authentication types
/// </summary>
enum 4511 "SMTP Authentication" implements "SMTP Authentication"
{
#if not CLEAN20
    ObsoleteReason = 'Use SMTP Authentication Types from the SMTP API app.';
    ObsoleteState = Pending;
    ObsoleteTag = '20.0';
#else
    Access = Internal;
#endif
    Extensible = false;

    /// <summary>
    /// Anonymous SMTP authentication.
    /// </summary>
    value(1; Anonymous)
    {
        Implementation = "SMTP Authentication" = "Dummy SMTP Authentication";
    }

    /// <summary>
    /// Basic SMTP authentication.
    /// </summary>
    value(3; Basic)
    {
        Implementation = "SMTP Authentication" = "Dummy SMTP Authentication";
    }

    /// <summary>
    /// OAuth 2.0 SMTP authentication.
    /// </summary>
    value(4; "OAuth 2.0")
    {
        Implementation = "SMTP Authentication" = "Dummy SMTP Authentication";
    }

    /// <summary>
    /// NTLM SMTP authentication.
    /// </summary>
    value(5; NTLM)
    {
        Implementation = "SMTP Authentication" = "Dummy SMTP Authentication";
    }
}