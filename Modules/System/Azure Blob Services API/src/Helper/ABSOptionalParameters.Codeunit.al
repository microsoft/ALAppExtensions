// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holder for the optional Azure Blob Storage HTTP headers and URL parameters.
/// </summary>
codeunit 9047 "ABS Optional Parameters"
{
    Access = Public;

    #region Headers
    /// <summary>
    /// Sets the value for 'x-ms-lease-id' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Guid value specifying the LeaseID</param>
    procedure LeaseId("Value": Guid)
    begin
        SetRequestHeader('x-ms-lease-id', ABSFormatHelper.RemoveCurlyBracketsFromString(Format("Value").ToLower()));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-source-lease-id' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the source LeaseID</param>
    procedure SourceLeaseId("Value": Text)
    begin
        SetRequestHeader('x-ms-source-lease-id', "Value");
    end;

    /// <summary>
    /// Sets the value for 'Origin' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure Origin("Value": Text)
    begin
        SetRequestHeader('Origin', "Value");
    end;

    /// <summary>
    /// Sets the value for 'Access-Control-Request-Method' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure AccessControlRequestMethod("Value": Enum "Http Request Type")
    begin
        SetRequestHeader('Access-Control-Request-Method', Format("Value"));
    end;

    /// <summary>
    /// Sets the value for 'Access-Control-Request-Headers' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure AccessControlRequestHeaders("Value": Text)
    begin
        SetRequestHeader('Access-Control-Request-Headers', "Value");
    end;

    /// <summary>
    /// Sets the value for 'x-ms-client-request-id' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure ClientRequestId("Value": Text)
    begin
        SetRequestHeader('x-ms-client-request-id', "Value");
    end;

    /// <summary>
    /// Sets the value for 'x-ms-blob-public-access' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Enum "Blob Public Access" value specifying the HttpHeader value</param>
    procedure BlobPublicAccess("Value": Enum "ABS Blob Public Access")
    begin
        SetRequestHeader('x-ms-blob-public-access', Format("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-meta-[MetaName]' HttpHeader for a request.
    /// </summary>
    /// <param name="MetaName">The name of the Metadata-value.</param>
    /// <param name="Value">Text value specifying the Metadata value</param>
    procedure Metadata(MetaName: Text; "Value": Text)
    var
        MetaKeyValuePairLbl: Label 'x-ms-meta-%1', Comment = '%1 = Key', Locked = true;
    begin
        SetRequestHeader(StrSubstNo(MetaKeyValuePairLbl, MetaName), "Value");
    end;

    /// <summary>
    /// Sets the value for 'x-ms-tags' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure TagsValue("Value": Text)
    begin
        SetRequestHeader('x-ms-tags', "Value"); // Supported in version 2019-12-12 and newer.
    end;

    /// <summary>
    /// Sets the value for 'x-ms-source-if-modified-since' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">DateTime value specifying the HttpHeader value</param>
    procedure SourceIfModifiedSince("Value": DateTime)
    begin
        SetRequestHeader('x-ms-source-if-modified-since', ABSFormatHelper.GetRfc1123DateTime("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-source-if-unmodified-since' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">DateTime value specifying the HttpHeader value</param>
    procedure SourceIfUnmodifiedSince("Value": DateTime)
    begin
        SetRequestHeader('x-ms-source-if-unmodified-since', ABSFormatHelper.GetRfc1123DateTime("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-source-if-match' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure SourceIfMatch("Value": Text)
    begin
        SetRequestHeader('x-ms-source-if-match', "Value");
    end;

    /// <summary>
    /// Sets the value for 'x-ms-source-if-none-match' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure SourceIfNoneMatch("Value": Text)
    begin
        SetRequestHeader('x-ms-source-if-none-match', "Value");
    end;

    /// <summary>
    /// Sets the value for 'x-ms-copy-source' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure CopySourceName("Value": Text)
    begin
        SetRequestHeader('x-ms-copy-source', "Value");
    end;

    /// <summary>
    /// Sets the value for 'x-ms-rehydrate-priority' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Enum "Rehydrate Priority" value specifying the HttpHeader value</param>
    procedure RehydratePriority("Value": Enum "ABS Rehydrate Priority")
    begin
        SetRequestHeader('x-ms-rehydrate-priority', Format("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-expiry-option' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Enum "Blob Expiry Option" value specifying the HttpHeader value</param>
    procedure BlobExpiryOption("Value": Enum "ABS Blob Expiry Option")
    begin
        SetRequestHeader('x-ms-expiry-option', Format("Value")); // Valid values are RelativeToCreation/RelativeToNow/Absolute/NeverExpire
    end;

    /// <summary>
    /// Sets the value for 'x-ms-expiry-time' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Integer value specifying the HttpHeader value</param>
    procedure BlobExpiryTime("Value": Integer)
    begin
        SetRequestHeader('x-ms-expiry-time', Format("Value")); // Either an RFC 1123 datetime or miliseconds-value
    end;

    /// <summary>
    /// Sets the value for 'x-ms-expiry-time' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">DateTime value specifying the HttpHeader value</param>
    procedure BlobExpiryTime("Value": DateTime)
    begin
        SetRequestHeader('x-ms-expiry-time', ABSFormatHelper.GetRfc1123DateTime("Value")); // Either an RFC 1123 datetime or miliseconds-value
    end;

    /// <summary>
    /// Sets the value for 'x-ms-access-tier' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Enum "Blob Access Tier" value specifying the HttpHeader value</param>
    procedure BlobAccessTier("Value": Enum "ABS Blob Access Tier")
    begin
        SetRequestHeader('x-ms-access-tier', Format("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-range' HttpHeader for a request.
    /// </summary>
    /// <param name="BytesStartValue">Integer value specifying the Bytes start range value</param>
    /// <param name="BytesEndValue">Integer value specifying the Bytes end range value</param>
    procedure Range(BytesStartValue: Integer; BytesEndValue: Integer)
    var
        RangeBytesLbl: Label 'bytes=%1-%2', Comment = '%1 = Start Range; %2 = End Range';
    begin
        SetRequestHeader('x-ms-range', StrSubstNo(RangeBytesLbl, BytesStartValue, BytesEndValue));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-source-range' HttpHeader for a request.
    /// </summary>
    /// <param name="BytesStartValue">Integer value specifying the Bytes start range value</param>
    /// <param name="BytesEndValue">Integer value specifying the Bytes end range value</param>
    procedure SourceRange(BytesStartValue: Integer; BytesEndValue: Integer)
    var
        RangeBytesLbl: Label 'bytes=%1-%2', Comment = '%1 = Start Range; %2 = End Range';
    begin
        SetRequestHeader('x-ms-source-range', StrSubstNo(RangeBytesLbl, BytesStartValue, BytesEndValue));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-requires-sync' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Boolean value specifying the HttpHeader value</param>
    procedure RequiresSync("Value": Boolean)
    var
        ValueText: Text;
    begin
        // Set as text, because otherwise it might give different formatted values based on language locale
        if "Value" then
            ValueText := 'true'
        else
            ValueText := 'false';

        SetRequestHeader('x-ms-requires-sync', ValueText);
    end;

    /// <summary>
    /// Sets the value for 'x-ms-lease-action' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Enum "ABS Lease Action" value specifying the HttpHeader value</param>    
    internal procedure LeaseAction("Value": Enum "ABS Lease Action")
    begin
        SetRequestHeader('x-ms-lease-action', Format("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-lease-break-period' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Integer value specifying the HttpHeader value.</param>
    internal procedure LeaseBreakPeriod("Value": Integer)
    begin
        SetRequestHeader('x-ms-lease-break-period', Format("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-lease-duration' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Integer value specifying the HttpHeader value.</param>
    internal procedure LeaseDuration("Value": Integer)
    begin
        SetRequestHeader('x-ms-lease-duration', Format("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-proposed-lease-id' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Guid value specifying the HttpHeader value.</param>
    internal procedure ProposedLeaseId("Value": Guid)
    begin
        SetRequestHeader('x-ms-proposed-lease-id', "Value");
    end;

    local procedure SetRequestHeader(Header: Text; HeaderValue: Text)
    begin
        RequestHeaders.Remove(Header);
        RequestHeaders.Add(Header, HeaderValue);
    end;

    internal procedure GetRequestHeaders(): Dictionary of [Text, Text]
    begin
        exit(RequestHeaders);
    end;

    #endregion

    #region Parameters

    /// <summary>
    /// Sets the optional timeout value for the request.
    /// </summary>
    /// <param name="Value">Timeout in seconds. Most operations have a max. limit of 30 seconds. For more Information see: https://docs.microsoft.com/en-us/rest/api/storageservices/setting-timeouts-for-blob-service-operations</param>
    procedure Timeout("Value": Integer)
    begin
        SetParameter('timeout', Format("Value"));
    end;

    /// <summary>
    /// The versionid parameter is an opaque DateTime value that, when present, specifies the Version of the blob to retrieve.
    /// </summary>
    /// <param name="Value">The DateTime identifying the version</param>
    procedure VersionId("Value": DateTime)
    begin
        SetParameter('versionid', ABSFormatHelper.GetRfc1123DateTime("Value"));
    end;

    /// <summary>
    /// The snapshot parameter is an opaque DateTime value that, when present, specifies the blob snapshot to retrieve. 
    /// </summary>
    /// <param name="Value">The DateTime identifying the Snapshot</param>
    procedure Snapshot("Value": DateTime)
    begin
        SetParameter('snapshot', ABSFormatHelper.GetRfc1123DateTime("Value"));
    end;

    /// <summary>
    /// The snapshot parameter is an opaque DateTime value that, when present, specifies the blob snapshot to retrieve. 
    /// </summary>
    /// <param name="Value">The DateTime identifying the Snapshot</param>
    procedure Snapshot("Value": Text)
    begin
        SetParameter('snapshot', "Value");
    end;

    /// <summary>
    /// Filters the results to return only blobs whose names begin with the specified prefix.
    /// </summary>
    /// <param name="Value">Prefix to search for</param>
    procedure Prefix("Value": Text)
    begin
        SetParameter('prefix', "Value");
    end;

    /// <summary>
    /// When the request includes this parameter, the operation returns a BlobPrefix element in the response body 
    /// that acts as a placeholder for all blobs with names that begin with the same substring until the delimiter character is reached. 
    /// The delimiter may be a single character or a string.
    /// </summary>
    /// <param name="Value">Delimiting character/string</param>
    procedure Delimiter("Value": Text)
    begin
        SetParameter('delimiter', "Value");
    end;

    /// <summary>
    /// Specifies the maximum number of blobs to return
    /// </summary>
    /// <param name="Value">Max. number of results to return. Must be positive, must not be greater than 5000</param>
    procedure MaxResults("Value": Integer)
    begin
        SetParameter('maxresults', Format("Value"));
    end;

    /// <summary>
    /// Identifiers the ID of a Block in BlockBlob
    /// </summary>
    /// <param name="Value">A valid Base64 string value that identifies the block. Prior to encoding, the string must be less than or equal to 64 bytes</param>
    procedure BlockId("Value": Text)
    begin
        SetParameter('blockid', "Value");
    end;

    local procedure SetParameter(Header: Text; HeaderValue: Text)
    begin
        Parameters.Remove(Header);
        Parameters.Add(Header, HeaderValue);
    end;

    internal procedure GetParameters(): Dictionary of [Text, Text]
    begin
        exit(Parameters);
    end;
    #endregion

    var
        ABSFormatHelper: Codeunit "ABS Format Helper";
        RequestHeaders: Dictionary of [Text, Text];
        Parameters: Dictionary of [Text, Text];
}