namespace Microsoft.Sustainability.RoleCenters;

table 6221 "Sustainability Goal Cue"
{
    Caption = 'Sustainability Goal Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Realized % for CO2"; Decimal)
        {
            Caption = 'Realized % for CO2';
            Editable = false;
        }
        field(3; "Realized % for CH4"; Decimal)
        {
            Caption = 'Realized % for CH4';
            Editable = false;
        }
        field(4; "Realized % for N2O"; Decimal)
        {
            Caption = 'Realized % for N2O';
            Editable = false;
        }
        field(5; "CO2 % vs Baseline"; Decimal)
        {
            Caption = 'CO2 % vs Baseline';
            Editable = false;
        }
        field(6; "CH4 % vs Baseline"; Decimal)
        {
            Caption = 'CH4 % vs Baseline';
            Editable = false;
        }
        field(7; "N2O % vs Baseline"; Decimal)
        {
            Caption = 'N2O % vs Baseline';
            Editable = false;
        }
        field(20; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
            Caption = 'Date Filter';
        }
        field(30; "Last Refreshed Datetime"; DateTime)
        {
            Caption = 'Last Refreshed Datetime';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}