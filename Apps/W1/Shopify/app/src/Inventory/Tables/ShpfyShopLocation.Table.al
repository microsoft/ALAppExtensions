namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Location;

/// <summary>
/// Table Shpfy Shop Location (ID 30113).
/// </summary>
table 30113 "Shpfy Shop Location"
{
    Access = Internal;
    Caption = 'Shopify Shop Location';
    DataClassification = CustomerContent;
    DrillDownPageId = "Shpfy Shop Locations Mapping";
    LookupPageId = "Shpfy Shop Locations Mapping";

    fields
    {
        field(1; "Shop Code"; Code[20])
        {
            Caption = 'Shop Code';
            DataClassification = CustomerContent;
            TableRelation = "Shpfy Shop";
            ValidateTableRelation = true;
        }

        field(2; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(3; Version; Biginteger)
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
            Editable = false;
            SqlTimestamp = true;
        }

        field(4; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(5; "Location Filter"; Text[250])
        {
            Caption = 'Location Filter';
            TableRelation = Location.Code;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
            Description = 'Filter on location for calculating the stock.';

            trigger OnValidate()
            var
                Location: Record Location;
            begin
                if "Location Filter" <> '' then begin
                    Location.SetFilter(Code, "Location Filter");
                    if Location.Count = 1 then
                        if Location.FindFirst() then
                            "Default Location Code" := Location.Code;
                end;
            end;
        }

        field(6; "Default Location Code"; Code[20])
        {
            Caption = 'Default Location Code';
            DataClassification = CustomerContent;
            Description = 'The default location code for use on a sales document.';
            TableRelation = Location.Code where("Use as In-Transit" = const(false));
            trigger OnValidate()
            begin
                if Rec."Location Filter" = '' then
                    Rec."Location Filter" := Rec."Default Location Code";
            end;
        }

        field(7; Disabled; Boolean)
        {
            Caption = 'Disabled';
            DataClassification = CustomerContent;
            ObsoleteReason = 'Replaced by Stock Calculation field.';
            ObsoleteTag = '25.0';
            ObsoleteState = Removed;
            Description = 'This disabled the synchronisation of the stock to Shopify.';
        }

        field(8; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = SystemMetadata;
            Description = 'Active in Shopfy';
            Editable = false;
        }
        field(9; "Is Primary"; Boolean)
        {
            Caption = 'Is Primary';
            DataClassification = SystemMetadata;
            Description = 'Is primary location in Shopify';
            Editable = false;
        }
        field(10; "Stock Calculation"; Enum "Shpfy Stock Calculation")
        {
            Caption = 'Stock calculation';
            DataClassification = SystemMetadata;
            InitValue = Disabled;
            Description = 'Select the stock calculation used for this location.';
        }
        field(11; "Is Fulfillment Service"; Boolean)
        {
            Caption = 'Is Fulfillment Service';
            DataClassification = SystemMetadata;
            Editable = false;
            Description = 'Check if this a fulfillment service location.';
        }
        field(12; "Default Product Location"; Boolean)
        {
            Caption = 'Default Product Location';
            DataClassification = SystemMetadata;
            Description = 'The default product locations will be added to new products in Shopify.';

            trigger OnValidate()
            var
                ShopLocation: Record "Shpfy Shop Location";
                ErrorInfo: ErrorInfo;
                MixLocationTypeErr: Label 'You can not use standard Shopify Locations with FulFillment Service Locations.';
            begin
                if Rec."Default Product Location" then begin
                    ShopLocation.SetRange("Is Fulfillment Service", not Rec."Is Fulfillment Service");
                    ShopLocation.SetRange("Default Product Location", true);
                    if not ShopLocation.IsEmpty then begin
                        ErrorInfo.Message(MixLocationTypeErr);
                        ErrorInfo.ErrorType := ErrorType::Client;
                        ErrorInfo.FieldNo := CurrFieldNo;
                        ErrorInfo.RecordId := Rec.RecordId;
                        ErrorInfo.SystemId := Rec.SystemId;
                        Error(ErrorInfo);
                    end;
                end;
            end;
        }
    }

    keys
    {
        key(PK; "Shop Code", Id)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        ShopInventory: Record "Shpfy Shop Inventory";
    begin
        ShopInventory.SetRange("Shop Code", "Shop Code");
        ShopInventory.SetRange("Location Id", Id);
        ShopInventory.DeleteAll(false);
    end;

    /// <summary> 
    /// Create Location Filter.
    /// </summary>
    internal procedure CreateLocationFilter()
    var
        Location: Record Location;
        CreateLocationFilter: Report "Shpfy Create Location Filter";
    begin
        if "Location Filter" <> '' then
            Location.SetFilter(Code, "Location Filter");
        CreateLocationFilter.SetTableView(Location);
        CreateLocationFilter.RunModal();
        "Location Filter" := CopyStr(CreateLocationFilter.GetLocationFilter(), 1, MaxStrLen("Location Filter"));
    end;

}