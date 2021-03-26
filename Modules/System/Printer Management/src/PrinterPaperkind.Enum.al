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

    /// <summary>
    /// A2 paper (420 mm by 594 mm).
    /// </summary>
    value(66; "A2")
    {
        Caption = 'A2 paper (420 mm by 594 mm).';
    }

    /// <summary>
    /// A3 paper (297 mm by 420 mm).
    /// </summary>
    value(8; "A3")
    {
        Caption = 'A3 paper (297 mm by 420 mm).';
    }

    /// <summary>
    /// A4 paper (210 mm by 297 mm).
    /// </summary>
    value(9; "A4")
    {
        Caption = 'A4 paper (210 mm by 297 mm).';
    }

    /// <summary>
    /// A5 paper (148 mm by 210 mm).
    /// </summary>
    value(11; "A5")
    {
        Caption = 'A5 paper (148 mm by 210 mm).';
    }

    /// <summary>
    /// A6 paper (105 mm by 148 mm).
    /// </summary>
    value(70; "A6")
    {
        Caption = 'A6 paper (105 mm by 148 mm).';
    }

    /// <summary>
    /// B4 paper (250 mm by 353 mm).
    /// </summary>
    value(12; "B4")
    {
        Caption = 'B4 paper (250 mm by 353 mm).';
    }

    /// <summary>
    /// B4 envelope (250 mm by 353 mm).
    /// </summary>
    value(33; "B4Envelope")
    {
        Caption = 'B4 envelope (250 mm by 353 mm).';
    }

    /// <summary>
    /// B5 paper (176 mm by 250 mm).
    /// </summary>
    value(13; "B5")
    {
        Caption = 'B5 paper (176 mm by 250 mm).';
    }

    /// <summary>
    /// B5 envelope (176 mm by 250 mm).
    /// </summary>
    value(34; "B5Envelope")
    {
        Caption = 'B5 envelope (176 mm by 250 mm).';
    }

    /// <summary>
    /// B6 envelope (176 mm by 125 mm).
    /// </summary>
    value(35; "B6Envelope")
    {
        Caption = 'B6 envelope (176 mm by 125 mm).';
    }

    /// <summary>
    /// JIS B6 paper (128 mm by 182 mm).
    /// </summary>
    value(88; "B6Jis")
    {
        Caption = 'JIS B6 paper (128 mm by 182 mm).';
    }

    /// <summary>
    /// C3 envelope (324 mm by 458 mm).
    /// </summary>
    value(29; "C3Envelope")
    {
        Caption = 'C3 envelope (324 mm by 458 mm).';
    }

    /// <summary>
    /// C4 envelope (229 mm by 324 mm).
    /// </summary>
    value(30; "C4Envelope")
    {
        Caption = 'C4 envelope (229 mm by 324 mm).';
    }

    /// <summary>
    /// C5 envelope (162 mm by 229 mm).
    /// </summary>
    value(28; "C5Envelope")
    {
        Caption = 'C5 envelope (162 mm by 229 mm).';
    }

    /// <summary>
    /// C65 envelope (114 mm by 229 mm).
    /// </summary>
    value(32; "C65Envelope")
    {
        Caption = 'C65 envelope (114 mm by 229 mm).';
    }

    /// <summary>
    /// C6 envelope (114 mm by 162 mm).
    /// </summary>
    value(31; "C6Envelope")
    {
        Caption = 'C6 envelope (114 mm by 162 mm).';
    }

    /// <summary>
    /// C paper (17 in. by 22 in.).
    /// </summary>
    value(24; "CSheet")
    {
        Caption = 'C paper (17 in. by 22 in.).';
    }

    /// <summary>
    /// DL envelope (110 mm by 220 mm).
    /// </summary>
    value(27; "DLEnvelope")
    {
        Caption = 'DL envelope (110 mm by 220 mm).';
    }

    /// <summary>
    /// D paper (22 in. by 34 in.).
    /// </summary>
    value(25; "DSheet")
    {
        Caption = 'D paper (22 in. by 34 in.).';
    }

    /// <summary>
    /// E paper (34 in. by 44 in.).
    /// </summary>
    value(26; "ESheet")
    {
        Caption = 'E paper (34 in. by 44 in.).';
    }

    /// <summary>
    /// Executive paper (7.25 in. by 10.5 in.).
    /// </summary>
    value(7; "Executive")
    {
        Caption = 'Executive paper (7.25 in. by 10.5 in.).';
    }

    /// <summary>
    /// Folio paper (8.5 in. by 13 in.).
    /// </summary>
    value(14; "Folio")
    {
        Caption = 'Folio paper (8.5 in. by 13 in.).';
    }

    /// <summary>
    /// German legal fanfold (8.5 in. by 13 in.).
    /// </summary>
    value(41; "GermanLegalFanfold")
    {
        Caption = 'German legal fanfold (8.5 in. by 13 in.).';
    }

    /// <summary>
    /// German standard fanfold (8.5 in. by 12 in.).
    /// </summary>
    value(40; "GermanStandardFanfold")
    {
        Caption = 'German standard fanfold (8.5 in. by 12 in.).';
    }

    /// <summary>
    /// Invitation envelope (220 mm by 220 mm).
    /// </summary>
    value(47; "InviteEnvelope")
    {
        Caption = 'Invitation envelope (220 mm by 220 mm).';
    }

    /// <summary>
    /// ISO B4 (250 mm by 353 mm).
    /// </summary>
    value(42; "IsoB4")
    {
        Caption = 'ISO B4 (250 mm by 353 mm).';
    }

    /// <summary>
    /// Italy envelope (110 mm by 230 mm).
    /// </summary>
    value(36; "ItalyEnvelope")
    {
        Caption = 'Italy envelope (110 mm by 230 mm).';
    }

    /// <summary>
    /// Japanese double postcard (200 mm by 148 mm).
    /// </summary>
    value(69; "JapaneseDoublePostcard")
    {
        Caption = 'Japanese double postcard (200 mm by 148 mm).';
    }

    /// <summary>
    /// Japanese Chou #3 envelope.
    /// </summary>
    value(73; "JapaneseEnvelopeChouNumber3")
    {
        Caption = 'Japanese Chou #3 envelope.';
    }

    /// <summary>
    /// Japanese Chou #4 envelope.
    /// </summary>
    value(74; "JapaneseEnvelopeChouNumber4")
    {
        Caption = 'Japanese Chou #4 envelope.';
    }

    /// <summary>
    /// Japanese Kaku #2 envelope.
    /// </summary>
    value(71; "JapaneseEnvelopeKakuNumber2")
    {
        Caption = 'Japanese Kaku #2 envelope.';
    }

    /// <summary>
    /// Japanese Kaku #3 envelope.
    /// </summary>
    value(72; "JapaneseEnvelopeKakuNumber3")
    {
        Caption = 'Japanese Kaku #3 envelope.';
    }

    /// <summary>
    /// Japanese You #4 envelope.
    /// </summary>
    value(91; "JapaneseEnvelopeYouNumber4")
    {
        Caption = 'Japanese You #4 envelope.';
    }

    /// <summary>
    /// Japanese postcard (100 mm by 148 mm).
    /// </summary>
    value(43; "JapanesePostcard")
    {
        Caption = 'Japanese postcard (100 mm by 148 mm).';
    }

    /// <summary>
    /// Ledger paper (17 in. by 11 in.).
    /// </summary>
    value(4; "Ledger")
    {
        Caption = 'Ledger paper (17 in. by 11 in.).';
    }

    /// <summary>
    /// Legal paper (8.5 in. by 14 in.).
    /// </summary>
    value(5; "Legal")
    {
        Caption = 'Legal paper (8.5 in. by 14 in.).';
    }

    /// <summary>
    /// Letter paper (8.5 in. by 11 in.).
    /// </summary>
    value(1; "Letter")
    {
        Caption = 'Letter paper (8.5 in. by 11 in.).';
    }

    /// <summary>
    /// Monarch envelope (3.875 in. by 7.5 in.).
    /// </summary>
    value(37; "MonarchEnvelope")
    {
        Caption = 'Monarch envelope (3.875 in. by 7.5 in.).';
    }

    /// <summary>
    /// Note paper (8.5 in. by 11 in.).
    /// </summary>
    value(18; "Note")
    {
        Caption = 'Note paper (8.5 in. by 11 in.).';
    }

    /// <summary>
    /// #10 envelope (4.125 in. by 9.5 in.).
    /// </summary>
    value(20; "Number10Envelope")
    {
        Caption = '#10 envelope (4.125 in. by 9.5 in.).';
    }

    /// <summary>
    /// #11 envelope (4.5 in. by 10.375 in.).
    /// </summary>
    value(21; "Number11Envelope")
    {
        Caption = '#11 envelope (4.5 in. by 10.375 in.).';
    }

    /// <summary>
    /// #12 envelope (4.75 in. by 11 in.).
    /// </summary>
    value(22; "Number12Envelope")
    {
        Caption = '#12 envelope (4.75 in. by 11 in.).';
    }

    /// <summary>
    /// #14 envelope (5 in. by 11.5 in.).
    /// </summary>
    value(23; "Number14Envelope")
    {
        Caption = '#14 envelope (5 in. by 11.5 in.).';
    }

    /// <summary>
    /// #9 envelope (3.875 in. by 8.875 in.).
    /// </summary>
    value(19; "Number9Envelope")
    {
        Caption = '#9 envelope (3.875 in. by 8.875 in.).';
    }

    /// <summary>
    /// 6 3/4 envelope (3.625 in. by 6.5 in.).
    /// </summary>
    value(38; "PersonalEnvelope")
    {
        Caption = '6 3/4 envelope (3.625 in. by 6.5 in.).';
    }

    /// <summary>
    /// 16K paper (146 mm by 215 mm).
    /// </summary>
    value(93; "Prc16K")
    {
        Caption = '16K paper (146 mm by 215 mm).';
    }

    /// <summary>
    /// 32K paper (97 mm by 151 mm).
    /// </summary>
    value(94; "Prc32K")
    {
        Caption = '32K paper (97 mm by 151 mm).';
    }

    /// <summary>
    /// #1 envelope (102 mm by 165 mm).
    /// </summary>
    value(96; "PrcEnvelopeNumber1")
    {
        Caption = '#1 envelope (102 mm by 165 mm).';
    }

    /// <summary>
    /// #10 envelope (324 mm by 458 mm).
    /// </summary>
    value(105; "PrcEnvelopeNumber10")
    {
        Caption = '#10 envelope (324 mm by 458 mm).';
    }

    /// <summary>
    /// #2 envelope (102 mm by 176 mm).
    /// </summary>
    value(97; "PrcEnvelopeNumber2")
    {
        Caption = '#2 envelope (102 mm by 176 mm).';
    }

    /// <summary>
    /// #3 envelope (125 mm by 176 mm).
    /// </summary>
    value(98; "PrcEnvelopeNumber3")
    {
        Caption = '#3 envelope (125 mm by 176 mm).';
    }

    /// <summary>
    /// #4 envelope (110 mm by 208 mm).
    /// </summary>
    value(99; "PrcEnvelopeNumber4")
    {
        Caption = '#4 envelope (110 mm by 208 mm).';
    }

    /// <summary>
    /// #5 envelope (110 mm by 220 mm).
    /// </summary>
    value(100; "PrcEnvelopeNumber5")
    {
        Caption = '#5 envelope (110 mm by 220 mm).';
    }

    /// <summary>
    /// #6 envelope (120 mm by 230 mm).
    /// </summary>
    value(101; "PrcEnvelopeNumber6")
    {
        Caption = '#6 envelope (120 mm by 230 mm).';
    }

    /// <summary>
    /// #7 envelope (160 mm by 230 mm).
    /// </summary>
    value(102; "PrcEnvelopeNumber7")
    {
        Caption = '#7 envelope (160 mm by 230 mm).';
    }

    /// <summary>
    /// #8 envelope (120 mm by 309 mm).
    /// </summary>
    value(103; "PrcEnvelopeNumber8")
    {
        Caption = '#8 envelope (120 mm by 309 mm).';
    }

    /// <summary>
    /// #9 envelope (229 mm by 324 mm).
    /// </summary>
    value(104; "PrcEnvelopeNumber9")
    {
        Caption = '#9 envelope (229 mm by 324 mm).';
    }

    /// <summary>
    /// Quarto paper (215 mm by 275 mm).
    /// </summary>
    value(15; "Quarto")
    {
        Caption = 'Quarto paper (215 mm by 275 mm).';
    }

    /// <summary>
    /// Standard paper (10 in. by 11 in.).
    /// </summary>
    value(45; "Standard10x11")
    {
        Caption = 'Standard paper (10 in. by 11 in.).';
    }

    /// <summary>
    /// Standard paper (10 in. by 14 in.).
    /// </summary>
    value(16; "Standard10x14")
    {
        Caption = 'Standard paper (10 in. by 14 in.).';
    }

    /// <summary>
    /// Standard paper (11 in. by 17 in.).
    /// </summary>
    value(17; "Standard11x17")
    {
        Caption = 'Standard paper (11 in. by 17 in.).';
    }

    /// <summary>
    /// Standard paper (12 in. by 11 in.).
    /// </summary>
    value(90; "Standard12x11")
    {
        Caption = 'Standard paper (12 in. by 11 in.).';
    }

    /// <summary>
    /// Standard paper (15 in. by 11 in.).
    /// </summary>
    value(46; "Standard15x11")
    {
        Caption = 'Standard paper (15 in. by 11 in.).';
    }

    /// <summary>
    /// Standard paper (9 in. by 11 in.).
    /// </summary>
    value(44; "Standard9x11")
    {
        Caption = 'Standard paper (9 in. by 11 in.).';
    }

    /// <summary>
    /// Statement paper (5.5 in. by 8.5 in.).
    /// </summary>
    value(6; "Statement")
    {
        Caption = 'Statement paper (5.5 in. by 8.5 in.).';
    }

    /// <summary>
    /// Tabloid paper (11 in. by 17 in.).
    /// </summary>
    value(3; "Tabloid")
    {
        Caption = 'Tabloid paper (11 in. by 17 in.).';
    }

    /// <summary>
    /// US standard fanfold (14.875 in. by 11 in.).
    /// </summary>
    value(39; "USStandardFanfold")
    {
        Caption = 'US standard fanfold (14.875 in. by 11 in.).';
    }

    /// <summary>
    /// Custom. The paper size is defined by the user.
    /// </summary>
    value(0; "Custom")
    {
        Caption = 'Custom. The paper size is defined by the user.';
    }
}
