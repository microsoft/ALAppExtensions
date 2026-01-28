// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Reflection;

codeunit 13695 "Standard Account DK"
{
    Access = Internal;

    procedure GetStandardAccountsCSV(StandardAccountType: Enum "Standard Account Type"): Text
    begin
        case StandardAccountType of
            StandardAccountType::"Four Digit Standard Account":
                exit(GetStandardAccountsCSV());
            StandardAccountType::"Standard Account 2025":
                exit(GetStandardAccountsDec2025CSV());
            else
                exit(GetStandardAccountsCSV());
        end;
    end;

    local procedure GetStandardAccountsDec2025CSV(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        CRLF: Text[2];
    begin
        CRLF := TypeHelper.CRLFSeparator();

        exit(
            '1010;Salg af varer og ydelser' + CRLF +
            '1050;Salg af varer udland, EU' + CRLF +
            '1100;Salg af varer udland, ikke-EU' + CRLF +
            '1150;Salg af ydelser udland, EU' + CRLF +
            '1200;Salg af ydelser udland, ikke-EU' + CRLF +
            '1210;Salgsrabatter' + CRLF +
            '1250;Salgsfragt' + CRLF +
            '1300;Regulering igangværende arbejder' + CRLF +
            '1390;Nettoomsætning' + CRLF +
            '1410;Varelagerregulering på lagre af færdigvarer og varer under fremstilling' + CRLF +
            '1430;Nedskrivning på lagre af færdigvarer og varer under fremstilling' + CRLF +
            '1450;Andel af nedskrivning på lagre af færdigvarer og varer under fremstilling (ej fradragsberettiget skattemæssigt)' + CRLF +
            '1460;Øvrige ændringer på lagre af færdigvarer og varer under fremstilling' + CRLF +
            '1490;Ændring i lagre af færdigvarer og varer under fremstilling' + CRLF +
            '1496;Arbejde udført for egen regning og opført under aktiver' + CRLF +
            '1497;Arbejde udført for egen regning og opført under aktiver' + CRLF +
            '1510;Gevinst ved salg af immaterielle anlægsaktiver' + CRLF +
            '1530;Gevinst ved salg af materielle anlægsaktiver' + CRLF +
            '1545;Offentlige tilskud' + CRLF +
            '1550;Øvrige andre driftsindtægter' + CRLF +
            '1590;Andre driftsindtægter' + CRLF +
            '1610;Varekøb' + CRLF +
            '1630;Varekøb udland, EU' + CRLF +
            '1650;Varekøb udland, ikke-EU' + CRLF +
            '1660;Ydelseskøb' + CRLF +
            '1710;Ydelseskøb udland, EU' + CRLF +
            '1740;Ydelseskøb, udland, ikke-EU' + CRLF +
            '1745;Underleverandører (varer/ydelser leveret til kunder)' + CRLF +
            '1760;Fragtomkostninger' + CRLF +
            '1770;Varelagerregulering på lagre af råvarer og hjælpematerialer' + CRLF +
            '1800;Nedskrivning på varelager' + CRLF +
            '1801;Øvrige produktionsomkostninger' + CRLF +
            '1805;Andel af nedskrivning på varelager (ej fradragsberettiget skattemæssigt)' + CRLF +
            '1807;Værdi af eget vareforbrug (kun klasse A)' + CRLF +
            '1810;Omkostninger til råvarer og hjælpematerialer' + CRLF +
            '1850;Annoncering og reklame' + CRLF +
            '1870;Udstillinger og dekoration' + CRLF +
            '1910;Repræsentationsomkostninger, skattemæssigt begrænset fradrag' + CRLF +
            '1930;Repræsentationsomkostninger, fuld fradragsret skattemæssigt' + CRLF +
            '1950;Andre salgsomkostninger' + CRLF +
            '1990;Gaver og blomster' + CRLF +
            '2000;Rejseomkostninger (salgsomkostning)' + CRLF +
            '2010;Salgsomkostninger' + CRLF +
            '2030;Husleje' + CRLF +
            '2050;El' + CRLF +
            '2060;Elafgift' + CRLF +
            '2070;Vand' + CRLF +
            '2080;Varme' + CRLF +
            '2085;Privat andel el, vand og varme (kun klasse A)' + CRLF +
            '2090;Vandafgift' + CRLF +
            '2100;Olie- og flaskegasafgift' + CRLF +
            '2110;Kulafgift' + CRLF +
            '2120;Naturgas- og bygasafgift' + CRLF +
            '2130;Co2-afgift' + CRLF +
            '2140;Øvrige afgifter' + CRLF +
            '2150;Rengøring og renovation (affaldshåndtering)' + CRLF +
            '2160;Reparation og vedligeholdelse' + CRLF +
            '2170;Reparation og vedligeholdelse, ejendom skattemæssigt afskrivningsberettiget, bygning 1' + CRLF +
            '2180;Forsikringer til lokaler og bygninger' + CRLF +
            '2190;Ejendomsskatter' + CRLF +
            '2200;Andre lokaleomkostninger' + CRLF +
            '2210;Lokaleomkostninger' + CRLF +
            '2230;Småanskaffelser under skattemæssig grænse for småaktiver' + CRLF +
            '2240;Småanskaffelser over skattemæssig grænse for småaktiver' + CRLF +
            '2255;Forskningsomkostninger' + CRLF +
            '2260;Udviklingsomkostninger' + CRLF +
            '2265;Andel af forskningsomkostninger (berettiget til forhøjet skattemæssigt fradrag)' + CRLF +
            '2266;Andel af udviklingsomkostninger (berettiget til forhøjet skattemæssigt fradrag)' + CRLF +
            '2280;Tab på tilgodehavender fra salg og tjenesteydelser' + CRLF +
            '2290;Regulering af nedskrivning på tilgodehavender fra salg og tjenesteydelser' + CRLF +
            '2295;Andel af regulering af nedskrivning på tilgodehavender fra salg og tjenesteydelser  (ej fradragsberettiget skattemæssigt)' + CRLF +
            '2310;It-udstyr (hardware, software inkl. licenser og abonnementer)' + CRLF +
            '2350;Kantineomkostninger' + CRLF +
            '2370;Kontingenter' + CRLF +
            '2375;Aviser og blade' + CRLF +
            '2380;Faglitteratur' + CRLF +
            '2390;Porto og gebyrer' + CRLF +
            '2410;Telefon og internet mv. (kun virksomhed)' + CRLF +
            '2430;Privat andel / fri-telefon (kun klasse A)' + CRLF +
            '2450;Kontorartikler' + CRLF +
            '2460;Leje og operationelle leasingydelser (ekskl. husleje)' + CRLF +
            '2470;Rejseomkostninger (administrationsomkostning)' + CRLF +
            '2480;Vikarassistance' + CRLF +
            '2510;Konsulentydelser' + CRLF +
            '2530;Leasingomkostninger, personbiler' + CRLF +
            '2540;Driftsomkostninger, personbiler' + CRLF +
            '2548;Leasingomkostninger, blandet benyttet personbil (kun klasse A)' + CRLF +
            '2550;Privat andel af biludgifter (kun klasse A)' + CRLF +
            '2560;Driftsomkostninger, varebiler' + CRLF +
            '2567;Leasingomkostninger, blandet benyttet varebil (kun klasse A)' + CRLF +
            '2569;Leasingomkostninger, varebiler' + CRLF +
            '2580;Privat andel af blandet benyttet varebil (kun klasse A)' + CRLF +
            '2620;Parkeringsomkostninger' + CRLF +
            '2650;Øvrige forsikringer' + CRLF +
            '2660;Offentlige gebyrer og bøder (ej fradragsberettiget skattemæssigt)' + CRLF +
            '2670;Revision og regnskabsmæssig assistance' + CRLF +
            '2680;Advokatmæssig assistance' + CRLF +
            '2690;Øvrige rådgivningshonorarer' + CRLF +
            '2700;Ej skattemæssigt fradragsberettigede rådgivningshonorarer' + CRLF +
            '2710;Administrationsvederlag/management fee' + CRLF +
            '2720;Øreafrunding/kassedifferencer' + CRLF +
            '2810;Andre eksterne omkostninger' + CRLF +
            '2830;Administrationsomkostninger' + CRLF +
            '2831;Andre eksterne omkostninger' + CRLF +
            '2832;Eksterne omkostninger' + CRLF +
            '2840;Bruttofortjeneste/Bruttotab' + CRLF +
            '2845;AM Bidragspligtig A-Indkomst' + CRLF +
            '2846;AM Bidragsfri A-Indkomst' + CRLF +
            '2847;B-honorar' + CRLF +
            '2860;Feriepenge og SH-tillæg' + CRLF +
            '2865;Ferietillæg' + CRLF +
            '2866;Feriepengeforpligtelse, regulering' + CRLF +
            '2870;Jubilæumsgratiale og fratrædelsesgodtgørelse' + CRLF +
            '2880;Bestyrelseshonorar' + CRLF +
            '2885;Lønrefusioner' + CRLF +
            '2887;Personalegoder' + CRLF +
            '2888;Fri bil' + CRLF +
            '2895;Skattefri rejse- og befordringsgodtgørelse' + CRLF +
            '2896;Kursusudgifter' + CRLF +
            '2897;ATP, medarbejder' + CRLF +
            '2898;ATP, arbejdsgiver' + CRLF +
            '2905;Lønninger' + CRLF +
            '2910;Pensioner, arbejdsgiver' + CRLF +
            '2920;Vederlag til afløsning af pensionstilsagn' + CRLF +
            '2925;Øvrige pensionsomkostninger' + CRLF +
            '2926;Pensioner' + CRLF +
            '2930;Øvrige omkostninger til social sikring' + CRLF +
            '2946;Lønsumsafgift' + CRLF +
            '2947;Arbejdsskadeforsikringer' + CRLF +
            '2948;Andre omkostninger til social sikring' + CRLF +
            '2990;Personaleomkostninger' + CRLF +
            '3000;Af- og nedskrivninger af erhvervede immaterielle anlægsaktiver' + CRLF +
            '3010;Af- og nedskrivninger af goodwill' + CRLF +
            '3020;Af- og nedskrivninger af grunde og bygninger' + CRLF +
            '3030;Af- og nedskrivninger af produktionsanlæg og maskiner' + CRLF +
            '3040;Af- og nedskrivninger af indretning af lejede lokaler' + CRLF +
            '3050;Af- og nedskrivninger af andre anlæg, driftsmateriel og inventar' + CRLF +
            '3060;Af- og nedskrivninger af software' + CRLF +
            '3070;Af- og nedskrivninger af finansielt leasede grunde og bygninger' + CRLF +
            '3080;Af- og nedskrivninger af finansielt leasede produktionsanlæg og maskiner' + CRLF +
            '3090;Af- og nedskrivninger af finansielt leasede andre anlæg, driftsmateriel og inventar' + CRLF +
            '3095;Privat andel af af- og nedskrivninger (kun klasse A)' + CRLF +
            '3097;Gevinst ved salg af andre anlæg, driftsmateriel og inventar blandet benyttet (kun klasse A)' + CRLF +
            '3099;Tab ved salg af andre anlæg, driftsmateriel og inventar blandet benyttet (kun klasse A)' + CRLF +
            '3100;Af- og nedskrivninger af materielle og immaterielle anlægsaktiver' + CRLF +
            '3130;Nedskrivning af omsætningsaktiver, som overstiger normale nedskrivninger' + CRLF +
            '3140;Nedskrivning af omsætningsaktiver, som overstiger normale nedskrivninger' + CRLF +
            '3160;Tab ved salg af immaterielle anlægsaktiver' + CRLF +
            '3165;Tab ved salg af materielle anlægsaktiver' + CRLF +
            '3170;Øvrige andre driftsomkostninger' + CRLF +
            '3175;Andre driftsomkostninger' + CRLF +
            '3185;Værdireguleringer af investeringsejendomme' + CRLF +
            '3190;Dagsværdiregulering af investeringsejendomme' + CRLF +
            '3193;Modtagne udbytter fra tilknyttede virksomheder' + CRLF +
            '3194;Gevinst ved afhændelse af kapitalandele i tilknyttede virksomheder' + CRLF +
            '3196;Tab ved afhændelse af kapitalandele i tilknyttede virksomheder' + CRLF +
            '3197;Nedskrivning af kapitalandele i tilknyttede virksomheder' + CRLF +
            '3198;Tilbageførsel af nedskrivning af kapitalandele i tilknyttede virksomheder' + CRLF +
            '3200;Øvrige indtægter af kapitalandele i tilknyttede virksomheder' + CRLF +
            '3205;Indtægter af kapitalandele i tilknyttede virksomheder' + CRLF +
            '3211;Modtagne udbytter fra associerede virksomheder' + CRLF +
            '3212;Gevinst ved afhændelse af kapitalandele i associerede virksomheder' + CRLF +
            '3214;Tab ved afhændelse af kapitalandele i associerede virksomheder' + CRLF +
            '3215;Nedskrivning af kapitalandele i associerede virksomheder' + CRLF +
            '3216;Tilbageførsel af nedskrivning af kapitalandele i associerede virksomheder' + CRLF +
            '3217;Øvrige indtægter af kapitalandele i associerede virksomheder' + CRLF +
            '3219;Indtægter af kapitalandele i associerede virksomheder' + CRLF +
            '3221;Modtagne udbytter fra kapitalinteresser' + CRLF +
            '3222;Gevinst ved afhændelse af kapitalinteresser' + CRLF +
            '3224;Tab ved afhændelse af kapitalinteresser' + CRLF +
            '3225;Nedskrivning af kapitalinteresser' + CRLF +
            '3226;Tilbageførsel af nedskrivning af kapitalinteresser' + CRLF +
            '3230;Øvrige indtægter af kapitalinteresser' + CRLF +
            '3240;Indtægter af kapitalinteresser' + CRLF +
            '3250;Indtægter af kapitalandele i tilknyttede og associerede virksomheder' + CRLF +
            '3252;Resultatandele, der hidrører fra tilknyttede virksomheder' + CRLF +
            '3260;Resultatandele, der hidrører fra tilknyttede virksomheder' + CRLF +
            '3262;Resultatandele, der hidrører fra associerede virksomheder' + CRLF +
            '3270;Resultatandele, der hidrører fra associerede virksomheder' + CRLF +
            '3272;Resultatandele, der hidrører fra kapitalinteresser' + CRLF +
            '3280;Resultatandele, der hidrører fra kapitalinteresser' + CRLF +
            '3380;Udbytte fra unoterede porteføljeaktier (bruttoudbytte)' + CRLF +
            '3385;Kursgevinster af andre kapitalandele, værdipapirer og tilgodehavender, der er anlægsaktiver' + CRLF +
            '3390;Renteindtægter af andre kapitalandele, værdipapirer og tilgodehavender, der er anlægsaktiver' + CRLF +
            '3395;Værdiregulering af andre kapitalandele og værdipaprer, der er anlægsaktiver' + CRLF +
            '3400;Øvrige indtægter af andre kapitalandele, værdipapirer og tilgodehavender, der er anlægsaktiver' + CRLF +
            '3410;Indtægter af andre kapitalandele, værdipapirer og tilgodehavender, der er anlægsaktiver' + CRLF +
            '3440;Andre finansielle indtægter fra tilknyttede virksomheder' + CRLF +
            '3445;Renteindtægter fra tilknyttede virksomheder' + CRLF +
            '3450;Andre finansielle indtægter fra tilknyttede virksomheder' + CRLF +
            '3470;Renter fra banker' + CRLF +
            '3490;Renter vedr. tilgodehavende fra salg af varer og tjenesteydelser' + CRLF +
            '3510;Rentetillæg mv. fra det offentlige (ej skattepligtig)' + CRLF +
            '3530;Øvrige finansielle indtægter' + CRLF +
            '3535;Valutakursregulering (gevinst)' + CRLF +
            '3536;Værdiregulering af børsnoterede værdipapirer, der er omsætningsaktiver' + CRLF +
            '3537;Værdiregulering af andre kapitalandele og værdipaprer, der er omsætningsaktiver' + CRLF +
            '3540;Andre finansielle indtægter' + CRLF +
            '3560;Nedskrivning af finansielle anlægs- og omsætningsaktiver' + CRLF +
            '3570;Nedskrivning af finansielle aktiver' + CRLF +
            '3590;Finansielle omkostninger, der hidrører fra tilknyttede virksomheder' + CRLF +
            '3596;Valutakursreguleringer, udenlandske dattervirksomheder' + CRLF +
            '3600;Finansielle omkostninger, der hidrører fra tilknyttede virksomheder' + CRLF +
            '3610;Valutakursregulering (tab)' + CRLF +
            '3630;Kurstab på likvider, bankgæld og prioritetsgæld' + CRLF +
            '3640;Renter på finansiel leasinggæld' + CRLF +
            '3650;Renter vedr. leverandører af varer og tjenesteydelser' + CRLF +
            '3670;Renter til banker og realkreditinstitutter' + CRLF +
            '3675;Renter til det offentlige (ej fradragsberettiget skattemæssigt)' + CRLF +
            '3690;Øvrige finansielle omkostninger' + CRLF +
            '3700;Andre finansielle omkostninger' + CRLF +
            '3701;Øvrige finansielle omkostninger' + CRLF +
            '3702;Resultat før skat' + CRLF +
            '3740;Årets skat (skat af årets skattepligtige indkomst)' + CRLF +
            '3760;Årets regulering af udskudt skat' + CRLF +
            '3780;Regulering af skat vedrørende tidligere år' + CRLF +
            '3790;Skat af årets resultat' + CRLF +
            '3810;Andre skatter' + CRLF +
            '3820;Andre skatter' + CRLF +
            '4999;Årets resultat' + CRLF +
            '5010;Færdiggjort udviklingsprojekter, herunder patenter og lignende rettigheder, der stammer fra udviklingsprojekter, Kostpris primo' + CRLF +
            '5011;Færdiggjort udviklingsprojekter, herunder patenter og lignende rettigheder, der stammer fra udviklingsprojekter, Årets tilgange' + CRLF +
            '5012;Færdiggjort udviklingsprojekter, herunder patenter og lignende rettigheder, der stammer fra udviklingsprojekter, Årets afgange' + CRLF +
            '5015;Færdiggjort udviklingsprojekter, herunder patenter og lignende rettigheder, der stammer fra udviklingsprojekter, Intern overførsel til/fra andre poster' + CRLF +
            '5020;Færdiggjort udviklingsprojekter, herunder patenter og lignende rettigheder, der stammer fra udviklingsprojekter, opskrivninger primo' + CRLF +
            '5021;Færdiggjort udviklingsprojekter, herunder patenter og lignende rettigheder, der stammer fra udviklingsprojekter, Årets opskrivninger' + CRLF +
            '5022;Færdiggjort udviklingsprojekter, herunder patenter og lignende rettigheder, der stammer fra udviklingsprojekter, årets tilbageførsler af tidligere års opskrivninger' + CRLF +
            '5030;Færdiggjort udviklingsprojekter, herunder patenter og lignende rettigheder, der stammer fra udviklingsprojekter, Af- og nedskrivninger primo' + CRLF +
            '5031;Færdiggjort udviklingsprojekter, herunder patenter og lignende rettigheder, der stammer fra udviklingsprojekter, Årets af- og nedskrivninger' + CRLF +
            '5032;Færdiggjort udviklingsprojekter, herunder patenter og lignende rettigheder, der stammer fra udviklingsprojekter, Tilbageførte af- og nedskrivninger' + CRLF +
            '5040;Færdiggjort udviklingsprojekter, herunder patenter og lignende rettigheder, der stammer fra udviklingsprojekter' + CRLF +
            '5042;Erhvervede immaterielle anlægsaktiver, kostpris primo' + CRLF +
            '5043;Erhvervede immaterielle anlægsaktiver, årets tilgange' + CRLF +
            '5044;Erhvervede immaterielle anlægsaktiver, årets afgange' + CRLF +
            '5050;Erhvervede immaterielle anlægsaktiver, Opskrivninger primo' + CRLF +
            '5051;Erhvervede immaterielle anlægsaktiver, Årets opskrivninger' + CRLF +
            '5052;Erhvervede immaterielle anlægsaktiver, Tilbageførte opskrivninger fra tidligere år' + CRLF +
            '5055;Erhvervede immaterielle anlægsaktiver, Af- og nedskrivninger primo' + CRLF +
            '5056;Erhvervede immaterielle anlægsaktiver, årets af- og nedskrivninger' + CRLF +
            '5057;Erhvervede immaterielle anlægsaktiver, tilbageførte af- og nedskrivninger' + CRLF +
            '5060;Erhvervede immaterielle anlægsaktiver' + CRLF +
            '5062;Goodwill, kostpris primo' + CRLF +
            '5063;Goodwill, årets tilgange' + CRLF +
            '5064;Goodwill, årets afgange' + CRLF +
            '5075;Goodwill, af- og nedskrivninger primo' + CRLF +
            '5076;Goodwill, årets af- og nedskrivninger' + CRLF +
            '5077;Goodwill, tilbageførte afskrivninger' + CRLF +
            '5079;Goodwill' + CRLF +
            '5085;Udviklingsprojekter under udførelse og forudbetalinger for immaterielle anlægsaktiver, Kostpris primo' + CRLF +
            '5090;Udviklingsprojekter under udførelse og forudbetalinger for immaterielle anlægsaktiver, Årets tilgange' + CRLF +
            '5095;Udviklingsprojekter under udførelse og forudbetalinger for immaterielle anlægsaktiver, Årets afgange' + CRLF +
            '5100;Udviklingsprojekter under udførelse og forudbetalinger for immaterielle anlægsaktiver, Intern overførsel til/fra andre poster' + CRLF +
            '5110;Udviklingsprojekter under udførelse og forudbetalinger for immaterielle anlægsaktiver, Af- og nedskrivninger primo' + CRLF +
            '5111;Udviklingsprojekter under udførelse og forudbetalinger for immaterielle anlægsaktiver, Årets af- og nedskrivninger' + CRLF +
            '5112;Udviklingsprojekter under udførelse og forudbetalinger for immaterielle anlægsaktiver, Tilbageførte af- og nedskrivninger' + CRLF +
            '5120;Udviklingsprojekter under udførelse og forudbetalinger for immaterielle anlægsaktiver' + CRLF +
            '5141;Immaterielle anlægsaktiver' + CRLF +
            '5160;Investeringsejendomme, kostpris primo' + CRLF +
            '5170;Investeringsejendomme, årets tilgange' + CRLF +
            '5180;Investeringsejendomme, årets afgange' + CRLF +
            '5185;Investeringsejendomme, intern overførsel til/fra andre poster' + CRLF +
            '5190;Investeringsejendomme, årets forbedringer' + CRLF +
            '5200;Investeringsejendomme, værdireguleringer primo' + CRLF +
            '5201;Investeringsejendomme, årets værdireguleringer' + CRLF +
            '5205;Investeringsejendomme, Af- og nedskrivninger primo' + CRLF +
            '5210;Investeringsejendomme, årets af- og nedskrivninger' + CRLF +
            '5220;Investeringsejendomme, tilbageførte af- og nedskrivninger' + CRLF +
            '5230;Investeringsejendomme' + CRLF +
            '5240;Investeringsejendomme under opførelse, kostpris primo' + CRLF +
            '5250;Investeringsejendomme under opførelse, årets tilgange' + CRLF +
            '5260;Investeringsejendomme under opførelse, årets afgange' + CRLF +
            '5265;Investeringsejendomme, intern overførsel til/fra andre poster' + CRLF +
            '5280;Investeringsejendomme under opførelse, øvrige værdireguleringer primo' + CRLF +
            '5281;Investeringsejendomme under opførelse, årets værdireguleringer' + CRLF +
            '5282;Investeringsejendomme under opførelse, nedskrivninger, primo' + CRLF +
            '5290;Investeringsejendomme under opførelse, årets nedskrivninger' + CRLF +
            '5300;Investeringsejendomme under opførelse, tilbageførte nedskrivninger' + CRLF +
            '5310;Investeringsejendomme under opførelse' + CRLF +
            '5320;Grunde og bygninger, kostpris primo' + CRLF +
            '5330;Grunde og bygninger, årets tilgange' + CRLF +
            '5340;Grunde og bygninger, årets afgange' + CRLF +
            '5350;Grunde og bygninger, årets forbedringer' + CRLF +
            '5370;Grunde og bygninger, værdireguleringer primo' + CRLF +
            '5371;Grunde og bygninger, årets værdireguleringer' + CRLF +
            '5372;Grunde og bygninger, Af- og nedskrivninger primo' + CRLF +
            '5390;Grunde og bygninger, årets af- og nedskrivninger' + CRLF +
            '5400;Grunde og bygninger, tilbageførte af- og nedskrivninger' + CRLF +
            '5410;Grunde og bygninger' + CRLF +
            '5420;Produktionsanlæg og maskiner, kostpris primo' + CRLF +
            '5430;Produktionsanlæg og maskiner, årets tilgange' + CRLF +
            '5440;Produktionsanlæg og maskiner, årets afgange' + CRLF +
            '5450;Produktionsanlæg og maskiner, Værdireguleringer primo' + CRLF +
            '5451;Produktionsanlæg og maskiner, Årets værdireguleringer' + CRLF +
            '5452;Produktionsanlæg og maskiner, Af- og nedskrivninger primo' + CRLF +
            '5470;Produktionsanlæg og maskiner, årets af- og nedskrivninger' + CRLF +
            '5480;Produktionsanlæg og maskiner, tilbageførte af- og nedskrivninger' + CRLF +
            '5490;Produktionsanlæg og maskiner' + CRLF +
            '5500;Indretning af lejede lokaler, kostpris primo' + CRLF +
            '5510;Indretning af lejede lokaler, årets tilgange' + CRLF +
            '5520;Indretning af lejede lokaler, årets afgange' + CRLF +
            '5530;Indretning af lejede lokaler, Værdireguleringer primo' + CRLF +
            '5531;Indretning af lejede lokaler, Årets værdireguleringer' + CRLF +
            '5532;Indretning af lejede lokaler, Af- og nedskrivninger primo' + CRLF +
            '5540;Indretning af lejede lokaler, årets af- og nedskrivninger' + CRLF +
            '5550;Indretning af lejede lokaler, tilbageførte af- og nedskrivninger' + CRLF +
            '5560;Indretning af lejede lokaler' + CRLF +
            '5570;Andre anlæg, driftsmateriel og inventar, kostpris primo' + CRLF +
            '5580;Andre anlæg, driftsmateriel og inventar, årets tilgange' + CRLF +
            '5590;Andre anlæg, driftsmateriel og inventar, årets afgange' + CRLF +
            '5600;Andre anlæg, driftsmateriel og inventar, Værdireguleringer primo' + CRLF +
            '5601;Andre anlæg, driftsmateriel og inventar, Årets værdireguleringer' + CRLF +
            '5602;Andre anlæg, driftsmateriel og inventar, Af- og nedskrivninger primo' + CRLF +
            '5610;Andre anlæg, driftsmateriel og inventar, årets af- og nedskrivninger' + CRLF +
            '5620;Andre anlæg, driftsmateriel og inventar, tilbageførte af- og nedskrivninger' + CRLF +
            '5630;Andre anlæg, driftsmateriel og inventar' + CRLF +
            '5640;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, kostpris primo' + CRLF +
            '5650;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, årets tilgange' + CRLF +
            '5660;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, årets afgange' + CRLF +
            '5670;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, værdireguleringer primo' + CRLF +
            '5671;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, årets værdireguleringer' + CRLF +
            '5675;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, nedskrivninger primo' + CRLF +
            '5676;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, årets nedskrivninger' + CRLF +
            '5677;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, tilbageførte nedskrivninger' + CRLF +
            '5680;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver' + CRLF +
            '5682;Andre anlæg, driftsmateriel og inventar blandet benyttet, kostpris primo (kun klasse A)' + CRLF +
            '5683;Andre anlæg, driftsmateriel og inventar blandet benyttet, Årets tilgange (kun klasse A)' + CRLF +
            '5684;Andre anlæg, driftsmateriel og inventar blandet benyttet, Årets afgange (kun klasse A)' + CRLF +
            '5685;Andre anlæg, driftsmateriel og inventar blandet benyttet, Værdireguleringer primo (kun klasse A)' + CRLF +
            '5686;Andre anlæg, driftsmateriel og inventar blandet benyttet, Årets værdireguleringer (kun klasse A)' + CRLF +
            '5687;Andre anlæg, driftsmateriel og inventar blandet benyttet, Af- og nedskrivninger primo (kun klasse A)' + CRLF +
            '5688;Andre anlæg, driftsmateriel og inventar blandet benyttet, Årets af- og nedskrivninger (kun klasse A)' + CRLF +
            '5689;Andre anlæg, driftsmateriel og inventar blandet benyttet, tilbageførte af- og nedskrivninger (kun klasse A)' + CRLF +
            '5690;Andre anlæg, driftsmateriel og inventar blandet benyttet, Gevinst og tab (kun klasse A)' + CRLF +
            '5695;Andre anlæg, driftsmateriel og inventar blandet benyttet (kun klasse A)' + CRLF +
            '5710;Finansielt leasede aktiver, Kostpris primo' + CRLF +
            '5720;Finansielt leasede aktiver, årets tilgange' + CRLF +
            '5730;Finansielt leasede aktiver, årets afgange' + CRLF +
            '5740;Finansielt leasede aktiver, værdireguleringer primo' + CRLF +
            '5741;Finansielt leasede aktiver, årets værdireguleringer' + CRLF +
            '5745;Finansielt leasede aktiver, af- og nedskrivninger primo' + CRLF +
            '5750;Finansielt leasede aktiver, årets af- og nedskrivninger' + CRLF +
            '5760;Finansielt leasede aktiver, tilbageførte af- og nedskrivninger' + CRLF +
            '5770;Finansielt leasede aktiver' + CRLF +
            '5771;Materielle anlægsaktiver' + CRLF +
            '5800;Kapitalandele i tilknyttede virksomheder, kostpris primo' + CRLF +
            '5810;Kapitalandele i tilknyttede virksomheder, årets tilgange' + CRLF +
            '5820;Kapitalandele i tilknyttede virksomheder, årets afgange' + CRLF +
            '5825;Kapitalandele i tilknyttede virksomheder, intern overførsel til/fra andre poster' + CRLF +
            '5829;Kapitalandele i tilknyttede virksomheder, opskrivninger primo' + CRLF +
            '5830;Kapitalandele i tilknyttede virksomheder, årets opskrivninger' + CRLF +
            '5831;Kapitalandele i tilknyttede virksomheder, årets tilbageførsler af tidligere års opskrivninger' + CRLF +
            '5835;Kapitalandele i tilknyttede virksomheder, nedskrivninger primo' + CRLF +
            '5836;Kapitalandele i tilknyttede virksomheder, årets nedskrivninger' + CRLF +
            '5837;Kapitalandele i tilknyttede virksomheder, årets tilbageførsler af tidligere års nedskrivninger' + CRLF +
            '5840;Kapitalandele i tilknyttede virksomheder' + CRLF +
            '5842;Tilgodehavender hos tilknyttede virksomheder (anlægsaktiv)' + CRLF +
            '5843;Tilgodehavender hos tilknyttede virksomheder, nedskrivninger primo (anlægsaktiv)' + CRLF +
            '5844;Tilgodehavender hos tilknyttede virksomheder, nedskrivninger i årets løb (anlægsaktiv)' + CRLF +
            '5845;Tilgodehavender hos tilknyttede virksomheder, tilbageførsel af tidligere års nedskrivninger (anlægsaktiv)' + CRLF +
            '5850;Tilgodehavender hos tilknyttede virksomheder (anlægsaktiv)' + CRLF +
            '5852;Kapitalandele i associerede virksomheder, kostpris primo' + CRLF +
            '5853;Kapitalandele i associerede virksomheder, årets tilgange' + CRLF +
            '5854;Kapitalandele i associerede virksomheder, årets afgange' + CRLF +
            '5855;Kapitalandele i associerede virksomheder, intern overførsel til/fra andre poster' + CRLF +
            '5860;Kapitalandele i associerede virksomheder, opskrivninger primo' + CRLF +
            '5861;Kapitalandele i associerede virksomheder, årets opskrivninger' + CRLF +
            '5862;Kapitalandele i associerede virksomheder, årets tilbageførsler af tidligere års opskrivninger' + CRLF +
            '5870;Kapitalandele i associerede virksomheder, nedskrivninger primo' + CRLF +
            '5871;Kapitalandele i associerede virksomheder, årets nedskrivninger' + CRLF +
            '5872;Kapitalandele i associerede virksomheder, årets tilbageførsler af tidligere års nedskrivninger' + CRLF +
            '5880;Kapitalandele i associerede virksomheder' + CRLF +
            '5882;Tilgodehavender hos associerede virksomheder (anlægsaktiv)' + CRLF +
            '5883;Tilgodehavender hos associerede virksomheder, nedskrivninger primo (anlægsaktiv)' + CRLF +
            '5884;Tilgodehavender hos associerede virksomheder, nedskrivninger i årets løb (anlægsaktiv)' + CRLF +
            '5885;Tilgodehavender hos associerede virksomheder, tilbageførsel af tidligere års nedskrivninger (anlægsaktiv)' + CRLF +
            '5890;Tilgodehavender hos associerede virksomheder (anlægsaktiv)' + CRLF +
            '5900;Kapitalinteresser, kostpris primo' + CRLF +
            '5910;Kapitalinteresser, årets tilgange' + CRLF +
            '5920;Kapitalinteresser, årets afgange' + CRLF +
            '5925;Kapitalinteresser, intern overførsel til/fra andre poster' + CRLF +
            '5929;Kapitalinteresser, opskrivninger primo' + CRLF +
            '5930;Kapitalinteresser, årets opskrivninger' + CRLF +
            '5931;Kapitalinteresser, årets tilbageførsler af tidligere års opskrivninger' + CRLF +
            '5935;Kapitalinteresser, nedskrivninger primo' + CRLF +
            '5940;Kapitalinteresser, årets nedskrivninger' + CRLF +
            '5950;Kapitalinteresser, årets tilbageførsler af tidligere års nedskrivninger' + CRLF +
            '5960;Kapitalinteresser' + CRLF +
            '5970;Tilgodehavender hos kapitalinteresser (anlægsaktiv)' + CRLF +
            '5980;Tilgodehavender hos kapitalinteresser, nedskrivninger primo (anlægsaktiv)' + CRLF +
            '5984;Tilgodehavender hos kapitalinteresser, nedskrivninger i årets løb (anlægsaktiv)' + CRLF +
            '5985;Tilgodehavender hos kapitalinteresser, tilbageførsel af tidligere års nedskrivninger (anlægsaktiv)' + CRLF +
            '5990;Tilgodehavender hos kapitalinteresser (anlægsaktiv)' + CRLF +
            '6000;Andre værdipapirer og kapitalandele' + CRLF +
            '6010;Andre værdipapirer og kapitalandele' + CRLF +
            '6020;Udskudte skatteaktiver (anlægsaktiv)' + CRLF +
            '6030;Øvrige tilgodehavender (anlægsaktiv)' + CRLF +
            '6040;Deposita (anlægsaktiv)' + CRLF +
            '6050;Andre tilgodehavender (anlægsaktiv)' + CRLF +
            '6061;Tilgodehavender hos direktionen (anlægsaktiv)' + CRLF +
            '6062;Tilgodehavender hos bestyrelsen (anlægsaktiv)' + CRLF +
            '6063;Tilgodehavender hos tilsynsråd (anlægsaktiv)' + CRLF +
            '6064;Tilgodehavender hos repræsentantskab (anlægsaktiv)' + CRLF +
            '6070;Tilgodehavender hos virksomhedsdeltagere og ledelse (anlægsaktiv)' + CRLF +
            '6071;Finansielle anlægsaktiver' + CRLF +
            '6072;Anlægsaktiver i alt' + CRLF +
            '6080;Råvarer og hjælpematerialer, kostpris primo' + CRLF +
            '6081;Råvarer og hjælpematerialer, årets tilgange' + CRLF +
            '6082;Råvarer og hjælpematerialer, årets afgange' + CRLF +
            '6083;Råvarer og hjælpematerialer, intern overførsel til/fra andre poster' + CRLF +
            '6085;Råvarer og hjælpematerialer, nedskrivninger primo' + CRLF +
            '6090;Råvarer og hjælpematerialer, årets nedskrivning' + CRLF +
            '6091;Råvarer og hjælpematerialer, tilbageførsel af tidligere års nedskrivninger' + CRLF +
            '6100;Råvarer og hjælpematerialer' + CRLF +
            '6110;Varer under fremstilling, kostpris primo' + CRLF +
            '6111;Varer under fremstilling, årets tilgange' + CRLF +
            '6112;Varer under fremstilling, årets afgange' + CRLF +
            '6113;Varer under fremstilling, intern overførsel til/fra andre poster' + CRLF +
            '6115;Varer under fremstilling, nedskrivninger primo' + CRLF +
            '6120;Varer under fremstilling, årets nedskrivning' + CRLF +
            '6121;Varer under fremstilling, tilbageførsel af tidligere års nedskrivninger' + CRLF +
            '6130;Varer under fremstilling' + CRLF +
            '6140;Fremstillede varer og handelsvarer, kostpris primo' + CRLF +
            '6141;Fremstillede varer og handelsvarer, årets tilgange' + CRLF +
            '6142;Fremstillede varer og handelsvarer, årets afgange' + CRLF +
            '6143;Fremstillede varer og handelsvarer, intern overførsel til/fra andre poster' + CRLF +
            '6145;Fremstillede varer og handelsvarer, nedskrivninger primo' + CRLF +
            '6150;Fremstillede varer og handelsvarer, årets nedskrivning' + CRLF +
            '6151;Fremstillede varer og handelsvarer, tilbageførsel af tidligere års nedskrivninger' + CRLF +
            '6160;Fremstillede varer og handelsvarer' + CRLF +
            '6170;Forudbetalinger for varer' + CRLF +
            '6180;Forudbetalinger for varer' + CRLF +
            '6181;Varebeholdninger' + CRLF +
            '6190;Tilgodehavender fra salg og tjenesteydelser' + CRLF +
            '6200;Tilgodehavender fra salg og tjenesteydelser, nedskrivninger primo' + CRLF +
            '6201;Nedskrivninger i årets løb' + CRLF +
            '6202;Tilbageførsel af tidligere års nedskrivninger' + CRLF +
            '6210;Tilgodehavender fra salg og tjenesteydelser' + CRLF +
            '6240;Igangværende arbejder for fremmed regning' + CRLF +
            '6250;Igangværende arbejder for fremmed regning' + CRLF +
            '6252;Tilgodehavender hos tilknyttede virksomheder (omsætningsaktiv)' + CRLF +
            '6255;Tilgodehavender hos tilknyttede virksomheder, nedskrivninger primo (omsætningsaktiv)' + CRLF +
            '6256;Tilgodehavender hos tilknyttede virksomheder, nedskrivninger i årets løb' + CRLF +
            '6257;Tilgodehavender hos tilknyttede virksomheder, tilbageførsel af tidligere års nedskrivninger (omsætningsaktiv)' + CRLF +
            '6260;Tilgodehavender hos tilknyttede virksomheder (omsætningsaktiv)' + CRLF +
            '6262;Tilgodehavender hos associerede virksomheder (omsætningsaktiv)' + CRLF +
            '6265;Tilgodehavender hos associerede virksomheder, nedskrivninger primo (omsætningsaktiv)' + CRLF +
            '6266;Tilgodehavender hos associerede virksomheder, nedskrivninger i årets løb (omsætningsaktiv)' + CRLF +
            '6267;Tilgodehavender hos associerede virksomheder, tilbageførsel af tidligere års nedskrivninger (omsætningsaktiv)' + CRLF +
            '6270;Tilgodehavender hos associerede virksomheder (omsætningsaktiv)' + CRLF +
            '6282;Tilgodehavender hos kapitalinteresser (omsætningsaktiv)' + CRLF +
            '6285;Tilgodehavender hos kapitalinteresser, nedskrivninger primo (omsætningsaktiv)' + CRLF +
            '6286;Tilgodehavender hos kapitalinteresser, nedskrivninger i årets løb (omsætningsaktiv)' + CRLF +
            '6287;Tilgodehavender hos kapitalinteresser, tilbageførsel af tidligere års nedskrivninger (omsætningsaktiv)' + CRLF +
            '6290;Tilgodehavender hos kapitalinteresser (omsætningsaktiv)' + CRLF +
            '6305;Udskudte skatteaktiver (omsætningsaktiv)' + CRLF +
            '6310;Tilgodehavende kildeskat (omsætningsaktiv)' + CRLF +
            '6315;Tilgodehavende selskabsskat (omsætningsaktiv)' + CRLF +
            '6320;Tilgodehavende moms (kortfristede)' + CRLF +
            '6330;Øvrige tilgodehavender (kortfristede)' + CRLF +
            '6340;Andre tilgodehavender (kortfristede)' + CRLF +
            '6350;Krav på indbetaling af virksomhedskapital og overkurs' + CRLF +
            '6360;Krav på indbetaling af virksomhedskapital og overkurs' + CRLF +
            '6365;Tilgodehavender hos direktionen (omsætningsaktiv)' + CRLF +
            '6370;Tilgodehavender hos bestyrelsens (omsætningsaktiv)' + CRLF +
            '6375;Tilgodehavender hos tilsynsråd (omsætningsaktiv)' + CRLF +
            '6376;Tilgodehavender hos repræsentantskab (omsætningsaktiv)' + CRLF +
            '6380;Tilgodehavender hos virksomhedsdeltagere og ledelse (omsætningsaktiv)' + CRLF +
            '6390;Periodeafgrænsningsposter, der kan opretholdes skattemæssigt' + CRLF +
            '6400;Periodeafgrænsningsposter, der ikke kan opretholdes skattemæssigt' + CRLF +
            '6410;Periodeafgrænsningsposter' + CRLF +
            '6411;Tilgodehavender' + CRLF +
            '6420;Kapitalandele i tilknyttede virksomheder som ikke er bestemt til vedvarende eje' + CRLF +
            '6430;Kapitalandele i tilknyttede virksomheder' + CRLF +
            '6450;Andre værdipapirer og kapitalandele som ikke er bestemt til vedvarende eje' + CRLF +
            '6460;Andre værdipapirer og kapitalandele' + CRLF +
            '6461;Værdipapirer og kapitalandele' + CRLF +
            '6470;Likvide beholdninger' + CRLF +
            '6480;Bankkonto' + CRLF +
            '6490;Likvide beholdninger' + CRLF +
            '6491;Omsætningsaktiver i alt' + CRLF +
            '6499;AKTIVER I ALT' + CRLF +
            '6510;Registreret kapital mv.' + CRLF +
            '6520;Indbetalt registreret kapital mv.' + CRLF +
            '6525;Ikke indbetalt registreret kapital mv.' + CRLF +
            '6530;Virksomhedskapital' + CRLF +
            '6540;Overkurs ved emission' + CRLF +
            '6550;Overkurs ved emission' + CRLF +
            '6560;Reserve for opskrivninger' + CRLF +
            '6570;Reserve for opskrivninger' + CRLF +
            '6800;Reserve for nettoopskrivning efter den indre værdis metode' + CRLF +
            '6810;Reserve for udlån og sikkerhedsstillelse' + CRLF +
            '6830;Reserve for ikke indbetalt virksomhedskapital og overkurs' + CRLF +
            '6840;Reserve for udviklingsomkostninger' + CRLF +
            '6870;Øvrige lovpligtige reserver' + CRLF +
            '6890;Vedtægtsmæssige reserver' + CRLF +
            '6910;Øvrige reserver' + CRLF +
            '6914;Reserve for iværksætterselskaber' + CRLF +
            '6915;Egenkapital primo (kun klasse A)' + CRLF +
            '6916;Årets resultat (kun klasse A)' + CRLF +
            '6917;Fri bil (kun klasse A)' + CRLF +
            '6918;Rejse og befordringsgodtgørelse (kun klasse A)' + CRLF +
            '6919;Fri telefon (Kun klasse A)' + CRLF +
            '6920;Private andele (Kun klasse A)' + CRLF +
            '6921;Private afskrivninger (Kun klasse A)' + CRLF +
            '6922;Driftsudgifter uden fradrag (Kun klasse A)' + CRLF +
            '6923;Privat hævet (kun klasse A)' + CRLF +
            '6924;Privat indskud (kun klasse A)' + CRLF +
            '6930;Andre reserver' + CRLF +
            '6935;Overført resultat, primo' + CRLF +
            '6940;Overført resultat, jf. resultatdisponering' + CRLF +
            '6950;Overført resultat' + CRLF +
            '6955;Foreslået udbytte, primo' + CRLF +
            '6956;Udloddet udbytte' + CRLF +
            '6960;Foreslået udbytte jf. resultatdisponeringen' + CRLF +
            '6970;Foreslået udbytte indregnet under egenkapitalen' + CRLF +
            '6971;Egenkapital i alt' + CRLF +
            '6985;Hensættelser til pensioner og lignende forpligtelser' + CRLF +
            '6990;Hensættelser til pensioner og lignende forpligtelser' + CRLF +
            '7010;Hensættelser til udskudt skat' + CRLF +
            '7030;Hensættelse til udskudt skat' + CRLF +
            '7040;Andre hensatte forpligtelser' + CRLF +
            '7050;Andre hensatte forpligtelser' + CRLF +
            '7051;Hensatte forpligtelser' + CRLF +
            '7055;Gæld, der er optaget ved udstedelse af obligationer (langfristet)' + CRLF +
            '7060;Gæld, der er optaget ved udstedelse af obligationer (langfristet)' + CRLF +
            '7065;Konvertible og udbyttegivende gældsbreve (langfristet)' + CRLF +
            '7070;Konvertible og udbyttegivende gældsbreve (langfristet)' + CRLF +
            '7110;Gæld til kredit- og realkreditinstitutter (langfristet)' + CRLF +
            '7120;Gæld til banker (langfristet)' + CRLF +
            '7125;Leasingforpligtelser (langfristet)' + CRLF +
            '7126;Øvrig langfristet gæld' + CRLF +
            '7130;Gæld til kreditinstitutter (langfristet)' + CRLF +
            '7145;Modtagne forudbetalinger fra kunder (langfristet)' + CRLF +
            '7150;Modtagne forudbetalinger fra kunder (langfristet)' + CRLF +
            '7155;Leverandører af varer og tjenesteydelser (langfristet)' + CRLF +
            '7160;Leverandører af varer og tjenesteydelser (langfristet)' + CRLF +
            '7165;Vekselgæld (langfristet)' + CRLF +
            '7170;Vekselgæld (langfristet)' + CRLF +
            '7175;Gæld til tilknyttede virksomheder (langfristet)' + CRLF +
            '7180;Gæld til tilknyttede virksomheder (langfristet)' + CRLF +
            '7185;Gæld til kapitalinteresser (langfristet)' + CRLF +
            '7190;Gæld til kapitalinteresser (langfristet)' + CRLF +
            '7195;Anden gæld (langfristet)' + CRLF +
            '7210;Gæld til virksomhedssdeltagere og ledelse (langfristet)' + CRLF +
            '7230;Deposita (langfristet)' + CRLF +
            '7240;Leasingforpligtelse (langfristet)' + CRLF +
            '7250;Skyldig selskabsskat (langfristet)' + CRLF +
            '7260;Anden gæld, herunder skyldige skatter og skyldige bidrag til social sikring (langfristet)' + CRLF +
            '7265;Periodeafgrænsningsposter (langfristet)' + CRLF +
            '7270;Periodeafgrænsningsposter (langfristet)' + CRLF +
            '7271;Langfristede gældsforpligtelser' + CRLF +
            '7285;Gæld, der er optaget ved udstedelse af obligationer (kortfristet)' + CRLF +
            '7290;Gæld, der er optaget ved udstedelse af obligationer (kortfristet)' + CRLF +
            '7295;Konvertible og udbyttegivende gældsbreve (kortfristet)' + CRLF +
            '7300;Konvertible og udbyttegivende gældsbreve (kortfristet)' + CRLF +
            '7310;Gæld til kredit- og realkreditinstitutter (kortfristet)' + CRLF +
            '7330;Gæld til banker (kortfristet)' + CRLF +
            '7345;Leasingforpligtelser (kortfristet)' + CRLF +
            '7350;Øvrig kortfristet gæld' + CRLF +
            '7360;Gæld til kreditinstitutter (kortfristet)' + CRLF +
            '7410;Modtagne forudbetalinger fra kunder (kortfristet)' + CRLF +
            '7420;Modtagne forudbetalinger fra kunder (kortfristet)' + CRLF +
            '7440;Leverandører af varer og tjenesteydelser (kortfristet)' + CRLF +
            '7450;Leverandører af varer og tjenesteydelser (kortfristet)' + CRLF +
            '7455;Igangværende arbejder for fremmed regning (kortfristet gæld)' + CRLF +
            '7456;Modtagne acontobetalinger (kortfristet gæld)' + CRLF +
            '7460;Igangværende arbejder for fremmed regning (kortfristet gæld)' + CRLF +
            '7465;Vekselgæld (kortfristet)' + CRLF +
            '7470;Vekselgæld (kortfristet)' + CRLF +
            '7510;Gæld til tilknyttede virksomheder (kortfristet)' + CRLF +
            '7530;Gæld til tilknyttede virksomheder (kortfristet)' + CRLF +
            '7535;Gæld til kapitalinteresser (kortfristet)' + CRLF +
            '7540;Gæld til kapitalinteresser (kortfristet)' + CRLF +
            '7590;Gæld til virksomhedsdeltagere og ledelse (kortfristet)' + CRLF +
            '7610;Deposita (kortfristet)' + CRLF +
            '7680;Salgsmoms' + CRLF +
            '7700;Moms af varekøb udland, EU og ikke-EU' + CRLF +
            '7720;Moms af ydelseskøb udland, EU og ikke-EU' + CRLF +
            '7740;Købsmoms' + CRLF +
            '7760;Olie- og flaskegasafgift' + CRLF +
            '7780;Elafgift' + CRLF +
            '7800;Naturgas- og bygasafgift' + CRLF +
            '7810;Kulafgift' + CRLF +
            '7820;Vandafgift' + CRLF +
            '7830;Co2-afgift' + CRLF +
            '7840;Skyldig moms' + CRLF +
            '7860;Skyldig løn og gager' + CRLF +
            '7880;Skyldig bonus og tantieme' + CRLF +
            '7900;Skyldige feriepenge' + CRLF +
            '7920;Skyldig A-skat' + CRLF +
            '7940;Skyldigt AM-bidrag' + CRLF +
            '7960;Skyldigt ATP-bidrag' + CRLF +
            '7980;Skyldigt AMP-bidrag' + CRLF +
            '8000;Anden skyldig pension' + CRLF +
            '8010;Skyldig arbejdsgiverbidrag (samlet betaling)' + CRLF +
            '8030;Skyldig feriepengeforpligtigelse' + CRLF +
            '8035;Skyldigt ferietillæg' + CRLF +
            '8040;Øvrig anden gæld' + CRLF +
            '8045;Modtagne offentlige tilskud til senere beskatning' + CRLF +
            '8050;Anden gæld, herunder skyldige skatter og skyldige bidrag til social sikring' + CRLF +
            '8070;Periodeafgrænsningsposter (kortfristet)' + CRLF +
            '8080;Periodeafgrænsningsposter (kortfristet)' + CRLF +
            '9950;Kortfristede gældsforpligtelser' + CRLF +
            '9999;PASSIVER I ALT');
    end;

    local procedure GetStandardAccountsCSV(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        CRLF: Text[2];
    begin
        CRLF := TypeHelper.CRLFSeparator();

        exit(
            '1010;Salg af varer og ydelser' + CRLF +
            '1050;Salg af varer udland, EU' + CRLF +
            '1100;Salg af varer udland, ikke-EU' + CRLF +
            '1150;Salg af ydelser udland, EU' + CRLF +
            '1200;Salg af ydelser udland, ikke-EU' + CRLF +
            '1300;Regulering igangværende arbejder' + CRLF +
            '1350;Værdireguleringer af investeringsejendomme' + CRLF +
            '1410;Varelagerregulering på lagre af færdigvarer og varer under fremstilling' + CRLF +
            '1430;Nedskrivning på lagre af færdigvarer og varer under fremstilling' + CRLF +
            '1460;Øvrige ændringer på lagre af færdigvarer og varer under fremstilling' + CRLF +
            '1510;Gevinst ved salg af immaterielle anlægsaktiver' + CRLF +
            '1530;Gevinst ved salg af materielle anlægsaktiver' + CRLF +
            '1540;Gevinst ved salg af finansielle anlægsaktiver' + CRLF +
            '1550;Øvrige andre driftsindtægter' + CRLF +
            '1610;Varekøb' + CRLF +
            '1630;Varekøb udland, EU' + CRLF +
            '1650;Varekøb udland, ikke-EU' + CRLF +
            '1660;Ydelseskøb' + CRLF +
            '1710;Ydelseskøb udland, EU' + CRLF +
            '1740;Ydelseskøb, udland, ikke-EU' + CRLF +
            '1770;Varelagerregulering på lagre af råvarer og hjælpematerialer' + CRLF +
            '1800;Nedskrivning på varelager' + CRLF +
            '1820;Andre eksterne omkostninger' + CRLF +
            '1830;Fragtomkostninger' + CRLF +
            '1850;Annoncering og reklame' + CRLF +
            '1870;Udstillinger og dekoration' + CRLF +
            '1890;Restaurationsbesøg' + CRLF +
            '1910;Repræsentationsomkostninger, skattemæssigt begrænset fradrag' + CRLF +
            '1930;Repræsentationsomkostninger, fuld fradragsret skattemæssigt' + CRLF +
            '1950;Andre salgsomkostninger' + CRLF +
            '1970;Aviser og blade' + CRLF +
            '1990;Gaver og blomster' + CRLF +
            '2030;Husleje, ekskl. el, vand og varme' + CRLF +
            '2050;El' + CRLF +
            '2060;Elafgift' + CRLF +
            '2070;Vand' + CRLF +
            '2080;Varme' + CRLF +
            '2090;Vandafgift' + CRLF +
            '2100;Olie- og flaskegasafgift' + CRLF +
            '2110;Kulafgift' + CRLF +
            '2120;Naturgas- og bygasafgift' + CRLF +
            '2130;Co2-afgift' + CRLF +
            '2140;Øvrige afgifter' + CRLF +
            '2150;Rengøring og renovation (affaldshåndtering)' + CRLF +
            '2160;Reparation og vedligeholdelse' + CRLF +
            '2170;Reparation og vedligeholdelse, ejendom skattemæssigt afskrivningsberettiget, bygning 1' + CRLF +
            '2180;Forsikringer' + CRLF +
            '2190;Ejendomsskatter' + CRLF +
            '2200;Andre lokaleomkostninger' + CRLF +
            '2230;Småanskaffelser under skattemæssig grænse for småaktiver' + CRLF +
            '2240;Småanskaffelser over skattemæssig grænse for småaktiver' + CRLF +
            '2250;Underleverandører' + CRLF +
            '2260;Forsknings- og udviklingsomkostninger' + CRLF +
            '2270;Øvrige produktionsomkostninger' + CRLF +
            '2280;Konstaterede tab på tilgodehavender fra salg og tjenesteydelser' + CRLF +
            '2290;Regulering af nedskrivning på tilgodehavender fra salg og tjenesteydelser' + CRLF +
            '2300;Regulering af tilgodehavender fra tilknyttede virksomheder og associerede virksomheder' + CRLF +
            '2310;It-udstyr mv.' + CRLF +
            '2330;Skattefri rejse- og befordringsgodtgørelse' + CRLF +
            '2350;Kantineudgifter' + CRLF +
            '2370;Kontingenter' + CRLF +
            '2380;Faglitteratur' + CRLF +
            '2390;Porto og gebyrer' + CRLF +
            '2410;Telefon og internet mv. (kun virksomhed)' + CRLF +
            '2420;Telefon og internet mv. (delvist privat)' + CRLF +
            '2450;Kontorartikler' + CRLF +
            '2460;Leje og operationelle leasingydelser (ekskl. husleje)' + CRLF +
            '2470;Rejseudgifter' + CRLF +
            '2480;Vikarassistance' + CRLF +
            '2510;Konsulentydelser' + CRLF +
            '2520;Kursusudgifter' + CRLF +
            '2530;Leasingomkostninger, personbiler' + CRLF +
            '2540;Driftsomkostninger, personbiler' + CRLF +
            '2560;Driftsomkostninger, varebiler' + CRLF +
            '2620;Parkeringsudgifter' + CRLF +
            '2630;Biludgifter efter statens takster' + CRLF +
            '2640;Fri bil' + CRLF +
            '2650;Arbejdsskadeforsikring' + CRLF +
            '2660;Offentlige gebyrer og bøder (ej fradragsberettiget skattemæssigt)' + CRLF +
            '2670;Revision og regnskabsmæssig assistance' + CRLF +
            '2680;Advokatmæssig assistance' + CRLF +
            '2690;Øvrige rådgivningshonorarer' + CRLF +
            '2700;Ej skattemæssigt fradragsberettigede rådgivningshonorarer' + CRLF +
            '2710;Administrationsvederlag/management fee' + CRLF +
            '2720;Øreafrunding/kassedifferencer' + CRLF +
            '2810;Andre eksterne omkostninger' + CRLF +
            '2850;Lønninger' + CRLF +
            '2860;Feriepengeforpligtelse' + CRLF +
            '2870;Jubilæumsgratiale og fratrædelsesgodtgørelse' + CRLF +
            '2880;Bestyrelseshonorar' + CRLF +
            '2890;AM Bidragspligtig A-Indkomst' + CRLF +
            '2900;AM Bidragsfri A-Indkomst' + CRLF +
            '2910;Pensioner' + CRLF +
            '2920;Vederlag til afløsning af pensionstilsagn' + CRLF +
            '2930;Omkostninger til social sikring' + CRLF +
            '2940;AER/ AUB' + CRLF +
            '2950;ATP' + CRLF +
            '2960;Andre personaleomkostninger' + CRLF +
            '2965;Personalegoder' + CRLF +
            '2968;Lønrefusioner' + CRLF +
            '2970;Udbetalte skattefrie godtgørelser i form af kørepenge og diæter' + CRLF +
            '2980;Lønsumsafgift' + CRLF +
            '3000;Af- og nedskrivninger af erhvervede immaterielle anlægsaktiver' + CRLF +
            '3010;Af- og nedskrivninger af goodwill' + CRLF +
            '3020;Af- og nedskrivninger af grunde og bygninger' + CRLF +
            '3030;Af- og nedskrivninger af produktionsanlæg og maskiner' + CRLF +
            '3040;Af- og nedskrivninger af indretning af lejede lokaler' + CRLF +
            '3050;Af- og nedskrivninger af andre anlæg, driftsmateriel og inventar' + CRLF +
            '3060;Af- og nedskrivninger af software' + CRLF +
            '3070;Af- og nedskrivninger af finansielt leasede grunde og bygninger' + CRLF +
            '3080;Af- og nedskrivninger af finansielt leasede produktionsanlæg og maskiner' + CRLF +
            '3090;Af- og nedskrivninger af finansielt leasede andre anlæg, driftsmateriel og inventar' + CRLF +
            '3130;Nedskrivninger af omsætningsaktiver, som overstiger normale nedskrivninger' + CRLF +
            '3160;Tab ved salg af immaterielle anlægsaktiver' + CRLF +
            '3170;Tab ved salg af materielle anlægsaktiver' + CRLF +
            '3180;Øvrige andre driftsomkostninger' + CRLF +
            '3200;Indtægter af kapitalandele i tilknyttede virksomheder' + CRLF +
            '3230;Indtægter af kapitalandele i kapitalinteresser' + CRLF +
            '3380;Udbytte fra unoterede porteføljeaktier (bruttoudbytte)' + CRLF +
            '3400;Øvrige indtægter af andre kapitalandele, værdipapirer og tilgodehavender, der er anlægsaktiver' + CRLF +
            '3440;Andre finansielle indtægter fra tilknyttede virksomheder' + CRLF +
            '3470;Renter fra banker' + CRLF +
            '3490;Renter vedr. tilgodehavende fra salg af varer og tjenesteydelser' + CRLF +
            '3510;Rentetillæg mv. fra det offentlige (ej skattepligtig)' + CRLF +
            '3530;Øvrige finansielle indtægter' + CRLF +
            '3560;Nedskrivning af finansielle aktiver' + CRLF +
            '3590;Finansielle omkostninger, der hidrører fra tilknyttede virksomheder' + CRLF +
            '3610;Valutakursreguleringer' + CRLF +
            '3620;Valutakursreguleringer, udenlandske dattervirksomheder' + CRLF +
            '3630;Kurstab på likvider, bankgæld og prioritetsgæld' + CRLF +
            '3640;Renter på finansiel leasinggæld' + CRLF +
            '3650;Renter vedr. leverandører af varer og tjenesteydelser' + CRLF +
            '3670;Renter til banker og realkreditinstitutter' + CRLF +
            '3675;Renter til det offentlige (ej fradragsberettiget skattemæssigt)' + CRLF +
            '3680;Værdireguleringer af investeringsejendomme' + CRLF +
            '3690;Andre finansielle omkostninger' + CRLF +
            '3740;Aktuel skat' + CRLF +
            '3760;Ændring af udskudt skat' + CRLF +
            '3780;Regulering vedrørende tidligere år' + CRLF +
            '3810;Andre skatter' + CRLF +
            '5010;Goodwill, bogført værdi primo' + CRLF +
            '5020;Goodwill, årets tilgange' + CRLF +
            '5030;Goodwill, årets afgange' + CRLF +
            '5040;Goodwill, øvrige værdireguleringer' + CRLF +
            '5050;Goodwill, årets af- og nedskrivninger' + CRLF +
            '5060;Goodwill, tilbageførte af- og nedskrivninger' + CRLF +
            '5080;Erhvervede immaterielle anlægsaktiver, bogført værdi primo' + CRLF +
            '5090;Erhvervede immaterielle anlægsaktiver, årets tilgange' + CRLF +
            '5100;Erhvervede immaterielle anlægsaktiver, årets afgange' + CRLF +
            '5110;Erhvervede immaterielle anlægsaktiver, øvrige værdireguleringer' + CRLF +
            '5120;Erhvervede immaterielle anlægsaktiver, årets af- og nedskrivninger' + CRLF +
            '5130;Erhvervede immaterielle anlægsaktiver, tilbageførte af- og nedskrivninger' + CRLF +
            '5160;Investeringsejendomme, bogført værdi primo' + CRLF +
            '5170;Investeringsejendomme, årets tilgange' + CRLF +
            '5180;Investeringsejendomme, årets afgange' + CRLF +
            '5190;Investeringsejendomme, årets forbedringer' + CRLF +
            '5200;Investeringsejendomme, øvrige værdireguleringer' + CRLF +
            '5210;Investeringsejendomme, årets af- og nedskrivninger' + CRLF +
            '5220;Investeringsejendomme, tilbageførte af- og nedskrivninger' + CRLF +
            '5240;Investeringsejendomme under opførelse, bogført værdi primo' + CRLF +
            '5250;Investeringsejendomme under opførelse, årets tilgange' + CRLF +
            '5260;Investeringsejendomme under opførelse, årets afgange' + CRLF +
            '5270;Investeringsejendomme under opførelse, årets forbedringer' + CRLF +
            '5280;Investeringsejendomme under opførelse, øvrige værdireguleringer' + CRLF +
            '5290;Investeringsejendomme under opførelse, årets nedskrivninger' + CRLF +
            '5300;Investeringsejendomme under opførelse, tilbageførte nedskrivninger' + CRLF +
            '5320;Grunde og bygninger, bogført værdi primo' + CRLF +
            '5330;Grunde og bygninger, årets tilgange' + CRLF +
            '5340;Grunde og bygninger, årets afgange' + CRLF +
            '5350;Grunde og bygninger, årets forbedringer' + CRLF +
            '5370;Grunde og bygninger, øvrige værdireguleringer' + CRLF +
            '5390;Grunde og bygninger, årets af- og nedskrivninger' + CRLF +
            '5400;Grunde og bygninger, tilbageførte af- og nedskrivninger' + CRLF +
            '5420;Produktionsanlæg og maskiner, bogført værdi primo' + CRLF +
            '5430;Produktionsanlæg og maskiner, årets tilgange' + CRLF +
            '5440;Produktionsanlæg og maskiner, årets afgange' + CRLF +
            '5450;Produktionsanlæg og maskiner, øvrige værdireguleringer' + CRLF +
            '5470;Produktionsanlæg og maskiner, årets af- og nedskrivninger' + CRLF +
            '5480;Produktionsanlæg og maskiner, tilbageførte af- og nedskrivninger' + CRLF +
            '5500;Indretning af lejede lokaler, bogført værdi primo' + CRLF +
            '5510;Indretning af lejede lokaler, årets tilgange' + CRLF +
            '5520;Indretning af lejede lokaler, årets afgange' + CRLF +
            '5530;Indretning af lejede lokaler, øvrige værdireguleringer' + CRLF +
            '5540;Indretning af lejede lokaler, årets af- og nedskrivninger' + CRLF +
            '5550;Indretning af lejede lokaler, tilbageførte af- og nedskrivninger' + CRLF +
            '5570;Andre anlæg, driftsmateriel og inventar, bogført værdi primo' + CRLF +
            '5580;Andre anlæg, driftsmateriel og inventar, årets tilgange' + CRLF +
            '5590;Andre anlæg, driftsmateriel og inventar, årets afgange' + CRLF +
            '5600;Andre anlæg, driftsmateriel og inventar, øvrige værdireguleringer' + CRLF +
            '5610;Andre anlæg, driftsmateriel og inventar, årets af- og nedskrivninger' + CRLF +
            '5620;Andre anlæg, driftsmateriel og inventar, tilbageførte af- og nedskrivninger' + CRLF +
            '5640;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, bogført værdi primo' + CRLF +
            '5650;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, årets tilgange' + CRLF +
            '5660;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, årets afgange' + CRLF +
            '5670;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, øvrige værdireguleringer' + CRLF +
            '5680;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, årets nedskrivninger' + CRLF +
            '5690;Materielle anlægsaktiver under udførelse og forudbetalinger for materielle anlægsaktiver, tilbageførte nedskrivninger' + CRLF +
            '5710;Finansielt leasede aktiver, bogført værdi primo' + CRLF +
            '5720;Finansielt leasede aktiver, årets tilgange' + CRLF +
            '5730;Finansielt leasede aktiver, årets afgange' + CRLF +
            '5740;Finansielt leasede aktiver, øvrige værdireguleringer' + CRLF +
            '5750;Finansielt leasede aktiver, årets af- og nedskrivninger' + CRLF +
            '5760;Finansielt leasede aktiver, tilbageførte af- og nedskrivninger' + CRLF +
            '5800;Kapitalandele i tilknyttede virksomheder, bogført værdi primo' + CRLF +
            '5810;Kapitalandele i tilknyttede virksomheder, årets tilgange' + CRLF +
            '5820;Kapitalandele i tilknyttede virksomheder, årets afgange' + CRLF +
            '5830;Kapitalandele i tilknyttede virksomheder, øvrige værdireguleringer' + CRLF +
            '5840;Kapitalandele i tilknyttede virksomheder, årets nedskrivninger' + CRLF +
            '5850;Kapitalandele i tilknyttede virksomheder, tilbageførte nedskrivninger' + CRLF +
            '5870;Langfristede tilgodehavender hos tilknyttede virksomheder' + CRLF +
            '5880;Nedskrivning på langfristede tilgodehavender hos tilknyttede virksomheder' + CRLF +
            '5900;Kapitalandele i kapitalinteresser, bogført værdi primo' + CRLF +
            '5910;Kapitalandele i kapitalinteresser, årets tilgange' + CRLF +
            '5920;Kapitalandele i kapitalinteresser, årets afgange' + CRLF +
            '5930;Kapitalandele i kapitalinteresser, øvrige værdireguleringer' + CRLF +
            '5940;Kapitalandele i kapitalinteresser, årets nedskrivninger' + CRLF +
            '5950;Kapitalandele i kapitalinteresser, bogført værdi primo, tilbageførte nedskrivninger' + CRLF +
            '5970;Langfristede tilgodehavender hos kapitalinteresser' + CRLF +
            '5980;Nedskrivning på langfristede tilgodehavender hos kapitalinteresser' + CRLF +
            '6000;Andre værdipapirer og kapitalandele' + CRLF +
            '6020;Udskudte skatteaktiver' + CRLF +
            '6030;Øvrige (langfristede) tilgodehavender' + CRLF +
            '6040;Deposita' + CRLF +
            '6060;Tilgodehavender hos virksomhedsdeltagere og ledelse' + CRLF +
            '6080;Råvarer og hjælpematerialer' + CRLF +
            '6090;Nedskrivning på råvarer og hjælpematerialer' + CRLF +
            '6110;Varer under fremstilling' + CRLF +
            '6120;Nedskrivning på varer under fremstilling' + CRLF +
            '6140;Fremstillede varer og handelsvarer' + CRLF +
            '6150;Nedskrivning på fremstillede varer og handelsvarer' + CRLF +
            '6170;Forudbetalinger for varer' + CRLF +
            '6190;Tilgodehavender fra salg og tjenesteydelser' + CRLF +
            '6200;Akkumulerede nedskrivninger til tab på tilgodehavender fra salg og tjenesteydelser' + CRLF +
            '6220;Kortfristede tilgodehavender hos tilknyttede virksomheder' + CRLF +
            '6230;Akkumulerede nedskrivninger til tab på tilgodehavender fra tilknyttede virksomheder' + CRLF +
            '6240;Kortfristede tilgodehavender hos kapitalinteresser' + CRLF +
            '6250;Akkumulerede nedskrivninger til tab på tilgodehavender fra kapitalinteresser' + CRLF +
            '6260;Kortfristede tilgodehavender hos tilknyttede virksomheder' + CRLF +
            '6270;Igangværende arbejder for fremmed regning' + CRLF +
            '6280;Igangværende arbejder for fremmed regning' + CRLF +
            '6290;Udskudte skatteaktiver' + CRLF +
            '6300;Tilgodehavende selskabsskat (kortfristet)' + CRLF +
            '6310;Tilgodehavende kildeskat' + CRLF +
            '6320;Tilgodehavende moms (kortfristet)' + CRLF +
            '6330;Øvrige tilgodehavender (kortfristede)' + CRLF +
            '6340;Andre tilgodehavender (kortfristede)' + CRLF +
            '6350;Krav på indbetaling af virksomhedskapital og overkurs' + CRLF +
            '6360;Krav på indbetaling af virksomhedskapital og overkurs' + CRLF +
            '6370;Kortfristede tilgodehavender hos virksomhedsdeltagere og ledelse' + CRLF +
            '6380;Kortfristede tilgodehavender hos virksomhedsdeltagere og ledelse' + CRLF +
            '6390;Periodeafgrænsningsposter, der kan opretholdes skattemæssigt' + CRLF +
            '6400;Periodeafgrænsningsposter, der ikke kan opretholdes skattemæssigt' + CRLF +
            '6410;Periodeafgrænsningsposter' + CRLF +
            '6411;Tilgodehavender' + CRLF +
            '6420;Kapitalandele i tilknyttede virksomheder' + CRLF +
            '6430;Kapitalandele i tilknyttede virksomheder' + CRLF +
            '6450;Andre værdipapirer og kapitalandele' + CRLF +
            '6460;Andre værdipapirer og kapitalandele' + CRLF +
            '6461;Værdipapirer og kapitalandele' + CRLF +
            '6470;Likvide beholdninger' + CRLF +
            '6480;Bankkonto' + CRLF +
            '6490;Likvide beholdninger' + CRLF +
            '6510;Registreret kapital mv.' + CRLF +
            '6520;Indbetalt registreret kapital mv.' + CRLF +
            '6530;Virksomhedskapital' + CRLF +
            '6540;Overkurs ved emission' + CRLF +
            '6550;Overkurs ved emission' + CRLF +
            '6560;Reserve for opskrivninger' + CRLF +
            '6570;Reserve for opskrivninger' + CRLF +
            '6580;Reserve for nettoopskrivning efter den indre værdis metode' + CRLF +
            '6590;Reserve for nettoopskrivning efter den indre værdis metode' + CRLF +
            '6810;Reserve for udlån og sikkerhedsstillelse' + CRLF +
            '6830;Reserve for ikke indbetalt virksomhedskapital og overkurs' + CRLF +
            '6870;Øvrige lovpligtige reserver' + CRLF +
            '6890;Vedtægtsmæssige reserver' + CRLF +
            '6910;Øvrige reserver' + CRLF +
            '6930;Andre reserver' + CRLF +
            '6940;Overført resultat' + CRLF +
            '6950;Overført resultat' + CRLF +
            '6960;Foreslået udbytte indregnet under egenkapitalen' + CRLF +
            '6970;Foreslået udbytte indregnet under egenkapitalen' + CRLF +
            '7010;Hensættelser til udskudt skat' + CRLF +
            '7020;Hensættelser til pensioner og lignende forpligtelser' + CRLF +
            '7030;Hensættelse til udskudt skat' + CRLF +
            '7040;Andre hensatte forpligtelser' + CRLF +
            '7050;Andre hensatte forpligtelser' + CRLF +
            '7110;Gæld til kreditinstitutter - langfristet gæld' + CRLF +
            '7120;Gæld til banker - langfristet gæld' + CRLF +
            '7130;Gæld til kreditinstitutter' + CRLF +
            '7160;Gæld til tilknyttede virksomheder - langfristet gæld' + CRLF +
            '7170;Gæld til kapitalinteresser - langfristet gæld' + CRLF +
            '7180;Gæld til tilknyttede virksomheder - langfristet gæld' + CRLF +
            '7190;Anden gæld - langfristet' + CRLF +
            '7210;Gæld til selskabsdeltagere og ledelse - langfristet gæld' + CRLF +
            '7230;Deposita - langfristet gæld' + CRLF +
            '7240;Leasingforpligtelse - langfristet gæld' + CRLF +
            '7250;Selskabsskat - langfristet gæld' + CRLF +
            '7260;Anden gæld, herunder skyldige skatter og skyldige bidrag til social sikring' + CRLF +
            '7310;Gæld til kreditinstitutter - kortfristet gæld' + CRLF +
            '7330;Gæld til banker - kortfristet gæld' + CRLF +
            '7350;Kreditinstitutter i øvrigt' + CRLF +
            '7360;Gæld til kreditinstitutter - kortfristet gæld' + CRLF +
            '7410;Modtagne forudbetalinger fra kunder' + CRLF +
            '7420;Modtagne forudbetalinger fra kunder' + CRLF +
            '7440;Leverandører af varer og tjenesteydelser' + CRLF +
            '7450;Leverandører af varer og tjenesteydelser' + CRLF +
            '7510;Gæld til tilknyttede virksomheder - kortfristet gæld' + CRLF +
            '7520;Gæld til kapitalinteresser - kortfristet gæld' + CRLF +
            '7530;Gæld til tilknyttede virksomheder - kortfristet gæld' + CRLF +
            '7590;Gæld til selskabsdeltagere og ledelse - kortfristet gæld' + CRLF +
            '7610;Deposita - kortfristet gæld' + CRLF +
            '7630;Leasingforpligtelse - kortfristet' + CRLF +
            '7680;Salgsmoms' + CRLF +
            '7700;Moms af varekøb udland, EU og ikke-EU' + CRLF +
            '7720;Moms af ydelseskøb udland, EU og ikke-EU' + CRLF +
            '7740;Købsmoms' + CRLF +
            '7760;Olie- og flaskegasafgift' + CRLF +
            '7780;Elafgift' + CRLF +
            '7800;Naturgas- og bygasafgift' + CRLF +
            '7810;Kulafgift' + CRLF +
            '7820;Vandafgift' + CRLF +
            '7830;Co2-afgift' + CRLF +
            '7840;Skyldig moms' + CRLF +
            '7860;Skyldig løn og gager' + CRLF +
            '7880;Skyldig bonus og tantieme' + CRLF +
            '7900;Skyldige feriepenge' + CRLF +
            '7920;Skyldig A-skat' + CRLF +
            '7940;Skyldigt AM-bidrag' + CRLF +
            '7960;Skyldigt ATP-bidrag' + CRLF +
            '7980;Skyldigt AMP-bidrag' + CRLF +
            '8000;Anden skyldig pension' + CRLF +
            '8040;Øvrig anden gæld' + CRLF +
            '8050;Anden gæld (kortfristet gæld)' + CRLF +
            '8070;Periodeafgrænsningsposter' + CRLF +
            '8080;Periodeafgrænsningsposter');
    end;
}
