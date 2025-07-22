// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.DemoTool.Helpers;

codeunit 31490 "Create Intrastat Del. Group CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertIntrastatDeliveryGroup();
    end;

    local procedure InsertIntrastatDeliveryGroup()
    var
        ContosoIntrastatCZ: Codeunit "Contoso Intrastat CZ";
    begin
        ContosoIntrastatCZ.InsertIntrastatDeliveryGroup(K(), KDescriptionLbl);
        ContosoIntrastatCZ.InsertIntrastatDeliveryGroup(L(), LDescriptionLbl);
        ContosoIntrastatCZ.InsertIntrastatDeliveryGroup(M(), MDescriptionLbl);
        ContosoIntrastatCZ.InsertIntrastatDeliveryGroup(N(), NDescriptionLbl);
    end;

    procedure K(): Code[10]
    begin
        exit(KTok);
    end;

    procedure L(): Code[10]
    begin
        exit(LTok);
    end;

    procedure M(): Code[10]
    begin
        exit(MTok);
    end;

    procedure N(): Code[10]
    begin
        exit(NTok);
    end;

    var
        KTok: Label 'K', MaxLength = 10, Locked = true;
        KDescriptionLbl: Label 'Kupující zajišťuje a hradí hlavní přepravu.', MaxLength = 100;
        LTok: Label 'L', MaxLength = 10, Locked = true;
        LDescriptionLbl: Label 'Prodávající hradí přepravu do přístavu určení.', MaxLength = 100;
        MTok: Label 'M', MaxLength = 10, Locked = true;
        MDescriptionLbl: Label 'Prodávající zajišťuje a hradí hlavní přepravu.', MaxLength = 100;
        NTok: Label 'N', MaxLength = 10, Locked = true;
        NDescriptionLbl: Label 'Dodací podmínky neodpovídají žádné z doložek Incoterms nebo dodání na hranici.', MaxLength = 100;
}
