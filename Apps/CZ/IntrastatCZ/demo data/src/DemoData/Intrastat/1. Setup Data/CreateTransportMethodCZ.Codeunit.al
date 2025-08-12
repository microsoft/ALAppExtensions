// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Intrastat;

using Microsoft.DemoTool.Helpers;

codeunit 31494 "Create Transport Method CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        ImportFromXml();
        InsertTransportMethod();
    end;

    local procedure ImportFromXml()
    begin
        NavApp.GetResource(XmlFileTok, FileInStream);
        ImportTransportMethodsCZ.SetSource(FileInStream);
        ImportTransportMethodsCZ.SetThresholdDate(WorkDate());
        ImportTransportMethodsCZ.Import();
    end;

    local procedure InsertTransportMethod()
    var
        ContosoIntrastatCZ: Codeunit "Contoso Intrastat CZ";
    begin
        ContosoIntrastatCZ.InsertTransportMethod(No3(), No3DescriptionLbl);
    end;

    procedure No3(): Code[10]
    begin
        exit(No3Tok);
    end;


    var
        ImportTransportMethodsCZ: XmlPort "Import Transport Methods CZ";
        FileInStream: InStream;
        XmlFileTok: Label 'drudo_i_003.xml', Locked = true;
        No3Tok: Label '3', Locked = true;
        No3DescriptionLbl: Label 'Silniční doprava', MaxLength = 80, Locked = true;
}