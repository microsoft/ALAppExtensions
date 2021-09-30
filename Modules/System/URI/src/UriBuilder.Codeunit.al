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
        UriBuilderImpl.Init(Uri);
    end;

    /// <summary>
    /// Sets the scheme name of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.scheme for more information.</remarks>
    /// <param name="Scheme">A string that represents the scheme name to set.</param>
    procedure SetScheme(Scheme: Text)
    begin
        UriBuilderImpl.SetScheme(Scheme);
    end;

    /// <summary>
    /// Gets the scheme name of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.scheme for more information.</remarks>
    /// <returns>The scheme name of the URI.</returns>
    procedure GetScheme(): Text
    begin
        exit(UriBuilderImpl.GetScheme());
    end;

    /// <summary>
    /// Sets the host name of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.host for more information.</remarks>
    /// <param name="Host">A string that represents the host name to set.</param>
    procedure SetHost(Host: Text)
    begin
        UriBuilderImpl.SetHost(Host);
    end;

    /// <summary>
    /// Gets the host name of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.host for more information.</remarks>
    /// <returns>The host name of the URI.</returns>
    procedure GetHost(): Text
    begin
        exit(UriBuilderImpl.GetHost());
    end;

    /// <summary>
    /// Sets the port number of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.port for more information.</remarks>
    /// <param name="Port">An integer that represents the port number to set.</param>
    procedure SetPort(Port: Integer)
    begin
        UriBuilderImpl.SetPort(Port);
    end;

    /// <summary>
    /// Gets the port number of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.port for more information.</remarks>
    /// <returns>The port number of the URI.</returns>
    procedure GetPort(): Integer
    begin
        exit(UriBuilderImpl.GetPort());
    end;

    /// <summary>
    /// Sets the path to the resource referenced by the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.path for more information.</remarks>
    /// <param name="Path">A string that represents the path to set.</param>
    procedure SetPath(Path: Text)
    begin
        UriBuilderImpl.SetPath(Path);
    end;

    /// <summary>
    /// Gets the path to the resource referenced by the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.path for more information.</remarks>
    /// <returns>The path to the resource referenced by the URI.</returns>
    procedure GetPath(): Text
    begin
        exit(UriBuilderImpl.GetPath());
    end;

    /// <summary>
    /// Sets any query information included in the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.query for more information.</remarks>
    /// <param name="Query">A string that represents the query information to set.</param>
    procedure SetQuery(Query: Text)
    begin
        UriBuilderImpl.SetQuery(Query);
    end;

    /// <summary>
    /// Gets the query information included in the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.query for more information.</remarks>
    /// <returns>The query information included in the URI.</returns>
    procedure GetQuery(): Text
    begin
        exit(UriBuilderImpl.GetQuery());
    end;

    /// <summary>
    /// Sets the fragment portion of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.fragment for more information.</remarks>
    /// <param name="Fragment">A string that represents the fragment portion to set.</param>
    procedure SetFragment(Fragment: Text)
    begin
        UriBuilderImpl.SetFragment(Fragment);
    end;

    /// <summary>
    /// Gets the fragment portion of the URI.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.fragment for more information.</remarks>
    /// <returns>The fragment portion of the URI.</returns>
    procedure GetFragment(): Text
    begin
        exit(UriBuilderImpl.GetFragment());
    end;

    /// <summary>
    /// Gets the Uri instance constructed by the specified "Uri Builder" instance.
    /// </summary>
    /// <remarks>Visit https://docs.microsoft.com/en-us/dotnet/api/system.uribuilder.uri for more information.</remarks>
    /// <param name="Uri">A Uri that contains the URI constructed by the Uri Builder.</param>
    procedure GetUri(var Uri: Codeunit Uri)
    begin
        UriBuilderImpl.GetUri(Uri);
    end;

    /// <summary>
    /// Adds a flag to the query string of this UriBuilder. In case the same query flag exists already, the action in <paramref name="DuplicateAction"/> is taken.
    /// </summary>
    /// <param name="Flag">A flag to add to the query string of this UriBuilder. This value will be encoded before being added to the URI query string. Cannot be empty.</param>
    /// <param name="DuplicateAction">Specifies which action to take if the flag already exist.</param>
    /// <error>If the provided <paramref name="Flag"/> is empty.</error>
    /// <error>If the provided <paramref name="DuplicateAction"/> is <c>"Throw Error"</c> and the flag already exists in the URI.</error>
    /// <error>If the provided <paramref name="DuplicateAction"/> is not a valid value for the enum.</error>
    /// <remarks>This function could alter the order of the existing query string parts. For example, if the previous URL was "https://microsoft.com?foo=bar&amp;john=doe" and the new flag is "contoso", the result could be "https://microsoft.com?john=doe&amp;foo=bar&amp;contoso".</remarks>
    procedure AddQueryFlag(Flag: Text; DuplicateAction: Enum "Uri Query Duplicate Behaviour")
    begin
        UriBuilderImpl.AddQueryFlag(Flag, DuplicateAction);
    end;

    /// <summary>
    /// Adds a flag to the query string of this UriBuilder. In case the same query flag exists already, only one occurrence is kept.
    /// </summary>
    /// <param name="Flag">A flag to add to the query string of this UriBuilder. This value will be encoded before being added to the URI query string. Cannot be empty.</param>
    /// <error>If the provided <paramref name="Flag"/> is empty.</error>
    /// <remarks>This function could alter the order of the existing query string parts. For example, if the previous URL was "https://microsoft.com?foo=bar&amp;john=doe" and the new flag is "contoso", the result could be "https://microsoft.com?john=doe&amp;foo=bar&amp;contoso".</remarks>
    procedure AddQueryFlag(Flag: Text)
    begin
        UriBuilderImpl.AddQueryFlag(Flag, Enum::"Uri Query Duplicate Behaviour"::"Overwrite All Matching");
    end;

    /// <summary>
    /// Adds a parameter key-value pair to the query string of this UriBuilder (in the form <c>ParameterKey=ParameterValue</c>). In case the same query key exists already, the action in <paramref name="DuplicateAction"/> is taken.
    /// </summary>
    /// <param name="ParameterKey">The key for the new query parameter. This value will be encoded before being added to the URI query string. Cannot be empty.</param>
    /// <param name="ParameterValue">The value for the new query parameter. This value will be encoded before being added to the URI query string. Can be empty.</param>
    /// <param name="DuplicateAction">Specifies which action to take if the ParameterKey specified already exist.</param>
    /// <error>If the provided <paramref name="ParameterKey"/> is empty.</error>
    /// <error>If the provided <paramref name="DuplicateAction"/> is <c>"Throw Error"</c>.</error>
    /// <error>If the provided <paramref name="DuplicateAction"/> is not a valid value for the enum.</error>
    /// <remarks>This function could alter the order of the existing query string parts. For example, if the previous URL was "https://microsoft.com?foo=bar&amp;john=doe" and the new flag is "contoso=42", the result could be "https://microsoft.com?john=doe&amp;foo=bar&amp;contoso=42".</remarks>
    procedure AddQueryParameter(ParameterKey: Text; ParameterValue: Text; DuplicateAction: Enum "Uri Query Duplicate Behaviour")
    begin
        UriBuilderImpl.AddQueryParameter(ParameterKey, ParameterValue, DuplicateAction);
    end;

    /// <summary>
    /// Adds a parameter key-value pair to the query string of this UriBuilder (in the form <c>ParameterKey=ParameterValue</c>). In case the same query key exists already, its value is overwritten.
    /// </summary>
    /// <param name="ParameterKey">The key for the new query parameter. This value will be encoded before being added to the URI query string. Cannot be empty.</param>
    /// <param name="ParameterValue">The value for the new query parameter. This value will be encoded before being added to the URI query string. Can be empty.</param>
    /// <error>If the provided <paramref name="ParameterKey"/> is empty.</error>
    /// <remarks>This function could alter the order of the existing query string parts. For example, if the previous URL was "https://microsoft.com?foo=bar&amp;john=doe" and the new flag is "contoso=42", the result could be "https://microsoft.com?john=doe&amp;foo=bar&amp;contoso=42".</remarks>
    procedure AddQueryParameter(ParameterKey: Text; ParameterValue: Text)
    begin
        UriBuilderImpl.AddQueryParameter(ParameterKey, ParameterValue, Enum::"Uri Query Duplicate Behaviour"::"Overwrite All Matching");
    end;

    var
        UriBuilderImpl: Codeunit "Uri Builder Impl.";
}
