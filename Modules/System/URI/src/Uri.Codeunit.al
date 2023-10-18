// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Utilities;

using System;

/// <summary>
/// Provides an object representation of a uniform resource identifier (URI) and easy access to the parts of the URI.
/// </summary>
/// <remarks>Visit https://learn.microsoft.com/dotnet/api/system.uri for more information.</remarks>
codeunit 3060 Uri
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Initializes a new instance of the Uri class with the specified URI.
    /// </summary>
    /// <remarks>Visit https://learn.microsoft.com/dotnet/api/system.uri.-ctor#System_Uri__ctor_System_String_ for more information.</remarks>
    /// <param name="UriString">A string that identifies the resource to be represented by the Uri instance. Note that an IPv6 address in string form must be enclosed within brackets. For example, "http://[2607:f8b0:400d:c06::69]".</param>
    procedure Init(UriString: Text)
    begin
        Uri := Uri.Uri(UriString);
    end;

    /// <summary>
    /// Gets the absolute URI.
    /// </summary>
    /// <returns>A string containing the entire URI.</returns>
    procedure GetAbsoluteUri(): Text
    begin
        exit(Uri.AbsoluteUri)
    end;

    /// <summary>
    /// Gets the scheme name for the URI.
    /// </summary>
    /// <remarks>Visit https://learn.microsoft.com/dotnet/api/system.uri.scheme for more information.</remarks>
    /// <returns>A text that contains the scheme for this URI, converted to lowercase.</returns>
    procedure GetScheme(): Text
    begin
        exit(Uri.Scheme);
    end;

    /// <summary>
    /// Gets the host name of the URI.
    /// </summary>
    /// <remarks>Visit https://learn.microsoft.com/dotnet/api/system.uri.host for more information.</remarks>
    /// <returns>A text that contains the host name for this URI.</returns>
    procedure GetHost(): Text
    begin
        exit(Uri.Host);
    end;

    /// <summary>
    /// Gets the authority of the URI.
    /// </summary>
    /// <remarks>Visit https://learn.microsoft.com/dotnet/api/system.uri.authority for more information.</remarks>
    /// <returns>A text that contains the authority for this URI.</returns>
    procedure GetAuthority(): Text
    begin
        exit(Uri.Authority);
    end;

    /// <summary>
    /// Gets the port number of the URI.
    /// </summary>
    /// <remarks>Visit https://learn.microsoft.com/dotnet/api/system.uri.port for more information.</remarks>
    /// <returns>An integer that contains the port number for this URI.</returns>
    procedure GetPort(): Integer
    begin
        exit(Uri.Port);
    end;

    /// <summary>
    /// Gets the absolute path of the URI.
    /// </summary>
    /// <remarks>Visit https://learn.microsoft.com/dotnet/api/system.uri.absolutepath for more information.</remarks>
    /// <returns>A text that contains the absolute path for this URI.</returns>
    procedure GetAbsolutePath(): Text
    begin
        exit(Uri.AbsolutePath);
    end;

    /// <summary>
    /// Gets any query information included in the specified URI.
    /// </summary>
    /// <remarks>Visit https://learn.microsoft.com/dotnet/api/system.uri.query for more information.</remarks>
    /// <returns>A text that contains the query information for this URI.</returns>
    procedure GetQuery(): Text
    begin
        exit(Uri.Query);
    end;

    /// <summary>
    /// Gets the escaped URI fragment.
    /// </summary>
    /// <remarks>Visit https://learn.microsoft.com/dotnet/api/system.uri.fragment for more information.</remarks>
    /// <returns>A text that contains the fragment portion for this URI.</returns>
    procedure GetFragment(): Text
    begin
        exit(Uri.Fragment);
    end;

    /// <summary>
    /// Gets a list containing the path segments that make up the specified URI.
    /// </summary>
    /// <remarks>Visit https://learn.microsoft.com/dotnet/api/system.uri.segments for more information.</remarks>
    /// <param name="Segments">An out variable that contains the path segments that make up the specified URI.</param>
    procedure GetSegments(var Segments: List of [Text])
    var
        Segment: DotNet String;
        Result: List of [Text];
    begin
        foreach Segment in Uri.Segments do
            Result.Add(Segment);

        Segments := Result;
    end;

    /// <summary>
    /// Converts a string to its escaped representation.
    /// </summary>
    /// <remarks>Visit https://learn.microsoft.com/dotnet/api/system.uri.escapedatastring for more information.</remarks>
    /// <param name="TextToEscape"></param>
    /// <returns>A string that contains the escaped representation of <paramref name="TextToEscape:"/>.</returns>
    procedure EscapeDataString(TextToEscape: Text): Text
    begin
        exit(Uri.EscapeDataString(TextToEscape));
    end;

    /// <summary>
    /// Converts a string to its unescaped representation.
    /// </summary>
    /// <remarks>Visit https://learn.microsoft.com/dotnet/api/system.uri.unescapedatastring for more information.</remarks>
    /// <param name="TextToUnescape"></param>
    /// <returns>A string that contains the unescaped representation of <paramref name="TextToUnescape:"/>.</returns>
    procedure UnescapeDataString(TextToUnescape: Text): Text
    begin
        exit(Uri.UnescapeDataString(TextToUnescape));
    end;

    /// <summary>
    /// Checks if the provded string is a valid URI.
    /// </summary>
    /// <param name="UriString">The string to check.</param>
    /// <returns>True if the provided string is a valid URI; otherwise - false.</returns>
    [TryFunction]
    procedure IsValidUri(UriString: Text)
    var
        LocalUri: DotNet Uri;
    begin
        LocalUri := LocalUri.Uri(UriString); // If creating the URI succeeds, then the UriString is a valid URI.
    end;

    /// <summary>
    /// Indicates whether the string is well-formed by attempting to construct a URI with the string and ensures that the string does not require further escaping.
    /// </summary>
    /// <remarks>Visit https://learn.microsoft.com/en-us/dotnet/api/system.uri.iswellformeduristring for more information.</remarks>
    /// <param name="UriString">The string used to attempt to construct a Uri.</param>
    /// <param name="UriKind">The type of the Uri in uriString.</param>
    /// <returns>True if the string was well-formed; otherwise, false.</returns>
    procedure IsWellFormedUriString(UriString: Text; UriKind: Enum UriKind): Boolean
    var
        DotNetlUriKind: DotNet UriKind;
    begin
        case UriKind of
            UriKind::RelativeOrAbsolute:
                exit(Uri.IsWellFormedUriString(UriString, DotNetlUriKind.RelativeOrAbsolute));
            UriKind::Absolute:
                exit(Uri.IsWellFormedUriString(UriString, DotNetlUriKind.Absolute));
            UriKind::Relative:
                exit(Uri.IsWellFormedUriString(UriString, DotNetlUriKind.Relative));
        end;
    end;

    /// <summary>
    /// Determines whether the current Uri instance is a base of the specified Uri instance.
    /// </summary>
    /// <remarks>Visit https://learn.microsoft.com/en-us/dotnet/api/system.uri.isbaseof for more information.</remarks>
    /// <param name="UriToTest">The specified URI to test.</param>
    /// <returns>True if the current Uri instance is a base of uri; otherwise, false.</returns>
    procedure IsBaseOf(var UriToTest: Codeunit Uri): Boolean
    var
        LocalUri: DotNet Uri;
    begin
        UriToTest.GetUri(LocalUri);
        exit(Uri.IsBaseOf(LocalUri));
    end;

    /// <summary>
    /// Gets the underlying .Net Uri variable.
    /// </summary>
    /// <param name="OutUri">A .Net object of class Uri that holds the underlying .Net Uri variable.</param>
    [Scope('OnPrem')]
    procedure GetUri(var OutUri: DotNet Uri)
    begin
        OutUri := Uri;
    end;

    /// <summary>
    /// Sets the underlying .Net Uri variable.
    /// </summary>
    /// <param name="NewUri">A .Net object of class Uri to set to the underlying .Net Uri variable.</param>
    [Scope('OnPrem')]
    procedure SetUri(NewUri: DotNet Uri)
    begin
        Uri := NewUri;
    end;

    var
        Uri: DotNet Uri;
}