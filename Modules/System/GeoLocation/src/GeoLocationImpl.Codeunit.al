// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 50101 "GeoLocation Impl."
{
    Access = Internal;

    var
        GeoLocationPage: Page GeoLocation;

    procedure GetGeoLocation(var Latitude: Decimal; var Longitude: Decimal): Boolean
    begin
        if not IsAvailable() then
            exit(false);

        Clear(GeoLocationPage);
        GeoLocationPage.SetHighAccuracy(true);
        GeoLocationPage.RunModal();
        if GeoLocationPage.HasGeoLocation() then begin
            GeoLocationPage.GetGeoLocation(Latitude, Longitude);
            exit(true);
        end;

        exit(false);
    end;

    procedure IsAvailable(): Boolean
    begin
        exit(GeoLocationPage.IsAvailable());
    end;
}