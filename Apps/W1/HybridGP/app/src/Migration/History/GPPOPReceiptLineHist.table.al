table 4062 "GPPOPReceiptLineHist"
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
        field(2; RCPTLNNM; Integer)
        {
            Caption = 'Receipt Line Number';
            DataClassification = CustomerContent;
        }
        field(3; PONUMBER; text[18])
        {
            Caption = 'PO Number';
            DataClassification = CustomerContent;
        }
        field(4; ITEMNMBR; text[32])
        {
            Caption = 'Item Number';
            DataClassification = CustomerContent;
        }
        field(5; ITEMDESC; text[102])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
        }
        field(6; VNDITNUM; text[32])
        {
            Caption = 'Vendor Item Number';
            DataClassification = CustomerContent;
        }
        field(7; VNDITDSC; text[102])
        {
            Caption = 'Vendor Item Description';
            DataClassification = CustomerContent;
        }
        field(8; UMQTYINB; Decimal)
        {
            Caption = 'U Of M QTY In Base';
            DataClassification = CustomerContent;
        }
        field(9; ACTLSHIP; Date)
        {
            Caption = 'Actual Ship Date';
            DataClassification = CustomerContent;
        }
        field(10; COMMNTID; text[16])
        {
            Caption = 'Comment ID';
            DataClassification = CustomerContent;
        }
        field(11; INVINDX; Integer)
        {
            Caption = 'Inventory Index';
            DataClassification = CustomerContent;
        }
        field(12; UOFM; text[10])
        {
            Caption = 'U Of M';
            DataClassification = CustomerContent;
        }
        field(13; UNITCOST; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
        }
        field(14; EXTDCOST; Decimal)
        {
            Caption = 'Extended Cost';
            DataClassification = CustomerContent;
        }
        field(15; LOCNCODE; text[12])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(16; RcptLineNoteIDArray_1; Decimal)
        {
            Caption = 'ReceiptLine Note ID Array 1';
            DataClassification = CustomerContent;
        }
        field(17; RcptLineNoteIDArray_2; Decimal)
        {
            Caption = 'ReceiptLine Note ID Array 2';
            DataClassification = CustomerContent;
        }
        field(18; RcptLineNoteIDArray_3; Decimal)
        {
            Caption = 'ReceiptLine Note ID Array 3';
            DataClassification = CustomerContent;
        }
        field(19; RcptLineNoteIDArray_4; Decimal)
        {
            Caption = 'ReceiptLine Note ID Array 4';
            DataClassification = CustomerContent;
        }
        field(20; RcptLineNoteIDArray_5; Decimal)
        {
            Caption = 'ReceiptLine Note ID Array 5';
            DataClassification = CustomerContent;
        }
        field(21; RcptLineNoteIDArray_6; Decimal)
        {
            Caption = 'ReceiptLine Note ID Array 6';
            DataClassification = CustomerContent;
        }
        field(22; RcptLineNoteIDArray_7; Decimal)
        {
            Caption = 'ReceiptLine Note ID Array 7';
            DataClassification = CustomerContent;
        }
        field(23; RcptLineNoteIDArray_8; Decimal)
        {
            Caption = 'ReceiptLine Note ID Array 8';
            DataClassification = CustomerContent;
        }
        field(24; NONINVEN; Option)
        {
            Caption = 'Non-Inventory Item';
            OptionMembers = "No","Yes";
            DataClassification = CustomerContent;
        }
        field(25; DECPLCUR; Option)
        {
            Caption = 'Decimal Places Currency';
            OptionMembers = ,,,,,,,"0","1","2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(26; DECPLQTY; Option)
        {
            Caption = 'Decimal Places QTYS';
            OptionMembers = ,"0","1","2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(27; ITMTRKOP; Option)
        {
            Caption = 'Item Tracking Option';
            OptionMembers = ,"None","Serial Numbers","Lot Numbers";
            DataClassification = CustomerContent;
        }
        field(28; TRXSORCE; text[14])
        {
            Caption = 'TRX Source';
            DataClassification = CustomerContent;
        }
        field(29; JOBNUMBR; text[18])
        {
            Caption = 'Job Number';
            DataClassification = CustomerContent;
        }
        field(30; COSTCODE; text[28])
        {
            Caption = 'Cost Code';
            DataClassification = CustomerContent;
        }
        field(31; COSTTYPE; Integer)
        {
            Caption = 'Cost Code Type';
            DataClassification = CustomerContent;
        }
        field(32; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(33; ORUNTCST; Decimal)
        {
            Caption = 'Originating Unit Cost';
            DataClassification = CustomerContent;
        }
        field(34; OREXTCST; Decimal)
        {
            Caption = 'Originating Extended Cost';
            DataClassification = CustomerContent;
        }
        field(35; ODECPLCU; Option)
        {
            Caption = 'Originating Decimal Places Currency';
            OptionMembers = ,"0","1","2","3","4","5","0 ","1 ","2 ","3 ","4 ","5 ";
            DataClassification = CustomerContent;
        }
        field(36; BOLPRONUMBER; text[32])
        {
            Caption = 'BOL_PRO Number';
            DataClassification = CustomerContent;
        }
        field(37; Capital_Item; Boolean)
        {
            Caption = 'Capital Item';
            DataClassification = CustomerContent;
        }
        field(38; Product_Indicator; Integer)
        {
            Caption = 'Product Indicator';
            DataClassification = CustomerContent;
        }
        field(39; Purchase_IV_Item_Taxable; Option)
        {
            Caption = 'Purchase IV Item Taxable';
            OptionMembers = ,"Taxable","Nontaxable","Base on vendor";
            DataClassification = CustomerContent;
        }
        field(40; Purchase_Item_Tax_Schedu; text[16])
        {
            Caption = 'Purchase Item Tax Schedule ID';
            DataClassification = CustomerContent;
        }
        field(41; Purchase_Site_Tax_Schedu; text[16])
        {
            Caption = 'Purchase Site Tax Schedule ID';
            DataClassification = CustomerContent;
        }
        field(42; BSIVCTTL; Boolean)
        {
            Caption = 'Based On Invoice Total';
            DataClassification = CustomerContent;
        }
        field(43; TAXAMNT; Decimal)
        {
            Caption = 'Tax Amount';
            DataClassification = CustomerContent;
        }
        field(44; ORTAXAMT; Decimal)
        {
            Caption = 'Originating Tax Amount';
            DataClassification = CustomerContent;
        }
        field(45; BCKTXAMT; Decimal)
        {
            Caption = 'Backout Tax Amount';
            DataClassification = CustomerContent;
        }
        field(46; OBTAXAMT; Decimal)
        {
            Caption = 'Originating Backout Tax Amount';
            DataClassification = CustomerContent;
        }
        field(47; PURPVIDX; Integer)
        {
            Caption = 'Purchase Price Variance Index';
            DataClassification = CustomerContent;
        }
        field(48; SHIPMTHD; text[16])
        {
            Caption = 'Shipping Method';
            DataClassification = CustomerContent;
        }
        field(49; Landed_Cost_Group_ID; text[16])
        {
            Caption = 'Landed Cost Group ID';
            DataClassification = CustomerContent;
        }
        field(50; Landed_Cost_Warnings; Integer)
        {
            Caption = 'Landed Cost Warnings';
            DataClassification = CustomerContent;
        }
        field(51; Landed_Cost; Boolean)
        {
            Caption = 'Landed Cost';
            DataClassification = CustomerContent;
        }
        field(52; Invoice_Match; Boolean)
        {
            Caption = 'Invoice Match';
            DataClassification = CustomerContent;
        }
        field(53; RCPTRETNUM; text[18])
        {
            Caption = 'Receipt Return Number';
            DataClassification = CustomerContent;
        }
        field(54; RCPTRETLNNUM; Integer)
        {
            Caption = 'Receipt Return Line Number';
            DataClassification = CustomerContent;
        }
        field(55; INVRETNUM; text[18])
        {
            Caption = 'Invoice Return Number';
            DataClassification = CustomerContent;
        }
        field(56; INVRETLNNUM; Integer)
        {
            Caption = 'Invoice Return Line Number';
            DataClassification = CustomerContent;
        }
        field(57; ISLINEINTRA; Boolean)
        {
            Caption = 'IsLineIntrastat';
            DataClassification = CustomerContent;
        }
        field(58; ProjNum; text[16])
        {
            Caption = 'Project Number';
            DataClassification = CustomerContent;
        }
        field(59; CostCatID; text[16])
        {
            Caption = 'Cost Category ID';
            DataClassification = CustomerContent;
        }
        field(60; TrackedDropShipped; Boolean)
        {
            Caption = 'TrackedDropShipped';
            DataClassification = CustomerContent;
        }
        field(61; OriginatingPrepaymentAmt; Decimal)
        {
            Caption = 'Originating Prepayment Amount';
            DataClassification = CustomerContent;
        }
        field(62; ORDISTKN; Decimal)
        {
            Caption = 'Originating Discount Taken Amount';
            DataClassification = CustomerContent;
        }
        field(63; ORTDISAM; Decimal)
        {
            Caption = 'Originating Trade Discount Amount';
            DataClassification = CustomerContent;
        }
        field(64; ORFRTAMT; Decimal)
        {
            Caption = 'Originating Freight Amount';
            DataClassification = CustomerContent;
        }
        field(65; ORMISCAMT; Decimal)
        {
            Caption = 'Originating Misc Amount';
            DataClassification = CustomerContent;
        }
        field(66; OriginatingPPTaxAmount; Decimal)
        {
            Caption = 'Originating Prepayment Tax Amount';
            DataClassification = CustomerContent;
        }
        field(67; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; POPRCTNM, RCPTLNNM)
        {
            Clustered = false;
        }
    }

    fieldgroups
    {
    }
}
