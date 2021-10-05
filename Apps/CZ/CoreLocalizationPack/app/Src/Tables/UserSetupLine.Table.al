table 11797 "User Setup Line CZL"
{
    Caption = 'User Setup Line (Obsolete)';
    DataCaptionFields = "User ID", Type;

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = "User Setup";
        }
        field(10; Type; Enum "User Setup Line Type CZL")
        {
            Caption = 'Type';
        }
        field(20; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(30; "Code / Name"; Code[20])
        {
            Caption = 'Code / Name';
            TableRelation = if (Type = Const("Location (quantity increase)")) Location
            else
            if (Type = Const("Location (quantity decrease)")) Location
            else
            if (Type = Const("Release Location (quantity increase)")) Location
            else
            if (Type = Const("Release Location (quantity decrease)")) Location
            else
            if (Type = Const("Bank Account")) "Bank Account"
            else
            if (Type = Const("Payment Order")) "Bank Account"
            else
            if (Type = Const("Bank Statement")) "Bank Account"
            else
            if (Type = Const("General Journal")) "Gen. Journal Template"
            else
            if (Type = Const("Item Journal")) "Item Journal Template"
            else
            if (Type = Const("Resource Journal")) "Res. Journal Template"
            else
            if (Type = Const("Job Journal")) "Job Journal Template"
            else
            if (Type = Const("Intrastat Journal")) "Intrastat Jnl. Template"
            else
            if (Type = Const("FA Journal")) "FA Journal Template"
            else
            if (Type = Const("Insurance Journal")) "Insurance Journal Template"
            else
            if (Type = Const("FA Reclass. Journal")) "FA Reclass. Journal Template"
            else
            if (Type = Const("Req. Worksheet")) "Req. Wksh. Template"
            else
            if (Type = Const("VAT Statement")) "VAT Statement Template"
            else
            if (Type = Const("Whse. Journal")) "Warehouse Journal Template"
            else
            if (Type = Const("Whse. Worksheet")) "Whse. Worksheet Template"
            else
            if (Type = Const("Invt. Movement Templates")) "Invt. Movement Template CZL";
        }
    }

    keys
    {
        key(Key1; "User ID", Type, "Line No.")
        {
            Clustered = true;
        }
    }
}

