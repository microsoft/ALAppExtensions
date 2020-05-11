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
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
        NotAMediaFieldErr: Label 'The provided field must be of type ''Media''.';

    procedure GetPicture(PictureStream: InStream; var PictureName: Text): Boolean
    var
        WasPictureTaken: Boolean;
    begin
        if not IsAvailable() then
            exit(false);

        Clear(Camera);

        Camera.SetQuality(100); // 100%
        Camera.RunModal();
        if Camera.HasPicture() then begin
            Camera.GetPicture(PictureStream);
            PictureName := StrSubstNo(PictureFileNameTok, Format(CurrentDateTime(), 0, '<Day,2>_<Month,2>_<Year4>_<Hours24>_<Minutes,2>_<Seconds,2>'));
            WasPictureTaken := true;
        end;

        exit(WasPictureTaken);
    end;

    procedure AddPicture(RecordVariant: Variant; FieldNo: Integer): Boolean
    var
        TempMedia: Record "Temp Media" temporary;
        RecordWithMediaRef: RecordRef;
        MediaFieldRef: FieldRef;
        PictureInStream: InStream;
        PictureName: Text;
    begin
        if not IsAvailable() then
            exit(false);

        RecordWithMediaRef.GetTable(RecordVariant);
        MediaFieldRef := RecordWithMediaRef.Field(FieldNo);

        if MediaFieldRef.Type <> FieldType::Media then
            Error(NotAMediaFieldErr);

        if not GetPicture(PictureInStream, PictureName) then
            exit(false);

        if not IsNullGuid(MediaFieldRef.Value) then
            if not Confirm(OverrideImageQst) then
                exit(false);

        TempMedia.Media.ImportStream(PictureInStream, PictureName, 'image/jpeg');
        MediaFieldRef.Value := TempMedia.Media;

        if not RecordWithMediaRef.Modify(true) then
            RecordWithMediaRef.Insert(true);

        exit(true);
    end;

    procedure IsAvailable(): Boolean
    begin
        if GuiAllowed() then
            exit(Camera.IsAvailable());
        exit(false);
    end;
}