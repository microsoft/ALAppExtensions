#if not CLEANSCHEMA24
table 11716 "Stg Intrastat Jnl. Line"
{
    Caption = 'Staging Intrastat Jnl. Line';
    ObsoleteState = Removed;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '24.0';

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Intrastat Jnl. Template";
        }
        field(2; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            TableRelation = "Intrastat Jnl. Batch".Name WHERE("Journal Template Name" = FIELD("Journal Template Name"));
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Receipt,Shipment';
            OptionMembers = Receipt,Shipment;
        }
        field(5; Date; Date)
        {
            Caption = 'Date';
        }
        field(6; "Tariff No."; Code[20])
        {
            Caption = 'Tariff No.';
            NotBlank = true;
            TableRelation = "Tariff Number";
        }
        field(7; "Item Description"; Text[250])
        {
            Caption = 'Item Description';
        }
        field(8; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(9; "Transaction Type"; Code[10])
        {
            Caption = 'Transaction Type';
            TableRelation = "Transaction Type";
        }
        field(10; "Transport Method"; Code[10])
        {
            Caption = 'Transport Method';
            TableRelation = "Transport Method";
        }
        field(11; "Source Type"; Option)
        {
            BlankZero = true;
            Caption = 'Source Type';
            OptionCaption = ',Item Entry,Job Entry';
            OptionMembers = ,"Item Entry","Job Entry";
        }
        field(12; "Source Entry No."; Integer)
        {
            Caption = 'Source Entry No.';
            Editable = false;
            TableRelation = IF ("Source Type" = CONST("Item Entry")) "Item Ledger Entry"
            ELSE
            IF ("Source Type" = CONST("Job Entry")) "Job Ledger Entry";
        }
        field(13; "Net Weight"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 2 : 5;
        }
        field(14; Amount; Decimal)
        {
            Caption = 'Amount';
            DecimalPlaces = 0 : 0;
        }
        field(15; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 3;
        }
        field(16; "Cost Regulation %"; Decimal)
        {
            Caption = 'Cost Regulation %';
            DecimalPlaces = 2 : 2;
            MaxValue = 100;
            MinValue = -100;
        }
        field(17; "Indirect Cost"; Decimal)
        {
            Caption = 'Indirect Cost';
            DecimalPlaces = 0 : 0;
        }
        field(18; "Statistical Value"; Decimal)
        {
            Caption = 'Statistical Value';
            DecimalPlaces = 0 : 0;
        }
        field(19; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(20; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(21; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(22; "Total Weight"; Decimal)
        {
            Caption = 'Total Weight';
            DecimalPlaces = 2 : 5;
            Editable = false;
        }
        field(23; "Supplementary Units"; Boolean)
        {
            Caption = 'Supplementary Units';
            Editable = false;
        }
        field(24; "Internal Ref. No."; Text[10])
        {
            Caption = 'Internal Ref. No.';
            Editable = false;
        }
        field(25; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
        }
        field(26; "Entry/Exit Point"; Code[10])
        {
            Caption = 'Entry/Exit Point';
            TableRelation = "Entry/Exit Point";
        }
        field(27; "Area"; Code[10])
        {
            Caption = 'Area';
            TableRelation = Area;
        }
        field(28; "Transaction Specification"; Code[10])
        {
            Caption = 'Transaction Specification';
            TableRelation = "Transaction Specification";
        }
        field(29; "Shpt. Method Code"; Code[10])
        {
            Caption = 'Shpt. Method Code';
            TableRelation = "Shipment Method";
        }
        field(30; "Partner VAT ID"; Text[50])
        {
            Caption = 'Partner VAT ID';
        }
        field(31; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
#if not CLEANSCHEMA23
        field(31060; "Additional Costs"; Boolean)
        {
            Caption = 'Additional Costs';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '23.0';
        }
        field(31061; "Source Entry Date"; Date)
        {
            Caption = 'Source Entry Date';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '23.0';
        }
        field(31062; "Statistic Indication"; Code[10])
        {
            Caption = 'Statistic Indication';
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '23.0';
        }
        field(31063; "Statistics Period"; Code[10])
        {
            Caption = 'Statistics Period';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '23.0';
        }
        field(31065; "Declaration No."; Code[10])
        {
            Caption = 'Declaration No.';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '23.0';
        }
        field(31066; "Statement Type"; Option)
        {
            Caption = 'Statement Type';
            Editable = false;
            OptionCaption = 'Primary,Null,Replacing,Deleting';
            OptionMembers = Primary,Null,Replacing,Deleting;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '23.0';
        }
        field(31067; "Prev. Declaration No."; Code[10])
        {
            Caption = 'Prev. Declaration No.';
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '23.0';
        }
        field(31068; "Prev. Declaration Line No."; Integer)
        {
            Caption = 'Prev. Declaration Line No.';
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '23.0';
        }
#endif
        field(31069; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";
        }
#if not CLEANSCHEMA23        
        field(31070; "Specific Movement"; Code[10])
        {
            Caption = 'Specific Movement';
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '23.0';
        }
        field(31071; "Supplem. UoM Code"; Code[10])
        {
            Caption = 'Supplem. UoM Code';
            Editable = false;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '23.0';
        }
        field(31072; "Supplem. UoM Quantity"; Decimal)
        {
            Caption = 'Supplem. UoM Quantity';
            DecimalPlaces = 0 : 3;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '23.0';
        }
        field(31073; "Supplem. UoM Net Weight"; Decimal)
        {
            Caption = 'Supplem. UoM Net Weight';
            DecimalPlaces = 2 : 5;
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '23.0';
        }
        field(31074; "Base Unit of Measure"; Code[10])
        {
            Caption = 'Base Unit of Measure';
            Editable = false;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to Core Localization Pack for Czech.';
            ObsoleteTag = '23.0';
        }
#endif
    }

    keys
    {
        key(Key1; "Journal Template Name", "Journal Batch Name", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Source Type", "Source Entry No.")
        {
        }
        key(Key3; Type, "Country/Region Code", "Tariff No.", "Transaction Type", "Transport Method")
        {
        }
        key(Key4; "Internal Ref. No.")
        {
        }
#if not CLEANSCHEMA23
        key(Key5; Type, "Country/Region Code", "Tariff No.", "Statistic Indication", "Transaction Type", "Shpt. Method Code", "Area", "Transport Method")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Field "Statistic Indication" is removed and cannot be used in an active key.';
            ObsoleteTag = '23.0';
        }
        key(Key6; Type, "Tariff No.", "Country/Region Code", "Country/Region of Origin Code", "Statistic Indication", "Transaction Type", "Shpt. Method Code", "Area", "Transport Method")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Field "Statistic Indication" is removed and cannot be used in an active key.';
            ObsoleteTag = '23.0';
        }
#endif
        key(Key7; "Document No.")
        {
        }
    }

}
#endif