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
        OrderHeader: Record "Shpfy Order Header";
        OrderRisk: Record "Shpfy Order Risk";
        OrderRisks: Codeunit "Shpfy Order Risks";
        JRisks: JsonArray;
    begin
        JRisks.ReadFrom('[{"level": "low", "message": "Low Risk", "display": true}, {"level": "medium", "message": "Medium Risk", "display": true}, {"level": "high", "message": "High Risk", "display": true}]');
        OrderHeader.Init();
        OrderHeader."Shopify Order Id" := Any.IntegerInRange(10000, 99999);

        OrderRisks.UpdateOrderRisks(OrderHeader, JRisks);

        if OrderRisk.Get(OrderHeader."Shopify Order Id", 1) then begin
            LibraryAssert.AreEqual(Enum::"Shpfy Risk Level"::Low, OrderRisk.Level, 'Risk Level');
            LibraryAssert.AreEqual('Low Risk', OrderRisk.Message, 'Risk Message');
        end;

        if OrderRisk.Get(OrderHeader."Shopify Order Id", 2) then begin
            LibraryAssert.AreEqual(Enum::"Shpfy Risk Level"::Medium, OrderRisk.Level, 'Risk Level');
            LibraryAssert.AreEqual('Medium Risk', OrderRisk.Message, 'Risk Message');
        end;

        if OrderRisk.Get(OrderHeader."Shopify Order Id", 3) then begin
            LibraryAssert.AreEqual(Enum::"Shpfy Risk Level"::High, OrderRisk.Level, 'Risk Level');
            LibraryAssert.AreEqual('High Risk', OrderRisk.Message, 'Risk Message');
        end;
    end;
}
