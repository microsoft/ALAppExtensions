// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1922 "Camera Impl."
{
    Access = Internal;

    var
        Camera: Page Camera;
        PictureFileNameTok: Label 'Picture_%1.jpeg', Comment = '%1 = String generated from current datetime to make sure file names are unique ';
#if not CLEAN20        
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
        UnsupportedFieldTypeErr: Label 'The field type %1 is not supported.', Comment = '%1 - The type of the field', Locked = true;
#endif        

    procedure GetPicture(PictureInStream: InStream; var PictureName: Text): Boolean
    var
        WasPictureTaken: Boolean;
    begin
        if not IsAvailable() then
            exit(false);

        Clear(Camera);

        Camera.SetQuality(100); // 100%
        Camera.RunModal();
        if Camera.HasPicture() then begin
            Camera.GetPicture(PictureInStream);
            PictureName := StrSubstNo(PictureFileNameTok, Format(CurrentDateTime(), 0, '<Day,2>_<Month,2>_<Year4>_<Hours24>_<Minutes,2>_<Seconds,2>'));
            WasPictureTaken := true;
        end;

        exit(WasPictureTaken);
    end;

#if not CLEAN20
    procedure AddPicture(RecordVariant: Variant; FieldNo: Integer): Boolean
    var
#pragma warning disable AA0073
        TempMedia: Record "Temp Media" temporary;
#pragma warning restore AA0073
        RecordWithMediaRef: RecordRef;
        MediaFieldRef: FieldRef;
        PictureInStream: InStream;
        PictureName: Text;
    begin
        if not IsAvailable() then
            exit(false);

        RecordWithMediaRef.GetTable(RecordVariant);
        MediaFieldRef := RecordWithMediaRef.Field(FieldNo);

        if not (MediaFieldRef.Type in [FieldType::Media, FieldType::MediaSet]) then
            Error(UnsupportedFieldTypeErr, MediaFieldRef.Type);

        if not GetPicture(PictureInStream, PictureName) then
            exit(false);

        if not IsNullGuid(MediaFieldRef.Value) then
            if not Confirm(OverrideImageQst) then
                exit(false);

        case MediaFieldRef.Type of
            FieldType::Media:
                begin
                    TempMedia.Media.ImportStream(PictureInStream, PictureName, 'image/jpeg');
                    MediaFieldRef.Value := TempMedia.Media;
                end;
            FieldType::MediaSet:
                begin
                    TempMedia.MediaSet.ImportStream(PictureInStream, PictureName, 'image/jpeg');
                    MediaFieldRef.Value := TempMedia.MediaSet;
                end;
        end;

        if not RecordWithMediaRef.Modify(true) then
            RecordWithMediaRef.Insert(true);

        exit(true);
    end;
#endif

    procedure IsAvailable(): Boolean
    begin
        if GuiAllowed() then
            exit(Camera.IsAvailable());
        exit(false);
    end;
}