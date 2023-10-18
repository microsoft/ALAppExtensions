// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

using System;

codeunit 3726 "Spotlight Tour Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure Start(PageId: Integer; SpotlightTourType: Enum "Spotlight Tour Type"; Title1: Text; Text1: Text; Title2: Text; Text2: Text)
    var
        SpotlightTour: DotNet SpotlightTour;
        TourDictionary: DotNet GenericDictionary2;
    begin
        if Tour.IsAvailable() then begin
            TourDictionary := TourDictionary.Dictionary();
            TourDictionary.Add('Step1Title', Title1);
            TourDictionary.Add('Step1Text', Text1);
            TourDictionary.Add('Step2Title', Title2);
            TourDictionary.Add('Step2Text', Text2);
            Tour := Tour.Create();
            GetSpolightTour(SpotlightTour, SpotlightTourType);
            Tour.StartSpotlightTour(PageId, SpotlightTour, TourDictionary, '0');
        end;
    end;

    local procedure GetSpolightTour(var SpotlightTour: DotNet SpotlightTour; SpotlightTourType: Enum "Spotlight Tour Type")
    begin
        case SpotlightTourType of
            SpotlightTourType::"Open in Excel":
                SpotlightTour := SpotlightTour::OpenInExcel;
            SpotlightTourType::"Share to Teams":
                SpotlightTour := SpotlightTour::ShareToTeams;
            else
                SpotlightTour := SpotlightTour::None;
        end;
    end;

    var
        [RunOnClient]
        Tour: DotNet Tour;

}