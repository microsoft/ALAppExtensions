// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Sales.History;
using System.Text;
using System.Utilities;
using System.IO;

page 6169 "E-Document QR Code Viewer"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'QR Code Viewer';
    SourceTable = "Sales Invoice Header";

    layout
    {
        area(Content)
        {
            field(QRCodeBase64Preview; QRCodePreviewTxt)
            {
                ApplicationArea = All;
                Caption = 'QR Code (preview)';
                Editable = false;

                trigger OnDrillDown()
                begin
                    ExportQRCodeToFile();
                end;
            }
            field(QRImage; Rec."QR Code Image")
            {
                ApplicationArea = All;
                Caption = 'QR Code Image';
                ToolTip = 'Image about the QR code';
                Editable = false;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ExportQRCode)
            {
                ApplicationArea = All;
                Caption = 'Export QR Code';
                Image = Export;
                ToolTip = 'Export QR code image to file';

                trigger OnAction()
                begin
                    ExportQRCodeToFile();
                end;
            }

            action(GenerateQRCodeImage)
            {
                ApplicationArea = All;
                Caption = 'Generate QR Image';
                ToolTip = 'Generate image from Base64';

                trigger OnAction()
                begin
                    SetQRCodeImageFromBase64();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        InStr: InStream;
    begin
        Clear(QRCodePreviewTxt);
        Rec.CalcFields("QR Code Base64");
        if Rec."QR Code Base64".HasValue then begin
            Rec."QR Code Base64".CreateInStream(InStr, TextEncoding::UTF8);
            InStr.ReadText(QRCodePreviewTxt);
            if StrLen(QRCodePreviewTxt) > MaxStrLen(QRCodePreviewTxt) then
                QRCodePreviewTxt := CopyStr(QRCodePreviewTxt, 1, MaxStrLen(QRCodePreviewTxt) - StrLen('...')) + '...';
        end;

        SetQRCodeImageFromBase64();
    end;

    local procedure ExportQRCodeToFile()
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        OutStream: OutStream;
        InStream: InStream;
        Base64Txt: Text;
        FileNameLbl: Label 'Invoice %1 QR Code.png', Locked = true;
    begin
        Rec.CalcFields("QR Code Base64");
        if not Rec."QR Code Base64".HasValue then
            exit;

        Rec."QR Code Base64".CreateInStream(InStream, TextEncoding::UTF8);
        InStream.ReadText(Base64Txt);

        if Base64Txt = '' then
            exit;

        TempBlob.CreateOutStream(OutStream);
        Base64Convert.FromBase64(Base64Txt, OutStream);

        FileMgt.BLOBExport(TempBlob, StrSubstNo(FileNameLbl, Rec."No."), true);
    end;

    local procedure SetQRCodeImageFromBase64()
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
        Base64Txt: Text;
    begin
        Rec.CalcFields("QR Code Base64");
        if not Rec."QR Code Base64".HasValue then
            exit;

        Rec."QR Code Base64".CreateInStream(InStream, TextEncoding::UTF8);
        InStream.ReadText(Base64Txt);

        if Base64Txt = '' then
            exit;

        TempBlob.CreateOutStream(OutStream);
        Base64Convert.FromBase64(Base64Txt, OutStream);

        TempBlob.CreateInStream(InStream);
        Rec."QR Code Image".ImportStream(InStream, 'image/png');
        Rec.Modify();
    end;

    var
        QRCodePreviewTxt: Text[250];
}
