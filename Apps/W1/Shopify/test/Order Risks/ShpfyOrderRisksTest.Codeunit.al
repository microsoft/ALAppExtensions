/// <summary>
/// Codeunit Shpfy Order Risks Test (ID 139579).
/// </summary>
codeunit 139579 "Shpfy Order Risks Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Any: codeunit Any;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestUpdateOrderRisks()
    var
        ShpfyOrderHeader: Record "Shpfy Order Header";
        ShpfyOrderRisk: Record "Shpfy Order Risk";
        ShpfyOrderRisks: Codeunit "Shpfy Order Risks";
        JRisks: JsonArray;
    begin
        JRisks.ReadFrom('[{"level": "low", "message": "Low Risk", "display": true}, {"level": "medium", "message": "Medium Risk", "display": true}, {"level": "high", "message": "High Risk", "display": true}]');
        ShpfyOrderHeader.Init();
        ShpfyOrderHeader."Shopify Order Id" := Any.IntegerInRange(10000, 99999);

        ShpfyOrderRisks.UpdateOrderRisks(ShpfyOrderHeader, JRisks);

        if ShpfyOrderRisk.Get(ShpfyOrderHeader."Shopify Order Id", 1) then begin
            LibraryAssert.AreEqual(Enum::"Shpfy Risk Level"::Low, ShpfyOrderRisk.Level, 'Risk Level');
            LibraryAssert.AreEqual('Low Risk', ShpfyOrderRisk.Message, 'Risk Message');
        end;

        if ShpfyOrderRisk.Get(ShpfyOrderHeader."Shopify Order Id", 2) then begin
            LibraryAssert.AreEqual(Enum::"Shpfy Risk Level"::Medium, ShpfyOrderRisk.Level, 'Risk Level');
            LibraryAssert.AreEqual('Medium Risk', ShpfyOrderRisk.Message, 'Risk Message');
        end;

        if ShpfyOrderRisk.Get(ShpfyOrderHeader."Shopify Order Id", 3) then begin
            LibraryAssert.AreEqual(Enum::"Shpfy Risk Level"::High, ShpfyOrderRisk.Level, 'Risk Level');
            LibraryAssert.AreEqual('High Risk', ShpfyOrderRisk.Message, 'Risk Message');
        end;
    end;
}
