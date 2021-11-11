// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9217 "IDA 2D Data Matrix Encoder" implements "Barcode Font Encoder 2D"
{
    Access = Internal;

    procedure EncodeFont(InputText: Text): Text
    var
        DotNetFontEncoder: DotNet DataMatrixFontEncoder;
        NullString: DotNet String;
        EncodingModes: DotNet EncodingModesDM;
        OutputTypes: DotNet OutputTypesDM;
    begin
        DotNetFontEncoder := DotNetFontEncoder.DataMatrix();

        // default options to encode for the fonts we provide.
        exit(DotNetFontEncoder.EncodeDM(InputText, true, EncodingModes::ASCII, -1, OutputTypes::IDA2DFont, NullString));
    end;
}