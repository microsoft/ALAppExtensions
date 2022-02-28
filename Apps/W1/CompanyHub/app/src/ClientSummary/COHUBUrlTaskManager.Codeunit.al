codeunit 1154 "COHUB Url Task Manager"
{
    TableNo = "COHUB Enviroment";
    Access = Internal;

    trigger OnRun()
    begin
        FetchCompanies(Rec);
    end;

    var
        CompanyPropNameTxt: Label 'Name', Locked = true;
        DisplayCompanyPropNameTxt: Label 'Display_Name', Locked = true;
        EvaluationCompanyPropNameTxt: Label 'Evaluation_Company', Locked = true;
        ArrayPropertyNameTxt: Label 'value', Locked = true;

        CouldNotFetchCompaniesMsg: Label 'Could not fetch companies, verify if you have permissions to access the company.';
        IncludeDemoComapniesMsg: Label 'Demo companies are currently not included. Choose the Include Demo Companies field to add them.', Comment = 'This message is added after CouldNotFetchCompaniesMsg';

        NotificatoinMessagePlaceholderLbl: Label '%1 %2', Locked = true;

    procedure FetchCompanies(var COHUBEnviroment: Record "COHUB Enviroment"): Boolean
    var
        COHUBAPIRequest: Codeunit "COHUB API Request";
        CouldNotFetchCompaniesNotification: Notification;
        CompanyJsonObject: JsonObject;
        CompanyJsonArray: JsonArray;
        CompanyJsonToken: JsonToken;
        CompanyJsonArrayToken: JsonToken;
        PropertyBag: JsonToken;
        CouldNotFetchCompaniesNotificationMsg: Text;
        CompanyResponse: Text;
        CompanyCount: Integer;
        AddedCompaniesCount: Integer;
        NumberOfCompaniesCount: Integer;
        CompanyPropNameValue: Text[50];
        DisplayCompanyPropNameValue: Text[50];
        CompanyUrl: Text;
        EvaluationCompanyPropNameValue: Boolean;
    begin
        if COHUBEnviroment.Link = '' then
            exit(false);

        if COHUBAPIRequest.InvokeGetCompanies(COHUBEnviroment, CompanyResponse, CompanyUrl) then begin
            CompanyJsonObject.ReadFrom(CompanyResponse);
            CompanyJsonObject.SelectToken(ArrayPropertyNameTxt, CompanyJsonArrayToken);
            CompanyJsonArray := CompanyJsonArrayToken.AsArray();

            // Get the count of companies in the array
            CompanyCount := CompanyJsonArray.Count();
            NumberOfCompaniesCount := CompanyCount;
            while CompanyCount > 0 do begin
                CompanyCount := CompanyCount - 1;
                CompanyJsonArray.Get(CompanyCount, CompanyJsonToken);
                CompanyJsonObject := CompanyJsonToken.AsObject();
                CompanyJsonObject.Get(CompanyPropNameTxt, PropertyBag);
                CompanyPropNameValue := CopyStr(PropertyBag.AsValue().AsText(), 1, MaxStrLen(CompanyPropNameValue));
                CompanyJsonObject.Get(DisplayCompanyPropNameTxt, PropertyBag);
                DisplayCompanyPropNameValue := CopyStr(PropertyBag.AsValue().AsText(), 1, MaxStrLen(DisplayCompanyPropNameValue));
                CompanyJsonObject.Get(EvaluationCompanyPropNameTxt, PropertyBag);
                EvaluationCompanyPropNameValue := PropertyBag.AsValue().AsBoolean();

                if (not EvaluationCompanyPropNameValue) or (EvaluationCompanyPropNameValue and COHUBEnviroment."Include Demo Companies") then begin
                    CreateEnviromentCompanyEndpointRecordAndGatherKPIData(COHUBEnviroment, CompanyPropNameValue, DisplayCompanyPropNameValue,
                      CompanyUrl, EvaluationCompanyPropNameValue);
                    AddedCompaniesCount := AddedCompaniesCount + 1;
                end;
            end;
        end;

        if GuiAllowed then
            if (AddedCompaniesCount = 0) and (NumberOfCompaniesCount > 0) then begin
                CouldNotFetchCompaniesNotificationMsg := CouldNotFetchCompaniesMsg;
                if not (COHUBEnviroment."Include Demo Companies") then
                    CouldNotFetchCompaniesNotificationMsg := StrSubstNo(NotificatoinMessagePlaceholderLbl, CouldNotFetchCompaniesNotificationMsg, IncludeDemoComapniesMsg);

                CouldNotFetchCompaniesNotification.Id := GetCouldNotFetchCompaniesGuid();
                CouldNotFetchCompaniesNotification.Recall();
                CouldNotFetchCompaniesNotification.Message(CouldNotFetchCompaniesNotificationMsg);
                CouldNotFetchCompaniesNotification.Scope := NotificationScope::GlobalScope;
                CouldNotFetchCompaniesNotification.Send();
            end;

        exit(NumberOfCompaniesCount > 0);
    end;

    local procedure GetCouldNotFetchCompaniesGuid(): Text
    begin
        exit('936d46b2-d2cb-4f51-b1c1-efeb93f63966');
    end;

    local procedure CreateEnviromentCompanyEndpointRecordAndGatherKPIData(COHUBEnviroment: Record "COHUB Enviroment"; CompanyNameValue: Text[50]; CompanyDisplayNameValue: Text[50]; CompanyUrl: Text; IsEvaulationCompany: Boolean)
    var
        COHUBCompanyEndpoint: Record "COHUB Company Endpoint";
        COHUBCompUrlTaskManager: Codeunit "COHUB Comp. Url Task Manager";
        CompanyEndpointExist: Boolean;
    begin
        CompanyEndpointExist := COHUBCompanyEndpoint.Get(COHUBEnviroment."No.", CompanyNameValue, UserSecurityId());
        COHUBCompanyEndpoint."Enviroment No." := COHUBEnviroment."No.";
        COHUBCompanyEndpoint."Company Name" := CompanyNameValue;
        COHUBCompanyEndpoint."Assigned To" := UserSecurityId();
        COHUBCompanyEndpoint."Company Display Name" := CompanyDisplayNameValue;
        COHUBCompanyEndpoint."ODATA Company URL" := COPYSTR(CompanyUrl, 1, MaxStrLen(COHUBCompanyEndpoint."ODATA Company URL"));
        COHUBCompanyEndpoint."Evaulation Company" := IsEvaulationCompany;
        if CompanyEndpointExist then
            COHUBCompanyEndpoint.Modify(true)
        else
            COHUBCompanyEndpoint.Insert(true);

        COHUBCompUrlTaskManager.GatherKPIData(COHUBCompanyEndpoint);
    end;
}

