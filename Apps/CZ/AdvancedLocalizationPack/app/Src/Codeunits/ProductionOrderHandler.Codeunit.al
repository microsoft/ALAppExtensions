codeunit 31258 "Production Order Handler CZA"
{
    [EventSubscriber(ObjectType::Table, Database::"Production Order", 'OnAfterInitRecord', '', false, false)]
    local procedure DefaultGenBusPostingGroupOnAfterInitRecord(var ProductionOrder: Record "Production Order")
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        ManufacturingSetup.Get();
        ProductionOrder.Validate("Gen. Bus. Posting Group", ManufacturingSetup."Default Gen.Bus.Post. Grp. CZA");
    end;
}
