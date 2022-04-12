/// <summary>
/// Report Shpfy Create Location Filter (ID 30101).
/// </summary>
report 30101 "Shpfy Create Location Filter"
{
    Caption = 'Shopify Create Location Filter';
    ProcessingOnly = true;
    UseRequestPage = true;
    UsageCategory = None;

    dataset
    {
        dataitem(Location; Location)
        {
            RequestFilterFields = Code;

            trigger OnPreDataItem()
            begin
                LocationFilter := Location.GetFilter(Code);
            end;
        }
    }

    var
        LocationFilter: Text;

    /// <summary> 
    /// Get Location Filter.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    internal procedure GetLocationFilter(): Text
    begin
        exit(LocationFilter);
    end;
}