namespace Microsoft.Finance.VAT.Reporting;

using System.Telemetry;

codeunit 13605 "Elec. VAT Decl. Http Comm." implements "Elec. VAT Decl. Communication"
{
    Access = Internal;

    var
        ElecVATDeclXml: Codeunit "Elec. VAT Decl. Xml";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        HttpRequestCodeErr: Label 'Http Request unsuccessful. Status Code: %1', Comment = '%1: Status code of http request';
        CertificateErr: Label 'Service has rejected authentication. Make sure you are using correct certificate, that has been registered with SKAT';
        ValidationErr: Label 'Service has rejected the request due to validation error. Some required field is missing in the request most likely.';
        ErrorTemplateErr: Label 'Service has returned Error code %1: %2', Comment = '%1 - error code, %2 - error description';
        Error4801Err: Label 'RSU is not delegated for this legal entity. Please follow steps in onboarding documentation to set up reporting for your legal entity.';
        Error4802Err: Label 'VAT Return Period is not open for reporting. Please check the VAT Return Period in the VAT Return Periods page.';
        Error4803Err: Label 'VAT Return Period has not ended yet, you cannot report VAT Return for it.';
        Error4804Err: Label 'VAT Return Period is older than 3 years, service does not accept it.';
        Error4810Err: Label 'VAT Statement draft is not approved yet, please log in to your SKAT.DK and approve it.';
        Error4812Err: Label 'VAT receipt does not exist.';
        Error507Err: Label 'Total declaration amount does not match the sum of the amounts in the declaration lines.';
        FeatureNameTxt: Label 'Electronic VAT Declaration DK', Locked = true;
        RequestSuccessfulTxt: Label 'Request was successful.', Locked = true;
        ResponsePreparedTxt: Label 'Response was prepared.', Locked = true;
        ResponseReceivedTxt: Label 'Response was received.', Locked = true;

    procedure SendMessage(EnvelopeInStream: InStream; Endpoint: Text) Response: Interface "Elec. VAT Decl. Response";
    var
        ElecVATDeclHttpResponse: Codeunit "Elec. VAT Decl. Http Response";
        HttpClient: HttpClient;
        Content: HttpContent;
        RequestContentHttpHeaders: HttpHeaders;
        HttpResponse: HttpResponseMessage;
        HttpResponseText: Text;
        HttpRequestText: Text;
    begin
        Content.WriteFrom(EnvelopeInStream);
        Content.GetHeaders(RequestContentHttpHeaders);
        RequestContentHttpHeaders.Remove('Content-Type');
        RequestContentHttpHeaders.Add('Content-Type', 'application/soap+xml');
        HttpClient.SetBaseAddress(Endpoint);
        Content.ReadAs(HttpRequestText);
        FeatureTelemetry.LogUsage('0000LR1', FeatureNameTxt, ResponsePreparedTxt);
        HttpClient.Post(Endpoint, Content, HttpResponse);
        HttpResponse.Content.ReadAs(HttpResponseText);
        FeatureTelemetry.LogUsage('0000LR2', FeatureNameTxt, ResponseReceivedTxt);
        CheckForKnownErrors(HttpResponse);
        if HttpResponse.HttpStatusCode <> 200 then
            Error(HttpRequestCodeErr, HttpResponse.HttpStatusCode);
        ElecVATDeclHttpResponse.Initialize(HttpResponse);
        FeatureTelemetry.LogUsage('0000LR3', FeatureNameTxt, RequestSuccessfulTxt);
        Response := ElecVATDeclHttpResponse;
    end;

    local procedure CheckForKnownErrors(Response: HttpResponseMessage)
    begin
        case Response.HttpStatusCode of
            200:
                ThrowKnownStatus200Error(Response);
            500:
                ThrowKnownStatus500Error(Response);
        end;
    end;

    local procedure ThrowKnownStatus500Error(Response: HttpResponseMessage)
    var
        ResponseText: Text;
    begin
        Response.Content.ReadAs(ResponseText);
        if StrPos(ResponseText, 'wsse:FailedAuthentication') > 0 then begin
            FeatureTelemetry.LogError('0000LQY', FeatureNameTxt, CertificateErr, '');
            Error(CertificateErr);
        end;
        if StrPos(ResponseText, 'BEA-382505: OSB Validate action failed validation') > 0 then begin
            FeatureTelemetry.LogError('0000LQZ', FeatureNameTxt, ValidationErr, '');
            Error(ValidationErr);
        end;
    end;

    local procedure ThrowKnownStatus200Error(Response: HttpResponseMessage)
    var
        ErrorNode: XmlNode;
        ErrorCode: Integer;
        ResponseText: Text;
    begin
        Response.Content.ReadAs(ResponseText);
        if not ElecVATDeclXml.TryGetErrorNodeFromResponseText(ResponseText, ErrorNode) then
            exit;

        Evaluate(ErrorCode, ErrorNode.AsXmlElement().InnerText());
        FeatureTelemetry.LogError('0000LR0', FeatureNameTxt, StrSubstNo(ErrorTemplateErr, ErrorCode, ''), '');
        case ErrorCode of
            4801:
                Error(ErrorTemplateErr, ErrorCode, Error4801Err);
            4802:
                Error(ErrorTemplateErr, ErrorCode, Error4802Err);
            4803:
                Error(ErrorTemplateErr, ErrorCode, Error4803Err);
            4804:
                Error(ErrorTemplateErr, ErrorCode, Error4804Err);
            4810:
                Error(ErrorTemplateErr, ErrorCode, Error4810Err);
            4812:
                Error(ErrorTemplateErr, ErrorCode, Error4812Err);
            507:
                Error(ErrorTemplateErr, ErrorCode, Error507Err);
        end;
    end;
}