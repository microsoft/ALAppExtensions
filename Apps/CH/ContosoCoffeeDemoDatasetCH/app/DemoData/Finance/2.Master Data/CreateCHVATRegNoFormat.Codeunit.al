// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoData.Foundation;
using Microsoft.DemoTool.Helpers;

codeunit 11617 "Create CH VAT Reg. No. Format"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateCountryRegion: Codeunit "Create Country/Region";
        ContosoCountryOrRegion: Codeunit "Contoso Country Or Region";
    begin
        ContosoCountryOrRegion.InsertVATRegNoFormat(CreateCountryRegion.CZ(), 40000, CZFormatLbl);
        ContosoCountryOrRegion.InsertVATRegNoFormat(CreateCountryRegion.CZ(), 50000, CZFormat1Lbl);
        ContosoCountryOrRegion.InsertVATRegNoFormat(CreateCountryRegion.CZ(), 60000, CZFormat2Lbl);
    end;

    var
        CZFormatLbl: Label '########', MaxLength = 20, Locked = true;
        CZFormat1Lbl: Label '#########', MaxLength = 20, Locked = true;
        CZFormat2Lbl: Label '##########', MaxLength = 20, Locked = true;
}
