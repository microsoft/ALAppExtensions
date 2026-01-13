// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Reflection;

codeunit 13696 "Standard Tax Code DK"
{
    Access = Internal;

    procedure GetStandardTaxCodesBefore2025CSV(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        CRLF: Text[2];
    begin
        CRLF := TypeHelper.CRLFSeparator();

        exit(
            'S1;Salgsmoms (udgående moms)' + CRLF +
            'S0;Skal som udgangspunkt medtages i rubrik C, hvis feks. skibe i udenrigsfart, salg af aviser' + CRLF +
            'S%;Skal ikke medtages i angivelsen' + CRLF +
            'SMF;Skal ikke medtages i angivelsen' + CRLF +
            'Sbrugt;Salgsmoms (udgående moms)' + CRLF +
            'Smargin;Salgsmoms (udgående moms)' + CRLF +
            'Smotor;Salgsmoms (udgående moms)' + CRLF +
            'Sleasing;Salgsmoms (udgående moms)' + CRLF +
            'Skunstnere;Salgsmoms (udgående moms)' + CRLF +
            'Slokal;Skal ikke medtages i angivelsen' + CRLF +
            'S2;Rubrik B - varer ' + CRLF +
            'S7;Rubrik B - oplysninger, der ikke skal indberettes til "EU-salg uden moms"' + CRLF +
            'S3;Rubrik B - ydelser' + CRLF +
            'SMFEU;Skal ikke medtages i angivelsen' + CRLF +
            'S4;Rubrik C - eksport udenfor EU' + CRLF +
            'S5;Rubrik C - eksport udenfor EU' + CRLF +
            'S6;Skal ikke medtages i angivelsen' + CRLF +
            'S-OSS;OSS angivelsen' + CRLF +
            'S-OSS;OSS angivelsen' + CRLF +
            'S-OSS;OSS angivelsen' + CRLF +
            'K1;Købsmoms (indgående moms)' + CRLF +
            'K3;Købsmoms (indgående moms - skønsmæssig andel)' + CRLF +
            'K0;Skal ikke medtages i angivelsen' + CRLF +
            'K7;Købsmoms (indgående moms 66,6%)' + CRLF +
            'K5A;Købsmoms (indgående moms 50%)' + CRLF +
            'K5B;Købsmoms (indgående moms 50% af "pro rata")' + CRLF +
            'KL1;Købsmoms (indgående moms 33,3%)' + CRLF +
            'K25A;Købsmoms (indgående moms 25%)' + CRLF +
            'K25B;Købsmoms (indgående moms 25% af "pro rata")' + CRLF +
            'KL2;Købsmoms (indgående moms - faktura fradrag)' + CRLF +
            'KL3;Købsmoms (indgående moms - faktura pro rata fradrag)' + CRLF +
            'K2;Købsmoms (indgående moms - omsætningsfordeling)' + CRLF +
            'K6;Købsmoms (indgående moms - omsætningsfordeling i sektoren)' + CRLF +
            'K4;Købsmoms (indgående moms - forholdsmæssig andel)' + CRLF +
            'K-brugtmoms;Indgår i særligt beregningsgrundlag' + CRLF +
            'K-marginmoms;Indgår i særligt beregningsgrundlag' + CRLF +
            'K-brugtbil;Indgår i særligt beregningsgrundlag' + CRLF +
            'K-leasingbil;Indgår i særligt beregningsgrundlag' + CRLF +
            'K-DK0-1;Salgsmoms (udgående) og købsmoms (indgående moms)' + CRLF +
            'K-DKO-2;Salgsmoms og købsmoms ( indgående moms omsætningsfordeling)' + CRLF +
            'K-DKO-3;Salgsmoms og købsmoms (indgående moms skønsmæssig andel)' + CRLF +
            'K-DKO-0;Salgsmoms (udgående moms)' + CRLF +
            'K-DKO-4;Salgsmoms og købsmoms ( indgående moms arealfordeling)' + CRLF +
            'K-LokalMoms;Tilbagesøgning efter refusionsordningsreglerne' + CRLF +
            'K-DKO-I;Refusionsordning' + CRLF +
            'K-EU-V-1;Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms)' + CRLF +
            'K-EU-V-3;Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - skønsmæssig andel)' + CRLF +
            'K-EU-V-0;Moms af varekøb i udlandet (både EU og lande uden for EU)' + CRLF +
            'K-EU-V-2;Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - omsætningsfordeling)' + CRLF +
            'K-EU-V-4;Moms af varekøb i udlandet (både EU og lande uden for EU)  samt Købsmoms (indgående moms - forholdsmæssig andel)' + CRLF +
            'K-EU-Y-1;Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms)' + CRLF +
            'K-EU-Y-3;Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - skønsmæssig andel)' + CRLF +
            'K-EU-Y-0;Moms af ydelseskøb i udlandet med omvendt betalingspligt ' + CRLF +
            'K-EU-Y-2;Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - omsætningsfordeling)' + CRLF +
            'K-EU-Y-4;Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - forholdsmæssig andel)' + CRLF +
            'KL-EU-2;Købsmoms (indgående moms - faktura fradrag)' + CRLF +
            'KL-EU-3;Købsmoms (indgående moms - faktura pro rata fradrag)' + CRLF +
            'K-EU-Y-L1;Moms af ydelseskøb i udlandet med omvendt betalingspligt samt Købsmoms (indgående moms 33,3%)' + CRLF +
            'K-EU-MF;Skal ikke medtages i angivelsen' + CRLF +
            'K-%EU-V-1;Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms)' + CRLF +
            'K-%EU-V-3;Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - skønsmæssig andel)' + CRLF +
            'K-%EU-V-0;Moms af varekøb i udlandet (både EU og lande uden for EU)' + CRLF +
            'K-%EU-V-2;Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - omsætningsfordeling)' + CRLF +
            'K-%EU-V-4;Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - forholdsmæssig andel)' + CRLF +
            'K-%EU-Y-1;Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms)' + CRLF +
            'K-%EU-Y-3;Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - skønsmæssig andel)' + CRLF +
            'K-%EU-Y-0;Moms af ydelseskøb i udlandet med omvendt betalingspligt' + CRLF +
            'K-%EU-Y-2;Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - omsætningsfordeling)' + CRLF +
            'K-%EU-Y-4;Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - forholdsmæssig andel)');
    end;

    procedure GetStandardTaxCodes2025CSV(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        CRLF: Text[2];
    begin
        CRLF := TypeHelper.CRLFSeparator();

        exit(
            'S01;Salgsmoms (udgående moms)' + CRLF +
            'S02;Skal som udgangspunkt medtages i rubrik C, hvis feks. skibe i udenrigsfart, salg af aviser' + CRLF +
            'S81;Skal ikke medtages i angivelsen' + CRLF +
            'S82;Skal ikke medtages i angivelsen' + CRLF +
            'S83;Salgsmoms (udgående moms)' + CRLF +
            'S84;Salgsmoms (udgående moms)' + CRLF +
            'S85;Salgsmoms (udgående moms)' + CRLF +
            'S86;Salgsmoms (udgående moms)' + CRLF +
            'S87;Salgsmoms (udgående moms)' + CRLF +
            'S88;Skal ikke medtages i angivelsen' + CRLF +
            'S21;Rubrik B - varer ' + CRLF +
            'S22;Rubrik B - oplysninger, der ikke skal indberettes til "EU-salg uden moms"' + CRLF +
            'S23;Rubrik B - ydelser' + CRLF +
            'S24;Skal ikke medtages i angivelsen' + CRLF +
            'S24;Skal ikke medtages i angivelsen' + CRLF +
            'S25;Skal ikke medtages på momsangivelsen, men som trekantshandel på EU-salgsangivelsen' + CRLF +
            'S41;Rubrik C - eksport udenfor EU.' + CRLF +
            'S42;Rubrik C - eksport udenfor EU.' + CRLF +
            'S43;Skal ikke medtages i angivelsen' + CRLF +
            'S61;OSS angivelsen + momsangivelsens rubrik C' + CRLF +
            'S62;OSS angivelsen + Rubrik B - oplysninger der ikke skal indberettes til "EU-salg uden moms"' + CRLF +
            'S63;OSS angivelsen + Rubrik C' + CRLF +
            'S64;OSS angivelsen (skal ikke angives på momsangivelsen)' + CRLF +
            'S65;OSS angivelsen + rubrik A  - varer' + CRLF +
            'K010;Købsmoms (indgående moms)' + CRLF +
            'K020;Købsmoms (indgående moms - skønsmæssig andel)' + CRLF +
            'K030;Skal ikke medtages i angivelsen' + CRLF +
            'K610;Købsmoms (indgående moms 66,6%)' + CRLF +
            'K040;Købsmoms (indgående moms 50%)' + CRLF +
            'K050;Købsmoms (indgående moms 50% af "pro rata")' + CRLF +
            'K060;Købsmoms (indgående moms 33,3%)' + CRLF +
            'K070;Købsmoms (indgående moms 25%)' + CRLF +
            'K080;Købsmoms (indgående moms 25% af "pro rata")' + CRLF +
            'K090;Købsmoms (indgående moms - faktura fradrag)' + CRLF +
            'K100;Købsmoms (indgående moms - faktura pro rata fradrag)' + CRLF +
            'K110;Købsmoms (indgående moms - omsætningsfordeling)' + CRLF +
            'K120;Købsmoms (indgående moms - omsætningsfordeling i sektoren)' + CRLF +
            'K130;Købsmoms (indgående moms - forholdsmæssig andel)' + CRLF +
            'K620;Indgår i særligt beregningsgrundlag' + CRLF +
            'K630;Indgår i særligt beregningsgrundlag' + CRLF +
            'K640;Indgår i særligt beregningsgrundlag' + CRLF +
            'K650;Indgår i særligt beregningsgrundlag' + CRLF +
            'K660;Salgsmoms (udgående) og købsmoms (indgående moms)' + CRLF +
            'K670;Salgsmoms og købsmoms ( indgående moms omsætningsfordeling)' + CRLF +
            'K680;Salgsmoms og købsmoms (indgående moms skønsmæssig andel)' + CRLF +
            'K690;Salgsmoms (udgående moms)' + CRLF +
            'K700;Salgsmoms og købsmoms ( indgående moms arealfordeling)' + CRLF +
            'K710;Tilbagesøgning efter refusionsordningsreglerne' + CRLF +
            'K720;Angives ikke på momsangivelsen - indgår i opgørelsen ved refusionsordning' + CRLF +
            'K210;Varer + Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms)' + CRLF +
            'K220;Varer + Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms)' + CRLF +
            'K230;Varer + Moms af varekøb i udlandet (både EU og lande uden for EU)' + CRLF +
            'K240;Varer + Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms)' + CRLF +
            'K250;Varer + Moms af varekøb i udlandet (både EU og lande uden for EU)  samt Købsmoms (indgående moms)' + CRLF +
            'K260;Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms)' + CRLF +
            'K270;Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms)' + CRLF +
            'K280;Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt ' + CRLF +
            'K290;Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - omsætningsfordeling)' + CRLF +
            'K300;Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - forholdsmæssig andel)' + CRLF +
            'K310;Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms)' + CRLF +
            'K320;Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms)' + CRLF +
            'K330;Ydelser + Moms af ydelseskøb i udlandet med omvendt betalingspligt samt Købsmoms (indgående moms 33,3%)' + CRLF +
            'K340;Skal ikke medtages i angivelsen' + CRLF +
            'K410;Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms)' + CRLF +
            'K420;Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - skønsmæssig andel)' + CRLF +
            'K430;Moms af varekøb i udlandet (både EU og lande uden for EU)' + CRLF +
            'K440;Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - omsætningsfordeling)' + CRLF +
            'K450;Moms af varekøb i udlandet (både EU og lande uden for EU) og Købsmoms (indgående moms - forholdsmæssig andel)' + CRLF +
            'K460;Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms)' + CRLF +
            'K470;Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - skønsmæssig andel)' + CRLF +
            'K480;Moms af ydelseskøb i udlandet med omvendt betalingspligt' + CRLF +
            'K490;Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - omsætningsfordeling)' + CRLF +
            'K500;Moms af ydelseskøb i udlandet med omvendt betalingspligt og Købsmoms (indgående moms - forholdsmæssig andel)');
    end;
}
