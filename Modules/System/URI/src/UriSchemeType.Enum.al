// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum has the Uri Scheme types.
/// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.scheme#remarks for more information.</remarks>
/// </summary>
enum 3061 "Uri Scheme Type"
{
    Extensible = false;

    /// <summary>
    /// The resource is a file on the local computer.
    /// </summary>
    value(0; "file") { }

    /// <summary>
    /// The resource is accessed through FTP.
    /// </summary>
    value(1; ftp) { }

    /// <summary>
    /// The resource is accessed through the Gopher protocol.
    /// </summary>
    value(2; gopher) { }

    /// <summary>
    /// The resource is accessed through HTTP.
    /// </summary>
    value(3; http) { }

    /// <summary>
    /// The resource is accessed through SSL-encrypted HTTP.
    /// </summary>
    value(4; https) { }

    /// <summary>
    /// The resource is an email address and is accessed through SMTP.
    /// </summary>
    value(5; mailto) { }

    /// <summary>
    /// The resource is accessed through NNTP.
    /// </summary>
    value(6; news) { }
}