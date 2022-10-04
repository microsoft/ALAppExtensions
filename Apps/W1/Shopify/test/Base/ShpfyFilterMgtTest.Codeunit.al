/// <summary>
/// Codeunit Shpfy Filter Mgt. Test (ID 139560).
/// </summary>
codeunit 139560 "Shpfy Filter Mgt. Test"
{
    Subtype = Test;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestCleanFilterValue()
    var
        ShpfyTestFields: Record "Shpfy Test Fields";
        ShpfyFilterMgt: Codeunit "Shpfy Filter Mgt.";
        Index: Integer;
        InvalidCharsTxt: Label '()*.<>=', Locked = true;
        SearchStrings: List of [Text];
    begin
        // Creating Test data.
        For Index := 1 to StrLen(Format(InvalidCharsTxt)) do begin
            ShpfyTestFields.BigIntegerField := Index;
            ShpfyTestFields.TextField := Any.AlphabeticText(5 + Index) + Format(InvalidCharsTxt) [Index] + Any.AlphabeticText(3);
            ShpfyTestFields.Insert();
        end;

        // [SCENARIO] Create for every record a searchstring with the function CleanFilterValue
        //            and try to find this record based on the created searchstring.
        //            the result must be that 1 record is found.

        // [GIVEN] Textfield to convert for creating a search string.
        if ShpfyTestFields.FindSet(false, false) then
            repeat
                SearchStrings.Add(ShpfyFilterMgt.CleanFilterValue(ShpfyTestFields.TextField));
            until ShpfyTestFields.Next() = 0;

        // [WHEN] filtering on a searchstring 
        // [THEN] this must give a result of 1 record back.
        for Index := 1 to SearchStrings.Count do begin
            ShpfyTestFields.SetFilter(TextField, SearchStrings.Get(Index));
            LibraryAssert.RecordCount(ShpfyTestFields, 1);
        end;
    end;
}