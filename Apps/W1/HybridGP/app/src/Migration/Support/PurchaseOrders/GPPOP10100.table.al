namespace Microsoft.DataMigration.GP;

table 40137 "GP POP10100"
{
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; PONUMBER; Text[18])
        {
            Caption = 'PONUMBER';
            DataClassification = CustomerContent;
        }
        field(2; POSTATUS; Option)
        {
            Caption = 'POSTATUS';
            OptionMembers = ,"New","Released","Change Order","Received","Closed","Canceled";
            DataClassification = CustomerContent;
        }
        field(3; STATGRP; Integer)
        {
            Caption = 'STATGRP';
            DataClassification = CustomerContent;
        }
        field(4; POTYPE; Option)
        {
            Caption = 'POTYPE';
            OptionMembers = ,"Standard","Drop-Ship","Blanket","Drop-Ship Blanket";
            DataClassification = CustomerContent;
        }
        field(7; DOCDATE; Date)
        {
            Caption = 'DOCDATE';
            DataClassification = CustomerContent;
        }
        field(10; PRMDATE; Date)
        {
            Caption = 'PRMDATE';
            DataClassification = CustomerContent;
        }
        field(14; SHIPMTHD; Text[16])
        {
            Caption = 'SHIPMTHD';
            DataClassification = CustomerContent;
        }
        field(22; VENDORID; Text[16])
        {
            Caption = 'VENDORID';
            DataClassification = CustomerContent;
        }
        field(28; PRSTADCD; Text[16])
        {
            Caption = 'PRSTADCD';
            DataClassification = CustomerContent;
        }
        field(29; CMPNYNAM; Text[66])
        {
            Caption = 'CMPNYNAM';
            DataClassification = CustomerContent;
        }
        field(30; CONTACT; Text[62])
        {
            Caption = 'CONTACT';
            DataClassification = CustomerContent;
        }
        field(31; ADDRESS1; Text[62])
        {
            Caption = 'ADDRESS1';
            DataClassification = CustomerContent;
        }
        field(32; ADDRESS2; Text[62])
        {
            Caption = 'ADDRESS2';
            DataClassification = CustomerContent;
        }
        field(34; CITY; Text[36])
        {
            Caption = 'CITY';
            DataClassification = CustomerContent;
        }
        field(35; STATE; Text[30])
        {
            Caption = 'STATE';
            DataClassification = CustomerContent;
        }
        field(36; ZIPCODE; Text[12])
        {
            Caption = 'ZIPCODE';
            DataClassification = CustomerContent;
        }
        field(38; COUNTRY; Text[62])
        {
            Caption = 'COUNTRY';
            DataClassification = CustomerContent;
        }
        field(43; PYMTRMID; Text[22])
        {
            Caption = 'PYMTRMID';
            DataClassification = CustomerContent;
        }
        field(71; CURNCYID; Text[16])
        {
            Caption = 'CURNCYID';
            DataClassification = CustomerContent;
        }
        field(72; CURRNIDX; Integer)
        {
            Caption = 'CURRNIDX';
            DataClassification = CustomerContent;
        }
        field(73; RATETPID; Text[16])
        {
            Caption = 'RATETPID';
            DataClassification = CustomerContent;
        }
        field(74; EXGTBLID; Text[16])
        {
            Caption = 'EXGTBLID';
            DataClassification = CustomerContent;
        }
        field(75; XCHGRATE; Decimal)
        {
            Caption = 'XCHGRATE';
            DataClassification = CustomerContent;
        }
        field(76; EXCHDATE; Date)
        {
            Caption = 'EXCHDATE';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; PONUMBER)
        {
            Clustered = true;
        }
    }
}