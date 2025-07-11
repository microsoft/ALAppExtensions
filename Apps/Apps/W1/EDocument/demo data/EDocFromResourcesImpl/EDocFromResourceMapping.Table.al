table 5428 "E-Doc From Resource Mapping"
{
    Access = Internal;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; ID; Integer)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the unique identifier for the mapping.';
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the purchase line to use the mapping for.';
            Editable = false;
        }
        field(3; "Type"; Enum "Purchase Line Type")
        {
            Caption = 'Type';
            ToolTip = 'Specifies the type of entity that will be posted for this purchase line, such as Item, Resource, or G/L Account.';
        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            ToolTip = 'Specifies what you''re selling. The options vary, depending on what you choose in the Type field.';
        }
        field(5; "Product Code"; Text[100])
        {
            Caption = 'Product Code';
            ToolTip = 'Specifies the product code for the item in the purchase line.';
        }
        field(6; "Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            ToolTip = 'Specifies the unit of measure for the item in the purchase line.';
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}