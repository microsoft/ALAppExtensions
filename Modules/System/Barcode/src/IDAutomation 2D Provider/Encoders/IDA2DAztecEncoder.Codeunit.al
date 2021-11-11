// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9216 "IDA 2D Aztec Encoder" implements "Barcode Font Encoder 2D"
{
    Access = Internal;

    procedure EncodeFont(InputText: Text): Text
    var
        DotNetFontEncoder: DotNet AztecFontEncoder;
        NullString: DotNet String;
        EncodingModes: DotNet EncodingModesAztec;
        OutputTypes: DotNet OutputTypesAztec;
    begin
        DotNetFontEncoder := DotNetFontEncoder.Aztec();

        // default options to encode for the fonts we provide.
        exit(DotNetFontEncoder.EncodeAztec(InputText, true, EncodingModes::Auto, 0, OutputTypes::IDA2DFont, NullString));
    end;
}