// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoTool.Helpers;

codeunit 31492 "Create Tariff Number CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        ImportFromXml();
    end;

    local procedure ImportFromXml()
    begin
        NavApp.GetResource(XmlFileTok, FileInStream);
        ImportTariffNumbersCZ.SetSource(FileInStream);
        ImportTariffNumbersCZ.SetThresholdDate(WorkDate());
        ImportTariffNumbersCZ.Import();
    end;

    var
        ImportTariffNumbersCZ: XmlPort "Import Tariff Numbers CZ";
        FileInStream: InStream;
        XmlFileTok: Label 'kn_i_004.xml', Locked = true;
}