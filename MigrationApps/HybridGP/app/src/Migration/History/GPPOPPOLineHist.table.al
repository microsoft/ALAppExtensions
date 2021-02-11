table 4058 "GPPOPPOLineHist"
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
        field(2; ORD; Integer)
        {
            Caption = 'Ord';
            DataClassification = CustomerContent;
        }
        field(3; POLNESTA; Option)
        {
            Caption = 'PO Line Status';
            OptionMembers = ,"New","Released","Change Order","Received","Closed","Canceled";
            DataClassification = CustomerContent;
        }
        field(4; POTYPE; Option)
        {
            Caption = 'PO Type';
            OptionMembers = ,"Standard","Drop-Ship","Blanket","Drop-Ship Blanket";
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
        field(7; VENDORID; text[16])
        {
            Caption = 'Vendor ID';
            DataClassification = CustomerContent;
        }
        field(8; VNDITNUM; text[32])
        {
            Caption = 'Vendor Item Number';
            DataClassification = CustomerContent;
        }
        field(9; VNDITDSC; text[102])
        {
            Caption = 'Vendor Item Description';
            DataClassification = CustomerContent;
        }
        field(10; NONINVEN; Option)
        {
            Caption = 'Non-Inventory Item';
            OptionMembers = "No","Yes";
            DataClassification = CustomerContent;
        }
        field(11; LOCNCODE; text[12])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(12; UOFM; text[10])
        {
            Caption = 'U Of M';
            DataClassification = CustomerContent;
        }
        field(13; UMQTYINB; Decimal)
        {
            Caption = 'U Of M QTY In Base';
            DataClassification = CustomerContent;
        }
        field(14; QTYORDER; Decimal)
        {
            Caption = 'QTY Ordered';
            DataClassification = CustomerContent;
        }
        field(15; QTYCANCE; Decimal)
        {
            Caption = 'QTY Canceled';
            DataClassification = CustomerContent;
        }
        field(16; UNITCOST; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
        }
        field(17; EXTDCOST; Decimal)
        {
            Caption = 'Extended Cost';
            DataClassification = CustomerContent;
        }
        field(18; INVINDX; Integer)
        {
            Caption = 'Inventory Index';
            DataClassification = CustomerContent;
        }
        field(19; REQDATE; Date)
        {
            Caption = 'Required Date';
            DataClassification = CustomerContent;
        }
        field(20; PRMDATE; Date)
        {
            Caption = 'Promised Date';
            DataClassification = CustomerContent;
        }
        field(21; PRMSHPDTE; Date)
        {
            Caption = 'Promised Ship Date';
            DataClassification = CustomerContent;
        }
        field(22; REQSTDBY; text[22])
        {
            Caption = 'Requested By';
            DataClassification = CustomerContent;
        }
        field(23; COMMNTID; text[16])
        {
            Caption = 'Comment ID';
            DataClassification = CustomerContent;
        }
        field(24; DOCTYPE; Option)
        {
            Caption = 'Document Type';
            OptionMembers = ,"Purchase Order","Receipt";
            DataClassification = CustomerContent;
        }
        field(25; POLNEARY_1; Decimal)
        {
            Caption = 'PO Line Note ID Array';
            DataClassification = CustomerContent;
        }
        field(26; POLNEARY_2; Decimal)
        {
            Caption = 'PO Line Note ID Array';
            DataClassification = CustomerContent;
        }
        field(27; POLNEARY_3; Decimal)
        {
            Caption = 'PO Line Note ID Array';
            DataClassification = CustomerContent;
        }
        field(28; POLNEARY_4; Decimal)
        {
            Caption = 'PO Line Note ID Array';
            DataClassification = CustomerContent;
        }
        field(29; POLNEARY_5; Decimal)
        {
            Caption = 'PO Line Note ID Array';
            DataClassification = CustomerContent;
        }
        field(30; POLNEARY_6; Decimal)
        {
            Caption = 'PO Line Note ID Array';
            DataClassification = CustomerContent;
        }
        field(31; POLNEARY_7; Decimal)
        {
            Caption = 'PO Line Note ID Array';
            DataClassification = CustomerContent;
        }
        field(32; POLNEARY_8; Decimal)
        {
            Caption = 'PO Line Note ID Array';
            DataClassification = CustomerContent;
        }
        field(33; POLNEARY_9; Decimal)
        {
            Caption = 'PO Line Note ID Array';
            DataClassification = CustomerContent;
        }
        field(34; DECPLCUR; Option)
        {
            Caption = 'Decimal Places Currency';
            OptionMembers = ,,,,,,,"0","1","2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(35; DECPLQTY; Option)
        {
            Caption = 'Decimal Places QTYS';
            OptionMembers = ,"0","1","2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(36; BRKFLD1; Integer)
        {
            Caption = 'Break Field 1';
            DataClassification = CustomerContent;
        }
        field(37; JOBNUMBR; text[18])
        {
            Caption = 'Job Number';
            DataClassification = CustomerContent;
        }
        field(38; COSTCODE; text[28])
        {
            Caption = 'Cost Code';
            DataClassification = CustomerContent;
        }
        field(39; COSTTYPE; Integer)
        {
            Caption = 'Cost Code Type';
            DataClassification = CustomerContent;
        }
        field(40; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(41; ORUNTCST; Decimal)
        {
            Caption = 'Originating Unit Cost';
            DataClassification = CustomerContent;
        }
        field(42; OREXTCST; Decimal)
        {
            Caption = 'Originating Extended Cost';
            DataClassification = CustomerContent;
        }
        field(43; LINEORIGIN; Option)
        {
            Caption = 'Line Origin';
            OptionMembers = ,"Manual","e. Req.","SOP","MRP","SMS-CL","SMS-RT","SMS-DP","MOP","PO Gen","POREQ";
            DataClassification = CustomerContent;
        }
        field(44; FREEONBOARD; Option)
        {
            Caption = 'Free On Board';
            OptionMembers = ,"None","Origin","Destination";
            DataClassification = CustomerContent;
        }
        field(45; ODECPLCU; Option)
        {
            Caption = 'Originating Decimal Places Currency';
            OptionMembers = ,"0","1","2","3","4","5","0 ","1 ","2 ","3 ","4 ","5 ";
            DataClassification = CustomerContent;
        }
        field(46; Product_Indicator; Integer)
        {
            Caption = 'Product Indicator';
            DataClassification = CustomerContent;
        }
        field(47; Source_Document_Number; text[12])
        {
            Caption = 'Source Document Number';
            DataClassification = CustomerContent;
        }
        field(48; Source_Document_Line_Num; Integer)
        {
            Caption = 'Source Document Line Number';
            DataClassification = CustomerContent;
        }
        field(49; RELEASEBYDATE; Date)
        {
            Caption = 'Release By Date';
            DataClassification = CustomerContent;
        }
        field(50; Released_Date; Date)
        {
            Caption = 'Released Date';
            DataClassification = CustomerContent;
        }
        field(51; Purchase_IV_Item_Taxable; Option)
        {
            Caption = 'Purchase IV Item Taxable';
            OptionMembers = ,"Taxable","Nontaxable","Base on vendor";
            DataClassification = CustomerContent;
        }
        field(52; Purchase_Item_Tax_Schedu; text[16])
        {
            Caption = 'Purchase Item Tax Schedule ID';
            DataClassification = CustomerContent;
        }
        field(53; Purchase_Site_Tax_Schedu; text[16])
        {
            Caption = 'Purchase Site Tax Schedule ID';
            DataClassification = CustomerContent;
        }
        field(54; PURCHSITETXSCHSRC; Integer)
        {
            Caption = 'Purchase Site Tax Schedule Source';
            DataClassification = CustomerContent;
        }
        field(55; BSIVCTTL; Boolean)
        {
            Caption = 'Based On Invoice Total';
            DataClassification = CustomerContent;
        }
        field(56; TAXAMNT; Decimal)
        {
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
        }
        field(57; ORTAXAMT; Decimal)
        {
            Caption = 'Originating Tax Amount';
            DataClassification = CustomerContent;
        }
        field(58; BCKTXAMT; Decimal)
        {
            Caption = 'Backout Tax Amount';
            DataClassification = CustomerContent;
        }
        field(59; OBTAXAMT; Decimal)
        {
            Caption = 'Originating Backout Tax Amount';
            DataClassification = CustomerContent;
        }
        field(60; Landed_Cost_Group_ID; text[16])
        {
            Caption = 'Landed Cost Group ID';
            DataClassification = CustomerContent;
        }
        field(61; SHIPMTHD; text[16])
        {
            Caption = 'Shipping Method';
            DataClassification = CustomerContent;
        }
        field(62; LineNumber; Integer)
        {
            Caption = 'LineNumber';
            DataClassification = CustomerContent;
        }
        field(63; ORIGPRMDATE; Date)
        {
            Caption = 'Original Promised Date';
            DataClassification = CustomerContent;
        }
        field(64; FSTRCPTDT; Date)
        {
            Caption = 'First Receipt Date';
            DataClassification = CustomerContent;
        }
        field(65; LSTRCPTDT; Date)
        {
            Caption = 'Last Receipt Date';
            DataClassification = CustomerContent;
        }
        field(66; RELEASE; Integer)
        {
            Caption = 'Release';
            DataClassification = CustomerContent;
        }
        field(67; ADRSCODE; text[16])
        {
            Caption = 'Address Code';
            DataClassification = CustomerContent;
        }
        field(68; CMPNYNAM; text[66])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(69; CONTACT; text[62])
        {
            Caption = 'Contact';
            DataClassification = CustomerContent;
        }
        field(70; ADDRESS1; text[62])
        {
            Caption = 'Address 1';
            DataClassification = CustomerContent;
        }
        field(71; ADDRESS2; text[62])
        {
            Caption = 'Address 2';
            DataClassification = CustomerContent;
        }
        field(72; ADDRESS3; text[62])
        {
            Caption = 'Address 3';
            DataClassification = CustomerContent;
        }
        field(73; CITY; text[36])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(74; STATE; text[30])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }
        field(75; ZIPCODE; text[12])
        {
            Caption = 'Zip Code';
            DataClassification = CustomerContent;
        }
        field(76; CCode; text[8])
        {
            Caption = 'Country Code';
            DataClassification = CustomerContent;
        }
        field(77; COUNTRY; text[62])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        field(78; PHONE1; text[22])
        {
            Caption = 'Phone 1';
            DataClassification = CustomerContent;
        }
        field(79; PHONE2; text[22])
        {
            Caption = 'Phone 2';
            DataClassification = CustomerContent;
        }
        field(80; PHONE3; text[22])
        {
            Caption = 'Phone 3';
            DataClassification = CustomerContent;
        }
        field(81; FAX; text[22])
        {
            Caption = 'Fax';
            DataClassification = CustomerContent;
        }
        field(82; ADDRSOURCE; Integer)
        {
            Caption = 'Address Source';
            DataClassification = CustomerContent;
        }
        field(83; Flags; Integer)
        {
            Caption = 'Flags';
            DataClassification = CustomerContent;
        }
        field(84; ProjNum; text[16])
        {
            Caption = 'Project Number';
            DataClassification = CustomerContent;
        }
        field(85; CostCatID; text[16])
        {
            Caption = 'Cost Category ID';
            DataClassification = CustomerContent;
        }
        field(86; ITMTRKOP; Option)
        {
            Caption = 'Item Tracking Option';
            OptionMembers = ,"None","Serial Numbers","Lot Numbers";
            DataClassification = CustomerContent;
        }
        field(87; VCTNMTHD; Option)
        {
            Caption = 'Valuation Method';
            OptionMembers = ,"FIFO Perpetual","LIFO Perpetual","Average Perpetual","FIFO Periodic","LIFO Periodic";
            DataClassification = CustomerContent;
        }
        field(88; Print_Phone_NumberGB; Option)
        {
            Caption = 'Print Phone Number GB';
            OptionMembers = "Do Not Print","Phone 1","Phone 2","Phone 3","Fax";
            DataClassification = CustomerContent;
        }
        field(89; DEX_ROW_TS; DateTime)
        {
            Caption = 'DEX_ROW_TS';
            DataClassification = CustomerContent;
        }
        field(90; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; PONUMBER, ORD, BRKFLD1)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }

}
