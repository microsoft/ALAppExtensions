table 4078 "GPSOPTrxHist"
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
        field(3; ORIGTYPE; Option)
        {
            Caption = 'Original Type';
            OptionMembers = ,"Quote","Order","Invoice","Return","Back Order","FulFillment Order";
            DataClassification = CustomerContent;
        }
        field(4; ORIGNUMB; text[22])
        {
            Caption = 'Original Number';
            DataClassification = CustomerContent;
        }
        field(5; DOCID; text[16])
        {
            Caption = 'Document ID';
            DataClassification = CustomerContent;
        }
        field(6; DOCDATE; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(7; GLPOSTDT; Date)
        {
            Caption = 'GL Posting Date';
            DataClassification = CustomerContent;
        }
        field(8; QUOTEDAT; Date)
        {
            Caption = 'Quote Date';
            DataClassification = CustomerContent;
        }
        field(9; QUOEXPDA; Date)
        {
            Caption = 'Quote Expiration Date';
            DataClassification = CustomerContent;
        }
        field(10; ORDRDATE; Date)
        {
            Caption = 'Order Date';
            DataClassification = CustomerContent;
        }
        field(11; INVODATE; Date)
        {
            Caption = 'Invoice Date';
            DataClassification = CustomerContent;
        }
        field(12; BACKDATE; Date)
        {
            Caption = 'Back Order Date';
            DataClassification = CustomerContent;
        }
        field(13; RETUDATE; Date)
        {
            Caption = 'Return Date';
            DataClassification = CustomerContent;
        }
        field(14; ReqShipDate; Date)
        {
            Caption = 'Requested Ship Date';
            DataClassification = CustomerContent;
        }
        field(15; FUFILDAT; Date)
        {
            Caption = 'Fulfillment Date';
            DataClassification = CustomerContent;
        }
        field(16; ACTLSHIP; Date)
        {
            Caption = 'Actual Ship Date';
            DataClassification = CustomerContent;
        }
        field(17; DISCDATE; Date)
        {
            Caption = 'Discount Date';
            DataClassification = CustomerContent;
        }
        field(18; DUEDATE; Date)
        {
            Caption = 'Due Date';
            DataClassification = CustomerContent;
        }
        field(19; REPTING; Boolean)
        {
            Caption = 'Repeating';
            DataClassification = CustomerContent;
        }
        field(20; TRXFREQU; Option)
        {
            Caption = 'TRX Frequency';
            OptionMembers = ,"Weekly","Biweekly","Semimonthly","Monthly","Bimonthly","Quarterly","Miscellaneous";
            DataClassification = CustomerContent;
        }
        field(21; TIMEREPD; Integer)
        {
            Caption = 'Times Repeated';
            DataClassification = CustomerContent;
        }
        field(22; TIMETREP; Integer)
        {
            Caption = 'Times To Repeat';
            DataClassification = CustomerContent;
        }
        field(23; DYSTINCR; Integer)
        {
            Caption = 'Days to Increment';
            DataClassification = CustomerContent;
        }
        field(24; DTLSTREP; Date)
        {
            Caption = 'Date Last Repeated';
            DataClassification = CustomerContent;
        }
        field(25; DSTBTCH1; text[16])
        {
            Caption = 'Dest Batch 1';
            DataClassification = CustomerContent;
        }
        field(26; DSTBTCH2; text[16])
        {
            Caption = 'Dest Batch 2';
            DataClassification = CustomerContent;
        }
        field(27; USDOCID1; text[16])
        {
            Caption = 'Use Document ID 1';
            DataClassification = CustomerContent;
        }
        field(28; USDOCID2; text[16])
        {
            Caption = 'Use Document ID 2';
            DataClassification = CustomerContent;
        }
        field(29; DISCFRGT; Decimal)
        {
            Caption = 'Discount Available Freight';
            DataClassification = CustomerContent;
        }
        field(30; ORDAVFRT; Decimal)
        {
            Caption = 'Originating Discount Available Freight';
            DataClassification = CustomerContent;
        }
        field(31; DISCMISC; Decimal)
        {
            Caption = 'Discount Available Misc';
            DataClassification = CustomerContent;
        }
        field(32; ORDAVMSC; Decimal)
        {
            Caption = 'Originating Discount Available Misc';
            DataClassification = CustomerContent;
        }
        field(33; DISAVAMT; Decimal)
        {
            Caption = 'Discount Available Amount';
            DataClassification = CustomerContent;
        }
        field(34; ORDAVAMT; Decimal)
        {
            Caption = 'Originating Discount Available Amount';
            DataClassification = CustomerContent;
        }
        field(35; DISCRTND; Decimal)
        {
            Caption = 'Discount Returned';
            DataClassification = CustomerContent;
        }
        field(36; ORDISRTD; Decimal)
        {
            Caption = 'Originating Discount Returned';
            DataClassification = CustomerContent;
        }
        field(37; DISTKNAM; Decimal)
        {
            Caption = 'Discount Taken Amount';
            DataClassification = CustomerContent;
        }
        field(38; ORDISTKN; Decimal)
        {
            Caption = 'Originating Discount Taken Amount';
            DataClassification = CustomerContent;
        }
        field(39; DSCPCTAM; Integer)
        {
            Caption = 'Discount Percent Amount';
            DataClassification = CustomerContent;
        }
        field(40; DSCDLRAM; Decimal)
        {
            Caption = 'Discount Dollar Amount';
            DataClassification = CustomerContent;
        }
        field(41; ORDDLRAT; Decimal)
        {
            Caption = 'Originating Discount Dollar Amount';
            DataClassification = CustomerContent;
        }
        field(42; DISAVTKN; Decimal)
        {
            Caption = 'Discount Available Taken';
            DataClassification = CustomerContent;
        }
        field(43; ORDATKN; Decimal)
        {
            Caption = 'Originating Discount Available Taken';
            DataClassification = CustomerContent;
        }
        field(44; PYMTRMID; text[22])
        {
            Caption = 'Payment Terms ID';
            DataClassification = CustomerContent;
        }
        field(45; PRCLEVEL; text[12])
        {
            Caption = 'PriceLevel';
            DataClassification = CustomerContent;
        }
        field(46; LOCNCODE; text[12])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(47; BCHSOURC; text[16])
        {
            Caption = 'Batch Source';
            DataClassification = CustomerContent;
        }
        field(48; BACHNUMB; text[16])
        {
            Caption = 'Batch Number';
            DataClassification = CustomerContent;
        }
        field(49; CUSTNMBR; text[16])
        {
            Caption = 'Customer Number';
            DataClassification = CustomerContent;
        }
        field(50; CUSTNAME; text[66])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(51; CSTPONBR; text[22])
        {
            Caption = 'Customer PO Number';
            DataClassification = CustomerContent;
        }
        field(52; PROSPECT; Integer)
        {
            Caption = 'Prospect';
            DataClassification = CustomerContent;
        }
        field(53; MSTRNUMB; Integer)
        {
            Caption = 'Master Number';
            DataClassification = CustomerContent;
        }
        field(54; PCKSLPNO; text[22])
        {
            Caption = 'Packing Slip Number';
            DataClassification = CustomerContent;
        }
        field(55; PICTICNU; text[22])
        {
            Caption = 'Picking Ticket Number';
            DataClassification = CustomerContent;
        }
        field(56; MRKDNAMT; Decimal)
        {
            Caption = 'Markdown Amount';
            DataClassification = CustomerContent;
        }
        field(57; ORMRKDAM; Decimal)
        {
            Caption = 'Originating Markdown Amount';
            DataClassification = CustomerContent;
        }
        field(58; PRBTADCD; text[16])
        {
            Caption = 'Primary Billto Address Code';
            DataClassification = CustomerContent;
        }
        field(59; PRSTADCD; text[16])
        {
            Caption = 'Primary Shipto Address Code';
            DataClassification = CustomerContent;
        }
        field(60; CNTCPRSN; text[62])
        {
            Caption = 'Contact Person';
            DataClassification = CustomerContent;
        }
        field(61; ShipToName; text[66])
        {
            Caption = 'ShipToName';
            DataClassification = CustomerContent;
        }
        field(62; ADDRESS1; text[62])
        {
            Caption = 'Address 1';
            DataClassification = CustomerContent;
        }
        field(63; ADDRESS2; text[62])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(64; ADDRESS3; text[62])
        {
            Caption = 'Address 3';
            DataClassification = CustomerContent;
        }
        field(65; CITY; text[36])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(66; STATE; text[30])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(67; ZIPCODE; text[12])
        {
            Caption = 'Zip Code';
            DataClassification = CustomerContent;
        }
        field(68; CCode; text[8])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
        }
        field(69; COUNTRY; text[62])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        field(70; PHNUMBR1; text[22])
        {
            Caption = 'Phone Number 1';
            DataClassification = CustomerContent;
        }
        field(71; PHNUMBR2; text[22])
        {
            Caption = 'Phone Number 2';
            DataClassification = CustomerContent;
        }
        field(72; PHONE3; text[22])
        {
            Caption = 'Phone 3';
            DataClassification = CustomerContent;
        }
        field(73; FAXNUMBR; text[22])
        {
            Caption = 'Fax Number';
            DataClassification = CustomerContent;
        }
        field(74; COMAPPTO; Option)
        {
            Caption = 'Commission Applied To';
            OptionMembers = "Sales","Invoice Total";
            DataClassification = CustomerContent;
        }
        field(75; COMMAMNT; Decimal)
        {
            Caption = 'Commission Amount';
            DataClassification = CustomerContent;
        }
        field(76; OCOMMAMT; Decimal)
        {
            Caption = 'Originating Commission Amount';
            DataClassification = CustomerContent;
        }
        field(77; CMMSLAMT; Decimal)
        {
            Caption = 'Commission Sale Amount';
            DataClassification = CustomerContent;
        }
        field(78; ORCOSAMT; Decimal)
        {
            Caption = 'Originating Commission Sales Amount';
            DataClassification = CustomerContent;
        }
        field(79; NCOMAMNT; Decimal)
        {
            Caption = 'Non-Commissioned Amount';
            DataClassification = CustomerContent;
        }
        field(80; ORNCMAMT; Decimal)
        {
            Caption = 'Originating Non-Commissioned Amount';
            DataClassification = CustomerContent;
        }
        field(81; SHIPMTHD; text[16])
        {
            Caption = 'Shipping Method';
            DataClassification = CustomerContent;
        }
        field(82; TRDISAMT; Decimal)
        {
            Caption = 'Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(83; ORTDISAM; Decimal)
        {
            Caption = 'Originating Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(84; TRDISPCT; Integer)
        {
            Caption = 'Trade Discount Percent';
            DataClassification = CustomerContent;
        }
        field(85; SUBTOTAL; Decimal)
        {
            Caption = 'Subtotal';
            DataClassification = CustomerContent;
        }
        field(86; ORSUBTOT; Decimal)
        {
            Caption = 'Originating Subtotal';
            DataClassification = CustomerContent;
        }
        field(87; REMSUBTO; Decimal)
        {
            Caption = 'Remaining Subtotal';
            DataClassification = CustomerContent;
        }
        field(88; OREMSUBT; Decimal)
        {
            Caption = 'Originating Remaining Subtotal';
            DataClassification = CustomerContent;
        }
        field(89; EXTDCOST; Decimal)
        {
            Caption = 'Extended Cost';
            DataClassification = CustomerContent;
        }
        field(90; OREXTCST; Decimal)
        {
            Caption = 'Originating Extended Cost';
            DataClassification = CustomerContent;
        }
        field(91; FRTAMNT; Decimal)
        {
            Caption = 'Freight Amount';
            DataClassification = CustomerContent;
        }
        field(92; ORFRTAMT; Decimal)
        {
            Caption = 'Originating Freight Amount';
            DataClassification = CustomerContent;
        }
        field(93; MISCAMNT; Decimal)
        {
            Caption = 'Misc Amount';
            DataClassification = CustomerContent;
        }
        field(94; ORMISCAMT; Decimal)
        {
            Caption = 'Originating Misc Amount';
            DataClassification = CustomerContent;
        }
        field(95; TXENGCLD; Boolean)
        {
            Caption = 'Tax Engine Called';
            DataClassification = CustomerContent;
        }
        field(96; TAXEXMT1; text[26])
        {
            Caption = 'Tax Exempt 1';
            DataClassification = CustomerContent;
        }
        field(97; TAXEXMT2; text[26])
        {
            Caption = 'Tax Exempt 2';
            DataClassification = CustomerContent;
        }
        field(98; TXRGNNUM; text[26])
        {
            Caption = 'Tax Registration Number';
            DataClassification = CustomerContent;
        }
        field(99; TAXSCHID; text[16])
        {
            Caption = 'Tax Schedule ID';
            DataClassification = CustomerContent;
        }
        field(100; TXSCHSRC; Option)
        {
            Caption = 'Tax Schedule Source';
            OptionMembers = "Tax Schedule ID","Site Tax Schedule ID","Single Tax Schedule ID","Ship To Tax Schedule ID";
            DataClassification = CustomerContent;
        }
        field(101; BSIVCTTL; Boolean)
        {
            Caption = 'Based On Invoice Total';
            DataClassification = CustomerContent;
        }
        field(102; FRTSCHID; text[16])
        {
            Caption = 'Freight Schedule ID';
            DataClassification = CustomerContent;
        }
        field(103; FRTTXAMT; Decimal)
        {
            Caption = 'Freight Tax Amount';
            DataClassification = CustomerContent;
        }
        field(104; ORFRTTAX; Decimal)
        {
            Caption = 'Originating Freight Tax Amount';
            DataClassification = CustomerContent;
        }
        field(105; FRGTTXBL; Option)
        {
            Caption = 'Freight Taxable';
            OptionMembers = ,"Taxable","Nontaxable","Base on customers";
            DataClassification = CustomerContent;
        }
        field(106; MSCSCHID; text[16])
        {
            Caption = 'Misc Schedule ID';
            DataClassification = CustomerContent;
        }
        field(107; MSCTXAMT; Decimal)
        {
            Caption = 'Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(108; ORMSCTAX; Decimal)
        {
            Caption = 'Originating Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(109; MISCTXBL; Option)
        {
            Caption = 'Misc Taxable';
            OptionMembers = ,"Taxable","Nontaxable","Base on customers";
            DataClassification = CustomerContent;
        }
        field(110; BKTFRTAM; Decimal)
        {
            Caption = 'Backout Freight Amount';
            DataClassification = CustomerContent;
        }
        field(111; ORBKTFRT; Decimal)
        {
            Caption = 'Originating Backout Freight Amount';
            DataClassification = CustomerContent;
        }
        field(112; BKTMSCAM; Decimal)
        {
            Caption = 'Backout Misc Amount';
            DataClassification = CustomerContent;
        }
        field(113; ORBKTMSC; Decimal)
        {
            Caption = 'Originating Backout Misc Amount';
            DataClassification = CustomerContent;
        }
        field(114; BCKTXAMT; Decimal)
        {
            Caption = 'Backout Tax Amount';
            DataClassification = CustomerContent;
        }
        field(115; OBTAXAMT; Decimal)
        {
            Caption = 'Originating Backout Tax Amount';
            DataClassification = CustomerContent;
        }
        field(116; TXBTXAMT; Decimal)
        {
            Caption = 'Taxable Tax Amount';
            DataClassification = CustomerContent;
        }
        field(117; OTAXTAMT; Decimal)
        {
            Caption = 'Originating Taxable Tax Amount';
            DataClassification = CustomerContent;
        }
        field(118; TAXAMNT; Decimal)
        {
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
        }
        field(119; ORTAXAMT; Decimal)
        {
            Caption = 'Originating Tax Amount';
            DataClassification = CustomerContent;
        }
        field(120; ECTRX; Boolean)
        {
            Caption = 'EC Transaction';
            DataClassification = CustomerContent;
        }
        field(121; DOCAMNT; Decimal)
        {
            Caption = 'Document Amount';
            DataClassification = CustomerContent;
        }
        field(122; ORDOCAMT; Decimal)
        {
            Caption = 'Originating Document Amount';
            DataClassification = CustomerContent;
        }
        field(123; PYMTRCVD; Decimal)
        {
            Caption = 'Payment Received';
            DataClassification = CustomerContent;
        }
        field(124; ORPMTRVD; Decimal)
        {
            Caption = 'Originating Payment Received';
            DataClassification = CustomerContent;
        }
        field(125; DEPRECVD; Decimal)
        {
            Caption = 'Deposit Received';
            DataClassification = CustomerContent;
        }
        field(126; ORDEPRVD; Decimal)
        {
            Caption = 'Originating Deposit Received';
            DataClassification = CustomerContent;
        }
        field(127; CODAMNT; Decimal)
        {
            Caption = 'COD Amount';
            DataClassification = CustomerContent;
        }
        field(128; ORCODAMT; Decimal)
        {
            Caption = 'Originating COD Amount';
            DataClassification = CustomerContent;
        }
        field(129; ACCTAMNT; Decimal)
        {
            Caption = 'Account Amount';
            DataClassification = CustomerContent;
        }
        field(130; ORACTAMT; Decimal)
        {
            Caption = 'Originating Account Amount';
            DataClassification = CustomerContent;
        }
        field(131; SALSTERR; text[16])
        {
            Caption = 'Sales Territory';
            DataClassification = CustomerContent;
        }
        field(132; SLPRSNID; text[16])
        {
            Caption = 'Salesperson ID';
            DataClassification = CustomerContent;
        }
        field(133; UPSZONE; text[4])
        {
            Caption = 'UPS Zone';
            DataClassification = CustomerContent;
        }
        field(134; TIMESPRT; Integer)
        {
            Caption = 'Times Printed';
            DataClassification = CustomerContent;
        }
        field(135; PSTGSTUS; Integer)
        {
            Caption = 'Posting Status';
            DataClassification = CustomerContent;
        }
        field(136; VOIDSTTS; Option)
        {
            Caption = 'Void Status';
            OptionMembers = "Not Voided","Voided";
            DataClassification = CustomerContent;
        }
        field(137; ALLOCABY; Option)
        {
            Caption = 'Allocate By';
            OptionMembers = ,"Line Item","Document/Batch";
            DataClassification = CustomerContent;
        }
        field(138; NOTEINDX; Decimal)
        {
            Caption = 'Note Index';
            DataClassification = CustomerContent;
        }
        field(139; CURNCYID; text[16])
        {
            Caption = 'Currency ID';
            DataClassification = CustomerContent;
        }
        field(140; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(141; RATETPID; text[16])
        {
            Caption = 'Rate Type ID';
            DataClassification = CustomerContent;
        }
        field(142; EXGTBLID; text[16])
        {
            Caption = 'Exchange Table ID';
            DataClassification = CustomerContent;
        }
        field(143; XCHGRATE; Decimal)
        {
            Caption = 'Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(144; DENXRATE; Decimal)
        {
            Caption = 'Denomination Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(145; EXCHDATE; Date)
        {
            Caption = 'Exchange Date';
            DataClassification = CustomerContent;
        }
        field(146; TIME1; DateTime)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }
        field(147; RTCLCMTD; Option)
        {
            Caption = 'Rate Calculation Method';
            OptionMembers = "Multiply","Divide";
            DataClassification = CustomerContent;
        }
        field(148; MCTRXSTT; Option)
        {
            Caption = 'MC Transaction State';
            OptionMembers = "No Euro","Nondenom to nondenom","Nondenom to Euro","Nondenom to denom","Denom to nondenom","Denom to denom","Denom to Euro","Euro to denom","Euro to nondenom";
            DataClassification = CustomerContent;
        }
        field(149; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(150; COMMNTID; text[16])
        {
            Caption = 'Comment ID';
            DataClassification = CustomerContent;
        }
        field(151; REFRENCE; text[32])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(152; POSTEDDT; Date)
        {
            Caption = 'Posted Date';
            DataClassification = CustomerContent;
        }
        field(153; PTDUSRID; text[16])
        {
            Caption = 'Posted User ID';
            DataClassification = CustomerContent;
        }
        field(154; USER2ENT; text[16])
        {
            Caption = 'User To Enter';
            DataClassification = CustomerContent;
        }
        field(155; CREATDDT; Date)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
        }
        field(156; MODIFDT; Date)
        {
            Caption = 'Modified Date';
            DataClassification = CustomerContent;
        }
        field(157; Tax_Date; Date)
        {
            Caption = 'Tax Date';
            DataClassification = CustomerContent;
        }
        field(158; APLYWITH; Boolean)
        {
            Caption = 'Apply Withholding';
            DataClassification = CustomerContent;
        }
        field(159; WITHHAMT; Decimal)
        {
            Caption = 'Withholding Amount';
            DataClassification = CustomerContent;
        }
        field(160; SHPPGDOC; Boolean)
        {
            Caption = 'Shipping Document';
            DataClassification = CustomerContent;
        }
        field(161; CORRCTN; Boolean)
        {
            Caption = 'Correction';
            DataClassification = CustomerContent;
        }
        field(162; SIMPLIFD; Boolean)
        {
            Caption = 'Simplified';
            DataClassification = CustomerContent;
        }
        field(163; DOCNCORR; text[22])
        {
            Caption = 'Document Number Corrected';
            DataClassification = CustomerContent;
        }
        field(164; SEQNCORR; Integer)
        {
            Caption = 'Sequence Number Corrected';
            DataClassification = CustomerContent;
        }
        field(165; SALEDATE; Date)
        {
            Caption = 'Sale Date';
            DataClassification = CustomerContent;
        }
        field(166; EXCEPTIONALDEMAND; Boolean)
        {
            Caption = 'Exceptional Demand';
            DataClassification = CustomerContent;
        }
        field(167; Flags; Integer)
        {
            Caption = 'Flags';
            DataClassification = CustomerContent;
        }
        field(168; SOPSTATUS; Option)
        {
            Caption = 'SOP Status';
            OptionMembers = "New","New ","Ready to Pick","Unconfirmed Pick","Ready to Pack","Unconfirmed Pack","Shipped","Ready to Post","In Process","Complete",;
            DataClassification = CustomerContent;
        }
        field(169; SHIPCOMPLETE; Boolean)
        {
            Caption = 'Ship Complete Document';
            DataClassification = CustomerContent;
        }
        field(170; DIRECTDEBIT; Boolean)
        {
            Caption = 'Direct Debit';
            DataClassification = CustomerContent;
        }
        field(171; WorkflowApprStatCreditLm; Option)
        {
            Caption = 'Workflow Approval Status Credit Limit';
            OptionMembers = ,"Not Submitted","Submitted","Not Needed","Pending Approval","Pending Changes","Approved","Rejected","Ended","Not Activated","Deactivated";
            DataClassification = CustomerContent;
        }
        field(172; WorkflowPriorityCreditLm; Option)
        {
            Caption = 'Workflow Priority Credit Limit';
            OptionMembers = ,"Low","Normal","High";
            DataClassification = CustomerContent;
        }
        field(173; WorkflowApprStatusQuote; Option)
        {
            Caption = 'Workflow Approval Status Quote';
            OptionMembers = ,"Not Submitted","Submitted","Not Needed","Pending Approval","Pending Changes","Approved","Rejected","Ended","Not Activated","Deactivated";
            DataClassification = CustomerContent;
        }
        field(174; WorkflowPriorityQuote; Option)
        {
            Caption = 'Workflow Priority Quote';
            OptionMembers = ,"Low","Normal","High";
            DataClassification = CustomerContent;
        }
        field(175; Workflow_Status; Option)
        {
            Caption = 'Workflow Status';
            OptionMembers = ,"Not Submitted","Submitted (Deprecated)","No Action Needed","Pending User Action","Recalled","Completed","Rejected","Workflow Ended (Deprecated)","Not Activated","Deactivated (Deprecated)";
            DataClassification = CustomerContent;
        }
        field(176; ContractExchangeRateStat; Integer)
        {
            Caption = 'Contract Exchange Rate Status';
            DataClassification = CustomerContent;
        }
        field(177; Print_Phone_NumberGB; Option)
        {
            Caption = 'Print Phone Number GB';
            OptionMembers = "Do Not Print","Phone 1","Phone 2","Phone 3","Fax";
            DataClassification = CustomerContent;
        }
        field(178; DEX_ROW_TS; DateTime)
        {
            Caption = 'DEX_ROW_TS';
            DataClassification = CustomerContent;
        }
        field(179; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; SOPNUMBE, SOPTYPE)
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


