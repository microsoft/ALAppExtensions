namespace Microsoft.DataMigration.GP;

#pragma warning disable AS0109
table 4031 "GPForecastTemp"
{
    TableType = Temporary;
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; DocNumber; Text[22])
        {
            DataClassification = CustomerContent;
            Caption = 'Document Number';
        }
        field(2; DocType; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Type';
            OptionMembers = "Invoice","Sales/Invoices","Credit Memo","Credit Memos";
        }
        field(3; DueDate; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Due Date';
        }
        field(4; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Amount';
        }
    }

    keys
    {
        key(PK; DocNumber)
        {
            Clustered = false;
        }
        key(DueDate; DUEDATE)
        {
            Clustered = false;
        }
    }
}
#pragma warning restore AS0109
