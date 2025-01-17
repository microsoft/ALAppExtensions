namespace System.DataAdministration;

using System.Reflection;

table 6204 "Transact. Storage Table Entry"
{
    Access = Internal;
    DataClassification = OrganizationIdentifiableInformation;
    InherentEntitlements = rimdX;
    InherentPermissions = rimdX;
    Permissions = tabledata "Transact. Storage Table Entry" = rimd;

    fields
    {
        field(1; "Table ID"; Integer)
        {
        }
        field(2; "Table Name"; Text[80])
        {
            CalcFormula = lookup("Table Metadata".Caption where(ID = field("Table ID")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Filter Record To DT"; DateTime)
        {
        }
        field(5; "Last Handled Date/Time"; DateTime)
        {
        }
        field(6; "No. Of Records Exported"; Integer)
        {
        }
        field(7; "Record Filters"; Text[2048])
        {
        }
        field(8; "Exported To ABS"; Boolean)
        {
        }
        field(9; "Blob Name in ABS"; Text[2048])
        {
        }
    }

    keys
    {
        key(PK; "Table ID")
        {
            Clustered = true;
        }
    }
}