table 4031 "GPForecastTemp"
{
#if CLEAN21
    TableType = Temporary;
#else 
    ObsoleteState = Pending;
    ObsoleteReason = 'Table will be moved to temporary';
    ObsoleteTag = '21.0';
#endif
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