namespace Microsoft.DataMigration;

enum 40010 "Cloud Migration Warning Type" implements "Cloud Migration Warning"
{
    Extensible = true;

    value(1; "Record Link")
    {
        Caption = 'Record Link';
        Implementation = "Cloud Migration Warning" = "Record Link Migration Warning";
    }
    value(2; "Tenant Media")
    {
        Caption = 'Tenant Media';
        Implementation = "Cloud Migration Warning" = "Tenant Media Warning";
    }
}