namespace Microsoft.SubscriptionBilling;

table 8005 "Item Templ. Sub. Package"
{
    Caption = 'Item Template Subscription Package';
    DataClassification = CustomerContent;

    fields
    {
        field(8000; "Item Template Code"; Code[20])
        {
            Caption = 'Item Template Code';
            Editable = false;
        }
        field(8001; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = "Subscription Package".Code;
        }
        field(8002; "Description"; Text[100])
        {
            Caption = 'Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Package".Description where(Code = field("Code")));
            Editable = false;
        }
        field(8003; "Standard"; Boolean)
        {
            Caption = 'Standard';
        }
        field(8004; "Price Group"; Code[10])
        {
            Caption = 'Price Group';
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Package"."Price Group" where(Code = field("Code")));
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Item Template Code", "Code")
        {
            Clustered = true;
        }
    }
}