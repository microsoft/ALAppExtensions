codeunit 11740 "Copy Document Mgt. Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopyFieldsFromOldSalesHeader', '', false, false)]
    local procedure CopyCreditMemoTypeFromOldSalesHeader(var ToSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header"; MoveNegLines: Boolean; IncludeHeader: Boolean)
    begin
        if ToSalesHeader."Document Type" in [ToSalesHeader."Document Type"::"Credit Memo", ToSalesHeader."Document Type"::"Return Order"] then
            ToSalesHeader."Credit Memo Type CZL" := OldSalesHeader."Credit Memo Type CZL"
        else
            Clear(ToSalesHeader."Credit Memo Type CZL");
    end;
}