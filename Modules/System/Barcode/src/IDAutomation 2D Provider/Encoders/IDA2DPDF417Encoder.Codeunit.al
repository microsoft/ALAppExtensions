// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9219 "IDA 2D PDF417 Encoder" implements "Barcode Font Encoder 2D"
{
    Access = Internal;

    procedure EncodeFont(InputText: Text): Text
    var
        DotNetFontEncoder: DotNet PDF417FontEncoder;
        NullString: DotNet String;
        EncodingModes: DotNet EncodingModesPDF417;
        OutputTypes: DotNet OutputTypesPDF417;
    begin
        DotNetFontEncoder := DotNetFontEncoder.PDF417();

        // default options to encode for the fonts we provide.
        exit(DotNetFontEncoder.EncodePDF417(InputText, true, 0, EncodingModes::Binary, 0, 0, false, OutputTypes::IDA2DFont, NullString));
    end;
}