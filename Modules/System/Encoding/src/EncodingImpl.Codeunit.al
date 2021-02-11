// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1487 "Encoding Impl."
{
    Access = Internal;

    procedure Convert(SourceCodepage: Integer; DestinationCodepage: Integer; Text: Text) ConvertedText: Text
    var
        Encoding: DotNet Encoding;
        SourceEncoding: DotNet Encoding;
        DestinationEncoding: DotNet Encoding;
        SourceBytes: DotNet Array;
        DestinationBytes: DotNet Array;
    begin
        SourceEncoding := Encoding.GetEncoding(SourceCodepage);
        DestinationEncoding := Encoding.GetEncoding(DestinationCodepage);

        SourceBytes := SourceEncoding.GetBytes(Text);
        DestinationBytes := Encoding.Convert(SourceEncoding, DestinationEncoding, SourceBytes);
        ConvertedText := DestinationEncoding.GetString(DestinationBytes);
    end;
}