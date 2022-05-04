/// <summary>
/// Table Shpfy Customer Address (ID 30106).
/// </summary>
table 30106 "Shpfy Customer Address"
{
    Access = Internal;
    Caption = 'Shopify Customer Address';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Id; BigInteger)
        {
            Caption = 'Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(2; "Customer Id"; BigInteger)
        {
            Caption = 'Customer Id';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(3; Company; Text[100])
        {
            Caption = 'Company';
            DataClassification = CustomerContent;
        }
        field(4; "First Name"; Text[50])
        {
            Caption = 'First Name';
            DataClassification = CustomerContent;
        }
        field(5; "Last Name"; Text[50])
        {
            Caption = 'Last Name';
            DataClassification = CustomerContent;
        }
        field(6; "Address 1"; Text[100])
        {
            Caption = 'Address1';
            DataClassification = CustomerContent;
        }
        field(7; "Address 2"; Text[100])
        {
            Caption = 'Address2';
            DataClassification = CustomerContent;
        }
        field(8; Zip; Code[20])
        {
            Caption = 'Zip';
            DataClassification = CustomerContent;
        }
        field(9; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }
        field(10; "Country/Region Code"; Code[2])
        {
            Caption = 'Country/Region Code';
            DataClassification = CustomerContent;
        }
        field(11; "Country/Region Name"; Text[50])
        {
            Caption = 'Country/Region Name';
            DataClassification = CustomerContent;
        }
        field(12; "Province Code"; Code[2])
        {
            Caption = 'Province Code';
            DataClassification = CustomerContent;
        }
        field(13; "Province Name"; Text[50])
        {
            Caption = 'Province Name';
            DataClassification = CustomerContent;
        }
        field(14; Phone; Text[30])
        {
            Caption = 'Phone';
            DataClassification = CustomerContent;
        }
        field(15; Default; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;
        }
        field(101; "Ship-To Address SystemId"; Guid)
        {
            Caption = 'Ship-To Address SystemId';
            DataClassification = SystemMetadata;
        }
        field(102; CustomerSystemId; Guid)
        {
            Caption = 'Customer System Id';
            DataClassification = SystemMetadata;
        }
        field(103; "Customer No."; Code[20])
        {
            CalcFormula = lookup(Customer."No." where(SystemId = field(CustomerSystemId)));
            Caption = 'Customer No.';
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        CustomerAddress: Record "Shpfy Customer Address";
        Math: Codeunit Math;
    begin
        if Id = 0 then
            if CustomerAddress.FindFirst() then
                Id := Math.Min(-1, CustomerAddress.Id - 1)
            else
                Id := -1;
        CustomerAddress.SetRange("Customer Id", "Customer Id");
        CustomerAddress.SetRange(Default, true);
        CustomerAddress.Default := CustomerAddress.IsEmpty();
    end;
}
