// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47043 "SL FlexDef"
{
    Access = Internal;
    Caption = 'SL FlexDef';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Align00; Text[1])
        {
            Caption = 'Align00';
        }
        field(2; Align01; Text[1])
        {
            Caption = 'Align01';
        }
        field(3; Align02; Text[1])
        {
            Caption = 'Align02';
        }
        field(4; Align03; Text[1])
        {
            Caption = 'Align03';
        }
        field(5; Align04; Text[1])
        {
            Caption = 'Align04';
        }
        field(6; Align05; Text[1])
        {
            Caption = 'Align05';
        }
        field(7; Align06; Text[1])
        {
            Caption = 'Align06';
        }
        field(8; Align07; Text[1])
        {
            Caption = 'Align07';
        }
        field(9; Caption; Text[31])
        {
            Caption = 'Caption';
        }
        field(10; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(11; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(12; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(13; Descr00; Text[15])
        {
            Caption = 'Descr00';
        }
        field(14; Descr01; Text[15])
        {
            Caption = 'Descr01';
        }
        field(15; Descr02; Text[15])
        {
            Caption = 'Descr02';
        }
        field(16; Descr03; Text[15])
        {
            Caption = 'Descr03';
        }
        field(17; Descr04; Text[15])
        {
            Caption = 'Descr04';
        }
        field(18; Descr05; Text[15])
        {
            Caption = 'Descr05';
        }
        field(19; Descr06; Text[15])
        {
            Caption = 'Descr06';
        }
        field(20; Descr07; Text[15])
        {
            Caption = 'Descr07';
        }
        field(21; EditMask00; Text[1])
        {
            Caption = 'EditMask00';
        }
        field(22; EditMask01; Text[1])
        {
            Caption = 'EditMask01';
        }
        field(23; EditMask02; Text[1])
        {
            Caption = 'EditMask02';
        }
        field(24; EditMask03; Text[1])
        {
            Caption = 'EditMask03';
        }
        field(25; EditMask04; Text[1])
        {
            Caption = 'EditMask04';
        }
        field(26; EditMask05; Text[1])
        {
            Caption = 'EditMask05';
        }
        field(27; EditMask06; Text[1])
        {
            Caption = 'EditMask06';
        }
        field(28; EditMask07; Text[1])
        {
            Caption = 'EditMask07';
        }
        field(29; fieldclass; Text[3])
        {
            Caption = 'fieldclass';
        }
        field(30; FieldClassName; Text[15])
        {
            Caption = 'FieldClassName';
        }
        field(31; FillChar00; Text[1])
        {
            Caption = 'FillChar00';
        }
        field(32; FillChar01; Text[1])
        {
            Caption = 'FillChar01';
        }
        field(33; FillChar02; Text[1])
        {
            Caption = 'FillChar02';
        }
        field(34; FillChar03; Text[1])
        {
            Caption = 'FillChar03';
        }
        field(35; FillChar04; Text[1])
        {
            Caption = 'FillChar04';
        }
        field(36; FillChar05; Text[1])
        {
            Caption = 'FillChar05';
        }
        field(37; FillChar06; Text[1])
        {
            Caption = 'FillChar06';
        }
        field(38; FillChar07; Text[1])
        {
            Caption = 'FillChar07';
        }
        field(39; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(40; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(41; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(42; MaxFieldLen; Integer)
        {
            Caption = 'MaxFieldLen';
        }
        field(43; MaxSegments; Integer)
        {
            Caption = 'MaxSegments';
        }
        field(44; NumberSegments; Integer)
        {
            Caption = 'NumberSegments';
        }
        field(45; SegLength00; Integer)
        {
            Caption = 'SegLength00';
        }
        field(46; SegLength01; Integer)
        {
            Caption = 'SegLength01';
        }
        field(47; SegLength02; Integer)
        {
            Caption = 'SegLength02';
        }
        field(48; SegLength03; Integer)
        {
            Caption = 'SegLength03';
        }
        field(49; SegLength04; Integer)
        {
            Caption = 'SegLength04';
        }
        field(50; SegLength05; Integer)
        {
            Caption = 'SegLength05';
        }
        field(51; SegLength06; Integer)
        {
            Caption = 'SegLength06';
        }
        field(52; SegLength07; Integer)
        {
            Caption = 'SegLength07';
        }
        field(53; Seperator00; Text[1])
        {
            Caption = 'Seperator00';
        }
        field(54; Seperator01; Text[1])
        {
            Caption = 'Seperator01';
        }
        field(55; Seperator02; Text[1])
        {
            Caption = 'Seperator02';
        }
        field(56; Seperator03; Text[1])
        {
            Caption = 'Seperator03';
        }
        field(57; Seperator04; Text[1])
        {
            Caption = 'Seperator04';
        }
        field(58; Seperator05; Text[1])
        {
            Caption = 'Seperator05';
        }
        field(59; Seperator06; Text[1])
        {
            Caption = 'Seperator06';
        }
        field(60; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(61; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(62; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(63; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(64; Validate00; Integer)
        {
            Caption = 'Validate00';
        }
        field(65; Validate01; Integer)
        {
            Caption = 'Validate01';
        }
        field(66; Validate02; Integer)
        {
            Caption = 'Validate02';
        }
        field(67; Validate03; Integer)
        {
            Caption = 'Validate03';
        }
        field(68; Validate04; Integer)
        {
            Caption = 'Validate04';
        }
        field(69; Validate05; Integer)
        {
            Caption = 'Validate05';
        }
        field(70; Validate06; Integer)
        {
            Caption = 'Validate06';
        }
        field(71; Validate07; Integer)
        {
            Caption = 'Validate07';
        }
        field(72; ValidCombosRequired; Integer)
        {
            Caption = 'ValidCombosRequired';
        }
    }

    keys
    {
        key(Key1; FieldClassName)
        {
            Clustered = true;
        }
    }
}