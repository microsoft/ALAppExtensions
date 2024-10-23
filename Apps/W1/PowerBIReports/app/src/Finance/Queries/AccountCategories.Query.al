namespace Microsoft.Finance.PowerBIReports;

query 36954 "Account Categories"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Account Categories';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'accountCategory';
    EntitySetName = 'accountCategories';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(PowerBIAccountCategory; "Account Category")
        {
            column(powerBIAccCategory; "Account Category Type")
            {
            }
            column(glAccCategoryEntryNo; "G/L Acc. Category Entry No.")
            {
            }
            column(parentAccCategoryEntryNo; "Parent Acc. Category Entry No.")
            {
            }
        }
    }
}