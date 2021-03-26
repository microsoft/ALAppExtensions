table 4056 "GPPOPLandedCostHist"
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
        field(3; LCLINENUMBER; Integer)
        {
            Caption = 'LC Line Number';
            DataClassification = CustomerContent;
        }
        field(4; LCHDRNUMBER; Integer)
        {
            Caption = 'LC Header Number';
            DataClassification = CustomerContent;
        }
        field(5; Landed_Cost_ID; text[16])
        {
            Caption = 'Landed Cost ID';
            DataClassification = CustomerContent;
        }
        field(6; NOTEINDX; Decimal)
        {
            Caption = 'Note Index';
            DataClassification = CustomerContent;
        }
        field(7; Long_Description; text[52])
        {
            Caption = 'Long Description';
            DataClassification = CustomerContent;
        }
        field(8; Landed_Cost_Type; Option)
        {
            Caption = 'Landed Cost Type';
            OptionMembers = ,"Line","Apportioned";
            DataClassification = CustomerContent;
        }
        field(9; VENDORID; text[16])
        {
            Caption = 'Vendor ID';
            DataClassification = CustomerContent;
        }
        field(10; Vendor_Note_Index; Decimal)
        {
            Caption = 'Vendor Note Index';
            DataClassification = CustomerContent;
        }
        field(11; CURNCYID; text[16])
        {
            Caption = 'Currency ID';
            DataClassification = CustomerContent;
        }
        field(12; Currency_Note_Index; Decimal)
        {
            Caption = 'Currency Note Index';
            DataClassification = CustomerContent;
        }
        field(13; CURRNIDX; Integer)
        {
            Caption = 'Currency Index';
            DataClassification = CustomerContent;
        }
        field(14; RATETPID; text[16])
        {
            Caption = 'Rate Type ID';
            DataClassification = CustomerContent;
        }
        field(15; EXGTBLID; text[16])
        {
            Caption = 'Exchange Table ID';
            DataClassification = CustomerContent;
        }
        field(16; XCHGRATE; Decimal)
        {
            Caption = 'Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(17; EXCHDATE; Date)
        {
            Caption = 'Exchange Date';
            DataClassification = CustomerContent;
        }
        field(18; TIME1; DateTime)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }
        field(19; RATECALC; OPTION)
        {
            Caption = 'Rate Calc Method';
            OptionMembers = "Multiply","Divide";
            DataClassification = CustomerContent;
        }
        field(20; DENXRATE; Decimal)
        {
            Caption = 'Denomination Exchange Rate';
            DataClassification = CustomerContent;
        }
        field(21; MCTRXSTT; Option)
        {
            Caption = 'MC Transaction State';
            OptionMembers = "No Euro","Nondenom to nondenom","Nondenom to Euro","Nondenom to denom","Denom to nondenom","Denom to denom","Denom to Euro","Euro to denom","Euro to nondenom";
            DataClassification = CustomerContent;
        }
        field(22; DECPLCUR; Option)
        {
            Caption = 'Decimal Places Currency';
            OptionMembers = "0","1","2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(23; ODECPLCU; Option)
        {
            Caption = 'Originating Decimal Places Currency';
            OptionMembers = ,"0","1","2","3","4","5";
            DataClassification = CustomerContent;
        }
        field(24; ACPURIDX; Integer)
        {
            Caption = 'Accrued Purchases Index';
            DataClassification = CustomerContent;
        }
        field(25; DistRef; text[32])
        {
            Caption = 'Distribution Reference';
            DataClassification = CustomerContent;
        }
        field(26; PURPVIDX; Integer)
        {
            Caption = 'Purchase Price Variance Index';
            DataClassification = CustomerContent;
        }
        field(27; Invoice_Match; Boolean)
        {
            Caption = 'Invoice Match';
            DataClassification = CustomerContent;
        }
        field(28; CALCMTHD; Option)
        {
            Caption = 'Calculation Method';
            OptionMembers = ,"Percent of Extended Cost","Flat Amount","Flat Amount Per Unit";
            DataClassification = CustomerContent;
        }
        field(29; Orig_Landed_Cost_Amount; Decimal)
        {
            Caption = 'Originating Landed Cost Amount';
            DataClassification = CustomerContent;
        }
        field(30; Calculation_Percentage; Integer)
        {
            Caption = 'Calculation Percentage';
            DataClassification = CustomerContent;
        }
        field(31; Total_Landed_Cost_Amount; Decimal)
        {
            Caption = 'Total Landed Cost Amount';
            DataClassification = CustomerContent;
        }
        field(32; Orig_TotalLandedCostAmt; Decimal)
        {
            Caption = 'Originating Total Landed Cost Amount';
            DataClassification = CustomerContent;
        }
        field(33; Landed_Cost_Warnings; Integer)
        {
            Caption = 'Landed Cost Warnings';
            DataClassification = CustomerContent;
        }
        field(34; Apportion_By; Option)
        {
            Caption = 'Apportion By';
            OptionMembers = ,"Value","Quantity","Weight","N\A";
            DataClassification = CustomerContent;
        }
        field(35; Orig_UnapportionedAmount; Decimal)
        {
            Caption = 'Originating Unapportioned Amount';
            DataClassification = CustomerContent;
        }
        field(36; INVINDX; Integer)
        {
            Caption = 'Inventory Index';
            DataClassification = CustomerContent;
        }
        field(37; DEX_ROW_ID; Integer)
        {
            Caption = 'DEX_ROW_ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; POPRCTNM, RCPTLNNM, LCLINENUMBER)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

}
