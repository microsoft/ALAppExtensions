// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Holds procedures to format headers and parameters to be used in requests.
/// </summary>
codeunit 8956 "AFS Optional Parameters"
{
    Access = Public;

    var
        AFSFormatHelper: Codeunit "AFS Format Helper";
        RequestHeaders: Dictionary of [Text, Text];
        Parameters: Dictionary of [Text, Text];

    /// <summary>
    /// Sets the value for 'x-ms-range' HttpHeader for a request.
    /// </summary>
    /// <param name="BytesStartValue">Integer value specifying the Bytes start range value</param>
    /// <param name="BytesEndValue">Integer value specifying the Bytes end range value</param>
    procedure Range(BytesStartValue: Integer; BytesEndValue: Integer)
    var
        RangeBytesLbl: Label 'bytes=%1-%2', Comment = '%1 = Start Range; %2 = End Range', Locked = true;
    begin
        SetRequestHeader('x-ms-range', StrSubstNo(RangeBytesLbl, BytesStartValue, BytesEndValue));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-write' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Enum "AFS Write" value specifying the HttpHeader value</param>
    procedure Write("Value": Enum "AFS Write")
    begin
        SetRequestHeader('x-ms-write', Format("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-lease-id' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Guid value specifying the LeaseID</param>
    procedure LeaseId("Value": Guid)
    begin
        SetRequestHeader('x-ms-lease-id', AFSFormatHelper.RemoveCurlyBracketsFromString(Format("Value").ToLower()));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-lease-action' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Enum "AFS Lease Action" value specifying the LeaseAction</param>
    internal procedure LeaseAction("Value": Enum "AFS Lease Action")
    begin
        SetRequestHeader('x-ms-lease-action', Format("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-lease-duration' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Integer value specifying the LeaseDuration in seconds</param>
    procedure LeaseDuration("Value": Integer)
    begin
        SetRequestHeader('x-ms-lease-duration', Format("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-proposed-lease-id' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Guid value specifying the ProposedLeaseId in seconds</param>
    procedure ProposedLeaseId("Value": Guid)
    begin
        SetRequestHeader('x-ms-proposed-lease-id', AFSFormatHelper.RemoveCurlyBracketsFromString(Format("Value").ToLower()));
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
    /// Sets the value for 'x-ms-file-last-write-time' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Enum "AFS File Last Write Time" value specifying the HttpHeader value</param>
    procedure FileLastWriteTime("Value": Enum "AFS File Last Write Time")
    begin
        SetRequestHeader('x-ms-file-last-write-time', Format("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-file-request-intent' HttpHeader for a request, 'backup' is an acceptable value.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure FileRequestIntent("Value": Text)
    begin
        SetRequestHeader('x-ms-file-request-intent', "Value");
    end;

    /// <summary>
    /// Sets the value for 'x-ms-file-permission' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure FilePermission("Value": Text)
    begin
        SetRequestHeader('x-ms-file-permission', "Value");
    end;

    /// <summary>
    /// Sets the value for 'x-ms-file-permission-key' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure FilePermissionKey("Value": Text)
    begin
        SetRequestHeader('x-ms-file-permission-key', "Value");
    end;

    /// <summary>
    /// Sets the value for 'x-ms-file-attributes' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure FileAttributes("Value": List of [Enum "AFS File Attribute"])
    var
        FileAttribute: Enum "AFS File Attribute";
        ValueText: Text;
    begin
        foreach FileAttribute in "Value" do
            ValueText += Format(FileAttribute) + ',';
        ValueText := ValueText.TrimEnd(',');

        SetRequestHeader('x-ms-file-attributes', ValueText);
    end;

    /// <summary>
    /// Sets the value for 'x-ms-file-creation-time' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Datetime of the file creation</param>
    procedure FileCreationTime("Value": DateTime)
    begin
        SetParameter('x-ms-file-creation-time', AFSFormatHelper.GetRfc1123DateTime("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-file-last-write-time' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Datetime of the file last write time</param>
    procedure FileLastWriteTime("Value": DateTime)
    begin
        SetParameter('x-ms-file-last-write-time', AFSFormatHelper.GetRfc1123DateTime("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-file-change-time' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Datetime of the file last change time</param>
    procedure FileChangeTime("Value": DateTime)
    begin
        SetParameter('x-ms-file-change-time', AFSFormatHelper.GetRfc1123DateTime("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-meta-name' HttpHeader for a request. name should adhere to C# identifiers naming convention.
    /// </summary>
    /// <param name="Key">Text value specifying the metadata name key</param>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure Meta("Key": Text; "Value": Text)
    begin
        SetRequestHeader('x-ms-meta-' + "Key", "Value");
    end;

    /// <summary>
    /// Sets the value for 'x-ms-file-permission-copy-mode' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Enum "AFS File Permission Copy Mode" value specifying the HttpHeader value</param>
    procedure FilePermissionCopyMode("Value": Enum "AFS File Permission Copy Mode")
    begin
        SetRequestHeader('x-ms-file-permission-copy-mode', Format("Value"));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-copy-source' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Text value specifying the HttpHeader value</param>
    procedure CopySource("Value": Text)
    begin
        SetRequestHeader('x-ms-copy-source', "Value");
    end;

    /// <summary>
    /// Sets the value for 'x-ms-allow-trailing-dot' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Boolean value specifying the HttpHeader value</param>
    procedure AllowTrailingDot("Value": Boolean)
    var
        ValueText: Text;
    begin
        // Set as text, because otherwise it might give different formatted values based on language locale
        ValueText := ConvertBooleanToText("Value");

        SetRequestHeader('x-ms-allow-trailing-dot', ValueText);
    end;

    /// <summary>
    /// Sets the value for 'x-ms-file-rename-replace-if-exists' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Boolean value specifying the HttpHeader value</param>
    procedure FileRenameReplaceIfExists("Value": Boolean)
    var
        ValueText: Text;
    begin
        // Set as text, because otherwise it might give different formatted values based on language locale
        ValueText := ConvertBooleanToText("Value");

        SetRequestHeader('x-ms-file-rename-replace-if-exists', ValueText);
    end;

    /// <summary>
    /// Sets the value for 'x-ms-file-rename-ignore-readonly' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Boolean value specifying the HttpHeader value</param>
    procedure FileRenameIgnoreReadOnly("Value": Boolean)
    var
        ValueText: Text;
    begin
        // Set as text, because otherwise it might give different formatted values based on language locale
        ValueText := ConvertBooleanToText("Value");

        SetRequestHeader('x-ms-file-rename-ignore-readonly', ValueText);
    end;

    /// <summary>
    /// Sets the value for 'x-ms-source-lease-id' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Guid value specifying the SourceLeaseID</param>
    procedure SourceLeaseId("Value": Guid)
    begin
        SetRequestHeader('x-ms-source-lease-id', AFSFormatHelper.RemoveCurlyBracketsFromString(Format("Value").ToLower()));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-destination-lease-id' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Guid value specifying the DestinationLeaseID</param>
    procedure DestinationLeaseId("Value": Guid)
    begin
        SetRequestHeader('x-ms-destination-lease-id', AFSFormatHelper.RemoveCurlyBracketsFromString(Format("Value").ToLower()));
    end;

    /// <summary>
    /// Sets the value for 'x-ms-file-copy-ignore-readonly' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Boolean value specifying the HttpHeader value</param>
    procedure FileCopyIgnoreReadOnly("Value": Boolean)
    var
        ValueText: Text;
    begin
        // Set as text, because otherwise it might give different formatted values based on language locale
        ValueText := ConvertBooleanToText("Value");

        SetRequestHeader('x-ms-file-copy-ignore-readonly', ValueText);
    end;

    /// <summary>
    /// Sets the value for 'x-ms-file-copy-set-archive' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Boolean value specifying the HttpHeader value</param>
    procedure FileCopySetArchive("Value": Boolean)
    var
        ValueText: Text;
    begin
        // Set as text, because otherwise it might give different formatted values based on language locale
        ValueText := ConvertBooleanToText("Value");

        SetRequestHeader('x-ms-file-copy-set-archive', ValueText);
    end;

    /// <summary>
    /// Sets the value for 'x-ms-file-extended-info' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Boolean value specifying the HttpHeader value</param>
    procedure FileExtendedInfo("Value": Boolean)
    var
        ValueText: Text;
    begin
        // Set as text, because otherwise it might give different formatted values based on language locale
        ValueText := ConvertBooleanToText("Value");

        SetRequestHeader('x-ms-file-extended-info', ValueText);
    end;

    /// <summary>
    /// Sets the value for 'x-ms-range-get-content-md5' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Boolean value specifying the HttpHeader value</param>
    procedure RangeGetContentMD5("Value": Boolean)
    var
        ValueText: Text;
    begin
        // Set as text, because otherwise it might give different formatted values based on language locale
        ValueText := ConvertBooleanToText("Value");

        SetRequestHeader('x-ms-range-get-content-md5', ValueText);
    end;

    /// <summary>
    /// Sets the value for 'x-ms-recursive' HttpHeader for a request.
    /// </summary>
    /// <param name="Value">Boolean value specifying the HttpHeader value</param>
    procedure Recursive("Value": Boolean)
    var
        ValueText: Text;
    begin
        // Set as text, because otherwise it might give different formatted values based on language locale
        ValueText := ConvertBooleanToText("Value");

        SetRequestHeader('x-ms-recursive', ValueText);
    end;

    /// <summary>
    /// Sets the optional timeout value for the request.
    /// </summary>
    /// <param name="Value">Timeout in seconds. Most operations have a max. limit of 30 seconds. For more Information see: https://go.microsoft.com/fwlink/?linkid=2210591</param>
    procedure Timeout("Value": Integer)
    begin
        SetParameter('timeout', Format("Value"));
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
    /// Specifies the share snapshot to query for the list of files and directories.
    /// </summary>
    /// <param name="Value">Datetime of the snapshot to query</param>
    procedure ShareSnapshot("Value": DateTime)
    begin
        SetParameter('sharesnapshot', AFSFormatHelper.GetRfc1123DateTime("Value"));
    end;

    /// <summary>
    /// A string value that identifies the portion of the list to be returned with the next list operation.
    /// </summary>
    /// <param name="Value">Text marker that was returned in previous operation</param>
    procedure Marker("Value": Text)
    begin
        SetParameter('marker', "Value");
    end;

    /// <summary>
    /// Specifies the maximum number of files or directories to return
    /// </summary>
    /// <param name="Value">Max. number of results to return. Must be positive, must not be greater than 5000</param>
    procedure MaxResults("Value": Integer)
    begin
        SetParameter('maxresults', Format("Value"));
    end;

    /// <summary>
    /// Specifies one or more properties to include in the response.
    /// </summary>
    /// <param name="Value">List of properties to include.</param>
    procedure Include("Value": List of [Enum "AFS Properties"])
    var
        Property: Enum "AFS Properties";
        ValueText: Text;
    begin
        foreach Property in "Value" do
            ValueText += Format(Property) + ',';
        ValueText := ValueText.TrimEnd(',');

        SetParameter('include', ValueText);
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

    local procedure SetParameter(Header: Text; HeaderValue: Text)
    begin
        Parameters.Remove(Header);
        Parameters.Add(Header, HeaderValue);
    end;

    local procedure ConvertBooleanToText("Value": Boolean) ValueText: Text
    begin
        if "Value" then
            ValueText := 'true'
        else
            ValueText := 'false';
    end;

    internal procedure GetParameters(): Dictionary of [Text, Text]
    begin
        exit(Parameters);
    end;
}