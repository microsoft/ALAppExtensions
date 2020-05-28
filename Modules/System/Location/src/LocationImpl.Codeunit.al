// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 50101 "Location Impl."
{
    Access = Internal;

    var
        LocationPage: Page Location;

    procedure GetLocation(var Latitude: Decimal; var Longitude: Decimal): Boolean
    begin
        if not IsAvailable() then
            exit(false);

        Clear(LocationPage);
        LocationPage.SetHighAccuracy(true);
        LocationPage.RunModal();
        if LocationPage.HasLocation() then begin
            LocationPage.GetLocation(Latitude, Longitude);
            exit(true)
        end;

        exit(false)
    end;

    procedure IsAvailable(): Boolean
    begin
        exit(LocationPage.IsAvailable());
    end;
}