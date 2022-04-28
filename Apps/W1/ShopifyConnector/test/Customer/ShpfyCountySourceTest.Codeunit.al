/// <summary>
/// Codeunit Shpfy CountySource Test (ID 30507).
/// </summary>
codeunit 30507 "Shpfy CountySource Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestCounty()
    var
        CustomerAddress: Record "Shpfy Customer Address" temporary;
        ICounty: Interface "Shpfy ICounty";
        RegionCodeTxt: Label 'RC', Locked = true;
        RegionNameTxt: Label 'Region Name', Locked = true;
    begin
        // [SCENARIO] Get the name or code of the region based on the enum value of "Shpfy County Source"
        CustomerAddress.Init();
        CustomerAddress."Province Code" := RegionCodeTxt;
        CustomerAddress."Province Name" := RegionNameTxt;

        // [GIVEN] "Shpfy County Source"::Code
        // [GIVEN] CustomerAddress
        ICounty := "Shpfy County Source"::Code;
        // [THEN] The result must be RegionCode
        Assert.AreEqual(RegionCodeTxt, ICounty.County(CustomerAddress), '"Shpfy County Source"::Code');

        // [GIVEN] "Shpfy County Source"::Name
        // [GIVEN] CustomerAddress
        ICounty := "Shpfy County Source"::Name;
        // [THEN] The result must be First Name + ' ' + Last Name
        Assert.AreEqual(RegionNameTxt, ICounty.County(CustomerAddress), '"Shpfy County Source"::Name');
    end;
}
