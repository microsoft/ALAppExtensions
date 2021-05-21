table 4055 "GPPOPDistributionHist"
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
        field(2; SEQNUMBR; Integer)
        {
            Caption = 'Sequence Number';
            DataClassification = CustomerContent;
        }
        field(3; ACTINDX; Integer)
        {
            Caption = 'Account Index';
            DataClassification = CustomerContent;
        }
        field(4; CRDTAMNT; Decimal)
        {
            Caption = 'Credit Amount';
            DataClassification = CustomerContent;
        }
        field(5; ORCRDAMT; Decimal)
        {
            Caption = 'Originating Credit Amount';
            DataClassification = CustomerContent;
        }
        field(6; DEBITAMT; Decimal)
        {
            Caption = 'Debit Amount';
            DataClassification = CustomerContent;
        }
        field(7; ORDBTAMT; Decimal)
        {
            Caption = 'Originating Debit Amount';
            DataClassification = CustomerContent;
        }
        field(8; DistRef; text[32])
        {
            Caption = 'Distribution Reference';
            DataClassification = CustomerContent;
        }
        field(9; DISTTYPE; Option)
        {
            Caption = 'Distribution Type';
            OptionMembers = ,"PURCH","TRADE","FREIGHT","MISC","TAX","AVAIL","PAY","OTHER","ACCRUED","ROUND","OVHD","AP-OVHD","CASH","TAKEN","Work in Progress","Unbilled Accounts Receivable","Cost of Goods Sold/Expense","Contra Account","Project Overhead","Unbilled Project Revenue";
            DataClassification = CustomerContent;
        }
        field(10; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(11; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(12; XCHGRATE; Decimal)
        {
            Caption = 'Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(13; VENDORID; text[16])
        {
            Caption = 'Vendor ID';
            DataClassification = CustomerContent;
        }
        field(14; CURNCYID; text[16])
        {
            Caption = 'Currency ID';
            DataClassification = CustomerContent;
        }
        field(15; RATETPID; text[16])
        {
            Caption = 'Rate Type ID';
            DataClassification = CustomerContent;
        }
        field(16; EXGTBLID; text[16])
        {
            Caption = 'Exchange Table ID';
            DataClassification = CustomerContent;
        }
        field(17; EXCHDATE; Date)
        {
            Caption = 'Exchange Date';
            DataClassification = CustomerContent;
        }
        field(18; TIME1; DateTime)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }
        field(19; RATECALC; Option)
        {
            Caption = 'Rate Calc Method';
            OptionMembers = "Multiply","Divide";
            DataClassification = CustomerContent;
        }
        field(20; DENXRATE; Decimal)
        {
            Caption = 'Denomination Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(21; MCTRXSTT; Option)
        {
            Caption = 'MC Transaction State';
            OptionMembers = "No Euro","Nondenom to nondenom","Nondenom to Euro","Nondenom to denom","Denom to nondenom","Denom to denom","Denom to Euro","Euro to denom","Euro to nondenom";
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
        key(PK; POPRCTNM, CURNCYID, VENDORID, DISTTYPE, ACTINDX, XCHGRATE, SEQNUMBR)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
