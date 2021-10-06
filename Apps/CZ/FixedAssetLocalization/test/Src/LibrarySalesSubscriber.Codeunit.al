#if not CLEAN18
codeunit 148077 "Library Sales Subscriber CZF"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Sales", 'OnAfterCreateSalesLineWithShipmentDate', '', false, false)]
    local procedure DeleteFAExtendedPostingGroupOnAfterCreateSalesLineWithShipmentDate(var SalesLine: Record "Sales Line")
    var
        FAExtendedPostingGroup: Record "FA Extended Posting Group";
    begin
        if SalesLine.Type <> SalesLine.Type::"Fixed Asset" then
            exit;

        FAExtendedPostingGroup.DeleteAll();
    end;
}
#endif