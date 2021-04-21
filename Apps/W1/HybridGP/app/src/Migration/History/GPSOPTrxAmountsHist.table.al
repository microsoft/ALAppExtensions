table 4077 "GPSOPTrxAmountsHist"
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
        field(4; CMPNTSEQ; Integer)
        {
            Caption = 'Component Sequence';
            DataClassification = CustomerContent;
        }
        field(5; ITEMNMBR; text[32])
        {
            Caption = 'Item Number';
            DataClassification = CustomerContent;
        }
        field(6; ITEMDESC; text[102])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
        }
        field(7; NONINVEN; Option)
        {
            Caption = 'Non-Inventory Item';
            OptionMembers = "No","Yes";
            DataClassification = CustomerContent;
        }
        field(8; DROPSHIP; Integer)
        {
            Caption = 'Drop Ship';
            DataClassification = CustomerContent;
        }
        field(9; UOFM; text[10])
        {
            Caption = 'U Of M';
            DataClassification = CustomerContent;
        }
        field(10; LOCNCODE; text[12])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(11; UNITCOST; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
        }
        field(12; ORUNTCST; Decimal)
        {
            Caption = 'Originating Unit Cost';
            DataClassification = CustomerContent;
        }
        field(13; UNITPRCE; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(14; ORUNTPRC; Decimal)
        {
            Caption = 'Originating Unit Price';
            DataClassification = CustomerContent;
        }
        field(15; XTNDPRCE; Decimal)
        {
            Caption = 'Extended Price';
            DataClassification = CustomerContent;
        }
        field(16; OXTNDPRC; Decimal)
        {
            Caption = 'Originating Extended Price';
            DataClassification = CustomerContent;
        }
        field(17; REMPRICE; Decimal)
        {
            Caption = 'Remaining Price';
            DataClassification = CustomerContent;
        }
        field(18; OREPRICE; Decimal)
        {
            Caption = 'Originating Remaining Price';
            DataClassification = CustomerContent;
        }
        field(19; EXTDCOST; Decimal)
        {
            Caption = 'Extended Cost';
            DataClassification = CustomerContent;
        }
        field(20; OREXTCST; Decimal)
        {
            Caption = 'Originating Extended Cost';
            DataClassification = CustomerContent;
        }
        field(21; MRKDNAMT; Decimal)
        {
            Caption = 'Markdown Amount';
            DataClassification = CustomerContent;
        }
        field(22; ORMRKDAM; Decimal)
        {
            Caption = 'Originating Markdown Amount';
            DataClassification = CustomerContent;
        }
        field(23; MRKDNPCT; Integer)
        {
            Caption = 'Markdown Percent';
            DataClassification = CustomerContent;
        }
        field(24; MRKDNTYP; Option)
        {
            Caption = 'Markdown Type';
            OptionMembers = "Percentage","Amount";
            DataClassification = CustomerContent;
        }
        field(25; INVINDX; Integer)
        {
            Caption = 'Inventory Index';
            DataClassification = CustomerContent;
        }
        field(26; CSLSINDX; Integer)
        {
            Caption = 'Cost Of Sales Index';
            DataClassification = CustomerContent;
        }
        field(27; SLSINDX; Integer)
        {
            Caption = 'Sales Index';
            DataClassification = CustomerContent;
        }
        field(28; MKDNINDX; Integer)
        {
            Caption = 'Markdown Index';
            DataClassification = CustomerContent;
        }
        field(29; RTNSINDX; Integer)
        {
            Caption = 'Returns Index';
            DataClassification = CustomerContent;
        }
        field(30; INUSINDX; Integer)
        {
            Caption = 'In Use Index';
            DataClassification = CustomerContent;
        }
        field(31; INSRINDX; Integer)
        {
            Caption = 'In Service Index';
            DataClassification = CustomerContent;
        }
        field(32; DMGDINDX; Integer)
        {
            Caption = 'Damaged Index';
            DataClassification = CustomerContent;
        }
        field(33; ITMTSHID; text[16])
        {
            Caption = 'Item Tax Schedule ID';
            DataClassification = CustomerContent;
        }
        field(34; IVITMTXB; Option)
        {
            Caption = 'IV Item Taxable';
            OptionMembers = ,"Taxable","Nontaxable","Base on customers";
            DataClassification = CustomerContent;
        }
        field(35; BKTSLSAM; Decimal)
        {
            Caption = 'Backout Sales Amount';
            DataClassification = CustomerContent;
        }
        field(36; ORBKTSLS; Decimal)
        {
            Caption = 'Originating Backout Sales Amount';
            DataClassification = CustomerContent;
        }
        field(37; TAXAMNT; Decimal)
        {
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
        }
        field(38; ORTAXAMT; Decimal)
        {
            Caption = 'Originating Tax Amount';
            DataClassification = CustomerContent;
        }
        field(39; TXBTXAMT; Decimal)
        {
            Caption = 'Taxable Tax Amount';
            DataClassification = CustomerContent;
        }
        field(40; OTAXTAMT; Decimal)
        {
            Caption = 'Originating Taxable Tax Amount';
            DataClassification = CustomerContent;
        }
        field(41; BSIVCTTL; Boolean)
        {
            Caption = 'Based On Invoice Total';
            DataClassification = CustomerContent;
        }
        field(42; TRDISAMT; Decimal)
        {
            Caption = 'Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(43; ORTDISAM; Decimal)
        {
            Caption = 'Originating Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(44; DISCSALE; Decimal)
        {
            Caption = 'Discount Available Sales';
            DataClassification = CustomerContent;
        }
        field(45; ORDAVSLS; Decimal)
        {
            Caption = 'Originating Discount Available Sales';
            DataClassification = CustomerContent;
        }
        field(46; QUANTITY; Decimal)
        {
            Caption = 'QTY';
            DataClassification = CustomerContent;
        }
        field(47; ATYALLOC; Decimal)
        {
            Caption = 'QTY Allocated';
            DataClassification = CustomerContent;
        }
        field(48; QTYINSVC; Decimal)
        {
            Caption = 'QTY In Service';
            DataClassification = CustomerContent;
        }
        field(49; QTYINUSE; Decimal)
        {
            Caption = 'QTY In Use';
            DataClassification = CustomerContent;
        }
        field(50; QTYDMGED; Decimal)
        {
            Caption = 'QTY Damaged';
            DataClassification = CustomerContent;
        }
        field(51; QTYRTRND; Decimal)
        {
            Caption = 'QTY Returned';
            DataClassification = CustomerContent;
        }
        field(52; QTYONHND; Decimal)
        {
            Caption = 'QTY On Hand';
            DataClassification = CustomerContent;
        }
        field(53; QTYCANCE; Decimal)
        {
            Caption = 'QTY Canceled';
            DataClassification = CustomerContent;
        }
        field(54; QTYCANOT; Decimal)
        {
            Caption = 'QTY Canceled Other';
            DataClassification = CustomerContent;
        }
        field(55; QTYORDER; Decimal)
        {
            Caption = 'QTY Ordered';
            DataClassification = CustomerContent;
        }
        field(56; QTYPRBAC; Decimal)
        {
            Caption = 'QTY Prev Back Ordered';
            DataClassification = CustomerContent;
        }
        field(57; QTYPRBOO; Decimal)
        {
            Caption = 'QTY Prev BO On Order';
            DataClassification = CustomerContent;
        }
        field(58; QTYPRINV; Decimal)
        {
            Caption = 'QTY Prev Invoiced';
            DataClassification = CustomerContent;
        }
        field(59; QTYPRORD; Decimal)
        {
            Caption = 'QTY Prev Ordered';
            DataClassification = CustomerContent;
        }
        field(60; QTYPRVRECVD; Decimal)
        {
            Caption = 'QTY Prev Received';
            DataClassification = CustomerContent;
        }
        field(61; QTYRECVD; Decimal)
        {
            Caption = 'QTY Received';
            DataClassification = CustomerContent;
        }
        field(62; QTYREMAI; Decimal)
        {
            Caption = 'QTY Remaining';
            DataClassification = CustomerContent;
        }
        field(63; QTYREMBO; Decimal)
        {
            Caption = 'QTY Remaining On BO';
            DataClassification = CustomerContent;
        }
        field(64; QTYTBAOR; Decimal)
        {
            Caption = 'QTY To Back Order';
            DataClassification = CustomerContent;
        }
        field(65; QTYTOINV; Decimal)
        {
            Caption = 'QTY To Invoice';
            DataClassification = CustomerContent;
        }
        field(66; QTYTORDR; Decimal)
        {
            Caption = 'QTY To Order';
            DataClassification = CustomerContent;
        }
        field(67; QTYFULFI; Decimal)
        {
            Caption = 'QTY Fulfilled';
            DataClassification = CustomerContent;
        }
        field(68; QTYSLCTD; Decimal)
        {
            Caption = 'QTY Selected';
            DataClassification = CustomerContent;
        }
        field(69; QTYBSUOM; Decimal)
        {
            Caption = 'QTY In Base U Of M';
            DataClassification = CustomerContent;
        }
        field(70; EXTQTYAL; Decimal)
        {
            Caption = 'Existing Qty Available';
            DataClassification = CustomerContent;
        }
        field(71; EXTQTYSEL; Decimal)
        {
            Caption = 'Existing Qty Selected';
            DataClassification = CustomerContent;
        }
        field(72; ReqShipDate; Date)
        {
            Caption = 'Requested Ship Date';
            DataClassification = CustomerContent;
        }
        field(73; FUFILDAT; Date)
        {
            Caption = 'Fulfillment Date';
            DataClassification = CustomerContent;
        }
        field(74; ACTLSHIP; Date)
        {
            Caption = 'Actual Ship Date';
            DataClassification = CustomerContent;
        }
        field(75; SHIPMTHD; text[16])
        {
            Caption = 'Shipping Method';
            DataClassification = CustomerContent;
        }
        field(76; SALSTERR; text[16])
        {
            Caption = 'Sales Territory';
            DataClassification = CustomerContent;
        }
        field(77; SLPRSNID; text[16])
        {
            Caption = 'Salesperson ID';
            DataClassification = CustomerContent;
        }
        field(78; PRCLEVEL; text[12])
        {
            Caption = 'PriceLevel';
            DataClassification = CustomerContent;
        }
        field(79; COMMNTID; text[16])
        {
            Caption = 'Comment ID';
            DataClassification = CustomerContent;
        }
        field(80; BRKFLD1; Integer)
        {
            Caption = 'Break Field 1';
            DataClassification = CustomerContent;
        }
        field(81; BRKFLD2; Integer)
        {
            Caption = 'Break Field 2';
            DataClassification = CustomerContent;
        }
        field(82; BRKFLD3; Integer)
        {
            Caption = 'Break Field 3';
            DataClassification = CustomerContent;
        }
        field(83; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(84; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(85; DOCNCORR; text[22])
        {
            Caption = 'Document Number Corrected';
            DataClassification = CustomerContent;
        }
        field(86; ORGSEQNM; Integer)
        {
            Caption = 'Original Sequence Number Corrected';
            DataClassification = CustomerContent;
        }
        field(87; ITEMCODE; text[16])
        {
            Caption = 'Item Code';
            DataClassification = CustomerContent;
        }
        field(88; PURCHSTAT; Option)
        {
            Caption = 'Purchasing Status';
            OptionMembers = ,"None","Needs Purchase","Purchased","Partially Purchased","Fully Received";
            DataClassification = CustomerContent;
        }
        field(89; DECPLQTY; Option)
        {
            Caption = 'Decimal Places QTYS';
            OptionMembers = ,"0","1","2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(90; DECPLCUR; Option)
        {
            Caption = 'Decimal Places Currency';
            OptionMembers = ,"0","1","2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(91; ODECPLCU; Option)
        {
            Caption = 'Originating Decimal Places Currency';
            OptionMembers = ,"0","1","2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(92; EXCEPTIONALDEMAND; Boolean)
        {
            Caption = 'Exceptional Demand';
            DataClassification = CustomerContent;
        }
        field(93; TAXSCHID; text[16])
        {
            Caption = 'Tax Schedule ID';
            DataClassification = CustomerContent;
        }
        field(94; TXSCHSRC; Option)
        {
            Caption = 'Tax Schedule Source';
            OptionMembers = "Tax Schedule ID","Site Tax Schedule ID","Single Tax Schedule ID","Ship To Tax Schedule ID";
            DataClassification = CustomerContent;
        }
        field(95; PRSTADCD; text[16])
        {
            Caption = 'Primary Shipto Address Code';
            DataClassification = CustomerContent;
        }
        field(96; ShipToName; text[66])
        {
            Caption = 'ShipToName';
            DataClassification = CustomerContent;
        }
        field(97; CNTCPRSN; text[62])
        {
            Caption = 'Contact Person';
            DataClassification = CustomerContent;
        }
        field(98; ADDRESS1; text[62])
        {
            Caption = 'Address 1';
            DataClassification = CustomerContent;
        }
        field(99; ADDRESS2; text[62])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(100; ADDRESS3; text[62])
        {
            Caption = 'Address 3';
            DataClassification = CustomerContent;
        }
        field(101; CITY; text[36])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(102; STATE; text[30])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(103; ZIPCODE; text[12])
        {
            Caption = 'Zip Code';
            DataClassification = CustomerContent;
        }
        field(104; CCode; text[8])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
        }
        field(105; COUNTRY; text[62])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        field(106; PHONE1; text[22])
        {
            Caption = 'Phone 1';
            DataClassification = CustomerContent;
        }
        field(107; PHONE2; text[22])
        {
            Caption = 'Phone 2';
            DataClassification = CustomerContent;
        }
        field(108; PHONE3; text[22])
        {
            Caption = 'Phone 3';
            DataClassification = CustomerContent;
        }
        field(109; FAXNUMBR; text[22])
        {
            Caption = 'Fax Number';
            DataClassification = CustomerContent;
        }
        field(110; Flags; Integer)
        {
            Caption = 'Flags';
            DataClassification = CustomerContent;
        }
        field(111; CONTNBR; text[12])
        {
            Caption = 'Contract Number';
            DataClassification = CustomerContent;
        }
        field(112; CONTLNSEQNBR; Decimal)
        {
            Caption = 'Contract Line SEQ Number';
            DataClassification = CustomerContent;
        }
        field(113; CONTSTARTDTE; Date)
        {
            Caption = 'Contract Start Date';
            DataClassification = CustomerContent;
        }
        field(114; CONTENDDTE; Date)
        {
            Caption = 'Contract End Date';
            DataClassification = CustomerContent;
        }
        field(115; CONTITEMNBR; text[32])
        {
            Caption = 'Contract Item Number';
            DataClassification = CustomerContent;
        }
        field(116; CONTSERIALNBR; text[22])
        {
            Caption = 'Contract Serial Number';
            DataClassification = CustomerContent;
        }
        field(117; ISLINEINTRA; Boolean)
        {
            Caption = 'IsLineIntrastat';
            DataClassification = CustomerContent;
        }
        field(118; Print_Phone_NumberGB; Option)
        {
            Caption = 'Print Phone Number GB';
            OptionMembers = "Do Not Print","Phone 1","Phone 2","Phone 3","Fax";
            DataClassification = CustomerContent;
        }
        field(119; DEX_ROW_TS; DateTime)
        {
            Caption = 'DEX_ROW_TS';
            DataClassification = CustomerContent;
        }
        field(120; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; SOPNUMBE, SOPTYPE, CMPNTSEQ, LNITMSEQ)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
