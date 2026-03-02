namespace Microsoft.DataMigration.GP;

table 4059 "GPPOPPOTaxHist"
{
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; PONUMBER; text[18])
        {
            Caption = 'PO Number';
            DataClassification = CustomerContent;
        }
        field(2; ORD; Integer)
        {
            Caption = 'Ord';
            DataClassification = CustomerContent;
        }
        field(3; TAXDTLID; text[16])
        {
            Caption = 'Tax Detail ID';
            DataClassification = CustomerContent;
        }
        field(4; BKOUTTAX; Boolean)
        {
            Caption = 'Backout Tax';
            DataClassification = CustomerContent;
        }
        field(5; TAXAMNT; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
        }
        field(6; ORTAXAMT; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Originating Tax Amount';
            DataClassification = CustomerContent;
        }
        field(7; FRTTXAMT; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Freight Tax Amount';
            DataClassification = CustomerContent;
        }
        field(8; ORFRTTAX; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Originating Freight Tax Amount';
            DataClassification = CustomerContent;
        }
        field(9; MSCTXAMT; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(10; ORMSCTAX; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Originating Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(11; TAXPURCH; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Taxable Purchases';
            DataClassification = CustomerContent;
        }
        field(12; ORGTXPCH; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Originating Taxable Purchases';
            DataClassification = CustomerContent;
        }
        field(13; TOTPURCH; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Total Purchases';
            DataClassification = CustomerContent;
        }
        field(14; ORTOTPUR; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Originating Total Purchases';
            DataClassification = CustomerContent;
        }
        field(15; TXDTOTTX; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Tax Detail Total Tax Potential';
            DataClassification = CustomerContent;
        }
        field(16; OTTAXPON; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'Originating Total Tax Potential';
            DataClassification = CustomerContent;
        }
        field(17; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(18; POP_Tax_Note_ID_Array_1; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'POP Tax Note ID Array';
            DataClassification = CustomerContent;
        }
        field(19; POP_Tax_Note_ID_Array_2; Decimal)
        {
            AutoFormatType = 0;
            Caption = 'POP Tax Note ID Array';
            DataClassification = CustomerContent;
        }
        field(20; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(21; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; PONUMBER, ORD, TAXDTLID)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
