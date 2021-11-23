// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Converts text to its qr code representation.
/// </summary>
codeunit 2890 "QR Code"
{
    Access = Public;
    SingleInstance = true;

    var
        QRCodeImpl: Codeunit "QR Code Impl.";

    /// <summary>
    /// Converts the value of the input string to its equivalent QR Code representation.
    /// </summary>
    /// <param name="SourceText">The string to convert.</param>
    /// <param name="QRCodeImageTempBlob">The TempBlob where the QR code is written to.</param>
    /// <param name="ErrorCorrectionLevel">The Error Correction Level.</param>
    /// <param name="ModuleSize">Module Size of the QR Code.</param>
    /// <param name="QuiteZoneWidth">Quite Zone Width of the QR Code.</param>
    /// <param name="CodePage">CodePage to use.</param>
    /// <returns>Creation succesfull.</returns>
    procedure GenerateQRCodeImage(SourceText: Text; QRCodeImageTempBlob: Codeunit "Temp Blob"; ErrorCorrectionLevel: Enum "QR Code Error Correction Level"; ModuleSize: Integer; QuiteZoneWidth: Integer; CodePage: Integer): Boolean
    begin
        exit(QRCodeImpl.GenerateQRCodeImage(SourceText, QRCodeImageTempBlob, ErrorCorrectionLevel, ModuleSize, QuiteZoneWidth, CodePage));
    end;

    /// <summary>
    /// Converts the value of the input string to its equivalent QR Code representation.
    /// </summary>
    /// <param name="SourceText">The string to convert.</param>
    /// <param name="QRCodeImageTempBlob">The TempBlob where the QR code is written to.</param>
    /// <param name="ErrorCorrectionLevel">The Error Correction Level.</param>
    /// <param name="ModuleSize">Module Size of the QR Code.</param>
    /// <param name="QuiteZoneWidth">Quite Zone Width of the QR Code.</param>
    /// <returns>Creation succesfull.</returns>
    procedure GenerateQRCodeImage(SourceText: Text; QRCodeImageTempBlob: Codeunit "Temp Blob"; ErrorCorrectionLevel: Enum "QR Code Error Correction Level"; ModuleSize: Integer; QuiteZoneWidth: Integer): Boolean
    begin
        exit(QRCodeImpl.GenerateQRCodeImage(SourceText, QRCodeImageTempBlob, ErrorCorrectionLevel, ModuleSize, QuiteZoneWidth, 932));
    end;

    /// <summary>
    /// Converts the value of the input string to its equivalent QR Code representation.
    /// </summary>
    /// <param name="SourceText">The string to convert.</param>
    /// <param name="QRCodeImageTempBlob">The TempBlob where the QR code is written to.</param>
    /// <param name="ErrorCorrectionLevel">The Error Correction Level.</param>
    /// <param name="ModuleSize">Module Size of the QR Code.</param>
    /// <returns>Creation succesfull.</returns>
    procedure GenerateQRCodeImage(SourceText: Text; QRCodeImageTempBlob: Codeunit "Temp Blob"; ErrorCorrectionLevel: Enum "QR Code Error Correction Level"; ModuleSize: Integer): Boolean
    begin
        exit(QRCodeImpl.GenerateQRCodeImage(SourceText, QRCodeImageTempBlob, ErrorCorrectionLevel, ModuleSize, 0, 932));
    end;

    /// <summary>
    /// Converts the value of the input string to its equivalent QR Code representation.
    /// </summary>
    /// <param name="SourceText">The string to convert.</param>
    /// <param name="QRCodeImageTempBlob">The TempBlob where the QR code is written to.</param>
    /// <returns>Creation succesfull.</returns>
    procedure GenerateQRCodeImage(SourceText: Text; QRCodeImageTempBlob: Codeunit "Temp Blob"): Boolean
    var
        ErrorCorrectionLevel: Enum "QR Code Error Correction Level";
    begin
        exit(QRCodeImpl.GenerateQRCodeImage(SourceText, QRCodeImageTempBlob, ErrorCorrectionLevel::Medium, 5, 0, 932));
    end;
}
