namespace Microsoft.PowerBIReports;

query 36950 "Dimension Set Entries"
{
    Access = Internal;
    Caption = 'Power BI Dimension Set Entries';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'dimensionSetEntry';
    EntitySetName = 'dimensionSetEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(PBIDimensionSetEntries; "Dimension Set Entry")
        {
            column(id; SystemId)
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
            column(valueCount; "Value Count")
            {
            }
            column(dimension1ValueCode; "Dimension 1 Value Code")
            {
            }
            column(dimension1ValueName; "Dimension 1 Value Name")
            {
            }
            column(dimension2ValueCode; "Dimension 2 Value Code")
            {
            }
            column(dimension2ValueName; "Dimension 2 Value Name")
            {
            }
            column(dimension3ValueCode; "Dimension 3 Value Code")
            {
            }
            column(dimension3ValueName; "Dimension 3 Value Name")
            {
            }
            column(dimension4ValueCode; "Dimension 4 Value Code")
            {
            }
            column(dimension4ValueName; "Dimension 4 Value Name")
            {
            }
            column(dimension5ValueCode; "Dimension 5 Value Code")
            {
            }
            column(dimension5ValueName; "Dimension 5 Value Name")
            {
            }
            column(dimension6ValueCode; "Dimension 6 Value Code")
            {
            }
            column(dimension6ValueName; "Dimension 6 Value Name")
            {
            }
            column(dimension7ValueCode; "Dimension 7 Value Code")
            {
            }
            column(dimension7ValueName; "Dimension 7 Value Name")
            {
            }
            column(dimension8ValueCode; "Dimension 8 Value Code")
            {
            }
            column(dimension8ValueName; "Dimension 8 Value Name")
            {
            }
        }
    }
}