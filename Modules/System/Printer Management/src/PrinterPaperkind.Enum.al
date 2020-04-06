// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the standard paper sizes
/// </summary>
enum 2616 "Printer Paper Kind"
{
    Extensible = false;
    value(66; "A2")
    {
        Caption = 'A2 paper (420 mm by 594 mm).';
    }
    value(8; "A3")
    {
        Caption = 'A3 paper (297 mm by 420 mm).';
    }
    value(9; "A4")
    {
        Caption = 'A4 paper (210 mm by 297 mm).';
    }
    value(11; "A5")
    {
        Caption = 'A5 paper (148 mm by 210 mm).';
    }
    value(70; "A6")
    {
        Caption = 'A6 paper (105 mm by 148 mm).';
    }
    value(12; "B4")
    {
        Caption = 'B4 paper (250 mm by 353 mm).';
    }
    value(33; "B4Envelope")
    {
        Caption = 'B4 envelope (250 mm by 353 mm).';
    }
    value(13; "B5")
    {
        Caption = 'B5 paper (176 mm by 250 mm).';
    }
    value(34; "B5Envelope")
    {
        Caption = 'B5 envelope (176 mm by 250 mm).';
    }
    value(35; "B6Envelope")
    {
        Caption = 'B6 envelope (176 mm by 125 mm).';
    }
    value(88; "B6Jis")
    {
        Caption = 'JIS B6 paper (128 mm by 182 mm).';
    }
    value(29; "C3Envelope")
    {
        Caption = 'C3 envelope (324 mm by 458 mm).';
    }
    value(30; "C4Envelope")
    {
        Caption = 'C4 envelope (229 mm by 324 mm).';
    }
    value(28; "C5Envelope")
    {
        Caption = 'C5 envelope (162 mm by 229 mm).';
    }
    value(32; "C65Envelope")
    {
        Caption = 'C65 envelope (114 mm by 229 mm).';
    }
    value(31; "C6Envelope")
    {
        Caption = 'C6 envelope (114 mm by 162 mm).';
    }
    value(24; "CSheet")
    {
        Caption = 'C paper (17 in. by 22 in.).';
    }
    value(27; "DLEnvelope")
    {
        Caption = 'DL envelope (110 mm by 220 mm).';
    }
    value(25; "DSheet")
    {
        Caption = 'D paper (22 in. by 34 in.).';
    }
    value(26; "ESheet")
    {
        Caption = 'E paper (34 in. by 44 in.).';
    }
    value(7; "Executive")
    {
        Caption = 'Executive paper (7.25 in. by 10.5 in.).';
    }
    value(14; "Folio")
    {
        Caption = 'Folio paper (8.5 in. by 13 in.).';
    }
    value(41; "GermanLegalFanfold")
    {
        Caption = 'German legal fanfold (8.5 in. by 13 in.).';
    }
    value(40; "GermanStandardFanfold")
    {
        Caption = 'German standard fanfold (8.5 in. by 12 in.).';
    }
    value(47; "InviteEnvelope")
    {
        Caption = 'Invitation envelope (220 mm by 220 mm).';
    }
    value(42; "IsoB4")
    {
        Caption = 'ISO B4 (250 mm by 353 mm).';
    }
    value(36; "ItalyEnvelope")
    {
        Caption = 'Italy envelope (110 mm by 230 mm).';
    }
    value(69; "JapaneseDoublePostcard")
    {
        Caption = 'Japanese double postcard (200 mm by 148 mm).';
    }
    value(73; "JapaneseEnvelopeChouNumber3")
    {
        Caption = 'Japanese Chou #3 envelope.';
    }
    value(74; "JapaneseEnvelopeChouNumber4")
    {
        Caption = 'Japanese Chou #4 envelope.';
    }
    value(71; "JapaneseEnvelopeKakuNumber2")
    {
        Caption = 'Japanese Kaku #2 envelope.';
    }
    value(72; "JapaneseEnvelopeKakuNumber3")
    {
        Caption = 'Japanese Kaku #3 envelope.';
    }
    value(91; "JapaneseEnvelopeYouNumber4")
    {
        Caption = 'Japanese You #4 envelope.';
    }
    value(43; "JapanesePostcard")
    {
        Caption = 'Japanese postcard (100 mm by 148 mm).';
    }
    value(4; "Ledger")
    {
        Caption = 'Ledger paper (17 in. by 11 in.).';
    }
    value(5; "Legal")
    {
        Caption = 'Legal paper (8.5 in. by 14 in.).';
    }
    value(1; "Letter")
    {
        Caption = 'Letter paper (8.5 in. by 11 in.).';
    }
    value(37; "MonarchEnvelope")
    {
        Caption = 'Monarch envelope (3.875 in. by 7.5 in.).';
    }
    value(18; "Note")
    {
        Caption = 'Note paper (8.5 in. by 11 in.).';
    }
    value(20; "Number10Envelope")
    {
        Caption = '#10 envelope (4.125 in. by 9.5 in.).';
    }
    value(21; "Number11Envelope")
    {
        Caption = '#11 envelope (4.5 in. by 10.375 in.).';
    }
    value(22; "Number12Envelope")
    {
        Caption = '#12 envelope (4.75 in. by 11 in.).';
    }
    value(23; "Number14Envelope")
    {
        Caption = '#14 envelope (5 in. by 11.5 in.).';
    }
    value(19; "Number9Envelope")
    {
        Caption = '#9 envelope (3.875 in. by 8.875 in.).';
    }
    value(38; "PersonalEnvelope")
    {
        Caption = '6 3/4 envelope (3.625 in. by 6.5 in.).';
    }
    value(93; "Prc16K")
    {
        Caption = '16K paper (146 mm by 215 mm).';
    }
    value(94; "Prc32K")
    {
        Caption = '32K paper (97 mm by 151 mm).';
    }
    value(96; "PrcEnvelopeNumber1")
    {
        Caption = '#1 envelope (102 mm by 165 mm).';
    }
    value(105; "PrcEnvelopeNumber10")
    {
        Caption = '#10 envelope (324 mm by 458 mm).';
    }
    value(97; "PrcEnvelopeNumber2")
    {
        Caption = '#2 envelope (102 mm by 176 mm).';
    }
    value(98; "PrcEnvelopeNumber3")
    {
        Caption = '#3 envelope (125 mm by 176 mm).';
    }
    value(99; "PrcEnvelopeNumber4")
    {
        Caption = '#4 envelope (110 mm by 208 mm).';
    }
    value(100; "PrcEnvelopeNumber5")
    {
        Caption = '#5 envelope (110 mm by 220 mm).';
    }
    value(101; "PrcEnvelopeNumber6")
    {
        Caption = '#6 envelope (120 mm by 230 mm).';
    }
    value(102; "PrcEnvelopeNumber7")
    {
        Caption = '#7 envelope (160 mm by 230 mm).';
    }
    value(103; "PrcEnvelopeNumber8")
    {
        Caption = '#8 envelope (120 mm by 309 mm).';
    }
    value(104; "PrcEnvelopeNumber9")
    {
        Caption = '#9 envelope (229 mm by 324 mm).';
    }
    value(15; "Quarto")
    {
        Caption = 'Quarto paper (215 mm by 275 mm).';
    }
    value(45; "Standard10x11")
    {
        Caption = 'Standard paper (10 in. by 11 in.).';
    }
    value(16; "Standard10x14")
    {
        Caption = 'Standard paper (10 in. by 14 in.).';
    }
    value(17; "Standard11x17")
    {
        Caption = 'Standard paper (11 in. by 17 in.).';
    }
    value(90; "Standard12x11")
    {
        Caption = 'Standard paper (12 in. by 11 in.).';
    }
    value(46; "Standard15x11")
    {
        Caption = 'Standard paper (15 in. by 11 in.).';
    }
    value(44; "Standard9x11")
    {
        Caption = 'Standard paper (9 in. by 11 in.).';
    }
    value(6; "Statement")
    {
        Caption = 'Statement paper (5.5 in. by 8.5 in.).';
    }
    value(3; "Tabloid")
    {
        Caption = 'Tabloid paper (11 in. by 17 in.).';
    }
    value(39; "USStandardFanfold")
    {
        Caption = 'US standard fanfold (14.875 in. by 11 in.).';
    }
    value(0; "Custom")
    {
        Caption = 'Custom. The paper size is defined by the user.';
    }
}
