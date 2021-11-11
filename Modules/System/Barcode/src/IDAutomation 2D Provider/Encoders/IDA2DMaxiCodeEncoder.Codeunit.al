// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9218 "IDA 2D Maxi Code Encoder" implements "Barcode Font Encoder 2D"
{
    Access = Internal;

    procedure EncodeFont(InputText: Text): Text
    var
        DotNetFontEncoder: DotNet MaxiCodeFontEncoder;
        NullString: DotNet String;
        EncodingModes: DotNet EncodingModesMaxiCode;
    begin
        DotNetFontEncoder := DotNetFontEncoder.MaxiCode();

        // default options to encode for the fonts we provide.
        exit(DotNetFontEncoder.EncodeMaxiCode(InputText, true, EncodingModes::Mode2, NullString));
    end;
}