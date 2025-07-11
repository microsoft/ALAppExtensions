// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;

codeunit 19003 "Create IN State"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
    begin
        ContosoINTaxSetup.InsertState(AndhraPradesh(), AndhraPradeshLbl, '02', '37');
        ContosoINTaxSetup.InsertState(AndamanNicobarIslands(), AndamanNicobarIslandsLbl, '01', '35');
        ContosoINTaxSetup.InsertState(ArunachalPradesh(), ArunachalPradeshLbl, '03', '12');
        ContosoINTaxSetup.InsertState(Assam(), AssamLbl, '04', '18');
        ContosoINTaxSetup.InsertState(Bihar(), BiharLbl, '05', '10');
        ContosoINTaxSetup.InsertState(Chattisgarh(), ChattisgarhLbl, '33', '22');
        ContosoINTaxSetup.InsertState(Chandigarh(), ChandigarhLbl, '06', '04');
        ContosoINTaxSetup.InsertState(DamanDiu(), DamanDiuLbl, '08', '25');
        ContosoINTaxSetup.InsertState(Delhi(), DelhiLbl, '09', '07');
        ContosoINTaxSetup.InsertState(DadraNagarHaveli(), DadraNagarHaveliLbl, '07', '26');
        ContosoINTaxSetup.InsertState(Goa(), GoaLbl, '10', '30');
        ContosoINTaxSetup.InsertState(Gujarat(), GujaratLbl, '11', '24');
        ContosoINTaxSetup.InsertState(HimachalPradesh(), HimachalPradeshLbl, '13', '02');
        ContosoINTaxSetup.InsertState(Haryana(), HaryanaLbl, '12', '06');
        ContosoINTaxSetup.InsertState(Jharkhand(), JharkhandLbl, '35', '20');
        ContosoINTaxSetup.InsertState(JammuKashmir(), JammuKashmirLbl, '14', '01');
        ContosoINTaxSetup.InsertState(Karnataka(), KarnatakaLbl, '15', '29');
        ContosoINTaxSetup.InsertState(Kerala(), KeralaLbl, '16', '32');
        ContosoINTaxSetup.InsertState(Ladakh(), LadakhLbl, '37', '38');
        ContosoINTaxSetup.InsertState(LakshadweepIslands(), LakshadweepIslandsLbl, '17', '31');
        ContosoINTaxSetup.InsertState(Maharashtra(), MaharashtraLbl, '19', '27');
        ContosoINTaxSetup.InsertState(Meghalaya(), MeghalayaLbl, '21', '17');
        ContosoINTaxSetup.InsertState(Manipur(), ManipurLbl, '20', '14');
        ContosoINTaxSetup.InsertState(MadhyaPradesh(), MadhyaPradeshLbl, '18', '23');
        ContosoINTaxSetup.InsertState(Mizoram(), MizoramLbl, '22', '15');
        ContosoINTaxSetup.InsertState(Nagaland(), NagalandLbl, '23', '13');
        ContosoINTaxSetup.InsertState(Odisha(), OdishaLbl, '24', '21');
        ContosoINTaxSetup.InsertState(Punjab(), PunjabLbl, '26', '03');
        ContosoINTaxSetup.InsertState(Pondicherry(), PondicherryLbl, '25', '34');
        ContosoINTaxSetup.InsertState(Rajasthan(), RajasthanLbl, '27', '08');
        ContosoINTaxSetup.InsertState(Sikkim(), SikkimLbl, '28', '11');
        ContosoINTaxSetup.InsertState(TamilNadu(), TamilNaduLbl, '29', '33');
        ContosoINTaxSetup.InsertState(Tripura(), TripuraLbl, '30', '16');
        ContosoINTaxSetup.InsertState(Telangana(), TelanganaLbl, '36', '36');
        ContosoINTaxSetup.InsertState(Uttarakhand(), UttarakhandLbl, '34', '05');
        ContosoINTaxSetup.InsertState(UttarPradesh(), UttarPradeshLbl, '31', '09');
        ContosoINTaxSetup.InsertState(WestBengal(), WestBengalLbl, '32', '19');
    end;

    procedure AndhraPradesh(): Code[10]
    begin
        exit(AndhraPradeshTok);
    end;

    procedure AndamanNicobarIslands(): Code[10]
    begin
        exit(AndamanNicobarIslandsTok);
    end;

    procedure ArunachalPradesh(): Code[10]
    begin
        exit(ArunachalPradeshTok);
    end;

    procedure Assam(): Code[10]
    begin
        exit(AssamTok);
    end;

    procedure Bihar(): Code[10]
    begin
        exit(BiharTok);
    end;

    procedure Chattisgarh(): Code[10]
    begin
        exit(ChattisgarhTok);
    end;

    procedure Chandigarh(): Code[10]
    begin
        exit(ChandigarhTok);
    end;

    procedure DamanDiu(): Code[10]
    begin
        exit(DamanDiuTok);
    end;

    procedure Delhi(): Code[10]
    begin
        exit(DelhiTok);
    end;

    procedure DadraNagarHaveli(): Code[10]
    begin
        exit(DadraNagarHaveliTok);
    end;

    procedure Goa(): Code[10]
    begin
        exit(GoaTok);
    end;

    procedure Gujarat(): Code[10]
    begin
        exit(GujaratTok);
    end;

    procedure HimachalPradesh(): Code[10]
    begin
        exit(HimachalPradeshTok);
    end;

    procedure Haryana(): Code[10]
    begin
        exit(HaryanaTok);
    end;

    procedure Jharkhand(): Code[10]
    begin
        exit(JharkhandTok);
    end;

    procedure JammuKashmir(): Code[10]
    begin
        exit(JammuKashmirTok);
    end;

    procedure Karnataka(): Code[10]
    begin
        exit(KarnatakaTok);
    end;

    procedure Kerala(): Code[10]
    begin
        exit(KeralaTok);
    end;

    procedure Ladakh(): Code[10]
    begin
        exit(LadakhTok);
    end;

    procedure LakshadweepIslands(): Code[10]
    begin
        exit(LakshadweepIslandsTok);
    end;

    procedure Maharashtra(): Code[10]
    begin
        exit(MaharashtraTok);
    end;

    procedure Meghalaya(): Code[10]
    begin
        exit(MeghalayaTok);
    end;

    procedure Manipur(): Code[10]
    begin
        exit(ManipurTok);
    end;

    procedure MadhyaPradesh(): Code[10]
    begin
        exit(MadhyaPradeshTok);
    end;

    procedure Mizoram(): Code[10]
    begin
        exit(MizoramTok);
    end;

    procedure Nagaland(): Code[10]
    begin
        exit(NagalandTok);
    end;

    procedure Odisha(): Code[10]
    begin
        exit(OdishaTok);
    end;

    procedure Punjab(): Code[10]
    begin
        exit(PunjabTok);
    end;

    procedure Pondicherry(): Code[10]
    begin
        exit(PondicherryTok);
    end;

    procedure Rajasthan(): Code[10]
    begin
        exit(RajasthanTok);
    end;

    procedure Sikkim(): Code[10]
    begin
        exit(SikkimTok);
    end;

    procedure TamilNadu(): Code[10]
    begin
        exit(TamilNaduTok);
    end;

    procedure Tripura(): Code[10]
    begin
        exit(TripuraTok);
    end;

    procedure Telangana(): Code[10]
    begin
        exit(TelanganaTok);
    end;

    procedure Uttarakhand(): Code[10]
    begin
        exit(UttarakhandTok);
    end;

    procedure UttarPradesh(): Code[10]
    begin
        exit(UttarPradeshTok);
    end;

    procedure WestBengal(): Code[10]
    begin
        exit(WestBengalTok);
    end;

    var
        AndhraPradeshTok: Label 'AD', MaxLength = 10;
        AndamanNicobarIslandsTok: Label 'AN', MaxLength = 10;
        ArunachalPradeshTok: Label 'AR', MaxLength = 10;
        AssamTok: Label 'AS', MaxLength = 10;
        BiharTok: Label 'BR', MaxLength = 10;
        ChattisgarhTok: Label 'CG', MaxLength = 10;
        ChandigarhTok: Label 'CH', MaxLength = 10;
        DamanDiuTok: Label 'DD', MaxLength = 10;
        DelhiTok: Label 'DL', MaxLength = 10;
        DadraNagarHaveliTok: Label 'DN', MaxLength = 10;
        GoaTok: Label 'GA', MaxLength = 10;
        GujaratTok: Label 'GJ', MaxLength = 10;
        HimachalPradeshTok: Label 'HP', MaxLength = 10;
        HaryanaTok: Label 'HR', MaxLength = 10;
        JharkhandTok: Label 'JH', MaxLength = 10;
        JammuKashmirTok: Label 'JK', MaxLength = 10;
        KarnatakaTok: Label 'KA', MaxLength = 10;
        KeralaTok: Label 'KL', MaxLength = 10;
        LadakhTok: Label 'LA', MaxLength = 10;
        LakshadweepIslandsTok: Label 'LD', MaxLength = 10;
        MaharashtraTok: Label 'MH', MaxLength = 10;
        MeghalayaTok: Label 'ML', MaxLength = 10;
        ManipurTok: Label 'MN', MaxLength = 10;
        MadhyaPradeshTok: Label 'MP', MaxLength = 10;
        MizoramTok: Label 'MZ', MaxLength = 10;
        NagalandTok: Label 'NL', MaxLength = 10;
        OdishaTok: Label 'OD', MaxLength = 10;
        PunjabTok: Label 'PB', MaxLength = 10;
        PondicherryTok: Label 'PY', MaxLength = 10;
        RajasthanTok: Label 'RJ', MaxLength = 10;
        SikkimTok: Label 'SK', MaxLength = 10;
        TamilNaduTok: Label 'TN', MaxLength = 10;
        TripuraTok: Label 'TR', MaxLength = 10;
        TelanganaTok: Label 'TS', MaxLength = 10;
        UttarakhandTok: Label 'UK', MaxLength = 10;
        UttarPradeshTok: Label 'UP', MaxLength = 10;
        WestBengalTok: Label 'WB', MaxLength = 10;
        AndhraPradeshLbl: Label 'Andhra Pradesh', MaxLength = 50;
        AndamanNicobarIslandsLbl: Label 'Andaman and Nicobar Islands', MaxLength = 50;
        ArunachalPradeshLbl: Label 'Arunachal Pradesh', MaxLength = 50;
        AssamLbl: Label 'Assam', MaxLength = 50;
        BiharLbl: Label 'Bihar', MaxLength = 50;
        ChattisgarhLbl: Label 'Chattisgarh', MaxLength = 50;
        ChandigarhLbl: Label 'Chandigarh', MaxLength = 50;
        DamanDiuLbl: Label 'Daman and Diu', MaxLength = 50;
        DelhiLbl: Label 'Delhi', MaxLength = 50;
        DadraNagarHaveliLbl: Label 'Dadra and Nagar Haveli', MaxLength = 50;
        GoaLbl: Label 'Goa', MaxLength = 50;
        GujaratLbl: Label 'Gujarat', MaxLength = 50;
        HimachalPradeshLbl: Label 'Himachal Pradesh', MaxLength = 50;
        HaryanaLbl: Label 'Haryana', MaxLength = 50;
        JharkhandLbl: Label 'Jharkhand', MaxLength = 50;
        JammuKashmirLbl: Label 'Jammu and Kashmir', MaxLength = 50;
        KarnatakaLbl: Label 'Karnataka', MaxLength = 50;
        KeralaLbl: Label 'Kerala', MaxLength = 50;
        LadakhLbl: Label 'Ladakh', MaxLength = 50;
        LakshadweepIslandsLbl: Label 'Lakshadweep Islands', MaxLength = 50;
        MaharashtraLbl: Label 'Maharashtra', MaxLength = 50;
        MeghalayaLbl: Label 'Meghalaya', MaxLength = 50;
        ManipurLbl: Label 'Manipur', MaxLength = 50;
        MadhyaPradeshLbl: Label 'Madhya Pradesh', MaxLength = 50;
        MizoramLbl: Label 'Mizoram', MaxLength = 50;
        NagalandLbl: Label 'Nagaland', MaxLength = 50;
        OdishaLbl: Label 'Odisha', MaxLength = 50;
        PunjabLbl: Label 'Punjab', MaxLength = 50;
        PondicherryLbl: Label 'Pondicherry', MaxLength = 50;
        RajasthanLbl: Label 'Rajasthan', MaxLength = 50;
        SikkimLbl: Label 'Sikkim', MaxLength = 50;
        TamilNaduLbl: Label 'Tamil Nadu', MaxLength = 50;
        TripuraLbl: Label 'Tripura', MaxLength = 50;
        TelanganaLbl: Label 'Telangana', MaxLength = 50;
        UttarakhandLbl: Label 'Uttarakhand', MaxLength = 50;
        UttarPradeshLbl: Label 'Uttar Pradesh', MaxLength = 50;
        WestBengalLbl: Label 'West Bengal', MaxLength = 50;
}
