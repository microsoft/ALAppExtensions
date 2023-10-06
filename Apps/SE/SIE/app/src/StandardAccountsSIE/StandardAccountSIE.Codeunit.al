// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Reflection;

codeunit 5314 "Standard Account SIE"
{
    procedure GetStandardAccountsCSV(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        CRLF: Text[2];
    begin
        CRLF := TypeHelper.CRLFSeparator();

        exit(
            '7201;2.1 Koncessioner, patent, licenser, varumärken, hyresrätter, goodwill och liknande rättigheter' + CRLF +
            '7202;2.2 Förskott avseende immateriella anläggningstillgångar' + CRLF +
            '7214;2.3 Byggnader och mark' + CRLF +
            '7215;2.4 Maskiner, inventarier och övriga materiella anläggningstillgångar' + CRLF +
            '7216;2.5 Förbättringsutgifter på annans fastighet' + CRLF +
            '7217;2.6 Pågående nyanläggningar och förskott avseende materiella anläggningstillgångar' + CRLF +
            '7230;2.7 Andelar i koncernföretag' + CRLF +
            '7231;2.8 Andelar i intresseföretag och gemensamt styrda företag' + CRLF +
            '7233;2.9 Ägarintresse i övriga företag och andra långfristiga värdepappersinnehav' + CRLF +
            '7232;2.10 Fordringar hos koncern-, intresse och gemensamt styrda företag' + CRLF +
            '7234;2.11 Lån till delägare eller närstående' + CRLF +
            '7235;2.12 Fordringar hos övriga företag som det finns ett ett ägarintresse i och Andra långfristiga fordringar' + CRLF +
            '7241;2.13 Råvaror och förnödenheter' + CRLF +
            '7242;2.14 Varor under tillverkning' + CRLF +
            '7243;2.15 Färdiga varor och handelsvaror' + CRLF +
            '7244;2.16 Övriga lagertillgångar' + CRLF +
            '7245;2.17 Pågående arbeten för annans räkning' + CRLF +
            '7246;2.18 Förskott till leverantörer' + CRLF +
            '7251;2.19 Kundfordringar' + CRLF +
            '7252;2.20 Fordringar hos koncern-, intresse- och gemensamt styrda företag' + CRLF +
            '7261;2.21 Fordringar hos övriga företag som det finns ett ägarintresse i och Övriga fordringar' + CRLF +
            '7262;2.22 Upparbetad men ej fakturerad intäkt' + CRLF +
            '7263;2.23 Förutbetalda kostnader och upplupna intäkter' + CRLF +
            '7270;2.24 Andelar i koncernföretag' + CRLF +
            '7271;2.25 Övriga kortfristiga placeringar' + CRLF +
            '7281;2.26 Kassa, bank och redovisningsmedel' + CRLF +
            '7301;2.27 Bundet eget kapital' + CRLF +
            '7302;2.28 Fritt eget kapital' + CRLF +
            '7321;2.29 Periodiseringsfonder' + CRLF +
            '7322;2.30 Ackumulerade överavskrivningar' + CRLF +
            '7323;2.31 Övriga obeskattade reserver' + CRLF +
            '7331;2.32 Avsättningar för pensioner och liknande förpliktelser enligt lagen (1967:531) om tryggande av pensionsutfästelserr m.m.' + CRLF +
            '7332;2.33 Övriga avsättningar för pensioner och liknande förpliktelser' + CRLF +
            '7333;2.34 Övriga avsättningar' + CRLF +
            '7350;2.35 Obligationslån' + CRLF +
            '7351;2.36 Checkräkningskredit' + CRLF +
            '7352;2.37 Övriga skulder till kreditinstitut' + CRLF +
            '7353;2.38 Skulder till koncern-, intresse och gemensamt styrda företag' + CRLF +
            '7354;2.39 Skulder till övriga företag som det finns ett ägarintresse i och övriga skulder' + CRLF +
            '7360;2.40 Checkräkningskredit' + CRLF +
            '7361;2.41 Övriga skulder till kreditinstitut' + CRLF +
            '7362;2.42 Förskott från kunder' + CRLF +
            '7363;2.43 Pågående arbeten för annans räkning' + CRLF +
            '7364;2.44 Fakturerad men ej upparbetad intäkt' + CRLF +
            '7365;2.45 Leverantörsskulder' + CRLF +
            '7366;2.46 Växelskulder' + CRLF +
            '7367;2.47 Skulder till koncern-, intresse och gemensamt styrda företag' + CRLF +
            '7369;2.48 Skulder till övriga företag som det finns ett ägarintresse i och Övriga skulder' + CRLF +
            '7368;2.49 Skatteskulder' + CRLF +
            '7370;2.50 Upplupna kostnader och förutbetalda intäkter' + CRLF +
            '7410;3.1 Nettoomsättning' + CRLF +
            '7411;3.2 Förändring av lager av produkter i arbete, färdiga varor och pågående arbete för annans räkning' + CRLF +
            '7510;3.2 Förändring av lager av produkter i arbete, färdiga varor och pågående arbete för annans räkning' + CRLF +
            '7412;3.3 Aktiverat arbete för egen räkning' + CRLF +
            '7413;3.4 Övriga rörelseintäkter' + CRLF +
            '7511;3.5 Råvaror och förnödenheter' + CRLF +
            '7512;3.6 Handelsvaror' + CRLF +
            '7513;3.7 Övriga externa kostnader' + CRLF +
            '7514;3.8 Personalkostnader' + CRLF +
            '7515;3.9 Av- och nedskrivningar av materiella och immateriella anläggningstillgångar' + CRLF +
            '7516;3.10 Nedskrivningar av omsättningstillgångar utöver normala nedskrivningar' + CRLF +
            '7517;3.11 Övriga rörelsekostnader' + CRLF +
            '7414;3.12 Resultat från andelar i koncernföretag' + CRLF +
            '7518;3.12 Resultat från andelar i koncernföretag	' + CRLF +
            '7415;3.13 Resultat från andelar i intresseföretag och gemensamt styrda företag' + CRLF +
            '7519;3.13 Resultat från andelar i intresseföretag och gemensamt styrda företag	' + CRLF +
            '7423;3.14 Resultat från övriga företag som det finns ett ägarintresse i' + CRLF +
            '7530;3.14 Resultat från övriga företag som det finns ett ägarintresse i	' + CRLF +
            '7416;3.15 Resultat från övriga anläggningstillgångar' + CRLF +
            '7520;3.15 Resultat från övriga anläggningstillgångar	' + CRLF +
            '7417;3.16 Övriga ränteintäkter och liknande resultatposter' + CRLF +
            '7521;3.17 Nedskrivningar av finansiella anläggningstillgångar och kortfristiga placeringar' + CRLF +
            '7522;3.18 Räntekostnader och liknande resultatposter' + CRLF +
            '7524;3.19 Lämnade koncernbidrag' + CRLF +
            '7419;3.20 Mottagna koncernbidrag' + CRLF +
            '7420;3.21 Återföring av periodiseringsfond' + CRLF +
            '7525;3.22 Avsättning till periodiseringsfond' + CRLF +
            '7421;3.23 Förändring av överavskrivningar' + CRLF +
            '7526;3.23 Förändring av överavskrivningar	' + CRLF +
            '7422;3.24 Övriga bokslutsdispositioner' + CRLF +
            '7527;3.24 Övriga bokslutsdispositioner	' + CRLF +
            '7528;3.25 Skatt på årets resultat' + CRLF +
            '7450;3.26 Årets resultat, vinst (flyttas till p. 4.1)  (+)' + CRLF +
            '7550;3.27 Årets resultat, förlust (flyttas till p. 4.2) (-)');
    end;
}
