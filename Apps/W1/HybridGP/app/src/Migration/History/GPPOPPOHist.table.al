table 4057 "GPPOPPOHist"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; PONUMBER; text[18])
        {
            Caption = 'PO Number';
            DataClassification = CustomerContent;
        }
        field(2; POSTATUS; Option)
        {
            Caption = 'PO Status';
            OptionMembers = ,"New","Released","Change Order","Received","Closed","Canceled";
            DataClassification = CustomerContent;
        }
        field(3; STATGRP; Option)
        {
            Caption = 'Status Group';
            OptionMembers = "Voided","Active","Closed";
            DataClassification = CustomerContent;
        }
        field(4; POTYPE; Option)
        {
            Caption = 'PO Type';
            OptionMembers = ,"Standard","Drop-Ship","Blanket","Drop-Ship Blanket";
            DataClassification = CustomerContent;
        }
        field(5; USER2ENT; text[16])
        {
            Caption = 'User To Enter';
            DataClassification = CustomerContent;
        }
        field(6; CONFIRM1; text[22])
        {
            Caption = 'Confirm With';
            DataClassification = CustomerContent;
        }
        field(7; DOCDATE; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(8; LSTEDTDT; Date)
        {
            Caption = 'Last Edit Date';
            DataClassification = CustomerContent;
        }
        field(9; LSTPRTDT; Date)
        {
            Caption = 'Last Printed Date';
            DataClassification = CustomerContent;
        }
        field(10; PRMDATE; Date)
        {
            Caption = 'Promised Date';
            DataClassification = CustomerContent;
        }
        field(11; PRMSHPDTE; Date)
        {
            Caption = 'Promised Ship Date';
            DataClassification = CustomerContent;
        }
        field(12; REQDATE; Date)
        {
            Caption = 'Required Date';
            DataClassification = CustomerContent;
        }
        field(13; REQTNDT; Date)
        {
            Caption = 'Requisition Date';
            DataClassification = CustomerContent;
        }
        field(14; SHIPMTHD; text[16])
        {
            Caption = 'Shipping Method';
            DataClassification = CustomerContent;
        }
        field(15; TXRGNNUM; text[26])
        {
            Caption = 'Tax Registration Number';
            DataClassification = CustomerContent;
        }
        field(16; REMSUBTO; Decimal)
        {
            Caption = 'Remaining Subtotal';
            DataClassification = CustomerContent;
        }
        field(17; SUBTOTAL; Decimal)
        {
            Caption = 'Subtotal';
            DataClassification = CustomerContent;
        }
        field(18; TRDISAMT; Decimal)
        {
            Caption = 'Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(20; FRTAMNT; Decimal)
        {
            Caption = 'Freight Amount';
            DataClassification = CustomerContent;
        }
        field(21; MSCCHAMT; Decimal)
        {
            Caption = 'Misc Charges Amount';
            DataClassification = CustomerContent;
        }
        field(22; TAXAMNT; Decimal)
        {
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
        }
        field(23; VENDORID; text[16])
        {
            Caption = 'Vendor ID';
            DataClassification = CustomerContent;
        }
        field(24; VENDNAME; text[66])
        {
            Caption = 'Vendor Name';
            DataClassification = CustomerContent;
        }
        field(25; MINORDER; Decimal)
        {
            Caption = 'Minimum Order';
            DataClassification = CustomerContent;
        }
        field(26; VADCDPAD; text[16])
        {
            Caption = 'Vendor Address Code - Purchase Address';
            DataClassification = CustomerContent;
        }
        field(27; CMPANYID; Integer)
        {
            Caption = 'Company ID';
            DataClassification = CustomerContent;
        }
        field(28; PRBTADCD; text[16])
        {
            Caption = 'Primary Billto Address Code';
            DataClassification = CustomerContent;
        }
        field(29; PRSTADCD; text[16])
        {
            Caption = 'Primary Shipto Address Code';
            DataClassification = CustomerContent;
        }
        field(30; CMPNYNAM; text[66])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(31; CONTACT; text[62])
        {
            Caption = 'Contact';
            DataClassification = CustomerContent;
        }
        field(32; ADDRESS1; text[62])
        {
            Caption = 'Address 1';
            DataClassification = CustomerContent;
        }
        field(33; ADDRESS2; text[62])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(34; ADDRESS3; text[62])
        {
            Caption = 'Address 3';
            DataClassification = CustomerContent;
        }
        field(35; CITY; text[36])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(36; STATE; text[30])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(37; ZIPCODE; text[12])
        {
            Caption = 'Zip Code';
            DataClassification = CustomerContent;
        }
        field(38; CCode; text[8])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
        }
        field(39; COUNTRY; text[62])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        field(40; PHONE1; text[22])
        {
            Caption = 'Phone 1';
            DataClassification = CustomerContent;
        }
        field(41; PHONE2; text[22])
        {
            Caption = 'Phone 2';
            DataClassification = CustomerContent;
        }
        field(42; PHONE3; text[22])
        {
            Caption = 'Phone 3';
            DataClassification = CustomerContent;
        }
        field(43; FAX; text[22])
        {
            Caption = 'Fax';
            DataClassification = CustomerContent;
        }
        field(44; PYMTRMID; text[22])
        {
            Caption = 'Payment Terms ID';
            DataClassification = CustomerContent;
        }
        field(45; DSCDLRAM; Decimal)
        {
            Caption = 'Discount Dollar Amount';
            DataClassification = CustomerContent;
        }
        field(46; DSCPCTAM; Integer)
        {
            Caption = 'Discount Percent Amount';
            DataClassification = CustomerContent;
        }
        field(47; DISAMTAV; Decimal)
        {
            Caption = 'Discount Amount Available';
            DataClassification = CustomerContent;
        }
        field(48; DISCDATE; Date)
        {
            Caption = 'Discount Date';
            DataClassification = CustomerContent;
        }
        field(49; DUEDATE; Date)
        {
            Caption = 'Due Date';
            DataClassification = CustomerContent;
        }
        field(50; CUSTNMBR; text[16])
        {
            Caption = 'Customer Number';
            DataClassification = CustomerContent;
        }
        field(51; TIMESPRT; Integer)
        {
            Caption = 'Times Printed';
            DataClassification = CustomerContent;
        }
        field(52; CREATDDT; Date)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
        }
        field(53; MODIFDT; Date)
        {
            Caption = 'Modified Date';
            DataClassification = CustomerContent;
        }
        field(54; PONOTIDS_1; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(55; PONOTIDS_2; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(56; PONOTIDS_3; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(57; PONOTIDS_4; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(58; PONOTIDS_5; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(59; PONOTIDS_6; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(60; PONOTIDS_7; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(61; PONOTIDS_8; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(62; PONOTIDS_9; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(63; PONOTIDS_10; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(64; PONOTIDS_11; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(65; PONOTIDS_12; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(66; PONOTIDS_13; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(67; PONOTIDS_14; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(68; PONOTIDS_15; Decimal)
        {
            Caption = 'PO Note ID Array';
            DataClassification = CustomerContent;
        }
        field(69; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(70; COMMNTID; text[16])
        {
            Caption = 'Comment ID';
            DataClassification = CustomerContent;
        }
        field(71; CANCSUB; Decimal)
        {
            Caption = 'Canceled Subtotal';
            DataClassification = CustomerContent;
        }
        field(72; CURNCYID; text[16])
        {
            Caption = 'Currency ID';
            DataClassification = CustomerContent;
        }
        field(73; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(74; RATETPID; text[16])
        {
            Caption = 'Rate Type ID';
            DataClassification = CustomerContent;
        }
        field(75; EXGTBLID; text[16])
        {
            Caption = 'Exchange Table ID';
            DataClassification = CustomerContent;
        }
        field(76; XCHGRATE; Decimal)
        {
            Caption = 'Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(77; EXCHDATE; Date)
        {
            Caption = 'Exchange Date';
            DataClassification = CustomerContent;
        }
        field(78; TIME1; DateTime)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }
        field(79; RATECALC; Option)
        {
            Caption = 'Rate Calc Method';
            OptionMembers = "Multiply","Divide";
            DataClassification = CustomerContent;
        }
        field(80; DENXRATE; Decimal)
        {
            Caption = 'Denomination Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(81; MCTRXSTT; Option)
        {
            Caption = 'MC Transaction State';
            OptionMembers = "No Euro","Nondenom to nondenom","Nondenom to Euro","Nondenom to denom","Denom to nondenom","Denom to denom","Denom to Euro","Euro to denom","Euro to nondenom";
            DataClassification = CustomerContent;
        }
        field(82; OREMSUBT; Decimal)
        {
            Caption = 'Originating Remaining Subtotal';
            DataClassification = CustomerContent;
        }
        field(83; ORSUBTOT; Decimal)
        {
            Caption = 'Originating Subtotal';
            DataClassification = CustomerContent;
        }
        field(84; Originating_Canceled_Sub; Decimal)
        {
            Caption = 'Originating Canceled Subtotal';
            DataClassification = CustomerContent;
        }
        field(85; ORTDISAM; Decimal)
        {
            Caption = 'Originating Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(86; ORFRTAMT; Decimal)
        {
            Caption = 'Originating Freight Amount';
            DataClassification = CustomerContent;
        }
        field(87; OMISCAMT; Decimal)
        {
            Caption = 'Originating Misc Charges Amount';
            DataClassification = CustomerContent;
        }
        field(88; ORTAXAMT; Decimal)
        {
            Caption = 'Originating Tax Amount';
            DataClassification = CustomerContent;
        }
        field(89; ORDDLRAT; Decimal)
        {
            Caption = 'Originating Discount Dollar Amount';
            DataClassification = CustomerContent;
        }
        field(90; ODISAMTAV; Decimal)
        {
            Caption = 'Originating Discount Amount Available';
            DataClassification = CustomerContent;
        }
        field(91; BUYERID; text[16])
        {
            Caption = 'Buyer ID';
            DataClassification = CustomerContent;
        }
        field(92; ALLOWSOCMTS; Boolean)
        {
            Caption = 'Allow SO Commitments';
            DataClassification = CustomerContent;
        }
        field(93; DISGRPER; Integer)
        {
            Caption = 'Discount Grace Period';
            DataClassification = CustomerContent;
        }
        field(94; DUEGRPER; Integer)
        {
            Caption = 'Due Date Grace Period';
            DataClassification = CustomerContent;
        }
        field(95; Revision_Number; Integer)
        {
            Caption = 'Revision Number';
            DataClassification = CustomerContent;
        }
        field(96; TAXSCHID; text[16])
        {
            Caption = 'Tax Schedule ID';
            DataClassification = CustomerContent;
        }
        field(97; TXSCHSRC; Option)
        {
            Caption = 'Tax Schedule Source';
            OptionMembers = "Tax Schedule ID","Site Tax Schedule ID","Single Tax Schedule ID","Ship To Tax Schedule ID";
            DataClassification = CustomerContent;
        }
        field(98; BSIVCTTL; Boolean)
        {
            Caption = 'Based On Invoice Total';
            DataClassification = CustomerContent;
        }
        field(99; Purchase_Freight_Taxable; Option)
        {
            Caption = 'Purchase Freight Taxable';
            OptionMembers = ,"Taxable","Nontaxable","Base on vendor";
            DataClassification = CustomerContent;
        }
        field(100; Purchase_Misc_Taxable; Option)
        {
            Caption = 'Purchase Misc Taxable';
            OptionMembers = ,"Taxable","Nontaxable","Base on vendor";
            DataClassification = CustomerContent;
        }
        field(101; FRTSCHID; text[16])
        {
            Caption = 'Freight Schedule ID';
            DataClassification = CustomerContent;
        }
        field(102; MSCSCHID; text[16])
        {
            Caption = 'Misc Schedule ID';
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
        field(105; MSCTXAMT; Decimal)
        {
            Caption = 'Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(106; ORMSCTAX; Decimal)
        {
            Caption = 'Originating Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(107; BCKTXAMT; Decimal)
        {
            Caption = 'Backout Tax Amount';
            DataClassification = CustomerContent;
        }
        field(108; OBTAXAMT; Decimal)
        {
            Caption = 'Originating Backout Tax Amount';
            DataClassification = CustomerContent;
        }
        field(109; BackoutFreightTaxAmt; Decimal)
        {
            Caption = 'Backout Freight Tax Amount';
            DataClassification = CustomerContent;
        }
        field(110; OrigBackoutFreightTaxAmt; Decimal)
        {
            Caption = 'Originating Backout Freight Tax Amount';
            DataClassification = CustomerContent;
        }
        field(111; BackoutMiscTaxAmt; Decimal)
        {
            Caption = 'Backout Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(112; OrigBackoutMiscTaxAmt; Decimal)
        {
            Caption = 'Originating Backout Misc Tax Amount';
            DataClassification = CustomerContent;
        }
        field(113; Flags; Integer)
        {
            Caption = 'Flags';
            DataClassification = CustomerContent;
        }
        field(114; POPCONTNUM; text[22])
        {
            Caption = 'POP Contract Number';
            DataClassification = CustomerContent;
        }
        field(115; CONTENDDTE; Date)
        {
            Caption = 'Contract End Date';
            DataClassification = CustomerContent;
        }
        field(116; CNTRLBLKTBY; Option)
        {
            Caption = 'Control Blanket By';
            OptionMembers = "Quantity","Value";
            DataClassification = CustomerContent;
        }
        field(117; PURCHCMPNYNAM; text[66])
        {
            Caption = 'Purchase Company Name';
            DataClassification = CustomerContent;
        }
        field(118; PURCHCONTACT; text[62])
        {
            Caption = 'Purchase Contact';
            DataClassification = CustomerContent;
        }
        field(119; PURCHADDRESS1; text[62])
        {
            Caption = 'Purchase Address 1';
            DataClassification = CustomerContent;
        }
        field(120; PURCHADDRESS2; text[62])
        {
            Caption = 'Purchase Address 2';
            DataClassification = CustomerContent;
        }
        field(121; PURCHADDRESS3; text[62])
        {
            Caption = 'Purchase Address 3';
            DataClassification = CustomerContent;
        }
        field(122; PURCHCITY; text[36])
        {
            Caption = 'Purchase City';
            DataClassification = CustomerContent;
        }
        field(123; PURCHSTATE; text[30])
        {
            Caption = 'Purchase State';
            DataClassification = CustomerContent;
        }
        field(124; PURCHZIPCODE; text[12])
        {
            Caption = 'Purchase Zip Code';
            DataClassification = CustomerContent;
        }
        field(125; PURCHCCode; text[8])
        {
            Caption = 'Purchase Country Code';
            DataClassification = CustomerContent;
        }
        field(126; PURCHCOUNTRY; text[62])
        {
            Caption = 'Purchase Country';
            DataClassification = CustomerContent;
        }
        field(127; PURCHPHONE1; text[22])
        {
            Caption = 'Purchase Phone 1';
            DataClassification = CustomerContent;
        }
        field(128; PURCHPHONE2; text[22])
        {
            Caption = 'Purchase Phone 2';
            DataClassification = CustomerContent;
        }
        field(129; PURCHPHONE3; text[22])
        {
            Caption = 'Purchase Phone 3';
            DataClassification = CustomerContent;
        }
        field(130; PURCHFAX; text[22])
        {
            Caption = 'Purchase Fax';
            DataClassification = CustomerContent;
        }
        field(131; BLNKTLINEEXTQTYSUM; Decimal)
        {
            Caption = 'Total Blanket Line Ext Qty';
            DataClassification = CustomerContent;
        }
        field(132; Workflow_Approval_Status; Option)
        {
            Caption = 'Workflow Approval Status';
            OptionMembers = ,"Not Submitted","Submitted","Not Needed","Pending Approval","Pending Changes","Approved","Rejected","Ended","Not Activated","Deactivated";
            DataClassification = CustomerContent;
        }
        field(133; Workflow_Priority; Option)
        {
            Caption = 'Workflow Priority';
            OptionMembers = ,"Low","Normal","High";
            DataClassification = CustomerContent;
        }
        field(134; Workflow_Status; Option)
        {
            Caption = 'Workflow Status';
            OptionMembers = ,"Not Submitted","Submitted (Deprecated)","No Action Needed","Pending User Action","Recalled","Completed","Rejected","Workflow Ended (Deprecated)","Not Activated","Deactivated (Deprecated)";
            DataClassification = CustomerContent;
        }
        field(135; Print_Phone_NumberGB; Option)
        {
            Caption = 'Print Phone Number GB';
            OptionMembers = "Do Not Print","Phone 1","Phone 2","Phone 3","Fax";
            DataClassification = CustomerContent;
        }
        field(136; PrepaymentAmount; Decimal)
        {
            Caption = 'Prepayment Amount';
            DataClassification = CustomerContent;
        }
        field(137; OriginatingPrepaymentAmt; Decimal)
        {
            Caption = 'Originating Prepayment Amount';
            DataClassification = CustomerContent;
        }
        field(138; DEX_ROW_TS; DateTime)
        {
            Caption = 'DEX_ROW_TS';
            DataClassification = CustomerContent;
        }
        field(139; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; PONUMBER)
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
