table 4053 "GPPMHist"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; VCHRNMBR; text[22])
        {
            Caption = 'Voucher Number';
            DataClassification = CustomerContent;
        }
        field(2; VENDORID; text[16])
        {
            Caption = 'Vendor ID';
            DataClassification = CustomerContent;
        }
        field(3; DOCTYPE; Option)
        {
            Caption = 'Document Type';
            OptionMembers = ,"Invoice","Finance Charge","Misc Charge","Return","Credit Memo","Payment";
            DataClassification = CustomerContent;
        }
        field(4; DOCDATE; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(5; DOCNUMBR; text[22])
        {
            Caption = 'Document Number';
            DataClassification = CustomerContent;
        }
        field(6; DOCAMNT; Decimal)
        {
            Caption = 'Document Amount';
            DataClassification = CustomerContent;
        }
        field(7; CURTRXAM; Decimal)
        {
            Caption = 'Current Trx Amount';
            DataClassification = CustomerContent;
        }
        field(8; DISTKNAM; Decimal)
        {
            Caption = 'Discount Taken Amount';
            DataClassification = CustomerContent;
        }
        field(9; DISCAMNT; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
        }
        field(10; DSCDLRAM; Decimal)
        {
            Caption = 'Discount Dollar Amount';
            DataClassification = CustomerContent;
        }
        field(11; BACHNUMB; text[16])
        {
            Caption = 'Batch Number';
            DataClassification = CustomerContent;
        }
        field(12; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(13; BCHSOURC; text[16])
        {
            Caption = 'Batch Source';
            DataClassification = CustomerContent;
        }
        field(14; DISCDATE; Date)
        {
            Caption = 'Discount Date';
            DataClassification = CustomerContent;
        }
        field(15; DUEDATE; Date)
        {
            Caption = 'Due Date';
            DataClassification = CustomerContent;
        }
        field(16; PORDNMBR; text[22])
        {
            Caption = 'Purchase Order Number';
            DataClassification = CustomerContent;
        }
        field(17; TEN99AMNT; Decimal)
        {
            Caption = '1099 Amount';
            DataClassification = CustomerContent;
        }
        field(18; WROFAMNT; Decimal)
        {
            Caption = 'Write Off Amount';
            DataClassification = CustomerContent;
        }
        field(19; DISAMTAV; Decimal)
        {
            Caption = 'Discount Amount Available';
            DataClassification = CustomerContent;
        }
        field(20; TRXDSCRN; text[32])
        {
            Caption = 'Transaction Description';
            DataClassification = CustomerContent;
        }
        field(21; UN1099AM; Decimal)
        {
            Caption = 'Unapplied 1099 Amount';
            DataClassification = CustomerContent;
        }
        field(22; BKTPURAM; Decimal)
        {
            Caption = 'Backout Purchases Amount';
            DataClassification = CustomerContent;
        }
        field(23; BKTFRTAM; Decimal)
        {
            Caption = 'Backout Freight Amount';
            DataClassification = CustomerContent;
        }
        field(24; BKTMSCAM; Decimal)
        {
            Caption = 'Backout Misc Amount';
            DataClassification = CustomerContent;
        }
        field(25; VOIDED; Boolean)
        {
            Caption = 'Voided';
            DataClassification = CustomerContent;
        }
        field(26; HOLD; Boolean)
        {
            Caption = 'Hold';
            DataClassification = CustomerContent;
        }
        field(27; CHEKBKID; text[16])
        {
            Caption = 'Checkbook ID';
            DataClassification = CustomerContent;
        }
        field(28; DINVPDOF; Date)
        {
            Caption = 'Date Invoice Paid Off';
            DataClassification = CustomerContent;
        }
        field(29; PPSAMDED; Decimal)
        {
            Caption = 'PPS Amount Deducted';
            DataClassification = CustomerContent;
        }
        field(30; PPSTAXRT; Integer)
        {
            Caption = 'PPS Tax Rate';
            DataClassification = CustomerContent;
        }
        field(31; PGRAMSBJ; Integer)
        {
            Caption = 'Percent Of Gross Amount Subject';
            DataClassification = CustomerContent;
        }
        field(32; GSTDSAMT; Decimal)
        {
            Caption = 'GST Discount Amount';
            DataClassification = CustomerContent;
        }
        field(33; POSTEDDT; Date)
        {
            Caption = 'Posted Date';
            DataClassification = CustomerContent;
        }
        field(34; PTDUSRID; text[16])
        {
            Caption = 'Posted User ID';
            DataClassification = CustomerContent;
        }
        field(35; MODIFDT; Date)
        {
            Caption = 'Modified Date';
            DataClassification = CustomerContent;
        }
        field(36; MDFUSRID; text[16])
        {
            Caption = 'Modified User ID';
            DataClassification = CustomerContent;
        }
        field(37; PYENTTYP; Option)
        {
            Caption = 'Payment Entry Type';
            OptionMembers = "Check","Cash","Credit Card","EFT";
            DataClassification = CustomerContent;
        }
        field(38; CARDNAME; text[16])
        {
            Caption = 'Card Name';
            DataClassification = CustomerContent;
        }
        field(39; PRCHAMNT; Decimal)
        {
            Caption = 'Purchases Amount';
            DataClassification = CustomerContent;
        }
        field(40; TRDISAMT; Decimal)
        {
            Caption = 'Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(41; MSCCHAMT; Decimal)
        {
            Caption = 'Misc Charges Amount';
            DataClassification = CustomerContent;
        }
        field(42; FRTAMNT; Decimal)
        {
            Caption = 'Freight Amount';
            DataClassification = CustomerContent;
        }
        field(43; TAXAMNT; Decimal)
        {
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
        }
        field(44; TTLPYMTS; Decimal)
        {
            Caption = 'Total Payments';
            DataClassification = CustomerContent;
        }
        field(45; CURNCYID; text[16])
        {
            Caption = 'Currency ID';
            DataClassification = CustomerContent;
        }
        field(46; PYMTRMID; text[22])
        {
            Caption = 'Payment Terms ID';
            DataClassification = CustomerContent;
        }
        field(47; SHIPMTHD; text[16])
        {
            Caption = 'Shipping Method';
            DataClassification = CustomerContent;
        }
        field(48; TAXSCHID; text[16])
        {
            Caption = 'Tax Schedule ID';
            DataClassification = CustomerContent;
        }
        field(49; PCHSCHID; text[16])
        {
            Caption = 'Purchase Schedule ID';
            DataClassification = CustomerContent;
        }
        field(50; FRTSCHID; text[16])
        {
            Caption = 'Freight Schedule ID';
            DataClassification = CustomerContent;
        }
        field(51; MSCSCHID; text[16])
        {
            Caption = 'Misc Schedule ID';
            DataClassification = CustomerContent;
        }
        field(52; PSTGDATE; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(53; DISAVTKN; Decimal)
        {
            Caption = 'Discount Available Taken';
            DataClassification = CustomerContent;
        }
        field(54; CNTRLTYP; Integer)
        {
            Caption = 'Control Type';
            DataClassification = CustomerContent;
        }
        field(55; NOTEINDX; Decimal)
        {
            Caption = 'Note Index';
            DataClassification = CustomerContent;
        }
        field(56; PRCTDISC; Integer)
        {
            Caption = 'Percent Discount';
            DataClassification = CustomerContent;
        }
        field(57; RETNAGAM; Decimal)
        {
            Caption = 'Retainage Amount';
            DataClassification = CustomerContent;
        }
        field(58; VOIDPDATE; Date)
        {
            Caption = 'Void GL Posting Date';
            DataClassification = CustomerContent;
        }
        field(59; ICTRX; Boolean)
        {
            Caption = 'IC TRX';
            DataClassification = CustomerContent;
        }
        field(60; Tax_Date; Date)
        {
            Caption = 'Tax Date';
            DataClassification = CustomerContent;
        }
        field(61; PRCHDATE; Date)
        {
            Caption = 'Purchase Date';
            DataClassification = CustomerContent;
        }
        field(62; CORRCTN; Boolean)
        {
            Caption = 'Correction';
            DataClassification = CustomerContent;
        }
        field(63; SIMPLIFD; Boolean)
        {
            Caption = 'Simplified';
            DataClassification = CustomerContent;
        }
        field(64; APLYWITH; Boolean)
        {
            Caption = 'Apply Withholding';
            DataClassification = CustomerContent;
        }
        field(65; Electronic; Boolean)
        {
            Caption = 'Electronic';
            DataClassification = CustomerContent;
        }
        field(66; ECTRX; Boolean)
        {
            Caption = 'EC Transaction';
            DataClassification = CustomerContent;
        }
        field(67; DocPrinted; Boolean)
        {
            Caption = 'DocPrinted';
            DataClassification = CustomerContent;
        }
        field(68; TaxInvReqd; Boolean)
        {
            Caption = 'Tax Invoice Required';
            DataClassification = CustomerContent;
        }
        field(69; VNDCHKNM; text[66])
        {
            Caption = 'Vendor Check Name';
            DataClassification = CustomerContent;
        }
        field(70; BackoutTradeDisc; Decimal)
        {
            Caption = 'Backout Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(71; CBVAT; Boolean)
        {
            Caption = 'Cash Based VAT';
            DataClassification = CustomerContent;
        }
        field(72; VADCDTRO; text[16])
        {
            Caption = 'Vendor Address Code - Remit To';
            DataClassification = CustomerContent;
        }
        field(73; TEN99TYPE; Option)
        {
            Caption = '1099 Type';
            OptionMembers = ,"Not a 1099 Vendor","Dividend","Interest","Miscellaneous";
            DataClassification = CustomerContent;
        }
        field(74; TEN99BOXNUMBER; Integer)
        {
            Caption = '1099 Box Number';
            DataClassification = CustomerContent;
        }
        field(75; PONUMBER; text[18])
        {
            Caption = 'PO Number';
            DataClassification = CustomerContent;
        }
        field(76; Workflow_Status; Option)
        {
            Caption = 'Workflow Status';
            OptionMembers = ,"Not Submitted","Submitted (Deprecated)","No Action Needed","Pending User Action","Recalled","Completed","Rejected","Workflow Ended (Deprecated)","Not Activated","Deactivated (Deprecated)";
            DataClassification = CustomerContent;
        }
        field(77; InvoiceReceiptDate; Date)
        {
            Caption = 'Invoice Receipt Date';
            DataClassification = CustomerContent;
        }
        field(78; DEX_ROW_TS; DateTime)
        {
            Caption = 'DEX_ROW_TS';
            DataClassification = CustomerContent;
        }
        field(79; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; DOCTYPE, VCHRNMBR)
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
