table 4072 "GPSOPPaymentWorkHist"
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
        field(4; PYMTTYPE; Option)
        {
            Caption = 'Payment Type';
            OptionMembers = ,"Cash Deposit","Check Deposit","Credit Card Deposit","Cash Payment","Check Payment","Credit Card Payment";
            DataClassification = CustomerContent;
        }
        field(5; DOCNUMBR; text[22])
        {
            Caption = 'Document Number';
            DataClassification = CustomerContent;
        }
        field(6; RMDTYPAL; Option)
        {
            Caption = 'RM Document Type-All';
            OptionMembers = ,"Sales/Invoices","Scheduled Payments","Debit Memos","Finance Charges","Service/Repairs","Warranty","Credit Memos","Returns","Payments";
            DataClassification = CustomerContent;
        }
        field(7; CHEKBKID; text[16])
        {
            Caption = 'Checkbook ID';
            DataClassification = CustomerContent;
        }
        field(8; CHEKNMBR; text[22])
        {
            Caption = 'Check Number';
            DataClassification = CustomerContent;
        }
        field(9; CARDNAME; text[16])
        {
            Caption = 'Card Name';
            DataClassification = CustomerContent;
        }
        field(10; RCTNCCRD; text[22])
        {
            Caption = 'Receipt Number Credit Card';
            DataClassification = CustomerContent;
        }
        field(11; AUTHCODE; text[16])
        {
            Caption = 'Authorization Code';
            DataClassification = CustomerContent;
        }
        field(12; AMNTPAID; Decimal)
        {
            Caption = 'Amount Paid';
            DataClassification = CustomerContent;
        }
        field(13; OAMTPAID; Decimal)
        {
            Caption = 'Originating Amount Paid';
            DataClassification = CustomerContent;
        }
        field(14; AMNTREMA; Decimal)
        {
            Caption = 'Amount Remaining';
            DataClassification = CustomerContent;
        }
        field(15; OAMNTREM; Decimal)
        {
            Caption = 'Originating Amount Remaining';
            DataClassification = CustomerContent;
        }
        field(16; DOCDATE; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(17; EXPNDATE; Date)
        {
            Caption = 'Expiration Date';
            DataClassification = CustomerContent;
        }
        field(18; CURNCYID; text[16])
        {
            Caption = 'Currency ID';
            DataClassification = CustomerContent;
        }
        field(19; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(20; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(21; DEPSTATS; Option)
        {
            Caption = 'Deposit Status';
            OptionMembers = "Not posted or transferred","Transferred","History";
            DataClassification = CustomerContent;
        }
        field(22; DELETE1; Boolean)
        {
            Caption = 'Delete';
            DataClassification = CustomerContent;
        }
        field(23; GLPOSTDT; Date)
        {
            Caption = 'GL Posting Date';
            DataClassification = CustomerContent;
        }
        field(24; CASHINDEX; Integer)
        {
            Caption = 'Cash Index';
            DataClassification = CustomerContent;
        }
        field(25; DEPINDEX; Integer)
        {
            Caption = 'Deposits Index';
            DataClassification = CustomerContent;
        }
        field(26; EFTFLAG; Boolean)
        {
            Caption = 'EFT Flag';
            DataClassification = CustomerContent;
        }
        field(27; DEX_ROW_ID; Integer)
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
