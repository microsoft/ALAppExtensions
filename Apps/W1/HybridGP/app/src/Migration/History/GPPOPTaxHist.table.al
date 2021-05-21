table 4064 "GPPOPTaxHist"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; POPRCTNM; text[18])
        {
            Caption = 'POP Receipt Number';
            DataClassification = CustomerContent;
        }
        field(2; RCPTLNNM; Integer)
        {
            Caption = 'Receipt Line Number';
            DataClassification = CustomerContent;
        }
        field(3; TAXDTLID; text[16])
        {
            Caption = 'Tax Detail ID';
            DataClassification = CustomerContent;
        }
        field(4; ACTINDX; Integer)
        {
            Caption = 'Account Index';
            DataClassification = CustomerContent;
        }
        field(5; BKOUTTAX; Boolean)
        {
            Caption = 'Backout Tax';
            DataClassification = CustomerContent;
        }
        field(6; TAXAMNT; Decimal)
        {
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
        }
        field(7; ORTAXAMT; Decimal)
        {
            Caption = 'Originating Tax Amount';
            DataClassification = CustomerContent;
        }
        field(8; TAXPURCH; Decimal)
        {
            Caption = 'Taxable Purchases';
            DataClassification = CustomerContent;
        }
        field(9; ORGTXPCH; Decimal)
        {
            Caption = 'Originating Taxable Purchases';
            DataClassification = CustomerContent;
        }
        field(10; TOTPURCH; Decimal)
        {
            Caption = 'Total Purchases';
            DataClassification = CustomerContent;
        }
        field(11; ORTOTPUR; Decimal)
        {
            Caption = 'Originating Total Purchases';
            DataClassification = CustomerContent;
        }
        field(12; FRTTXAMT; Decimal)
        {
            Caption = 'Freight Tax Amount';
            DataClassification = CustomerContent;
        }
        field(13; ORFRTTAX; Decimal)
        {
            Caption = 'Originating Freight Tax Amount';
            DataClassification = CustomerContent;
        }
        field(14; MSCTXAMT; Decimal)
        {
            Caption = 'Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(15; ORMSCTAX; Decimal)
        {
            Caption = 'Originating Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(16; TXDTOTTX; Decimal)
        {
            Caption = 'Tax Detail Total Tax Potential';
            DataClassification = CustomerContent;
        }
        field(17; OTTAXPON; Decimal)
        {
            Caption = 'Originating Total Tax Potential';
            DataClassification = CustomerContent;
        }
        field(18; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(19; POP_Tax_Note_ID_Array_1; Decimal)
        {
            Caption = 'POP Tax Note ID Array';
            DataClassification = CustomerContent;
        }
        field(20; POP_Tax_Note_ID_Array_2; Decimal)
        {
            Caption = 'POP Tax Note ID Array';
            DataClassification = CustomerContent;
        }
        field(21; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(22; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; POPRCTNM, RCPTLNNM, TAXDTLID, ACTINDX)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
