#if not CLEAN22
#pragma warning disable AL0432
codeunit 148062 "Library - ERM Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - ERM", 'OnAfterFillSalesHeaderExcludedFieldList', '', false, false)]
    local procedure OnAfterFillSalesHeaderExcludedFieldListAddVatDateCZ(var FieldListToExclude: List of [Text])
    var
        SalesHeader: Record "Sales Header";
    begin
        FieldListToExclude.Add(SalesHeader.FieldName("VAT Date CZL"));
    end;
}
#pragma warning restore AL0432
#endif