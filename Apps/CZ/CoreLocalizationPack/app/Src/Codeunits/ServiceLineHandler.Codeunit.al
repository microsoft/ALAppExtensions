codeunit 11785 "Service Line Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure CopyFieldsOnAfterAssignItemValues(var ServiceLine: Record "Service Line"; Item: Record Item)
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceLine."Tariff No. CZL" := Item."Tariff No.";
        ServiceLine."Statistic Indication CZL" := Item."Statistic Indication CZL";
        ServiceLine."Country/Reg. of Orig. Code CZL" := Item."Country/Region of Origin Code";
        if ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.") then
            ServiceLine."Physical Transfer CZL" := ServiceHeader."Physical Transfer CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignResourceValues', '', false, false)]
    local procedure TariffNoOnAfterAssignResourceValues(var ServiceLine: Record "Service Line"; Resource: Record Resource)
    begin
        ServiceLine."Tariff No. CZL" := Resource."Tariff No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnBeforeModifyEvent', '', false, false)]
    local procedure RemoveVATCorrectionOnBeforeModifyEvent(var Rec: Record "Service Line"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        RemoveVATCorrection(Rec);
    end;

    local procedure RemoveVATCorrection(var ServiceLine: Record "Service Line")
    var
        ServiceLine2: Record "Service Line";
    begin
        // remove vat correction on current line
        if (ServiceLine."VAT Difference" <> 0) and (ServiceLine.Quantity <> 0) then begin
            ServiceLine."VAT Difference" := 0;
            ServiceLine.UpdateAmounts();
        end;

        // remove vat correction on another lines except the current line
        ServiceLine2.Reset();
        ServiceLine2.SetRange("Document Type", ServiceLine."Document Type");
        ServiceLine2.SetRange("Document No.", ServiceLine."Document No.");
        ServiceLine2.SetFilter("Line No.", '<>%1', ServiceLine."Line No.");
        ServiceLine2.SetFilter("VAT Difference", '<>0');
        if ServiceLine2.FindSet() then
            repeat
                ServiceLine2."VAT Difference" := 0;
                ServiceLine2.UpdateAmounts();
                ServiceLine2.Modify();
            until ServiceLine2.Next() = 0;
    end;
}