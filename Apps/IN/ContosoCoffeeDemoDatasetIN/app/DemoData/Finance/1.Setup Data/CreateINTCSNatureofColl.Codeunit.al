// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 19041 "Create IN TCS Nature of Coll."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
    begin
        ContosoINTaxSetup.InsertTCSNatureofCollection(NatureofCollection1H(), NatureofCollection1HDescLbl, true);
        ContosoINTaxSetup.InsertTCSNatureofCollection(NatureofCollectionA(), NatureofCollectionADescLbl, false);
        ContosoINTaxSetup.InsertTCSNatureofCollection(NatureofCollectionB(), NatureofCollectionBDescLbl, false);
        ContosoINTaxSetup.InsertTCSNatureofCollection(NatureofCollectionC(), NatureofCollectionCDescLbl, false);
        ContosoINTaxSetup.InsertTCSNatureofCollection(NatureofCollectionD(), NatureofCollectionDDescLbl, false);
        ContosoINTaxSetup.InsertTCSNatureofCollection(NatureofCollectionE(), NatureofCollectionEDescLbl, false);
        ContosoINTaxSetup.InsertTCSNatureofCollection(NatureofCollectionF(), NatureofCollectionFDescLbl, false);
        ContosoINTaxSetup.InsertTCSNatureofCollection(NatureofCollectionG(), NatureofCollectionGDescLbl, false);
        ContosoINTaxSetup.InsertTCSNatureofCollection(NatureofCollectionH(), NatureofCollectionHDescLbl, false);
        ContosoINTaxSetup.InsertTCSNatureofCollection(NatureofCollectionI(), NatureofCollectionIDescLbl, false);
        ContosoINTaxSetup.InsertTCSNatureofCollection(NatureofCollectionL(), NatureofCollectionLDescLbl, false);
        ContosoINTaxSetup.InsertTCSNatureofCollection(NatureofCollectionM(), NatureofCollectionMDescLbl, false);
    end;

    procedure NatureofCollection1H(): Code[10]
    begin
        exit(NatureofCollection1HTok);
    end;

    procedure NatureofCollectionA(): Code[10]
    begin
        exit(NatureofCollectionATok);
    end;

    procedure NatureofCollectionB(): Code[10]
    begin
        exit(NatureofCollectionBTok);
    end;

    procedure NatureofCollectionC(): Code[10]
    begin
        exit(NatureofCollectionCTok);
    end;

    procedure NatureofCollectionD(): Code[10]
    begin
        exit(NatureofCollectionDTok);
    end;

    procedure NatureofCollectionE(): Code[10]
    begin
        exit(NatureofCollectionETok);
    end;

    procedure NatureofCollectionF(): Code[10]
    begin
        exit(NatureofCollectionFTok);
    end;

    procedure NatureofCollectionG(): Code[10]
    begin
        exit(NatureofCollectionGTok);
    end;

    procedure NatureofCollectionH(): Code[10]
    begin
        exit(NatureofCollectionHTok);
    end;

    procedure NatureofCollectionI(): Code[10]
    begin
        exit(NatureofCollectionITok);
    end;

    procedure NatureofCollectionL(): Code[10]
    begin
        exit(NatureofCollectionLTok);
    end;

    procedure NatureofCollectionM(): Code[10]
    begin
        exit(NatureofCollectionMTok);
    end;

    var
        NatureofCollection1HTok: Label '1H', MaxLength = 10;
        NatureofCollectionATok: Label 'A', MaxLength = 10;
        NatureofCollectionBTok: Label 'B', MaxLength = 10;
        NatureofCollectionCTok: Label 'C', MaxLength = 10;
        NatureofCollectionDTok: Label 'D', MaxLength = 10;
        NatureofCollectionETok: Label 'E', MaxLength = 10;
        NatureofCollectionFTok: Label 'F', MaxLength = 10;
        NatureofCollectionGTok: Label 'G', MaxLength = 10;
        NatureofCollectionHTok: Label 'H', MaxLength = 10;
        NatureofCollectionITok: Label 'I', MaxLength = 10;
        NatureofCollectionLTok: Label 'L', MaxLength = 10;
        NatureofCollectionMTok: Label 'M', MaxLength = 10;
        NatureofCollection1HDescLbl: Label 'U/S 206 - 1H', MaxLength = 30;
        NatureofCollectionADescLbl: Label 'Alcoholic liquor for human con', MaxLength = 30;
        NatureofCollectionBDescLbl: Label 'Timber obtained under a forest', MaxLength = 30;
        NatureofCollectionCDescLbl: Label 'Timber obtained under any mode', MaxLength = 30;
        NatureofCollectionDDescLbl: Label 'Any other forest product not b', MaxLength = 30;
        NatureofCollectionEDescLbl: Label 'Scrap', MaxLength = 30;
        NatureofCollectionFDescLbl: Label 'Parking Lot', MaxLength = 30;
        NatureofCollectionGDescLbl: Label 'Toll Plaza', MaxLength = 30;
        NatureofCollectionHDescLbl: Label 'Mining and Quarrying', MaxLength = 30;
        NatureofCollectionIDescLbl: Label 'Tendu leaves', MaxLength = 30;
        NatureofCollectionLDescLbl: Label 'Sale of Motor vehicle', MaxLength = 30;
        NatureofCollectionMDescLbl: Label 'Sale in cash of any goods (oth', MaxLength = 30;
}
