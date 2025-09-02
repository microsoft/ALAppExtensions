// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Intrastat;

using Microsoft.DemoTool.Helpers;

codeunit 31492 "Create Tariff Number CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        ImportFromXml();
        InsertTariffNumber();
    end;

    local procedure ImportFromXml()
    begin
        NavApp.GetResource(XmlFileTok, FileInStream);
        ImportTariffNumbersCZ.SetSource(FileInStream);
        ImportTariffNumbersCZ.SetThresholdDate(WorkDate());
        ImportTariffNumbersCZ.Import();
    end;

    local procedure InsertTariffNumber()
    var
        ContosoIntrastatCZ: Codeunit "Contoso Intrastat CZ";
    begin
        ContosoIntrastatCZ.InsertTariffNumber(No94031098Tok, No94031098DescriptionLbl, No94031098DescriptionENLbl, '');
    end;

    procedure No94031098(): Code[10]
    begin
        exit(No94031098Tok);
    end;

    var
        ImportTariffNumbersCZ: XmlPort "Import Tariff Numbers CZ";
        FileInStream: InStream;
        XmlFileTok: Label 'kn_i_004.xml', Locked = true;
        No94031098Tok: Label '94031098', Locked = true;
        No94031098DescriptionLbl: Label 'Kancelářský kovový nábytek, > 80 cm výšky (kromě sedadel, skříní s dveřmi, žaluziemi nebo sklopnými ', MaxLength = 100, Locked = true;
        No94031098DescriptionENLbl: Label 'Metal furniture for offices, of > 80 cm in height (excl. tables with special fittings for drawing of', MaxLength = 100, Locked = true;
}