codeunit 148112 MTDHttpClientMockService
{
    var
        UnauthorizedVRNCalls: Dictionary of [Text, Integer];

    procedure ClearUnauthorizedVRNCalls()
    begin
        Clear(UnauthorizedVRNCalls);
    end;

    procedure HandleRequest(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        RequestPath: Text;
    begin

        RequestPath := Request.Path;

        if RequestPath.Contains('333333301') then
            exit(HandleMTDRequest('200_blanked.txt', 200, Response));
        if RequestPath.Contains('333333302') then
            exit(HandleMTDRequest('200_dummyjson.txt', 200, Response));
        if RequestPath.Contains('333333303') then
            exit(HandleMTDRequest('400_blanked.txt', 400, Response));
        if RequestPath.Contains('MockServicePacket304') then
            exit(HandleMTDRequest('401_unauthorized.txt', 401, Response));
        if RequestPath.Contains('333333305') then
            exit(HandleMTDRequest('404_not_found_blanked.txt', 404, Response));
        if RequestPath.Contains('333333310') then
            exit(HandleMTDRequest('400_vrn_invalid.txt', 400, Response));
        if RequestPath.Contains('333333311') then
            exit(HandleMTDRequest('400_invalid_date_from.txt', 400, Response));
        if RequestPath.Contains('333333312') then
            exit(HandleMTDRequest('400_date_from_invalid.txt', 400, Response));
        if RequestPath.Contains('333333313') then
            exit(HandleMTDRequest('400_invalid_date_to.txt', 400, Response));
        if RequestPath.Contains('333333314') then
            exit(HandleMTDRequest('400_date_to_invalid.txt', 400, Response));
        if RequestPath.Contains('333333315') then
            exit(HandleMTDRequest('400_invalid_date_range.txt', 400, Response));
        if RequestPath.Contains('333333316') then
            exit(HandleMTDRequest('400_date_range_invalid.txt', 400, Response));
        if RequestPath.Contains('333333317') then
            exit(HandleMTDRequest('400_invalid_status.txt', 400, Response));
        if RequestPath.Contains('333333318') then
            exit(HandleMTDRequest('400_period_key_invalid.txt', 400, Response));
        if RequestPath.Contains('333333319') then
            exit(HandleMTDRequest('400_invalid_request.txt', 400, Response));
        if RequestPath.Contains('333333320') then
            exit(HandleMTDRequest('400_vat_total_value.txt', 400, Response));
        if RequestPath.Contains('333333321') then
            exit(HandleMTDRequest('400_vat_net_value.txt', 400, Response));
        if RequestPath.Contains('333333322') then
            exit(HandleMTDRequest('400_invalid_numeric_value.txt', 400, Response));
        if RequestPath.Contains('333333323') then
            exit(HandleMTDRequest('403_date_range_too_large.txt', 403, Response));
        if RequestPath.Contains('333333324') then
            exit(HandleMTDRequest('403_not_finalised.txt', 403, Response));
        if RequestPath.Contains('333333325') then
            exit(HandleMTDRequest('403_duplicate_submission.txt', 403, Response));
        if RequestPath.Contains('333333326') then
            exit(HandleMTDRequest('403_clientoruseragent_not_authorised.txt', 403, Response));
        if RequestPath.Contains('333333327') then
            exit(HandleMTDRequest('404_not_found.txt', 404, Response));
        if RequestPath.Contains('333333328') then
            exit(HandleMTDRequest('400_custom.txt', 400, Response));
        if RequestPath.Contains('333333329') then
            exit(HandleMTDRequest('429_too_many_requests.txt', 429, Response));
        if RequestPath.Contains('333333330') then
            exit(HandleMTDRequest('200_payment.txt', 200, Response));
        if RequestPath.Contains('333333331') then
            exit(HandleMTDRequest('200_payment_nodate.txt', 200, Response));
        if RequestPath.Contains('333333332') then
            exit(HandleMTDRequest('200_payments.txt', 200, Response));
        if RequestPath.Contains('333333333') then
            exit(HandleMTDRequest('200_payments_nodates.txt', 200, Response));
        if RequestPath.Contains('333333334') then
            exit(HandleMTDRequest('200_payments_firstdate.txt', 200, Response));
        if RequestPath.Contains('333333335') then
            exit(HandleMTDRequest('200_payments_seconddate.txt', 200, Response));
        if RequestPath.Contains('333333336') then
            exit(HandleMTDRequest('200_liability.txt', 200, Response));
        if RequestPath.Contains('333333337') then
            exit(HandleMTDRequest('200_liabilities.txt', 200, Response));
        if RequestPath.Contains('333333338') then
            exit(HandleMTDRequest('200_vatreturn.txt', 200, Response));
        if RequestPath.Contains('333333339') then
            exit(HandleMTDRequest('201_submit.txt', 201, Response));
        if RequestPath.Contains('333333340') then
            exit(HandleMTDRequest('200_period_open.txt', 200, Response));
        if RequestPath.Contains('333333341') then
            exit(HandleMTDRequest('200_period_closed.txt', 200, Response));
        if RequestPath.Contains('333333342') then
            exit(HandleMTDRequest('200_periods.txt', 200, Response));
        if RequestPath.Contains('MockServicePacket343') then
            exit(HandleMTDRequest('201_submit.txt', 201, Response));
        if RequestPath.Contains('333333344') then
            exit(HandleOneOffUnauthorizedRequest('333333344', '201_submit.txt', 201, Response));
        if RequestPath.Contains('MockServicePacket345') then
            exit(HandleMTDRequest('200_authorize_343.txt', 200, Response));
        if RequestPath.Contains('MockServicePacket346') then
            exit(HandleMTDRequest('200_payment.txt', 200, Response));
        if RequestPath.Contains('333333347') then
            exit(HandleOneOffUnauthorizedRequest('333333347', '200_payment.txt', 200, Response));
        if RequestPath.Contains('MockServicePacket348') then
            exit(HandleMTDRequest('200_authorize_346.txt', 200, Response));
        if RequestPath.Contains('MockServicePacket349') then
            exit(HandleMTDRequest('200_liability.txt', 200, Response));
        if RequestPath.Contains('333333350') then
            exit(HandleOneOffUnauthorizedRequest('333333350', '200_liability.txt', 200, Response));
        if RequestPath.Contains('MockServicePacket351') then
            exit(HandleMTDRequest('200_authorize_349.txt', 200, Response));
        if RequestPath.Contains('MockServicePacket352') then
            exit(HandleMTDRequest('200_period_open.txt', 200, Response));
        if RequestPath.Contains('333333353') then
            exit(HandleOneOffUnauthorizedRequest('333333353', '200_period_open.txt', 200, Response));
        if RequestPath.Contains('MockServicePacket354') then
            exit(HandleMTDRequest('200_authorize_352.txt', 200, Response));
        if RequestPath.Contains('MockServicePacket355') then
            exit(HandleMTDRequest('200_vatreturn.txt', 200, Response));
        if RequestPath.Contains('333333356') then
            exit(HandleOneOffUnauthorizedRequest('333333356', '200_vatreturn.txt', 200, Response));
        if RequestPath.Contains('MockServicePacket357') then
            exit(HandleMTDRequest('200_authorize_355.txt', 200, Response));
        if RequestPath.Contains('MockServicePacket358') then
            exit(HandleMTDRequest('201_submit.txt', 201, Response));
        if RequestPath.Contains('MockServicePacket359') then
            exit(HandleMTDRequest('408_timeout.txt', 408, Response));
        if RequestPath.Contains('MockServicePacket360') then
            exit(HandleMTDRequest('200_authorize_358.txt', 200, Response));
        if RequestPath.Contains('MockServicePacket398') then
            exit(HandleMTDRequest('200_authorize_expiresinsec.txt', 200, Response));
        if RequestPath.Contains('MockServicePacket399') then
            exit(HandleMTDRequest('200_authorize.txt', 200, Response));

        exit(false);
    end;

    local procedure HandleMTDRequest(ResourcePath: Text; StatusCode: Integer; var Response: TestHttpResponseMessage): Boolean
    begin
        Response.Content.WriteFrom(NavApp.GetResourceAsText(ResourcePath, TextEncoding::UTF8));
        Response.HttpStatusCode := StatusCode;
        exit(false);
    end;

    local procedure HandleOneOffUnauthorizedRequest(VRN: Text; SuccessResourcePath: Text; SuccessStatusCode: Integer; var Response: TestHttpResponseMessage): Boolean
    var
        CallCount: Integer;
    begin
        if UnauthorizedVRNCalls.Get(VRN, CallCount) then begin
            UnauthorizedVRNCalls.Set(VRN, CallCount + 1);
            exit(HandleMTDRequest(SuccessResourcePath, SuccessStatusCode, Response));
        end;
        UnauthorizedVRNCalls.Set(VRN, 1);
        exit(HandleMTDRequest('401_unauthorized.txt', 401, Response));
    end;
}