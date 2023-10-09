// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Azure.Storage;

using System.TestLibraries.Utilities;

codeunit 132921 "ABS Test Library"
{
    Access = Internal;

    var
        Any: Codeunit Any;

    procedure GetSampleTextBlobContent(): Text
    var
        SampleText: Text;
    begin
        SampleText := 'This is just a sample text as content for a text blob.';
        SampleText += GetNewLineCharacter();
        SampleText += 'This is another line for sample content';
        SampleText += GetNewLineCharacter();
        SampleText += 'This is another line for sample content';
        exit(SampleText);
    end;

    procedure GetBlobName(): Text
    begin
        Any.SetSeed(Random(2000));
        Sleep(Any.IntegerInRange(5, 75));
        Any.SetSeed(Random(5000));
        exit(Any.AlphabeticText(Any.IntegerInRange(5, 50)));
    end;

    procedure GetBlobTags(): Dictionary of [Text, Text]
    var
        TagDictionary: Dictionary of [Text, Text];
        i: Integer;
    begin
        for i := 1 to 10 do begin
            Any.SetSeed(Random(2000));
            TagDictionary.Add(
                Any.AlphabeticText(Any.IntegerInRange(1, 10)),
                Any.AlphabeticText(Any.IntegerInRange(1, 50))
            );
        end;

        exit(TagDictionary);
    end;

    procedure GetContainerName(): Text
    begin
        Any.SetSeed(Random(2000));
        Sleep(Any.IntegerInRange(5, 75));
        Any.SetSeed(Random(5000));
        exit(Any.AlphabeticText(Any.IntegerInRange(5, 20)));
    end;

    procedure GetListOfContainerNames(var ContainerNames: List of [Text])
    var
        MaxItems: Integer;
        i: Integer;
    begin
        Clear(ContainerNames);
        Any.SetSeed(Random(5000));
        MaxItems := Any.IntegerInRange(2, 5);
        for i := 1 to MaxItems do
            ContainerNames.Add(GetContainerName());
    end;

    procedure GetListOfBlobNames(var BlobNames: List of [Text])
    var
        MaxItems: Integer;
        i: Integer;
    begin
        Clear(BlobNames);
        Any.SetSeed(Random(5000));
        MaxItems := Any.IntegerInRange(2, 8);
        for i := 1 to MaxItems do
            BlobNames.Add(GetBlobName());
    end;

    procedure GetDefaultBlobServiceProperties(WithSampleCorsRules: Boolean): XmlDocument
    var
        DefaultText: Text;
        Document: XmlDocument;
        Declaration: XmlDeclaration;
    begin
        DefaultText := '<StorageServiceProperties>';
        DefaultText += '  <Logging>';
        DefaultText += '    <Version>1.0</Version>';
        DefaultText += '    <Delete>true</Delete>';
        DefaultText += '    <Read>true</Read>';
        DefaultText += '    <Write>true</Write>';
        DefaultText += '    <RetentionPolicy>';
        DefaultText += '      <Enabled>false</Enabled>';
        DefaultText += '    </RetentionPolicy>';
        DefaultText += '  </Logging>';
        DefaultText += '  <HourMetrics>';
        DefaultText += '    <Version>1.0</Version>';
        DefaultText += '    <Enabled>false</Enabled>';
        DefaultText += '    <RetentionPolicy>';
        DefaultText += '      <Enabled>false</Enabled>';
        DefaultText += '    </RetentionPolicy>';
        DefaultText += '  </HourMetrics>';
        DefaultText += '  <MinuteMetrics>';
        DefaultText += '    <Version>1.0</Version>';
        DefaultText += '    <Enabled>false</Enabled>';
        DefaultText += '    <RetentionPolicy>';
        DefaultText += '      <Enabled>false</Enabled>';
        DefaultText += '    </RetentionPolicy>';
        DefaultText += '  </MinuteMetrics>';
        if not WithSampleCorsRules then
            DefaultText += '  <Cors />'
        else begin
            DefaultText += '  <Cors>';
            DefaultText += '    <CorsRule> ';
            DefaultText += '      <AllowedOrigins>*</AllowedOrigins> ';
            DefaultText += '      <AllowedMethods>GET,PUT</AllowedMethods> ';
            DefaultText += '      <MaxAgeInSeconds>500</MaxAgeInSeconds> ';
            DefaultText += '      <ExposedHeaders>*</ExposedHeaders> ';
            DefaultText += '      <AllowedHeaders>x-ms-meta-target*,x-ms-meta-customheader</AllowedHeaders>   ';
            DefaultText += '    </CorsRule> ';
            DefaultText += '  </Cors>';
        end;
        DefaultText += '  <DefaultServiceVersion>2020-06-12</DefaultServiceVersion>';
        DefaultText += '  <StaticWebsite>';
        DefaultText += '    <Enabled>false</Enabled>';
        DefaultText += '  </StaticWebsite>';
        DefaultText += '</StorageServiceProperties>';
        XmlDocument.ReadFrom(DefaultText, Document);
        Declaration := XmlDeclaration.Create('1.0', 'utf-8', 'yes');
        Document.SetDeclaration(Declaration);
        exit(Document);
    end;

    procedure GetSampleContainerACL(): XmlDocument
    var
        DefaultText: Text;
        Document: XmlDocument;
    begin
        DefaultText := '<?xml version="1.0" encoding="utf-8"?>';
        DefaultText += '<SignedIdentifiers>';
        DefaultText += '  <SignedIdentifier>';
        DefaultText += '    <Id>MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI=</Id>';
        DefaultText += '    <AccessPolicy>';
        DefaultText += '      <Start>2020-09-28T08:49:37.0000000Z</Start>';
        DefaultText += '      <Expiry>2020-09-29T08:49:37.0000000Z</Expiry>';
        DefaultText += '      <Permission>rwd</Permission>';
        DefaultText += '    </AccessPolicy>';
        DefaultText += '  </SignedIdentifier>';
        DefaultText += '</SignedIdentifiers>';
        XmlDocument.ReadFrom(DefaultText, Document);
        exit(Document);
    end;

    procedure GetServiceResponseBlobWithHierarchicalName(): Text;
    var
        Builder: TextBuilder;
    begin
        Builder.Append('<?xml version="1.0" encoding="utf-8"?>');
        Builder.Append('<EnumerationResults ContainerName="https://myaccount.blob.core.windows.net/mycontainer">');
        Builder.Append('<Blobs>');
        Builder.Append('<Blob>');
        Builder.Append('<Name>rootdir/filename.txt</Name>');
        Builder.Append('<Url>https://myaccount.blob.core.windows.net/mycontainer/rootdir/filename.txt</Url>');
        Builder.Append('<Properties>');
        Builder.Append('<Last-Modified>Sat, 23 Sep 2023 21:32:55 GMT</Last-Modified>');
        Builder.Append('<Etag>0x8DBBC7CA6253661</Etag>');
        Builder.Append('<Content-Length>1</Content-Length>');
        Builder.Append('<Content-Type>text/plain</Content-Type>');
        Builder.Append('<Content-Encoding />');
        Builder.Append('<Content-Language />');
        Builder.Append('<Content-MD5>dpT0pmMW5TyM3Z2ZVL1hHQ==</Content-MD5>');
        Builder.Append('<Cache-Control />');
        Builder.Append('<BlobType>BlockBlob</BlobType>');
        Builder.Append('<LeaseStatus>unlocked</LeaseStatus>');
        Builder.Append('</Properties>');
        Builder.Append('</Blob>');
        Builder.Append('</Blobs>');
        Builder.Append('<NextMarker />');
        Builder.Append('</EnumerationResults>');

        exit(Builder.ToText());
    end;

    procedure GetServiceResponseHierarchicalNamespace(): Text;
    var
        Builder: TextBuilder;
    begin
        Builder.Append('<?xml version="1.0" encoding="utf-8"?>');
        Builder.Append('<EnumerationResults ServiceEndpoint="https://myaccount.blob.core.windows.net/" ContainerName="mycontainer">');
        Builder.Append('<Blobs>');
        Builder.Append('<Blob>');
        Builder.Append('<Name>rootdir</Name>');
        Builder.Append('<Properties>');
        Builder.Append('<Creation-Time>Sat, 23 Sep 2023 21:04:18 GMT</Creation-Time>');
        Builder.Append('<Last-Modified>Sat, 23 Sep 2023 21:04:18 GMT</Last-Modified>');
        Builder.Append('<Etag>0x8DBBC78A6E95AF7</Etag>');
        Builder.Append('<ResourceType>directory</ResourceType>');
        Builder.Append('<Content-Length>0</Content-Length>');
        Builder.Append('<Content-Type>application/octet-stream</Content-Type>');
        Builder.Append('<Content-Encoding />');
        Builder.Append('<Content-Language />');
        Builder.Append('<Content-CRC64>AAAAAAAAAAA=</Content-CRC64>');
        Builder.Append('<Content-MD5 />');
        Builder.Append('<Cache-Control />');
        Builder.Append('<Content-Disposition />');
        Builder.Append('<BlobType>BlockBlob</BlobType>');
        Builder.Append('<AccessTier>Hot</AccessTier>');
        Builder.Append('<AccessTierInferred>true</AccessTierInferred>');
        Builder.Append('<LeaseStatus>unlocked</LeaseStatus>');
        Builder.Append('<LeaseState>available</LeaseState>');
        Builder.Append('<ServerEncrypted>true</ServerEncrypted>');
        Builder.Append('</Properties>');
        Builder.Append('<OrMetadata />');
        Builder.Append('</Blob>');
        Builder.Append('<Blob>');
        Builder.Append('<Name>rootdir/subdirectory</Name>');
        Builder.Append('<Properties>');
        Builder.Append('<Creation-Time>Tue, 26 Sep 2023 21:47:48 GMT</Creation-Time>');
        Builder.Append('<Last-Modified>Tue, 26 Sep 2023 21:47:48 GMT</Last-Modified>');
        Builder.Append('<Etag>0x8DBBEDA39F9C41D</Etag>');
        Builder.Append('<ResourceType>directory</ResourceType>');
        Builder.Append('<Content-Length>0</Content-Length>');
        Builder.Append('<Content-Type>application/octet-stream</Content-Type>');
        Builder.Append('<Content-Encoding />');
        Builder.Append('<Content-Language />');
        Builder.Append('<Content-CRC64>AAAAAAAAAAA=</Content-CRC64>');
        Builder.Append('<Content-MD5 />');
        Builder.Append('<Cache-Control />');
        Builder.Append('<Content-Disposition />');
        Builder.Append('<BlobType>BlockBlob</BlobType>');
        Builder.Append('<AccessTier>Hot</AccessTier>');
        Builder.Append('<AccessTierInferred>true</AccessTierInferred>');
        Builder.Append('<LeaseStatus>unlocked</LeaseStatus>');
        Builder.Append('<LeaseState>available</LeaseState>');
        Builder.Append('<ServerEncrypted>true</ServerEncrypted>');
        Builder.Append('</Properties>');
        Builder.Append('<OrMetadata />');
        Builder.Append('</Blob>');
        Builder.Append('<Blob>');
        Builder.Append('<Name>rootdir/subdirectory/filename.txt</Name>');
        Builder.Append('<Properties>');
        Builder.Append('<Creation-Time>Wed, 27 Sep 2023 20:24:18 GMT</Creation-Time>');
        Builder.Append('<Last-Modified>Wed, 27 Sep 2023 20:24:18 GMT</Last-Modified>');
        Builder.Append('<Etag>0x8DBBF97BA4A9839</Etag>');
        Builder.Append('<ResourceType>file</ResourceType>');
        Builder.Append('<Content-Length>1</Content-Length>');
        Builder.Append('<Content-Type>text/plain</Content-Type>');
        Builder.Append('<Content-Encoding />');
        Builder.Append('<Content-Language />');
        Builder.Append('<Content-CRC64 />');
        Builder.Append('<Content-MD5>dpT0pmMW5TyM3Z2ZVL1hHQ==</Content-MD5>');
        Builder.Append('<Cache-Control />');
        Builder.Append('<Content-Disposition />');
        Builder.Append('<BlobType>BlockBlob</BlobType>');
        Builder.Append('<AccessTier>Hot</AccessTier>');
        Builder.Append('<AccessTierInferred>true</AccessTierInferred>');
        Builder.Append('<LeaseStatus>unlocked</LeaseStatus>');
        Builder.Append('<LeaseState>available</LeaseState>');
        Builder.Append('<ServerEncrypted>true</ServerEncrypted>');
        Builder.Append('</Properties>');
        Builder.Append('<OrMetadata />');
        Builder.Append('</Blob>');
        Builder.Append('</Blobs>');
        Builder.Append('<NextMarker />');
        Builder.Append('</EnumerationResults>');

        exit(Builder.ToText());
    end;

    procedure GetSampleResponseRootDirName(): Text
    begin
        exit('rootdir');
    end;

    procedure GetSampleResponseSubdirName(): Text
    begin
        exit('subdirectory');
    end;

    procedure GetSampleResponseFileName(): Text
    begin
        exit('filename.txt');
    end;

    local procedure GetNewLineCharacter(): Text
    var
        LF: Char;
    begin
        LF := 10;
        exit(Format(LF));
    end;
}