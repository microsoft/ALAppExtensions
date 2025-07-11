// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 31209 "Create Commodity CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertCommodity();
        InsertCommoditySetup();
    end;

    local procedure InsertCommodity()
    var
        ContosoCommodityCZ: Codeunit "Contoso Commodity CZ";
    begin
        ContosoCommodityCZ.InsertCommodity(Code0(), Code0DescriptionTok);
        ContosoCommodityCZ.InsertCommodity(Code1(), Code1DescriptionTok);
        ContosoCommodityCZ.InsertCommodity(Code11(), Code11DescriptionTok);
        ContosoCommodityCZ.InsertCommodity(Code12(), Code12DescriptionTok);
        ContosoCommodityCZ.InsertCommodity(Code13(), Code13DescriptionTok);
        ContosoCommodityCZ.InsertCommodity(Code14(), Code14DescriptionTok);
        ContosoCommodityCZ.InsertCommodity(Code15(), Code15DescriptionTok);
        ContosoCommodityCZ.InsertCommodity(Code16(), Code16DescriptionTok);
        ContosoCommodityCZ.InsertCommodity(Code17(), Code17DescriptionTok);
        ContosoCommodityCZ.InsertCommodity(Code4(), Code4DescriptionTok);
        ContosoCommodityCZ.InsertCommodity(Code5(), Code5DescriptionTok);
    end;

    local procedure InsertCommoditySetup()
    var
        ContosoCommodityCZ: Codeunit "Contoso Commodity CZ";
    begin
        ContosoCommodityCZ.InsertCommoditySetup(Code0(), DMY2Date(1, 1, 2013), 0);
        ContosoCommodityCZ.InsertCommoditySetup(Code12(), DMY2Date(1, 4, 2015), 100000);
        ContosoCommodityCZ.InsertCommoditySetup(Code13(), DMY2Date(1, 4, 2015), 100000);
        ContosoCommodityCZ.InsertCommoditySetup(Code14(), DMY2Date(1, 4, 2015), 100000);
        ContosoCommodityCZ.InsertCommoditySetup(Code15(), DMY2Date(1, 4, 2015), 100000);
        ContosoCommodityCZ.InsertCommoditySetup(Code16(), DMY2Date(1, 4, 2015), 100000);
        ContosoCommodityCZ.InsertCommoditySetup(Code17(), DMY2Date(1, 4, 2015), 100000);
    end;

    procedure Code0(): Code[10]
    begin
        exit(Code0Tok);
    end;

    procedure Code1(): Code[10]
    begin
        exit(Code1Tok);
    end;

    procedure Code4(): Code[10]
    begin
        exit(Code4Tok);
    end;

    procedure Code5(): Code[10]
    begin
        exit(Code5Tok);
    end;

    procedure Code11(): Code[10]
    begin
        exit(Code11Tok);
    end;

    procedure Code12(): Code[10]
    begin
        exit(Code12Tok);
    end;

    procedure Code13(): Code[10]
    begin
        exit(Code13Tok);
    end;

    procedure Code14(): Code[10]
    begin
        exit(Code14Tok);
    end;

    procedure Code15(): Code[10]
    begin
        exit(Code15Tok);
    end;

    procedure Code16(): Code[10]
    begin
        exit(Code16Tok);
    end;

    procedure Code17(): Code[10]
    begin
        exit(Code17Tok);
    end;


    var
        Code0Tok: Label '0', Locked = true, MaxLength = 10;
        Code1Tok: Label '1', Locked = true, MaxLength = 10;
        Code4Tok: Label '4', Locked = true, MaxLength = 10;
        Code5Tok: Label '5', Locked = true, MaxLength = 10;
        Code11Tok: Label '11', Locked = true, MaxLength = 10;
        Code12Tok: Label '12', Locked = true, MaxLength = 10;
        Code13Tok: Label '13', Locked = true, MaxLength = 10;
        Code14Tok: Label '14', Locked = true, MaxLength = 10;
        Code15Tok: Label '15', Locked = true, MaxLength = 10;
        Code16Tok: Label '16', Locked = true, MaxLength = 10;
        Code17Tok: Label '17', Locked = true, MaxLength = 10;
        Code0DescriptionTok: Label 'Bez kontroly limitu', MaxLength = 50, Locked = true;
        Code1DescriptionTok: Label '§92b - dodání zlata', MaxLength = 50, Locked = true;
        Code4DescriptionTok: Label '§92e - poskytnutí stavebních nebo montážních prací', MaxLength = 50, Locked = true;
        Code5DescriptionTok: Label '§92c - zboží uvedené v příloze č.5 zákona ', MaxLength = 50, Locked = true;
        Code11DescriptionTok: Label '§92f  - povolenky na emise', MaxLength = 50, Locked = true;
        Code12DescriptionTok: Label '§92f - obiloviny a technické plodiny', MaxLength = 50, Locked = true;
        Code13DescriptionTok: Label '§92f - kovy', MaxLength = 50, Locked = true;
        Code14DescriptionTok: Label '§92f - mobilní telefony', MaxLength = 50, Locked = true;
        Code15DescriptionTok: Label '§92f - integrované obvody', MaxLength = 50, Locked = true;
        Code16DescriptionTok: Label '§92f - přenos. zařízení pro automat. zpracov. dat', MaxLength = 50, Locked = true;
        Code17DescriptionTok: Label '§92f - videoherní konzole', MaxLength = 50, Locked = true;
}
