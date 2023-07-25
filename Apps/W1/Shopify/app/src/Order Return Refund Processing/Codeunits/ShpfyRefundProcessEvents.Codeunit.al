codeunit 30247 "Shpfy Refund Process Events"
{
    Access = Internal;

    [InternalEvent(false)]
    internal procedure OnBeforeReleaseSalesHeader(var SalesHeader: Record "Sales Header"; RefundHeader: Record "Shpfy Refund Header"; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnAfterReleaseSalesHeader(var SalesHeader: Record "Sales Header"; RefundHeader: Record "Shpfy Refund Header")
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnBeforeCreateSalesHeader(RefundHeader: Record "Shpfy Refund Header"; var SalesHeader: Record "Sales Header"; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnAfterCreateSalesHeader(RefundHeader: Record "Shpfy Refund Header"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnBeforeCreateItemSalesLine(RefundHeader: Record "Shpfy Refund Header"; RefundLine: Record "Shpfy Refund Line"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var NextLineNo: Integer; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnAfterCreateItemSalesLine(RefundHeader: Record "Shpfy Refund Header"; RefundLine: Record "Shpfy Refund Line"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnBeforeCreateItemSalesLineFromReturnLine(RefundHeader: Record "Shpfy Refund Header"; ReturnLine: Record "Shpfy Return Line"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; var NextLineNo: Integer; var Handled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnAfterCreateItemSalesLineFromReturnLine(RefundHeader: Record "Shpfy Refund Header"; ReturnLine: Record "Shpfy Return Line"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

}