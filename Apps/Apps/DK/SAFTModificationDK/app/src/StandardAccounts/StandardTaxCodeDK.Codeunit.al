// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Reflection;

codeunit 13696 "Standard Tax Code DK"
{
    Access = Internal;

    procedure GetStandardTaxCodesCSV(): Text
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
            'S7;Rubrik B - oplysninger, der ikke skal indberettes til ”EU-salg uden moms”' + CRLF +
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
}
