namespace Microsoft.Sustainability.Journal;

table 6215 "Sustainability Jnl. Template"
{
    Access = Public;
    Caption = 'Sustainability Journal Template';
    DataClassification = CustomerContent;
    DataPerCompany = true;
    Extensible = true;

    fields
    {
        field(1; Name; Code[10])
        {
            Caption = 'Name';
            NotBlank = true;
        }
        field(2; Description; Text[80])
        {
            Caption = 'Description';
        }
        field(3; Recurring; Boolean)
        {
            Caption = 'Recurring';
        }
    }

    keys
    {
        key(Key1; Name)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
    begin
        SustainabilityJnlBatch.SetRange("Journal Template Name", Name);
        SustainabilityJnlBatch.DeleteAll(true);
    end;
}