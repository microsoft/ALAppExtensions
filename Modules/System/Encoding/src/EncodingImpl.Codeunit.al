// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1486 "Encoding Impl."
{
    Access = Internal;

    procedure Convert(SrcCodepage: Integer; DstCodepage: Integer; Text: Text) ConvertedText: Text
    var
        Encoding: DotNet Encoding;
        SrcEncoding: DotNet Encoding;
        DstEncoding: DotNet Encoding;
        SrcBytes: DotNet Array;
        DstBytes: DotNet Array;
    begin
        SrcEncoding := Encoding.GetEncoding(SrcCodepage);
        DstEncoding := Encoding.GetEncoding(DstCodepage);

        SrcBytes := SrcEncoding.GetBytes(Text);
        DstBytes := Encoding.Convert(SrcEncoding, DstEncoding, SrcBytes);
        ConvertedText := DstEncoding.GetString(DstBytes);
    end;
}