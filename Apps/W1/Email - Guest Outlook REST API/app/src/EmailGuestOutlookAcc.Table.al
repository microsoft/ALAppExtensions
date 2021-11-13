table 89001 "Email Guest Outlook Acc."
{
    TableType = Temporary;
    DataCaptionFields = "Email Address";

    fields
    {
        field(1; Id; Guid)
        {
        }
        field(2; Name; Text[250])
        {
        }
        field(3; "Email Address"; Text[250])
        {
        }
        field(4; "Outlook API Email Connector"; Enum "Email Connector")
        {
        }
    }

    keys
    {
        key(PK; Id)
        {
        }
    }
}