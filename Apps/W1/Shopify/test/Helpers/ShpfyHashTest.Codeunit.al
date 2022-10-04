codeunit 139573 "Shpfy Hash Test"
{
    Subtype = Test;

    var
        Any: Codeunit Any;
        LibraryAssert: codeunit "Library Assert";

    [Test]
    procedure UnitTestCalcHash()
    var
        ShpfyHash: codeunit "Shpfy Hash";
        HashA: Integer;
        HashB: Integer;
        TextA: Text;
        TextB: Text;
    begin
        // [SCENARIO] Two of the same text values gives the same hash values
        // [GIVEN] A TextValue TextA filled in with a random text.
        TextA := Any.AlphanumericText(20);
        // [GIVEN] A TextValue TextB filled in with the same value of TextA.
        TextB := TextA;

        // [WHEN] Calculate the has values for TextA and TextB
        HashA := ShpfyHash.CalcHash(TextA);
        HashB := ShpfyHash.CalcHash(TextB);

        // [THEN] HashA = HashB
        LibraryAssert.AreEqual(HashA, HashB, 'HashA = HashB');

        // [SCENARIO] Two of the differnt text values gives possible different hash values.
        // [GIVEN] A TextValue TextA filled in with a random text.
        TextA := Any.AlphanumericText(20);
        // [GIVEN] A TextValue TextB filled in with a random text.
        TextB := Any.AlphanumericText(20);

        // [WHEN] Calculate the has values for TextA and TextB
        HashA := ShpfyHash.CalcHash(TextA);
        HashB := ShpfyHash.CalcHash(TextB);

        // [THEN] HashA <> HashB
        LibraryAssert.AreNotEqual(HashA, HashB, 'HashA <> HashB');
    end;
}
