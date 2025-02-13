namespace Microsoft.Purchases.Document;

using Microsoft.Purchases.Posting;

codeunit 31180 "Item Charge Assgnt Handler CZL"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostItemChargeLineOnAfterPostItemCharge', '', false, false)]
    local procedure ItemChargeAssgntWithAssignValuesOnPostItemChargeLineOnAfterPostItemCharge(sender: Codeunit "Purch.-Post"; var TempItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)" temporary; PurchHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line")
    var
        ItemChargeAssgntPurchCZL: Codeunit "Item Charge Assgnt. Purch. CZL";
    begin
        if TempItemChargeAssgntPurch."Applies-to Doc. Type" = TempItemChargeAssgntPurch."Applies-to Doc. Type"::"Item Ledger Entry Positive Adjmt. CZL" then begin
            ItemChargeAssgntPurchCZL.PostItemChargePerPosAdjItem(sender, TempItemChargeAssgntPurch, PurchHeader, PurchLine);
            TempItemChargeAssgntPurch.Mark(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Charge Assgnt. (Purch.)", 'OnAssignByAmountOnAfterAssignAppliesToDocLineAmount', '', false, false)]
    local procedure ItemChargeAssgntWithAssignValuesOnAssignByAmountOnAfterAssignAppliesToDocLineAmount(ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; var TempItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)" temporary; PurchHeader: Record "Purchase Header")
    var
        ItemChargeAssgntPurchCZL: Codeunit "Item Charge Assgnt. Purch. CZL";
    begin
        if ItemChargeAssignmentPurch."Applies-to Doc. Type" = ItemChargeAssignmentPurch."Applies-to Doc. Type"::"Item Ledger Entry Positive Adjmt. CZL" then
            ItemChargeAssgntPurchCZL.AssignByAmountItemLedgerEntryPositiveAdjmt(ItemChargeAssignmentPurch, TempItemChargeAssignmentPurch, PurchHeader);
    end;
}
