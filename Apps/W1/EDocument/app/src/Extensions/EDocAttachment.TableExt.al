tableextension 6160 "E-Doc. Attachment" extends "Document Attachment"
{
    fields
    {
        field(6360; "E-Document Attachment"; Boolean)
        {
            DataClassification = SystemMetadata;
        }
        field(6361; "E-Document Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
            TableRelation = "E-Document";
        }
    }
}