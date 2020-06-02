// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 50101 "Geolocation Impl."
{
    Access = Internal;

    var
        GeolocationPage: Page Geolocation;

    procedure GetGeolocation(var Latitude: Decimal; var Longitude: Decimal): Boolean
    begin
        if not IsAvailable() then
            exit(false);

        Clear(GeolocationPage);
        GeolocationPage.SetHighAccuracy(true);
        GeolocationPage.RunModal();
        if GeolocationPage.HasGeolocation() then begin
            GeolocationPage.GetGeolocation(Latitude, Longitude);
            exit(true);
        end;

        exit(false);
    end;

    procedure IsAvailable(): Boolean
    begin
        exit(GeolocationPage.IsAvailable());
    end;
}