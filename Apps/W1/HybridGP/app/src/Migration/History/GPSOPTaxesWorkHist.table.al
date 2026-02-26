namespace Microsoft.DataMigration.GP;

table 4075 "GPSOPTaxesWorkHist"
{
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; SOPTYPE; Option)
        {
            Caption = 'SOP Type';
            OptionMembers = ,"Quote","Order","Invoice","Return","Back Order","FulFillment Order";
            DataClassification = CustomerContent;
        }
        field(2; SOPNUMBE; text[22])
        {
            Caption = 'SOP Number';
            DataClassification = CustomerContent;
        }
        field(3; LNITMSEQ; Integer)
        {
            Caption = 'Line Item Sequence';
            DataClassification = CustomerContent;
        }
        field(4; TAXDTLID; text[16])
        {
            Caption = 'Tax Detail ID';
            DataClassification = CustomerContent;
        }
        field(5; ACTINDX; Integer)
        {
            Caption = 'Account Index';
            DataClassification = CustomerContent;
        }
        field(6; BKOUTTAX; Boolean)
        {
            Caption = 'Backout Tax';
            DataClassification = CustomerContent;
        }
        field(7; TXABLETX; Boolean)
        {
            Caption = 'Taxable Tax';
            DataClassification = CustomerContent;
        }
        field(8; STAXAMNT; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Sales Tax Amount';
            DataClassification = CustomerContent;
        }
        field(9; ORSLSTAX; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Originating Sales Tax Amount';
            DataClassification = CustomerContent;
        }
        field(10; FRTTXAMT; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Freight Tax Amount';
            DataClassification = CustomerContent;
        }
        field(11; ORFRTTAX; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Originating Freight Tax Amount';
            DataClassification = CustomerContent;
        }
        field(12; MSCTXAMT; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(13; ORMSCTAX; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Originating Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(14; TAXDTSLS; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Tax Detail Total Sales';
            DataClassification = CustomerContent;
        }
        field(15; ORTOTSLS; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Originating Total Sales';
            DataClassification = CustomerContent;
        }
        field(16; TDTTXSLS; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Tax Detail Total Taxable Sales';
            DataClassification = CustomerContent;
        }
        field(17; ORTXSLS; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Originating Total Taxable Sales';
            DataClassification = CustomerContent;
        }
        field(18; TXDTOTTX; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Tax Detail Total Tax Potential';
            DataClassification = CustomerContent;
        }
        field(19; OTTAXPON; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Originating Total Tax Potential';
            DataClassification = CustomerContent;
        }
        field(20; DELETE1; Boolean)
        {
            Caption = 'Delete';
            DataClassification = CustomerContent;
        }
        field(21; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(22; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(23; TXDTLPCTAMT; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Tax Detail Percent or Amount';
            DataClassification = CustomerContent;
        }
        field(24; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; SOPTYPE, SOPNUMBE, LNITMSEQ, TAXDTLID)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
