// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.eServices;

using Microsoft.DemoTool.Helpers;

codeunit 5236 "Create Online Map Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoEServices: Codeunit "Contoso eServices";
        OnlineMapParaSetup: Codeunit "Create Online Map Para. Setup";
    begin
        ContosoEServices.InsertEServicesOnlineMapSetup(OnlineMapParaSetup.OnlineMapParameter(), 0, 0, false);
    end;
}
