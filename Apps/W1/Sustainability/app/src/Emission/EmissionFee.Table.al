namespace Microsoft.Sustainability.Emission;

using Microsoft.Foundation.Address;
using Microsoft.Inventory.Location;
using Microsoft.Sustainability.Account;

table 6226 "Emission Fee"
{
    Caption = 'Emission Fee';
    DataClassification = CustomerContent;
    LookupPageId = "Emission Fees";
    DrillDownPageId = "Emission Fees";

    fields
    {
        field(1; "Emission Type"; Enum "Emission Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Emission Type';

            trigger OnValidate()
            begin
                if Rec."Emission Type" = Rec."Emission Type"::CO2 then
                    Rec.Validate("Carbon Equivalent Factor", 1);

                if Rec."Emission Type" <> Rec."Emission Type"::CO2 then
                    Rec.TestField("Carbon Fee", 0);
            end;
        }
        field(3; "Carbon Fee"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Carbon Fee';
            DecimalPlaces = 2 : 5;

            trigger OnValidate()
            begin
                if (Rec."Carbon Fee" <> 0) then
                    Rec.TestField("Emission Type", Rec."Emission Type"::CO2);
            end;
        }
        field(4; "Carbon Equivalent Factor"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Carbon Equivalent Factor';
            DecimalPlaces = 2 : 5;
        }
        field(5; "Starting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                if (Rec."Starting Date" > Rec."Ending Date") and (Rec."Ending Date" <> 0D) then
                    Error(InvalidStartDateErr, Rec.FieldCaption("Starting Date"), Rec.FieldCaption("Ending Date"));
            end;
        }
        field(6; "Ending Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                if CurrFieldNo = 0 then
                    exit;

                Rec.Validate("Starting Date");
            end;
        }
        field(7; "Scope Type"; Enum "Emission Scope")
        {
            DataClassification = CustomerContent;
            Caption = 'Scope Type';
        }
        field(8; "Responsibility Center"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center".Code;
        }
        field(35; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
    }

    keys
    {
        key(Key1; "Emission Type", "Scope Type", "Starting Date", "Ending Date", "Country/Region Code", "Responsibility Center")
        {
            Clustered = true;
        }
    }

    var
        InvalidStartDateErr: Label '%1 cannot be after %2', Comment = '%1 - Starting Date,%2 - Ending Date';
}