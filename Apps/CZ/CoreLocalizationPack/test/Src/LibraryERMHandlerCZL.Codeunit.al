#if not CLEAN22
#pragma warning disable AL0432, AS0072
codeunit 148062 "Library - ERM Handler CZL"
{
    ObsoleteReason = 'Not used.';
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - ERM", 'OnAfterFillSalesHeaderExcludedFieldList', '', false, false)]
    local procedure OnAfterFillSalesHeaderExcludedFieldListAddVatDateCZ(var FieldListToExclude: List of [Text])
    var
        SalesHeader: Record "Sales Header";
    begin
        FieldListToExclude.Add(SalesHeader.FieldName("VAT Date CZL"));
    end;
}
#pragma warning restore AL0432, AS0072
#endif