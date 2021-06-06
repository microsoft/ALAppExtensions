codeunit 31384 "ItemJnl-Check Line Handler CZA"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Check Line", 'OnAfterCheckItemJnlLine', '', false, false)]
    local procedure CheckExactCostReturnOnAfterCheckItemJnlLine(var ItemJnlLine: Record "Item Journal Line"; CalledFromInvtPutawayPick: Boolean; CalledFromAdjustment: Boolean)
    var
        InventorySetup: Record "Inventory Setup";
        ManufacturingSetup: Record "Manufacturing Setup";
        Item: Record Item;
        ReservationEntry: Record "Reservation Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        ItemTrackingSetup: Record "Item Tracking Setup";
        ItemTrackingManagement: Codeunit "Item Tracking Management";
    begin
        if (not ItemJnlLine.Adjustment) and (ItemJnlLine."Value Entry Type" = ItemJnlLine."Value Entry Type"::"Direct Cost") then
            case ItemJnlLine."Entry Type" of
                ItemJnlLine."Entry Type"::Consumption:
                    if ItemJnlLine.Quantity < 0 then begin
                        ManufacturingSetup.Get();
                        if ManufacturingSetup."Exact Cost Rev.Mand. Cons. CZA" then begin
                            Item.Get(ItemJnlLine."Item No.");
                            ItemTrackingCode.Code := Item."Item Tracking Code";
                            ItemTrackingManagement.GetItemTrackingSetup(
                                ItemTrackingCode, ItemJnlLine."Entry Type",
                                ItemJnlLine.Signed(ItemJnlLine."Quantity (Base)") > 0, ItemTrackingSetup);

                            if ItemTrackingSetup.TrackingRequired() then begin
                                ReservationEntry.SetSourceFilter(Database::"Item Journal Line", ItemJnlLine."Entry Type".AsInteger(), ItemJnlLine."Journal Template Name", ItemJnlLine."Line No.", true);
                                ReservationEntry.SetSourceFilter(ItemJnlLine."Journal Batch Name", 0);
                                ReservationEntry.SetRange("Reservation Status", ReservationEntry."Reservation Status"::Prospect);
                                if ReservationEntry.FindSet(false, false) then
                                    repeat
                                        ReservationEntry.TestField("Appl.-from Item Entry");
                                    until ReservationEntry.Next() = 0;
                            end else
                                ItemJnlLine.TestField("Applies-from Entry");
                        end;
                    end;
                ItemJnlLine."Entry Type"::"Negative Adjmt.":
                    if ItemJnlLine.Quantity < 0 then begin
                        InventorySetup.Get();
                        if InventorySetup."Exact Cost Revers. Mandat. CZA" then begin
                            Item.Get(ItemJnlLine."Item No.");
                            ItemTrackingCode.Code := Item."Item Tracking Code";
                            ItemTrackingManagement.GetItemTrackingSetup(
                                ItemTrackingCode, ItemJnlLine."Entry Type",
                                ItemJnlLine.Signed(ItemJnlLine."Quantity (Base)") > 0, ItemTrackingSetup);

                            if ItemTrackingSetup.TrackingRequired() then begin
                                ReservationEntry.SetSourceFilter(Database::"Item Journal Line", ItemJnlLine."Entry Type".AsInteger(), ItemJnlLine."Journal Template Name", ItemJnlLine."Line No.", true);
                                ReservationEntry.SetSourceFilter(ItemJnlLine."Journal Batch Name", 0);
                                ReservationEntry.SetRange("Reservation Status", ReservationEntry."Reservation Status"::Prospect);
                                if ReservationEntry.FindSet(false, false) then
                                    repeat
                                        ReservationEntry.TestField("Appl.-from Item Entry");
                                    until ReservationEntry.Next() = 0;
                            end else
                                ItemJnlLine.TestField("Applies-from Entry");
                        end;
                    end;
            end;
    end;
}