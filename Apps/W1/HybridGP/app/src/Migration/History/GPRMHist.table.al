table 4065 "GPRMHist"
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
        field(9; DUEDATE; Date)
        {
            Caption = 'Due Date';
            DataClassification = CustomerContent;
        }
        field(10; DOCDATE; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(11; POSTDATE; Date)
        {
            Caption = 'Post Date';
            DataClassification = CustomerContent;
        }
        field(12; PSTUSRID; text[16])
        {
            Caption = 'Post User ID';
            DataClassification = CustomerContent;
        }
        field(13; GLPOSTDT; Date)
        {
            Caption = 'GL Posting Date';
            DataClassification = CustomerContent;
        }
        field(14; LSTEDTDT; Date)
        {
            Caption = 'Last Edit Date';
            DataClassification = CustomerContent;
        }
        field(15; LSTUSRED; text[16])
        {
            Caption = 'Last User to Edit';
            DataClassification = CustomerContent;
        }
        field(16; ORTRXAMT; Decimal)
        {
            Caption = 'Original Trx Amount';
            DataClassification = CustomerContent;
        }
        field(17; CURTRXAM; Decimal)
        {
            Caption = 'Current Trx Amount';
            DataClassification = CustomerContent;
        }
        field(18; SLSAMNT; Decimal)
        {
            Caption = 'Sales Amount';
            DataClassification = CustomerContent;
        }
        field(19; COSTAMNT; Decimal)
        {
            Caption = 'Cost Amount';
            DataClassification = CustomerContent;
        }
        field(20; FRTAMNT; Decimal)
        {
            Caption = 'Freight Amount';
            DataClassification = CustomerContent;
        }
        field(21; MISCAMNT; Decimal)
        {
            Caption = 'Misc Amount';
            DataClassification = CustomerContent;
        }
        field(22; TAXAMNT; Decimal)
        {
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
        }
        field(23; COMDLRAM; Decimal)
        {
            Caption = 'Commission Dollar Amount';
            DataClassification = CustomerContent;
        }
        field(24; CASHAMNT; Decimal)
        {
            Caption = 'Cash Amount';
            DataClassification = CustomerContent;
        }
        field(25; DISTKNAM; Decimal)
        {
            Caption = 'Discount Taken Amount';
            DataClassification = CustomerContent;
        }
        field(26; DISAVAMT; Decimal)
        {
            Caption = 'Discount Available Amount';
            DataClassification = CustomerContent;
        }
        field(27; DISCRTND; Decimal)
        {
            Caption = 'Discount Returned';
            DataClassification = CustomerContent;
        }
        field(28; DISCDATE; Date)
        {
            Caption = 'Discount Date';
            DataClassification = CustomerContent;
        }
        field(29; DSCDLRAM; Decimal)
        {
            Caption = 'Discount Dollar Amount';
            DataClassification = CustomerContent;
        }
        field(30; DSCPCTAM; Integer)
        {
            Caption = 'Discount Percent Amount';
            DataClassification = CustomerContent;
        }
        field(31; WROFAMNT; Decimal)
        {
            Caption = 'Write Off Amount';
            DataClassification = CustomerContent;
        }
        field(32; TRXDSCRN; text[32])
        {
            Caption = 'Transaction Description';
            DataClassification = CustomerContent;
        }
        field(33; CSPORNBR; text[22])
        {
            Caption = 'Customer Purchase Order Number';
            DataClassification = CustomerContent;
        }
        field(34; SLPRSNID; text[16])
        {
            Caption = 'Salesperson ID';
            DataClassification = CustomerContent;
        }
        field(35; SLSTERCD; text[16])
        {
            Caption = 'Sales Territory Code';
            DataClassification = CustomerContent;
        }
        field(36; DINVPDOF; Date)
        {
            Caption = 'Date Invoice Paid Off';
            DataClassification = CustomerContent;
        }
        field(37; PPSAMDED; Decimal)
        {
            Caption = 'PPS Amount Deducted';
            DataClassification = CustomerContent;
        }
        field(38; GSTDSAMT; Decimal)
        {
            Caption = 'GST Discount Amount';
            DataClassification = CustomerContent;
        }
        field(39; DELETE1; Boolean)
        {
            Caption = 'Delete';
            DataClassification = CustomerContent;
        }
        field(40; TAXSCHID; text[16])
        {
            Caption = 'Tax Schedule ID';
            DataClassification = CustomerContent;
        }
        field(41; SLSCHDID; text[16])
        {
            Caption = 'Sales Schedule ID';
            DataClassification = CustomerContent;
        }
        field(42; FRTSCHID; text[16])
        {
            Caption = 'Freight Schedule ID';
            DataClassification = CustomerContent;
        }
        field(43; MSCSCHID; text[16])
        {
            Caption = 'Misc Schedule ID';
            DataClassification = CustomerContent;
        }
        field(44; CURNCYID; text[16])
        {
            Caption = 'Currency ID';
            DataClassification = CustomerContent;
        }
        field(45; SHIPMTHD; text[16])
        {
            Caption = 'Shipping Method';
            DataClassification = CustomerContent;
        }
        field(46; PYMTRMID; text[22])
        {
            Caption = 'Payment Terms ID';
            DataClassification = CustomerContent;
        }
        field(47; TRDISAMT; Decimal)
        {
            Caption = 'Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(48; NOTEINDX; Decimal)
        {
            Caption = 'Note Index';
            DataClassification = CustomerContent;
        }
        field(49; VOIDSTTS; Option)
        {
            Caption = 'Void Status';
            OptionMembers = "Not Voided","Voided";
            DataClassification = CustomerContent;
        }
        field(50; VOIDDATE; Date)
        {
            Caption = 'Void Date';
            DataClassification = CustomerContent;
        }
        field(51; BALFWDNM; text[22])
        {
            Caption = 'Balance Forward Number';
            DataClassification = CustomerContent;
        }
        field(52; CSHRCTYP; Option)
        {
            Caption = 'Cash Receipt Type';
            OptionMembers = "Check","Cash","Credit Card";
            DataClassification = CustomerContent;
        }
        field(53; Tax_Date; Date)
        {
            Caption = 'Tax Date';
            DataClassification = CustomerContent;
        }
        field(54; APLYWITH; Boolean)
        {
            Caption = 'Apply Withholding';
            DataClassification = CustomerContent;
        }
        field(55; SALEDATE; Date)
        {
            Caption = 'Sale Date';
            DataClassification = CustomerContent;
        }
        field(56; CORRCTN; Boolean)
        {
            Caption = 'Correction';
            DataClassification = CustomerContent;
        }
        field(57; SIMPLIFD; Boolean)
        {
            Caption = 'Simplified';
            DataClassification = CustomerContent;
        }
        field(58; Electronic; Boolean)
        {
            Caption = 'Electronic';
            DataClassification = CustomerContent;
        }
        field(59; ECTRX; Boolean)
        {
            Caption = 'EC Transaction';
            DataClassification = CustomerContent;
        }
        field(60; BKTSLSAM; Decimal)
        {
            Caption = 'Backout Sales Amount';
            DataClassification = CustomerContent;
        }
        field(61; BackoutTradeDisc; Decimal)
        {
            Caption = 'Backout Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(62; BKTFRTAM; Decimal)
        {
            Caption = 'Backout Freight Amount';
            DataClassification = CustomerContent;
        }
        field(63; BKTMSCAM; Decimal)
        {
            Caption = 'Backout Misc Amount';
            DataClassification = CustomerContent;
        }
        field(64; Factoring; Boolean)
        {
            Caption = 'Factoring';
            DataClassification = CustomerContent;
        }
        field(65; DIRECTDEBIT; Boolean)
        {
            Caption = 'Direct Debit';
            DataClassification = CustomerContent;
        }
        field(66; ADRSCODE; text[16])
        {
            Caption = 'Address Code';
            DataClassification = CustomerContent;
        }
        field(67; EFTFLAG; Boolean)
        {
            Caption = 'EFT Flag';
            DataClassification = CustomerContent;
        }
        field(68; DEX_ROW_TS; DateTime)
        {
            Caption = 'DEX_ROW_TS';
            DataClassification = CustomerContent;
        }
        field(69; DEX_ROW_ID; Integer)
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
