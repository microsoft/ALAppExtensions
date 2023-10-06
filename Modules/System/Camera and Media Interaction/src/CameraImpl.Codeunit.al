// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Device;

codeunit 1922 "Camera Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        Camera: Page Camera;
        PictureFileNameTok: Label 'Picture_%1.jpeg', Comment = '%1 = String generated from current datetime to make sure file names are unique '; 

    procedure GetPicture(Quality: Integer; PictureInStream: InStream; var PictureName: Text): Boolean
    var
        WasPictureTaken: Boolean;
    begin
        if not IsAvailable() then
            exit(false);

        Clear(Camera);

        Camera.SetQuality(Quality);
        Camera.RunModal();
        if Camera.HasPicture() then begin
            Camera.GetPicture(PictureInStream);
            PictureName := StrSubstNo(PictureFileNameTok, Format(CurrentDateTime(), 0, '<Day,2>_<Month,2>_<Year4>_<Hours24>_<Minutes,2>_<Seconds,2>'));
            WasPictureTaken := true;
        end;

        exit(WasPictureTaken);
    end;

    procedure IsAvailable(): Boolean
    begin
        if GuiAllowed() then
            exit(Camera.IsAvailable());
        exit(false);
    end;
}