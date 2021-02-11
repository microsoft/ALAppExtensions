table 4066 "GPRMOpen"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; CUSTNMBR; text[16])
        {
            Caption = 'Customer Number';
            DataClassification = CustomerContent;
        }
        field(2; CPRCSTNM; text[16])
        {
            Caption = 'Corporate Customer Number';
            DataClassification = CustomerContent;
        }
        field(3; DOCNUMBR; text[22])
        {
            Caption = 'Document Number';
            DataClassification = CustomerContent;
        }
        field(4; CHEKNMBR; text[22])
        {
            Caption = 'Check Number';
            DataClassification = CustomerContent;
        }
        field(5; BACHNUMB; text[16])
        {
            Caption = 'Batch Number';
            DataClassification = CustomerContent;
        }
        field(6; BCHSOURC; text[16])
        {
            Caption = 'Batch Source';
            DataClassification = CustomerContent;
        }
        field(7; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(8; RMDTYPAL; Option)
        {
            Caption = 'RM Document Type-All';
            OptionMembers = ,"Sales/Invoices","Scheduled Payments","Debit Memos","Finance Charges","Service/Repairs","Warranty","Credit Memos","Returns","Payments";
            DataClassification = CustomerContent;
        }
        field(9; CSHRCTYP; Option)
        {
            Caption = 'Cash Receipt Type';
            OptionMembers = "Check","Cash","Credit Card";
            DataClassification = CustomerContent;
        }
        field(10; CBKIDCRD; text[16])
        {
            Caption = 'Checkbook ID Credit Card';
            DataClassification = CustomerContent;
        }
        field(11; CBKIDCSH; text[16])
        {
            Caption = 'Checkbook ID Cash';
            DataClassification = CustomerContent;
        }
        field(12; CBKIDCHK; text[16])
        {
            Caption = 'Checkbook ID Check';
            DataClassification = CustomerContent;
        }
        field(13; DUEDATE; Date)
        {
            Caption = 'Due Date';
            DataClassification = CustomerContent;
        }
        field(14; DOCDATE; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(15; POSTDATE; Date)
        {
            Caption = 'Post Date';
            DataClassification = CustomerContent;
        }
        field(16; PSTUSRID; text[16])
        {
            Caption = 'Post User ID';
            DataClassification = CustomerContent;
        }
        field(17; GLPOSTDT; Date)
        {
            Caption = 'GL Posting Date';
            DataClassification = CustomerContent;
        }
        field(18; LSTEDTDT; Date)
        {
            Caption = 'Last Edit Date';
            DataClassification = CustomerContent;
        }
        field(19; LSTUSRED; text[16])
        {
            Caption = 'Last User to Edit';
            DataClassification = CustomerContent;
        }
        field(20; ORTRXAMT; Decimal)
        {
            Caption = 'Original Trx Amount';
            DataClassification = CustomerContent;
        }
        field(21; CURTRXAM; Decimal)
        {
            Caption = 'Current Trx Amount';
            DataClassification = CustomerContent;
        }
        field(22; SLSAMNT; Decimal)
        {
            Caption = 'Sales Amount';
            DataClassification = CustomerContent;
        }
        field(23; COSTAMNT; Decimal)
        {
            Caption = 'Cost Amount';
            DataClassification = CustomerContent;
        }
        field(24; FRTAMNT; Decimal)
        {
            Caption = 'Freight Amount';
            DataClassification = CustomerContent;
        }
        field(25; MISCAMNT; Decimal)
        {
            Caption = 'Misc Amount';
            DataClassification = CustomerContent;
        }
        field(26; TAXAMNT; Decimal)
        {
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
        }
        field(27; COMDLRAM; Decimal)
        {
            Caption = 'Commission Dollar Amount';
            DataClassification = CustomerContent;
        }
        field(28; CASHAMNT; Decimal)
        {
            Caption = 'Cash Amount';
            DataClassification = CustomerContent;
        }
        field(29; DISTKNAM; Decimal)
        {
            Caption = 'Discount Taken Amount';
            DataClassification = CustomerContent;
        }
        field(30; DISAVAMT; Decimal)
        {
            Caption = 'Discount Available Amount';
            DataClassification = CustomerContent;
        }
        field(31; DISAVTKN; Decimal)
        {
            Caption = 'Discount Available Taken';
            DataClassification = CustomerContent;
        }
        field(32; DISCRTND; Decimal)
        {
            Caption = 'Discount Returned';
            DataClassification = CustomerContent;
        }
        field(33; DISCDATE; Date)
        {
            Caption = 'Discount Date';
            DataClassification = CustomerContent;
        }
        field(34; DSCDLRAM; Decimal)
        {
            Caption = 'Discount Dollar Amount';
            DataClassification = CustomerContent;
        }
        field(35; DSCPCTAM; Integer)
        {
            Caption = 'Discount Percent Amount';
            DataClassification = CustomerContent;
        }
        field(36; WROFAMNT; Decimal)
        {
            Caption = 'Write Off Amount';
            DataClassification = CustomerContent;
        }
        field(37; TRXDSCRN; text[32])
        {
            Caption = 'Transaction Description';
            DataClassification = CustomerContent;
        }
        field(38; CSPORNBR; text[22])
        {
            Caption = 'Customer Purchase Order Number';
            DataClassification = CustomerContent;
        }
        field(39; SLPRSNID; text[16])
        {
            Caption = 'Salesperson ID';
            DataClassification = CustomerContent;
        }
        field(40; SLSTERCD; text[16])
        {
            Caption = 'Sales Territory Code';
            DataClassification = CustomerContent;
        }
        field(41; DINVPDOF; Date)
        {
            Caption = 'Date Invoice Paid Off';
            DataClassification = CustomerContent;
        }
        field(42; PPSAMDED; Decimal)
        {
            Caption = 'PPS Amount Deducted';
            DataClassification = CustomerContent;
        }
        field(43; GSTDSAMT; Decimal)
        {
            Caption = 'GST Discount Amount';
            DataClassification = CustomerContent;
        }
        field(44; DELETE1; Boolean)
        {
            Caption = 'Delete';
            DataClassification = CustomerContent;
        }
        field(45; AGNGBUKT; Integer)
        {
            Caption = 'Aging Bucket';
            DataClassification = CustomerContent;
        }
        field(46; VOIDSTTS; Option)
        {
            Caption = 'Void Status';
            OptionMembers = "Not Voided","Voided";
            DataClassification = CustomerContent;
        }
        field(47; VOIDDATE; Date)
        {
            Caption = 'Void Date';
            DataClassification = CustomerContent;
        }
        field(48; TAXSCHID; text[16])
        {
            Caption = 'Tax Schedule ID';
            DataClassification = CustomerContent;
        }
        field(49; CURNCYID; text[16])
        {
            Caption = 'Currency ID';
            DataClassification = CustomerContent;
        }
        field(50; PYMTRMID; text[22])
        {
            Caption = 'Payment Terms ID';
            DataClassification = CustomerContent;
        }
        field(51; SHIPMTHD; text[16])
        {
            Caption = 'Shipping Method';
            DataClassification = CustomerContent;
        }
        field(52; TRDISAMT; Decimal)
        {
            Caption = 'Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(53; SLSCHDID; text[16])
        {
            Caption = 'Sales Schedule ID';
            DataClassification = CustomerContent;
        }
        field(54; FRTSCHID; text[16])
        {
            Caption = 'Freight Schedule ID';
            DataClassification = CustomerContent;
        }
        field(55; MSCSCHID; text[16])
        {
            Caption = 'Misc Schedule ID';
            DataClassification = CustomerContent;
        }
        field(56; NOTEINDX; Decimal)
        {
            Caption = 'Note Index';
            DataClassification = CustomerContent;
        }
        field(57; Tax_Date; Date)
        {
            Caption = 'Tax Date';
            DataClassification = CustomerContent;
        }
        field(58; APLYWITH; Boolean)
        {
            Caption = 'Apply Withholding';
            DataClassification = CustomerContent;
        }
        field(59; SALEDATE; Date)
        {
            Caption = 'Sale Date';
            DataClassification = CustomerContent;
        }
        field(60; CORRCTN; Boolean)
        {
            Caption = 'Correction';
            DataClassification = CustomerContent;
        }
        field(61; SIMPLIFD; Boolean)
        {
            Caption = 'Simplified';
            DataClassification = CustomerContent;
        }
        field(62; Electronic; Boolean)
        {
            Caption = 'Electronic';
            DataClassification = CustomerContent;
        }
        field(63; ECTRX; Boolean)
        {
            Caption = 'EC Transaction';
            DataClassification = CustomerContent;
        }
        field(64; BKTSLSAM; Decimal)
        {
            Caption = 'Backout Sales Amount';
            DataClassification = CustomerContent;
        }
        field(65; BKTFRTAM; Decimal)
        {
            Caption = 'Backout Freight Amount';
            DataClassification = CustomerContent;
        }
        field(66; BKTMSCAM; Decimal)
        {
            Caption = 'Backout Misc Amount';
            DataClassification = CustomerContent;
        }
        field(67; BackoutTradeDisc; Decimal)
        {
            Caption = 'Backout Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(68; Factoring; Boolean)
        {
            Caption = 'Factoring';
            DataClassification = CustomerContent;
        }
        field(69; DIRECTDEBIT; Boolean)
        {
            Caption = 'Direct Debit';
            DataClassification = CustomerContent;
        }
        field(70; ADRSCODE; text[16])
        {
            Caption = 'Address Code';
            DataClassification = CustomerContent;
        }
        field(71; EFTFLAG; Boolean)
        {
            Caption = 'EFT Flag';
            DataClassification = CustomerContent;
        }
        field(72; DEX_ROW_TS; DateTime)
        {
            Caption = 'DEX_ROW_TS';
            DataClassification = CustomerContent;
        }
        field(73; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; CUSTNMBR, RMDTYPAL, DOCNUMBR)
        {
            Clustered = false;
        }

        key(DueDate; DUEDATE)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
