// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoTool.Helpers;

codeunit 31495 "Create Specific Movement CZ"
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
        ImportSpecificMovementsCZ.SetSource(FileInStream);
        ImportSpecificMovementsCZ.SetThresholdDate(WorkDate());
        ImportSpecificMovementsCZ.Import();
    end;

    var
        ImportSpecificMovementsCZ: XmlPort "Import Specific Movements CZ";
        FileInStream: InStream;
        XmlFileTok: Label 'pohyb_i_003.xml', Locked = true;
}