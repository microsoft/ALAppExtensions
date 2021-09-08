// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides a custom constructor for uniform resource identifiers (URIs) and modifies URIs for the Uri codeunit.
/// </summary>
/// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder for more information.</remarks>
codeunit 3061 "Uri Builder"
{
    Access = Public;

    /// <summary>
    /// Initializes a new instance of the UriBuilder class with the specified URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.-ctor#System_UriBuilder__ctor_System_String_ for more information.</remarks>
    /// <param name="Uri">A URI string.</param>
    procedure Init(Uri: Text)
    begin
        UriBuilder := UriBuilder.UriBuilder(Uri);
    end;

    /// <summary>
    /// Sets the scheme name of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.scheme for more information.</remarks>
    /// <param name="Scheme">A string that represents the scheme name to set.</param>
    procedure SetScheme(Scheme: Text)
    begin
        UriBuilder.Scheme := Scheme;
    end;

    /// <summary>
    /// Gets the scheme name of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.scheme for more information.</remarks>
    /// <returns>The scheme name of the URI.</returns>
    procedure GetScheme(): Text
    begin
        exit(UriBuilder.Scheme);
    end;

    /// <summary>
    /// Sets the host name of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.host for more information.</remarks>
    /// <param name="Host">A string that represents the host name to set.</param>
    procedure SetHost(Host: Text)
    begin
        UriBuilder.Host := Host;
    end;

    /// <summary>
    /// Gets the host name of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.host for more information.</remarks>
    /// <returns>The host name of the URI.</returns>
    procedure GetHost(): Text
    begin
        exit(UriBuilder.Host);
    end;

    /// <summary>
    /// Sets the port number of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.port for more information.</remarks>
    /// <param name="Port">An integer that represents the port number to set.</param>
    procedure SetPort(Port: Integer)
    begin
        UriBuilder.Port := Port;
    end;

    /// <summary>
    /// Gets the port number of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.port for more information.</remarks>
    /// <returns>The port number of the URI.</returns>
    procedure GetPort(): Integer
    begin
        exit(UriBuilder.Port);
    end;

    /// <summary>
    /// Sets the path to the resource referenced by the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.path for more information.</remarks>
    /// <param name="Path">A string that represents the path to set.</param>
    procedure SetPath(Path: Text)
    begin
        UriBuilder.Path := Path;
    end;

    /// <summary>
    /// Gets the path to the resource referenced by the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.path for more information.</remarks>
    /// <returns>The path to the resource referenced by the URI.</returns>
    procedure GetPath(): Text
    begin
        exit(UriBuilder.Path);
    end;

    /// <summary>
    /// Sets any query information included in the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.query for more information.</remarks>
    /// <param name="Query">A string that represents the query information to set.</param>
    procedure SetQuery(Query: Text)
    begin
        UriBuilder.Query := Query;
    end;

    /// <summary>
    /// Gets the query information included in the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.query for more information.</remarks>
    /// <returns>The query information included in the URI.</returns>
    procedure GetQuery(): Text
    begin
        exit(UriBuilder.Query);
    end;

    /// <summary>
    /// Sets the fragment portion of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.fragment for more information.</remarks>
    /// <param name="Fragment">A string that represents the fragment portion to set.</param>
    procedure SetFragment(Fragment: Text)
    begin
        UriBuilder.Fragment := Fragment;
    end;

    /// <summary>
    /// Gets the fragment portion of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.fragment for more information.</remarks>
    /// <returns>The fragment portion of the URI.</returns>
    procedure GetFragment(): Text
    begin
        exit(UriBuilder.Fragment);
    end;

    /// <summary>
    /// Gets the Uri instance constructed by the specified "Uri Builder" instance.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.uri for more information.</remarks>
    /// <param name="Uri">A Uri that contains the URI constructed by the Uri Builder.</param>
    procedure GetUri(var Uri: Codeunit Uri)
    begin
        Uri.SetUri(UriBuilder.Uri);
    end;

    var
        UriBuilder: DotNet UriBuilder;
}
