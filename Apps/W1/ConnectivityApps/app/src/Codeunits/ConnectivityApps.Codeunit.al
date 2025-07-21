// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

codeunit 20350 "Connectivity Apps"
{
    Access = Internal;

    var
        ConnectivityAppsImpl: Codeunit "Connectivity Apps Impl.";

    procedure Load(var ConnectivityApp: Record "Connectivity App")
    begin
        ConnectivityAppsImpl.Load(ConnectivityApp);
    end;

    procedure LoadCategory(var ConnectivityApp: Record "Connectivity App"; ConnectivityAppCategory: Enum "Connectivity Apps Category")
    begin
        ConnectivityAppsImpl.LoadCategory(ConnectivityApp, ConnectivityAppCategory);
    end;

    procedure LoadImages(var ConnectivityApp: Record "Connectivity App")
    begin
        ConnectivityAppsImpl.LoadImages(ConnectivityApp);
    end;

    procedure IsConnectivityAppsAvailableForGeoAndCategory(ConnectivityAppCategory: Enum "Connectivity Apps Category"): Boolean
    begin
        exit(ConnectivityAppsImpl.IsConnectivityAppsAvailableForGeo(ConnectivityAppCategory));
    end;
}
