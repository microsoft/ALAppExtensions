table 4069 "GPSOPDepositHist"
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
        field(3; LNITMSEQ; Integer)
        {
            Caption = 'Line Item Sequence';
            DataClassification = CustomerContent;
        }
        field(4; CUSTNMBR; text[16])
        {
            Caption = 'Customer Number';
            DataClassification = CustomerContent;
        }
        field(5; CUSTNAME; text[66])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(6; DOCDATE; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(7; DOCNUMBR; text[22])
        {
            Caption = 'Document Number';
            DataClassification = CustomerContent;
        }
        field(8; RMDTYPAL; Option)
        {
            Caption = 'RM Document Type-All';
            OptionMembers = ,"Sales/Invoices","Scheduled Payments","Debit Memos","Finance Charges","Service/Repairs","Warranty","Credit Memos","Returns","Payments";
            DataClassification = CustomerContent;
        }
        field(9; PYMTTYPE; Option)
        {
            Caption = 'Payment Type';
            OptionMembers = ,"Cash Deposit","Check Deposit","Credit Card Deposit","Cash Payment","Check Payment","Credit Card Payment";
            DataClassification = CustomerContent;
        }
        field(10; AMNTPAID; Decimal)
        {
            Caption = 'Amount Paid';
            DataClassification = CustomerContent;
        }
        field(11; OAMTPAID; Decimal)
        {
            Caption = 'Originating Amount Paid';
            DataClassification = CustomerContent;
        }
        field(12; CHEKBKID; text[16])
        {
            Caption = 'Checkbook ID';
            DataClassification = CustomerContent;
        }
        field(13; CHEKNMBR; text[22])
        {
            Caption = 'Check Number';
            DataClassification = CustomerContent;
        }
        field(14; CARDNAME; text[16])
        {
            Caption = 'Card Name';
            DataClassification = CustomerContent;
        }
        field(15; RCTNCCRD; text[22])
        {
            Caption = 'Receipt Number Credit Card';
            DataClassification = CustomerContent;
        }
        field(16; EXPNDATE; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;
        }
        field(17; AUTHCODE; text[16])
        {
            Caption = 'Authorization Code';
            DataClassification = CustomerContent;
        }
        field(18; PYMNTDAT; Date)
        {
            Caption = 'Payment Date';
            DataClassification = CustomerContent;
        }
        field(19; GLPOSTDT; Date)
        {
            Caption = 'GL Posting Date';
            DataClassification = CustomerContent;
        }
        field(20; CASHINDEX; Integer)
        {
            Caption = 'Cash Index';
            DataClassification = CustomerContent;
        }
        field(21; DEPINDEX; Integer)
        {
            Caption = 'Deposits Index';
            DataClassification = CustomerContent;
        }
        field(22; DELETE1; Boolean)
        {
            Caption = 'Delete';
            DataClassification = CustomerContent;
        }
        field(23; CURNCYID; text[16])
        {
            Caption = 'Currency ID';
            DataClassification = CustomerContent;
        }
        field(24; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(25; XCHGRATE; Decimal)
        {
            Caption = 'Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(26; DENXRATE; Decimal)
        {
            Caption = 'Denomination Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(27; RATETPID; text[16])
        {
            Caption = 'Rate Type ID';
            DataClassification = CustomerContent;
        }
        field(28; RTCLCMTD; Option)
        {
            Caption = 'Rate Calculation Method';
            OptionMembers = "Multiply","Divide";
            DataClassification = CustomerContent;
        }
        field(29; EXGTBLID; text[16])
        {
            Caption = 'Exchange Table ID';
            DataClassification = CustomerContent;
        }
        field(30; EXCHDATE; Date)
        {
            Caption = 'Exchange Date';
            DataClassification = CustomerContent;
        }
        field(31; MCTRXSTT; Option)
        {
            Caption = 'MC Transaction State';
            OptionMembers = "No Euro","Nondenom to nondenom","Nondenom to Euro","Nondenom to denom","Denom to nondenom","Denom to denom","Denom to Euro","Euro to denom","Euro to nondenom";
            DataClassification = CustomerContent;
        }
        field(32; TIME1; DateTime)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }
        field(33; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(34; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; TRXSORCE, SOPTYPE, SOPNUMBE, LNITMSEQ)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
