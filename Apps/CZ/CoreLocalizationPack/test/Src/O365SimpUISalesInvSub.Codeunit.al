codeunit 148062 "O365 Simp. UI Sales Inv. Sub."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"O365 Simplify UI Sales Invoice", 'OnAfterFillSalesHeaderExcludedFieldList', '', false, false)]
    local procedure OnAfterFillSalesHeaderExcludedFieldListAddVatDateCZ(var FieldListToExclude: List of [Text])
    var
        SalesHeader: Record "Sales Header";
    begin
        FieldListToExclude.Add(SalesHeader.FieldName("VAT Date CZL"));
    end;
}
