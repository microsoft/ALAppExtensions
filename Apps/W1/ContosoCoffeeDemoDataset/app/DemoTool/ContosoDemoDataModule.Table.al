table 5161 "Contoso Demo Data Module"
{
    DataCaptionFields = Name;
    DataClassification = CustomerContent;
    Access = Internal;
    Extensible = false;
    DataPerCompany = true;
    ReplicateData = false;
    InherentEntitlements = RimdX;
    InherentPermissions = RimdX;

    fields
    {
        field(1; Module; Enum "Contoso Demo Data Module")
        {
            Caption = 'Module';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(3; "Data Level"; Enum "Contoso Demo Data Level")
        {
            Caption = 'Data Level';
        }
        field(4; Install; Boolean)
        {
            Caption = 'Install';
        }
        field(5; "Is Setup Company"; Boolean)
        {
            Caption = 'Setup Company';
        }
    }

    keys
    {
        key(Key1; Module)
        {
            Clustered = true;
        }
    }
}