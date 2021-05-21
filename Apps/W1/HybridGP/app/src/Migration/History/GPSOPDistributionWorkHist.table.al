table 4070 "GPSOPDistributionWorkHist"
{
    ReplicateData = false;
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
        field(3; SEQNUMBR; Integer)
        {
            Caption = 'Sequence Number';
            DataClassification = CustomerContent;
        }
        field(4; DISTTYPE; Option)
        {
            Caption = 'Distribution Type';
            OptionMembers = ,"SALES","RECV","CASH","TAKEN","AVAIL","TRADE","FREIGHT","MISC","TAXES","MARK","COMMEXP","COMMPAY","OTHER","COGS","INV","RETURNS","IN USE","IN SERVICE","DAMAGED","UNIT","DEPOSITS","ROUND","REBATE","RZGAIN","RZLOSS";
            DataClassification = CustomerContent;
        }
        field(5; DistRef; text[32])
        {
            Caption = 'Distribution Reference';
            DataClassification = CustomerContent;
        }
        field(6; ACTINDX; Integer)
        {
            Caption = 'Account Index';
            DataClassification = CustomerContent;
        }
        field(7; DEBITAMT; Decimal)
        {
            Caption = 'Debit Amount';
            DataClassification = CustomerContent;
        }
        field(8; ORDBTAMT; Decimal)
        {
            Caption = 'Originating Debit Amount';
            DataClassification = CustomerContent;
        }
        field(9; CRDTAMNT; Decimal)
        {
            Caption = 'Credit Amount';
            DataClassification = CustomerContent;
        }
        field(10; ORCRDAMT; Decimal)
        {
            Caption = 'Originating Credit Amount';
            DataClassification = CustomerContent;
        }
        field(11; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(12; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(13; POSTED; Boolean)
        {
            Caption = 'Posted';
            DataClassification = CustomerContent;
        }
        field(14; Contract_Exchange_Rate; Decimal)
        {
            Caption = 'Contract Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(15; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; SOPTYPE, SOPNUMBE, SEQNUMBR)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
