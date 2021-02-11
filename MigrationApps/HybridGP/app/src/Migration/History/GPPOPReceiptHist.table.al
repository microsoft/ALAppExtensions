table 4061 "GPPOPReceiptHist"
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
        field(2; POPTYPE; Option)
        {
            Caption = 'POP Type';
            OptionMembers = ,"Shipment","Invoice","Shipment/Invoice","Return","Return w/Credit","Inventory Return","Inventory Return w/Credit";
            DataClassification = CustomerContent;
        }
        field(3; VNDDOCNM; text[22])
        {
            Caption = 'Vendor Document Number';
            DataClassification = CustomerContent;
        }
        field(4; receiptdate; Date)
        {
            Caption = 'Receipt Date';
            DataClassification = CustomerContent;
        }
        field(5; GLPOSTDT; Date)
        {
            Caption = 'GL Posting Date';
            DataClassification = CustomerContent;
        }
        field(6; ACTLSHIP; Date)
        {
            Caption = 'Actual Ship Date';
            DataClassification = CustomerContent;
        }
        field(7; BCHSOURC; text[16])
        {
            Caption = 'Batch Source';
            DataClassification = CustomerContent;
        }
        field(8; BACHNUMB; text[16])
        {
            Caption = 'Batch Number';
            DataClassification = CustomerContent;
        }
        field(9; VENDORID; text[16])
        {
            Caption = 'Vendor ID';
            DataClassification = CustomerContent;
        }
        field(10; VENDNAME; text[66])
        {
            Caption = 'Vendor Name';
            DataClassification = CustomerContent;
        }
        field(11; SUBTOTAL; Decimal)
        {
            Caption = 'Subtotal';
            DataClassification = CustomerContent;
        }
        field(12; TRDISAMT; Decimal)
        {
            Caption = 'Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(14; FRTAMNT; Decimal)
        {
            Caption = 'Freight Amount';
            DataClassification = CustomerContent;
        }
        field(15; MISCAMNT; Decimal)
        {
            Caption = 'Misc Amount';
            DataClassification = CustomerContent;
        }
        field(16; TAXAMNT; Decimal)
        {
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
        }
        field(17; TEN99AMNT; Decimal)
        {
            Caption = '1099 Amount';
            DataClassification = CustomerContent;
        }
        field(18; PYMTRMID; text[22])
        {
            Caption = 'Payment Terms ID';
            DataClassification = CustomerContent;
        }
        field(19; DSCPCTAM; Integer)
        {
            Caption = 'Discount Percent Amount';
            DataClassification = CustomerContent;
        }
        field(20; DSCDLRAM; Decimal)
        {
            Caption = 'Discount Dollar Amount';
            DataClassification = CustomerContent;
        }
        field(21; DISAVAMT; Decimal)
        {
            Caption = 'Discount Available Amount';
            DataClassification = CustomerContent;
        }
        field(22; DISCDATE; Date)
        {
            Caption = 'Discount Date';
            DataClassification = CustomerContent;
        }
        field(23; DUEDATE; Date)
        {
            Caption = 'Due Date';
            DataClassification = CustomerContent;
        }
        field(24; REFRENCE; text[32])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(25; VOIDSTTS; Option)
        {
            Caption = 'Void Status';
            OptionMembers = "Not Voided","Voided";
            DataClassification = CustomerContent;
        }
        field(26; RCPTNOTE_1; Decimal)
        {
            Caption = 'Receipt Note ID Array 1';
            DataClassification = CustomerContent;
        }
        field(27; RCPTNOTE_2; Decimal)
        {
            Caption = 'Receipt Note ID Array 2';
            DataClassification = CustomerContent;
        }
        field(28; RCPTNOTE_3; Decimal)
        {
            Caption = 'Receipt Note ID Array 3';
            DataClassification = CustomerContent;
        }
        field(29; RCPTNOTE_4; Decimal)
        {
            Caption = 'Receipt Note ID Array 4';
            DataClassification = CustomerContent;
        }
        field(30; RCPTNOTE_5; Decimal)
        {
            Caption = 'Receipt Note ID Array 5';
            DataClassification = CustomerContent;
        }
        field(31; RCPTNOTE_6; Decimal)
        {
            Caption = 'Receipt Note ID Array 6';
            DataClassification = CustomerContent;
        }
        field(32; RCPTNOTE_7; Decimal)
        {
            Caption = 'Receipt Note ID Array 7';
            DataClassification = CustomerContent;
        }
        field(33; RCPTNOTE_8; Decimal)
        {
            Caption = 'Receipt Note ID Array 8';
            DataClassification = CustomerContent;
        }
        field(34; POSTEDDT; Date)
        {
            Caption = 'Posted Date';
            DataClassification = CustomerContent;
        }
        field(35; PTDUSRID; text[16])
        {
            Caption = 'Posted User ID';
            DataClassification = CustomerContent;
        }
        field(36; USER2ENT; text[16])
        {
            Caption = 'User To Enter';
            DataClassification = CustomerContent;
        }
        field(37; CREATDDT; Date)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
        }
        field(38; MODIFDT; Date)
        {
            Caption = 'Modified Date';
            DataClassification = CustomerContent;
        }
        field(39; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(40; VCHRNMBR; text[22])
        {
            Caption = 'Voucher Number';
            DataClassification = CustomerContent;
        }
        field(41; Tax_Date; Date)
        {
            Caption = 'Tax Date';
            DataClassification = CustomerContent;
        }
        field(42; CURNCYID; text[16])
        {
            Caption = 'Currency ID';
            DataClassification = CustomerContent;
        }
        field(43; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(44; RATETPID; text[16])
        {
            Caption = 'Rate Type ID';
            DataClassification = CustomerContent;
        }
        field(45; EXGTBLID; text[16])
        {
            Caption = 'Exchange Table ID';
            DataClassification = CustomerContent;
        }
        field(46; XCHGRATE; Decimal)
        {
            Caption = 'Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(47; EXCHDATE; Date)
        {
            Caption = 'Exchange Date';
            DataClassification = CustomerContent;
        }
        field(48; TIME1; DateTime)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }
        field(49; RATECALC; Option)
        {
            Caption = 'Rate Calc Method';
            OptionMembers = "Multiply","Divide";
            DataClassification = CustomerContent;
        }
        field(50; DENXRATE; Decimal)
        {
            Caption = 'Denomination Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(51; MCTRXSTT; Option)
        {
            Caption = 'MC Transaction State';
            OptionMembers = "No Euro","Nondenom to nondenom","Nondenom to Euro","Nondenom to denom","Denom to nondenom","Denom to denom","Denom to Euro","Euro to Denom","Euro to nondenom";
            DataClassification = CustomerContent;
        }
        field(52; ORSUBTOT; Decimal)
        {
            Caption = 'Originating Subtotal';
            DataClassification = CustomerContent;
        }
        field(53; ORTDISAM; Decimal)
        {
            Caption = 'Originating Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(54; ORFRTAMT; Decimal)
        {
            Caption = 'Originating Freight Amount';
            DataClassification = CustomerContent;
        }
        field(55; ORMISCAMT; Decimal)
        {
            Caption = 'Originating Misc Amount';
            DataClassification = CustomerContent;
        }
        field(56; ORTAXAMT; Decimal)
        {
            Caption = 'Originating Tax Amount';
            DataClassification = CustomerContent;
        }
        field(57; OR1099AM; Decimal)
        {
            Caption = 'Originating 1099 Amount';
            DataClassification = CustomerContent;
        }
        field(58; ORDDLRAT; Decimal)
        {
            Caption = 'Originating Discount Dollar Amount';
            DataClassification = CustomerContent;
        }
        field(59; ORDAVAMT; Decimal)
        {
            Caption = 'Originating Discount Available Amount';
            DataClassification = CustomerContent;
        }
        field(60; SIMPLIFD; Boolean)
        {
            Caption = 'Simplified';
            DataClassification = CustomerContent;
        }
        field(61; WITHHAMT; Decimal)
        {
            Caption = 'Withholding Amount';
            DataClassification = CustomerContent;
        }
        field(62; ECTRX; Boolean)
        {
            Caption = 'EC Transaction';
            DataClassification = CustomerContent;
        }
        field(63; TXRGNNUM; text[26])
        {
            Caption = 'Tax Registration Number';
            DataClassification = CustomerContent;
        }
        field(64; TAXSCHID; text[16])
        {
            Caption = 'Tax Schedule ID';
            DataClassification = CustomerContent;
        }
        field(65; BSIVCTTL; Boolean)
        {
            Caption = 'Based On Invoice Total';
            DataClassification = CustomerContent;
        }
        field(66; Purchase_Freight_Taxable; Option)
        {
            Caption = 'Purchase Freight Taxable';
            OptionMembers = ,"Taxable","Nontaxable","Base on vendor";
            DataClassification = CustomerContent;
        }
        field(67; Purchase_Misc_Taxable; Option)
        {
            Caption = 'Purchase Misc Taxable';
            OptionMembers = ,"Taxable","Nontaxable","Base on vendor";
            DataClassification = CustomerContent;
        }
        field(68; FRTSCHID; text[16])
        {
            Caption = 'Freight Schedule ID';
            DataClassification = CustomerContent;
        }
        field(69; MSCSCHID; text[16])
        {
            Caption = 'Misc Schedule ID';
            DataClassification = CustomerContent;
        }
        field(70; FRTTXAMT; Decimal)
        {
            Caption = 'Freight Tax Amount';
            DataClassification = CustomerContent;
        }
        field(71; ORFRTTAX; Decimal)
        {
            Caption = 'Originating Freight Tax Amount';
            DataClassification = CustomerContent;
        }
        field(72; MSCTXAMT; Decimal)
        {
            Caption = 'Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(73; ORMSCTAX; Decimal)
        {
            Caption = 'Originating Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(74; BCKTXAMT; Decimal)
        {
            Caption = 'Backout Tax Amount';
            DataClassification = CustomerContent;
        }
        field(75; OBTAXAMT; Decimal)
        {
            Caption = 'Originating Backout Tax Amount';
            DataClassification = CustomerContent;
        }
        field(76; TaxInvReqd; Boolean)
        {
            Caption = 'Tax Invoice Required';
            DataClassification = CustomerContent;
        }
        field(77; BackoutFreightTaxAmt; Decimal)
        {
            Caption = 'Backout Freight Tax Amount';
            DataClassification = CustomerContent;
        }
        field(78; OrigBackoutFreightTaxAmt; Decimal)
        {
            Caption = 'Originating Backout Freight Tax Amount';
            DataClassification = CustomerContent;
        }
        field(79; BackoutMiscTaxAmt; Decimal)
        {
            Caption = 'Backout Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(80; OrigBackoutMiscTaxAmt; Decimal)
        {
            Caption = 'Originating Backout Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(81; TaxInvRecvd; Boolean)
        {
            Caption = 'Tax Invoice Received';
            DataClassification = CustomerContent;
        }
        field(82; APLYWITH; Boolean)
        {
            Caption = 'Apply Withholding';
            DataClassification = CustomerContent;
        }
        field(83; PPSTAXRT; Integer)
        {
            Caption = 'PPS Tax Rate';
            DataClassification = CustomerContent;
        }
        field(84; SHIPMTHD; text[16])
        {
            Caption = 'Shipping Method';
            DataClassification = CustomerContent;
        }
        field(85; Total_Landed_Cost_Amount; Decimal)
        {
            Caption = 'Total Landed Cost Amount';
            DataClassification = CustomerContent;
        }
        field(86; CBVAT; Boolean)
        {
            Caption = 'Cash Based VAT';
            DataClassification = CustomerContent;
        }
        field(87; VADCDTRO; text[16])
        {
            Caption = 'Vendor Address Code - Remit To';
            DataClassification = CustomerContent;
        }
        field(88; REVALJRNENTRY; Integer)
        {
            Caption = 'Revaluation Journal Entry';
            DataClassification = CustomerContent;
        }
        field(89; REVALTRXSOURCE; text[14])
        {
            Caption = 'Revaluation TRX Source';
            DataClassification = CustomerContent;
        }
        field(90; TEN99TYPE; Option)
        {
            Caption = '1099 Type';
            OptionMembers = ,"Not a 1099 Vendor","Dividend","Interest","Miscellaneous";
            DataClassification = CustomerContent;
        }
        field(91; TEN99BOXNUMBER; Integer)
        {
            Caption = '1099 Box Number';
            DataClassification = CustomerContent;
        }
        field(92; REPLACEGOODS; Boolean)
        {
            Caption = 'Replace Returned Goods';
            DataClassification = CustomerContent;
        }
        field(93; INVOICEEXPECTED; Boolean)
        {
            Caption = 'Invoice Expected Returns';
            DataClassification = CustomerContent;
        }
        field(94; PrepaymentAmount; Decimal)
        {
            Caption = 'Prepayment Amount';
            DataClassification = CustomerContent;
        }
        field(95; OriginatingPrepaymentAmt; Decimal)
        {
            Caption = 'Originating Prepayment Amount';
            DataClassification = CustomerContent;
        }
        field(96; DISTKNAM; Decimal)
        {
            Caption = 'Discount Taken Amount';
            DataClassification = CustomerContent;
        }
        field(97; ORDISTKN; Decimal)
        {
            Caption = 'Originating Discount Taken Amount';
            DataClassification = CustomerContent;
        }
        field(98; DISAVTKN; Decimal)
        {
            Caption = 'Discount Available Taken';
            DataClassification = CustomerContent;
        }
        field(99; ORDATKN; Decimal)
        {
            Caption = 'Originating Discount Available Taken';
            DataClassification = CustomerContent;
        }
        field(100; InvoiceReceiptDate; Date)
        {
            Caption = 'Invoice Receipt Date';
            DataClassification = CustomerContent;
        }
        field(101; Workflow_Status; Option)
        {
            Caption = 'Workflow Status';
            OptionMembers = ,"Not Submitted","Submitted (Deprecated)","No Action Needed","Pending User Action","Recalled","Completed","Rejected","Workflow Ended (Deprecated)","Not Activated","Deactivated (Deprecated)";
            DataClassification = CustomerContent;
        }
        field(102; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; POPRCTNM)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
