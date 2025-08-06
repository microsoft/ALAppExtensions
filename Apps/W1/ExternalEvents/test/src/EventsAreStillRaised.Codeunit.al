codeunit 139641 "Events Are Still Raised"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    [Test]
    procedure TestEventOnAfterFinalizePostingAreBeeingRaised()
    var
        SalesHeader: Record "Sales Header";
        ARSubscribers: Codeunit "AR Subscribers";
        LibrarySales: Codeunit "Library - Sales";
    begin
        BindSubscription(ARSubscribers);
        ARSubscribers.ClearOnAfterFinalizePostingSalesInvoiceCalled();
        LibrarySales.CreateSalesOrder(SalesHeader);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        if not ARSubscribers.GetOnAfterFinalizePostingSalesInvoiceCalled() then
            error('OnAfterFinalizePosting has not been raised');

        if not ARSubscribers.GetOnAfterCustLedgEntryInsertCalled() then
            error('OnAfterCustLedgEntryInsert has  not been raised')
    end;

}
