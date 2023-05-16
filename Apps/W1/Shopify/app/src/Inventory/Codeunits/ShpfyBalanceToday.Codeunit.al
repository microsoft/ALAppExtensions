codeunit 30212 "Shpfy Balance Today" implements "Shpfy Stock Calculation"
{
    procedure GetStock(var Item: Record Item): decimal;
    var
        ItemAvailabilityFormsMgt: codeunit "Item Availability Forms Mgt";
        GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable : decimal;
    begin
        ItemAvailabilityFormsMgt.CalcAvailQuantities(Item, true, GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable);
        exit(ProjAvailableBalance);
    end;
}

