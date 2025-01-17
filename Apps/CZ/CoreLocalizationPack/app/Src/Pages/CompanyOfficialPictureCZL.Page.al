// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Company;

using System.Device;
using System.IO;
using System.Utilities;

#pragma implicitwith disable
page 11738 "Company Official Picture CZL"
{
    Caption = 'Company Official Picture';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    SourceTable = "Company Official CZL";

    layout
    {
        area(content)
        {
            field(Image; Rec.Image)
            {
                ApplicationArea = Basic, Suite;
                ShowCaption = false;
                ToolTip = 'Specifies the picture of the company official.';
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(TakePicture)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Take';
                Image = Camera;
                ToolTip = 'Activate the camera on the device.';
                Visible = CameraAvailable;

                trigger OnAction()
                begin
                    TakeNewPicture();
                end;
            }
            action(ImportPicture)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import a picture file.';
                Ellipsis = true;

                trigger OnAction()
                var
                    FromFileName: Text;
                    InStr: InStream;
                begin
                    Rec.TestField("No.");
                    Rec.TestField("First Name");
                    Rec.TestField("Last Name");
                    if Rec.Image.HasValue() then
                        if not ConfirmManagement.GetResponseOrDefault(OverrideImageQst, true) then
                            exit;
                    FromFileName := FileManagement.BLOBImport(TempBlob, ImageExtensionTok);
                    if FromFileName = '' then
                        exit;
                    TempBlob.CreateInStream(InStr);
                    Rec.Image.ImportStream(InStr, Rec."First Name" + ' ' + Rec."Last Name");
                    Rec.Modify(true);
                end;
            }
            action(ExportFile)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Export';
                Enabled = DeleteExportEnabled;
                Image = Export;
                ToolTip = 'Export the picture to a file.';

                trigger OnAction()
                var
                    ToFileName: Text;
                    OutStr: OutStream;
                begin
                    Rec.TestField("No.");
                    Rec.TestField("First Name");
                    Rec.TestField("Last Name");
                    if Rec.Image.HasValue() then begin
                        TempBlob.CreateOutStream(OutStr);
                        Rec.Image.ExportStream(OutStr);
                        ToFileName := Rec."First Name" + ' ' + Rec."Last Name" + ImageExtensionTok;
                        FileManagement.BLOBExport(TempBlob, ToFileName, true);
                    end;
                end;
            }
            action(DeletePicture)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Delete';
                Enabled = DeleteExportEnabled;
                Image = Delete;
                ToolTip = 'Delete the record.';
                Ellipsis = true;

                trigger OnAction()
                begin
                    Rec.TestField("No.");
                    if not ConfirmManagement.GetResponseOrDefault(DeleteImageQst, false) then
                        exit;
                    Clear(Rec.Image);
                    Rec.Modify(true);
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        SetEditableOnPictureActions();
    end;

    trigger OnOpenPage()
    begin
        CameraAvailable := Camera.IsAvailable();
    end;

    var
        ConfirmManagement: Codeunit "Confirm Management";
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        Camera: Codeunit Camera;
        CameraAvailable: Boolean;
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
        DeleteImageQst: Label 'Are you sure you want to delete the picture?';
        DeleteExportEnabled: Boolean;
        ImageExtensionTok: Label '.png', Locked = true;
        MimeTypeTok: Label 'image/jpeg', Locked = true;

    local procedure SetEditableOnPictureActions()
    begin
        DeleteExportEnabled := Rec.Image.HasValue();
    end;

    local procedure TakeNewPicture()
    var
        PictureInstream: InStream;
        PictureDescription: Text;
    begin
        Rec.TestField("No.");

        if Rec.Image.HasValue() then
            if not Confirm(OverrideImageQst) then
                exit;

        if Camera.GetPicture(PictureInstream, PictureDescription) then begin
            Clear(Rec.Image);
            Rec.Image.ImportStream(PictureInstream, PictureDescription, MimeTypeTok);
            Rec.Modify(true)
        end;
    end;
}
