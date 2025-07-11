// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;
using System.Utilities;
using System.IO;

page 6111 "Inbound E-Doc. Picture"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    Extensible = false;
    PageType = CardPart;
    SourceTable = "E-Doc. Data Storage";

    layout
    {
        area(content)
        {
            field(Picture; TempMediaRepository.Image)
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the picture';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        LoadPdfImage();
    end;

    local procedure LoadPdfImage()
    var
        PdfDocument: Codeunit "PDF Document";
        TempBlob: Codeunit "Temp Blob";
        PdfStream, ImageStream : InStream;
        EDocDataStorageImageDescriptionLbl: Label 'Pdf Preview';
    begin
        if Rec."Entry No." <> xRec."Entry No." then
            PdfLoaded := false;

        if Rec."File Format" <> Enum::"E-Doc. File Format"::PDF then
            exit;

        if PdfLoaded then
            exit;


        Rec.CalcFields("Data Storage");
        Rec."Data Storage".CreateInStream(PdfStream, TextEncoding::UTF8);
        if PdfDocument.Load(PdfStream) then begin
            TempBlob.CreateInStream(ImageStream, TextEncoding::UTF8);
            PdfDocument.ConvertToImage(ImageStream, "Image Format"::Png, 1);
            TempMediaRepository.Image.ImportStream(ImageStream, EDocDataStorageImageDescriptionLbl, 'image/png');
        end;
    end;

    var
        TempMediaRepository: Record "Media Repository" temporary;
        PdfLoaded: Boolean;

}

