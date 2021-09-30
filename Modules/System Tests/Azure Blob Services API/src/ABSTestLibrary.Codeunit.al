// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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

    local procedure GetNewLineCharacter(): Text
    var
        LF: Char;
    begin
        LF := 10;
        exit(Format(LF));
    end;
}