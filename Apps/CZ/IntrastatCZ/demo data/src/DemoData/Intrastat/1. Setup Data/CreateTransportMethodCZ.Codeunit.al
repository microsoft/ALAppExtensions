// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoTool.Helpers;

codeunit 31494 "Create Transport Method CZ"
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
        ImportTransportMethodsCZ.SetSource(FileInStream);
        ImportTransportMethodsCZ.SetThresholdDate(WorkDate());
        ImportTransportMethodsCZ.Import();
    end;

    var
        ImportTransportMethodsCZ: XmlPort "Import Transport Methods CZ";
        FileInStream: InStream;
        XmlFileTok: Label 'drudo_i_003.xml', Locked = true;
}