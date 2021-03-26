codeunit 31027 "Tariff Number Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Tariff Number", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteStatisticIndicationCZLOnAfterDeleteTariffNumber(var Rec: Record "Tariff Number")
    var
        StatisticIndicationCZL: Record "Statistic Indication CZL";
    begin
        if Rec.IsTemporary() then
            exit;
        StatisticIndicationCZL.SetRange("Tariff No.", Rec."No.");
        StatisticIndicationCZL.DeleteAll();
    end;
}