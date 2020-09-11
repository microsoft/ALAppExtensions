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
