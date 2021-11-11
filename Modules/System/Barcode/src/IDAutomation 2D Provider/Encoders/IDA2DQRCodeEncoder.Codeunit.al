// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9220 "IDA 2D QR-Code Encoder" implements "Barcode Font Encoder 2D"
{
    Access = Internal;

    procedure EncodeFont(InputText: Text): Text
    var
        DotNetFontEncoder: DotNet QRCodeFontEncoder;
        NullString: DotNet String;
        EncodingModes: DotNet EncodingModesQR;
        OutputTypes: DotNet OutputTypesQR;
        Versions: DotNet VersionsQR;
        ErrorCorrectionLevels: DotNet ErrorCorrectionLevelsQR;
    begin
        DotNetFontEncoder := DotNetFontEncoder.QRCode();

        // default options to encode for the fonts we provide.
        exit(DotNetFontEncoder.EncodeQR(InputText, true, EncodingModes::Byte, Versions::AUTO, ErrorCorrectionLevels::M, OutputTypes::IDA2DFont, true, NullString, false));
    end;
}