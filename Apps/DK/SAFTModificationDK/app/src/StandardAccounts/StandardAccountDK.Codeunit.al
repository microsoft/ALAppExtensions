// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Reflection;

codeunit 13695 "Standard Account DK"
{
    Access = Internal;

    procedure GetStandardAccountsCSV(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        CRLF: Text[2];
    begin
        CRLF := TypeHelper.CRLFSeparator();

        exit(
            '1010;Salg af varer og ydelser;' + CRLF +
            '1050;Salg af varer udland, EU;' + CRLF +
            '1100;Salg af varer udland, ikke-EU;' + CRLF +
            '1150;Salg af ydelser udland, EU;' + CRLF +
            '1200;Salg af ydelser udland, ikke-EU;' + CRLF +
            '1300;Regulering igangværende arbejder;' + CRLF +
            '1350;Værdireguleringer af investeringsejendomme;' + CRLF +
            '1410;Varelagerregulering på lagre af færdigvarer og varer under fremstilling;' + CRLF +
            '1430;Nedskrivning på lagre af færdigvarer og varer under fremstilling;' + CRLF +
            '1460;Øvrige ændringer på lagre af færdigvarer og varer under fremstilling;' + CRLF +
            '1510;Gevinst ved salg af immaterielle anlægsaktiver;' + CRLF +
            '1530;Gevinst ved salg af materielle anlægsaktiver;' + CRLF +
            '1540;Gevinst ved salg af finansielle anlægsaktiver;' + CRLF +
            '1550;Øvrige andre driftsindtægter;' + CRLF +
            '1610;Varekøb;' + CRLF +
            '1630;Varekøb udland, EU;' + CRLF +
            '1650;Varekøb udland, ikke-EU;' + CRLF +
            '1660;Ydelseskøb;' + CRLF +
            '1710;Ydelseskøb udland, EU;' + CRLF +
            '1740;Ydelseskøb, udland, ikke-EU;' + CRLF +
            '1770;Varelagerregulering på lagre af råvarer og hjælpematerialer;' + CRLF +
            '1800;Nedskrivning på varelager;' + CRLF +
            '1820;Andre eksterne omkostninger;' + CRLF +
            '1830;Fragtomkostninger;' + CRLF +
            '1850;Annoncering og reklame;' + CRLF +
            '1870;Udstillinger og dekoration;' + CRLF +
            '1890;Restaurationsbesøg;' + CRLF +
            '1910;Repræsentationsomkostninger, skattemæssigt begrænset fradrag;' + CRLF +
            '1930;Repræsentationsomkostninger, fuld fradragsret skattemæssigt;' + CRLF +
            '1950;Andre salgsomkostninger;' + CRLF +
            '1970;Aviser og blade;' + CRLF +
            '1990;Gaver og blomster;' + CRLF +
            '2030;Husleje, ekskl. el, vand og varme;' + CRLF +
            '2050;El;' + CRLF +
            '2060;Elafgift;' + CRLF +
            '2070;Vand;' + CRLF +
            '2080;Varme;' + CRLF +
            '2090;Vandafgift;' + CRLF +
            '2100;Olie- og flaskegasafgift;' + CRLF +
            '2110;Kulafgift;' + CRLF +
            '2120;Naturgas- og bygasafgift;' + CRLF +
            '2130;Co2-afgift;' + CRLF +
            '2140;Øvrige afgifter;' + CRLF +
            '2150;Rengøring og renovation (affaldshåndtering);' + CRLF +
            '2160;Reparation og vedligeholdelse;' + CRLF +
            '2170;Reparation og vedligeholdelse, ejendom skattemæssigt afskrivningsberettiget, bygning 1;' + CRLF +
            '2180;Forsikringer;' + CRLF +
            '2190;Ejendomsskatter;' + CRLF +
            '2200;Andre lokaleomkostninger;' + CRLF +
            '2230;Småanskaffelser under skattemæssig grænse for småaktiver;' + CRLF +
            '2240;Småanskaffelser over skattemæssig grænse for småaktiver;' + CRLF +
            '2250;Underleverandører;' + CRLF +
            '2260;Forsknings- og udviklingsomkostninger;' + CRLF +
            '2270;Øvrige produktionsomkostninger;' + CRLF +
            '2280;Konstaterede tab på tilgodehavender fra salg og tjenesteydelser;' + CRLF +
            '2290;Regulering af nedskrivning på tilgodehavender fra salg og tjenesteydelser;' + CRLF +
            '2300;Regulering af tilgodehavender fra tilknyttede virksomheder og associerede virksomheder;' + CRLF +
            '2310;It-udstyr mv.;' + CRLF +
            '2330;Skattefri rejse- og befordringsgodtgørelse;' + CRLF +
            '2350;Kantineudgifter;' + CRLF +
            '2370;Kontingenter;' + CRLF +
            '2380;Faglitteratur;' + CRLF +
            '2390;Porto og gebyrer;' + CRLF +
            '2410;Telefon og internet mv. (kun virksomhed);' + CRLF +
            '2420;Telefon og internet mv. (delvist privat);' + CRLF +
            '2450;Kontorartikler;' + CRLF +
            '2460;Leje og operationelle leasingydelser (ekskl. husleje);' + CRLF +
            '2470;Rejseudgifter;' + CRLF +
            '2480;Vikarassistance;' + CRLF +
            '2510;Konsulentydelser;' + CRLF +
            '2520;Kursusudgifter;' + CRLF +
            '2530;Leasingomkostninger, personbiler;' + CRLF +
            '2540;Driftsomkostninger, personbiler;' + CRLF +
            '2560;Driftsomkostninger, varebiler;' + CRLF +
            '2620;Parkeringsudgifter;' + CRLF +
            '2630;Biludgifter efter statens takster;' + CRLF +
            '2640;Fri bil;' + CRLF +
            '2650;Arbejdsskadeforsikring;' + CRLF +
            '2660;Offentlige gebyrer og bøder (ej fradragsberettiget skattemæssigt);' + CRLF +
            '2670;Revision og regnskabsmæssig assistance;' + CRLF +
            '2680;Advokatmæssig assistance;' + CRLF +
            '2690;Øvrige rådgivningshonorarer;' + CRLF +
            '2700;Ej skattemæssigt fradragsberettigede rådgivningshonorarer;' + CRLF +
            '2710;Administrationsvederlag/management fee;' + CRLF +
            '2720;Øreafrunding/kassedifferencer;' + CRLF +
            '2810;Andre eksterne omkostninger;' + CRLF +
            '2850;Lønninger;' + CRLF +
            '2860;Feriepengeforpligtelse;' + CRLF +
            '2870;Jubilæumsgratiale og fratrædelsesgodtgørelse;' + CRLF +
            '2880;Bestyrelseshonorar;' + CRLF +
            '2890;AM Bidragspligtig A-Indkomst;' + CRLF +
            '2900;AM Bidragsfri A-Indkomst;' + CRLF +
            '2910;Pensioner;' + CRLF +
            '2920;Vederlag til afløsning af pensionstilsagn;' + CRLF +
            '2930;Omkostninger til social sikring;' + CRLF +
            '2940;AER/ AUB;' + CRLF +
            '2950;ATP;' + CRLF +
            '2960;Andre personaleomkostninger;' + CRLF +
            '2965;Personalegoder;' + CRLF +
            '2968;Lønrefusioner;' + CRLF +
            '2970;Udbetalte skattefrie godtgørelser i form af kørepenge og diæter;' + CRLF +
            '2980;Lønsumsafgift;' + CRLF +
            '3000;Af- og nedskrivninger af erhvervede immaterielle anlægsaktiver;' + CRLF +
            '3010;Af- og nedskrivninger af goodwill;' + CRLF +
            '3020;Af- og nedskrivninger af grunde og bygninger;' + CRLF +
            '3030;Af- og nedskrivninger af produktionsanlæg og maskiner;' + CRLF +
            '3040;Af- og nedskrivninger af indretning af lejede lokaler;' + CRLF +
            '3050;Af- og nedskrivninger af andre anlæg, driftsmateriel og inventar;' + CRLF +
            '3060;Af- og nedskrivninger af software;' + CRLF +
            '3070;Af- og nedskrivninger af finansielt leasede grunde og bygninger;' + CRLF +
            '3080;Af- og nedskrivninger af finansielt leasede produktionsanlæg og maskiner;' + CRLF +
            '3090;Af- og nedskrivninger af finansielt leasede andre anlæg, driftsmateriel og inventar;' + CRLF +
            '3130;Nedskrivninger af omsætningsaktiver, som overstiger normale nedskrivninger;' + CRLF +
            '3160;Tab ved salg af immaterielle anlægsaktiver;' + CRLF +
            '3170;Tab ved salg af materielle anlægsaktiver;' + CRLF +
            '3180;Øvrige andre driftsomkostninger;' + CRLF +
            '3200;Indtægter af kapitalandele i tilknyttede virksomheder;' + CRLF +
            '3230;Indtægter af kapitalandele i kapitalinteresser;' + CRLF +
            '3380;Udbytte fra unoterede porteføljeaktier (bruttoudbytte);' + CRLF +
            '3400;Øvrige indtægter af andre kapitalandele, værdipapirer og tilgodehavender, der er anlægsaktiver;' + CRLF +
            '3440;Andre finansielle indtægter fra tilknyttede virksomheder;' + CRLF +
            '3470;Renter fra banker;' + CRLF +
            '3490;Renter vedr. tilgodehavende fra salg af varer og tjenesteydelser;' + CRLF +
            '3510;Rentetillæg mv. fra det offentlige (ej skattepligtig);' + CRLF +
            '3530;Øvrige finansielle indtægter;' + CRLF +
            '3560;Nedskrivning af finansielle aktiver;' + CRLF +
            '3590;Finansielle omkostninger, der hidrører fra tilknyttede virksomheder;' + CRLF +
            '3610;Valutakursreguleringer;' + CRLF +
            '3620;Valutakursreguleringer, udenlandske dattervirksomheder;' + CRLF +
            '3630;Kurstab på likvider, bankgæld og prioritetsgæld;' + CRLF +
            '3640;Renter på finansiel leasinggæld;' + CRLF +
            '3650;Renter vedr. leverandører af varer og tjenesteydelser;' + CRLF +
            '3670;Renter til banker og realkreditinstitutter;' + CRLF +
            '3675;Renter til det offentlige (ej fradragsberettiget skattemæssigt);' + CRLF +
            '3680;Værdireguleringer af investeringsejendomme;' + CRLF +
            '3690;Andre finansielle omkostninger;' + CRLF +
            '3740;Aktuel skat;' + CRLF +
            '3760;Ændring af udskudt skat;' + CRLF +
            '3780;Regulering vedrørende tidligere år;' + CRLF +
            '3810;Andre skatter;' + CRLF +
            '5010;Goodwill, bogført værdi primo;' + CRLF +
            '5020;Goodwill, årets tilgange;' + CRLF +
            '5030;Goodwill, årets afgange;' + CRLF +
            '5040;Goodwill, øvrige værdireguleringer;' + CRLF +
            '5050;Goodwill, årets af- og nedskrivninger;' + CRLF +
            '5060;Goodwill, tilbageførte af- og nedskrivninger;' + CRLF +
            '5080;Erhvervede immaterielle anlægsaktiver, bogført værdi primo;' + CRLF +
            '5090;Erhvervede immaterielle anlægsaktiver, årets tilgange;' + CRLF +
            '5100;Erhvervede immaterielle anlægsaktiver, årets afgange;' + CRLF +
            '5110;Erhvervede immaterielle anlægsaktiver, øvrige værdireguleringer;' + CRLF +
            '5120;Erhvervede immaterielle anlægsaktiver, årets af- og nedskrivninger;' + CRLF +
            '5130;Erhvervede immaterielle anlægsaktiver, tilbageførte af- og nedskrivninger;' + CRLF +
            '5160;Investeringsejendomme, bogført værdi primo;' + CRLF +
            '5170;Investeringsejendomme, årets tilgange;' + CRLF +
            '5180;Investeringsejendomme, årets afgange;' + CRLF +
            '5190;Investeringsejendomme, årets forbedringer;' + CRLF +
            '5200;Investeringsejendomme, øvrige værdireguleringer;' + CRLF +
            '5210;Investeringsejendomme, årets af- og nedskrivninger;' + CRLF +
            '5220;Investeringsejendomme, tilbageførte af- og nedskrivninger;' + CRLF +
            '5240;Investeringsejendomme under opførelse, bogført værdi primo;' + CRLF +
            '5250;Investeringsejendomme under opførelse, årets tilgange;' + CRLF +
            '5260;Investeringsejendomme under opførelse, årets afgange;' + CRLF +
            '5270;Investeringsejendomme under opførelse, årets forbedringer;' + CRLF +
            '5280;Investeringsejendomme under opførelse, øvrige værdireguleringer;' + CRLF +
            '5290;Investeringsejendomme under opførelse, årets nedskrivninger;' + CRLF +
            '5300;Investeringsejendomme under opførelse, tilbageførte nedskrivninger;' + CRLF +
            '5320;Grunde og bygninger, bogført værdi primo;' + CRLF +
            '5330;Grunde og bygninger, årets tilgange;' + CRLF +
            '5340;Grunde og bygninger, årets afgange;' + CRLF +
            '5350;Grunde og bygninger, årets forbedringer;' + CRLF +
            '5370;Grunde og bygninger, øvrige værdireguleringer;' + CRLF +
            '5390;Grunde og bygninger, årets af- og nedskrivninger;' + CRLF +
            '5400;Grunde og bygninger, tilbageførte af- og nedskrivninger;' + CRLF +
            '5420;Produktionsanlæg og maskiner, bogført værdi primo;' + CRLF +
            '5430;Produktionsanlæg og maskiner, årets tilgange;' + CRLF +
            '5440;Produktionsanlæg og maskiner, årets afgange;' + CRLF +
            '5450;Produktionsanlæg og maskiner, øvrige værdireguleringer;' + CRLF +
            '5470;Produktionsanlæg og maskiner, årets af- og nedskrivninger;' + CRLF +
            '5480;Produktionsanlæg og maskiner, tilbageførte af- og nedskrivninger;' + CRLF +
            '5500;Indretning af lejede lokaler, bogført værdi primo;' + CRLF +
            '5510;Indretning af lejede lokaler, årets tilgange;' + CRLF +
            '5520;Indretning af lejede lokaler, årets afgange;' + CRLF +
            '5530;Indretning af lejede lokaler, øvrige værdireguleringer;' + CRLF +
            '5540;Indretning af lejede lokaler, årets af- og nedskrivninger;' + CRLF +
            '5550;Indretning af lejede lokaler, tilbageførte af- og nedskrivninger;' + CRLF +
            '5570;Andre anlæg, driftsmateriel og inventar, bogført værdi primo;' + CRLF +
            '5580;Andre anlæg, driftsmateriel og inventar, årets tilgange;' + CRLF +
            '5590;Andre anlæg, driftsmateriel og inventar, årets afgange;' + CRLF +
            '5600;Andre anlæg, driftsmateriel og inventar, øvrige værdireguleringer;' + CRLF +
            '5610;Andre anlæg, driftsmateriel og inventar, årets af- og nedskrivninger;' + CRLF +
            '5620;Andre anlæg, driftsmateriel og inventar, tilbageførte af- og nedskrivninger;' + CRLF +
            '5640;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, bogført værdi primo;' + CRLF +
            '5650;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, årets tilgange;' + CRLF +
            '5660;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, årets afgange;' + CRLF +
            '5670;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, øvrige værdireguleringer;' + CRLF +
            '5680;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, årets nedskrivninger;' + CRLF +
            '5690;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, tilbageførte nedskrivninger;' + CRLF +
            '5710;Finansielt leasede aktiver, bogført værdi primo;' + CRLF +
            '5720;Finansielt leasede aktiver, årets tilgange;' + CRLF +
            '5730;Finansielt leasede aktiver, årets afgange;' + CRLF +
            '5740;Finansielt leasede aktiver, øvrige værdireguleringer;' + CRLF +
            '5750;Finansielt leasede aktiver, årets af- og nedskrivninger;' + CRLF +
            '5760;Finansielt leasede aktiver, tilbageførte af- og nedskrivninger;' + CRLF +
            '5800;Kapitalandele i tilknyttede virksomheder, bogført værdi primo;' + CRLF +
            '5810;Kapitalandele i tilknyttede virksomheder, årets tilgange;' + CRLF +
            '5820;Kapitalandele i tilknyttede virksomheder, årets afgange;' + CRLF +
            '5830;Kapitalandele i tilknyttede virksomheder, øvrige værdireguleringer;' + CRLF +
            '5840;Kapitalandele i tilknyttede virksomheder, årets nedskrivninger;' + CRLF +
            '5850;Kapitalandele i tilknyttede virksomheder, tilbageførte nedskrivninger;' + CRLF +
            '5870;Langfristede tilgodehavender hos tilknyttede virksomheder;' + CRLF +
            '5880;Nedskrivning på langfristede tilgodehavender hos tilknyttede virksomheder;' + CRLF +
            '5900;Kapitalandele i kapitalinteresser, bogført værdi primo;' + CRLF +
            '5910;Kapitalandele i kapitalinteresser, årets tilgange;' + CRLF +
            '5920;Kapitalandele i kapitalinteresser, årets afgange;' + CRLF +
            '5930;Kapitalandele i kapitalinteresser, øvrige værdireguleringer;' + CRLF +
            '5940;Kapitalandele i kapitalinteresser, årets nedskrivninger;' + CRLF +
            '5950;Kapitalandele i kapitalinteresser, bogført værdi primo, tilbageførte nedskrivninger;' + CRLF +
            '5970;Langfristede tilgodehavender hos kapitalinteresser;' + CRLF +
            '5980;Nedskrivning på langfristede tilgodehavender hos kapitalinteresser;' + CRLF +
            '6000;Andre værdipapirer og kapitalandele;' + CRLF +
            '6020;Udskudte skatteaktiver;' + CRLF +
            '6030;Øvrige (langfristede) tilgodehavender;' + CRLF +
            '6040;Deposita;' + CRLF +
            '6060;Tilgodehavender hos virksomhedsdeltagere og ledelse;' + CRLF +
            '6080;Råvarer og hjælpematerialer;' + CRLF +
            '6090;Nedskrivning på råvarer og hjælpematerialer;' + CRLF +
            '6110;Varer under fremstilling;' + CRLF +
            '6120;Nedskrivning på varer under fremstilling;' + CRLF +
            '6140;Fremstillede varer og handelsvarer;' + CRLF +
            '6150;Nedskrivning på fremstillede varer og handelsvarer;' + CRLF +
            '6170;Forudbetalinger for varer;' + CRLF +
            '6190;Tilgodehavender fra salg og tjenesteydelser;' + CRLF +
            '6200;Akkumulerede nedskrivninger til tab på tilgodehavender fra salg og tjenesteydelser;' + CRLF +
            '6220;Kortfristede tilgodehavender hos tilknyttede virksomheder;' + CRLF +
            '6230;Akkumulerede nedskrivninger til tab på tilgodehavender fra tilknyttede virksomheder;' + CRLF +
            '6240;Kortfristede tilgodehavender hos kapitalinteresser;' + CRLF +
            '6250;Akkumulerede nedskrivninger til tab på tilgodehavender fra kapitalinteresser;' + CRLF +
            '6260;Kortfristede tilgodehavender hos tilknyttede virksomheder;' + CRLF +
            '6270;Igangværende arbejder for fremmed regning;' + CRLF +
            '6280;Igangværende arbejder for fremmed regning;' + CRLF +
            '6290;Udskudte skatteaktiver;' + CRLF +
            '6300;Tilgodehavende selskabsskat (kortfristet);' + CRLF +
            '6310;Tilgodehavende kildeskat;' + CRLF +
            '6320;Tilgodehavende moms (kortfristet);' + CRLF +
            '6330;Øvrige tilgodehavender (kortfristede);' + CRLF +
            '6340;Andre tilgodehavender (kortfristede);' + CRLF +
            '6350;Krav på indbetaling af virksomhedskapital og overkurs;' + CRLF +
            '6360;Krav på indbetaling af virksomhedskapital og overkurs;' + CRLF +
            '6370;Kortfristede tilgodehavender hos virksomhedsdeltagere og ledelse;' + CRLF +
            '6380;Kortfristede tilgodehavender hos virksomhedsdeltagere og ledelse;' + CRLF +
            '6390;Periodeafgrænsningsposter, der kan opretholdes skattemæssigt;' + CRLF +
            '6400;Periodeafgrænsningsposter, der ikke kan opretholdes skattemæssigt;' + CRLF +
            '6410;Periodeafgrænsningsposter;' + CRLF +
            '6411;Tilgodehavender;' + CRLF +
            '6420;Kapitalandele i tilknyttede virksomheder;' + CRLF +
            '6430;Kapitalandele i tilknyttede virksomheder;' + CRLF +
            '6450;Andre værdipapirer og kapitalandele;' + CRLF +
            '6460;Andre værdipapirer og kapitalandele;' + CRLF +
            '6461;Værdipapirer og kapitalandele;' + CRLF +
            '6470;Likvide beholdninger;' + CRLF +
            '6480;Bankkonto;' + CRLF +
            '6490;Likvide beholdninger;' + CRLF +
            '6510;Registreret kapital mv.;' + CRLF +
            '6520;Indbetalt registreret kapital mv.;' + CRLF +
            '6530;Virksomhedskapital;' + CRLF +
            '6540;Overkurs ved emission;' + CRLF +
            '6550;Overkurs ved emission;' + CRLF +
            '6560;Reserve for opskrivninger;' + CRLF +
            '6570;Reserve for opskrivninger;' + CRLF +
            '6580;Reserve for nettoopskrivning efter den indre værdis metode;' + CRLF +
            '6590;Reserve for nettoopskrivning efter den indre værdis metode;' + CRLF +
            '6810;Reserve for udlån og sikkerhedsstillelse;' + CRLF +
            '6830;Reserve for ikke indbetalt virksomhedskapital og overkurs;' + CRLF +
            '6870;Øvrige lovpligtige reserver;' + CRLF +
            '6890;Vedtægtsmæssige reserver;' + CRLF +
            '6910;Øvrige reserver;' + CRLF +
            '6930;Andre reserver;' + CRLF +
            '6940;Overført resultat;' + CRLF +
            '6950;Overført resultat;' + CRLF +
            '6960;Foreslået udbytte indregnet under egenkapitalen;' + CRLF +
            '6970;Foreslået udbytte indregnet under egenkapitalen;' + CRLF +
            '7010;Hensættelser til udskudt skat;' + CRLF +
            '7020;Hensættelser til pensioner og lignende forpligtelser;' + CRLF +
            '7030;Hensættelse til udskudt skat;' + CRLF +
            '7040;Andre hensatte forpligtelser;' + CRLF +
            '7050;Andre hensatte forpligtelser;' + CRLF +
            '7110;Gæld til kreditinstitutter - langfristet gæld;' + CRLF +
            '7120;Gæld til banker - langfristet gæld;' + CRLF +
            '7130;Gæld til kreditinstitutter;' + CRLF +
            '7160;Gæld til tilknyttede virksomheder - langfristet gæld;' + CRLF +
            '7170;Gæld til kapitalinteresser - langfristet gæld;' + CRLF +
            '7180;Gæld til tilknyttede virksomheder - langfristet gæld;' + CRLF +
            '7190;Anden gæld - langfristet;' + CRLF +
            '7210;Gæld til selskabsdeltagere og ledelse - langfristet gæld;' + CRLF +
            '7230;Deposita - langfristet gæld;' + CRLF +
            '7240;Leasingforpligtelse - langfristet gæld;' + CRLF +
            '7250;Selskabsskat - langfristet gæld;' + CRLF +
            '7260;Anden gæld, herunder skyldige skatter og skyldige bidrag til social sikring;' + CRLF +
            '7310;Gæld til kreditinstitutter - kortfristet gæld;' + CRLF +
            '7330;Gæld til banker - kortfristet gæld;' + CRLF +
            '7350;Kreditinstitutter i øvrigt;' + CRLF +
            '7360;Gæld til kreditinstitutter - kortfristet gæld;' + CRLF +
            '7410;Modtagne forudbetalinger fra kunder;' + CRLF +
            '7420;Modtagne forudbetalinger fra kunder;' + CRLF +
            '7440;Leverandører af varer og tjenesteydelser;' + CRLF +
            '7450;Leverandører af varer og tjenesteydelser;' + CRLF +
            '7510;Gæld til tilknyttede virksomheder - kortfristet gæld;' + CRLF +
            '7520;Gæld til kapitalinteresser - kortfristet gæld;' + CRLF +
            '7530;Gæld til tilknyttede virksomheder - kortfristet gæld;' + CRLF +
            '7590;Gæld til selskabsdeltagere og ledelse - kortfristet gæld;' + CRLF +
            '7610;Deposita - kortfristet gæld;' + CRLF +
            '7630;Leasingforpligtelse - kortfristet;' + CRLF +
            '7680;Salgsmoms;' + CRLF +
            '7700;Moms af varekøb udland, EU og ikke-EU;' + CRLF +
            '7720;Moms af ydelseskøb udland, EU og ikke-EU;' + CRLF +
            '7740;Købsmoms;' + CRLF +
            '7760;Olie- og flaskegasafgift;' + CRLF +
            '7780;Elafgift;' + CRLF +
            '7800;Naturgas- og bygasafgift;' + CRLF +
            '7810;Kulafgift;' + CRLF +
            '7820;Vandafgift;' + CRLF +
            '7830;Co2-afgift;' + CRLF +
            '7840;Skyldig moms;' + CRLF +
            '7860;Skyldig løn og gager;' + CRLF +
            '7880;Skyldig bonus og tantieme;' + CRLF +
            '7900;Skyldige feriepenge;' + CRLF +
            '7920;Skyldig A-skat;' + CRLF +
            '7940;Skyldigt AM-bidrag;' + CRLF +
            '7960;Skyldigt ATP-bidrag;' + CRLF +
            '7980;Skyldigt AMP-bidrag;' + CRLF +
            '8000;Anden skyldig pension;' + CRLF +
            '8040;Øvrig anden gæld;' + CRLF +
            '8050;Anden gæld (kortfristet gæld);' + CRLF +
            '8070;Periodeafgrænsningsposter;' + CRLF +
            '8080;Periodeafgrænsningsposter;');
    end;
}
