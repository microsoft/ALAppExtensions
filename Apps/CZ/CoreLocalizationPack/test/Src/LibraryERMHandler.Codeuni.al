codeunit 148062 "Library - ERM Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - ERM", 'OnAfterFillSalesHeaderExcludedFieldList', '', false, false)]
    local procedure OnAfterFillSalesHeaderExcludedFieldListAddVatDateCZ(var FieldListToExclude: List of [Text])
    var
        SalesHeader: Record "Sales Header";
    begin
        FieldListToExclude.Add(SalesHeader.FieldName("VAT Date CZL"));
#if not CLEAN19
#pragma warning disable AL0432
        FieldListToExclude.Add(SalesHeader.FieldName("Prepayment Type"));
#pragma warning restore AL0432
#endif
    end;
}
