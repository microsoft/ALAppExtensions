page 20109 "AMC Bank Signup to Service"
{
    Caption = 'AMC Banking Signup webservice';

    PageType = StandardDialog;
    SourceTable = "Company Information";
    UsageCategory = None;
    ContextSensitiveHelpPage = '403';

    layout
    {
        area(content)
        {
            group(SolutionLicense)
            {
                Caption = 'Solution information';
                group(SolutionGrp)
                {
                    Caption = '';
                    field("Solution"; "Solution")
                    {
                        Caption = 'Solution';
                        ApplicationArea = Suite;
                        Visible = true;
                        Enabled = false;
                        ToolTip = 'Specifies which solution of AMC Banking is purchased.';
                    }
                }
                Group(LicenseGrp)
                {
                    Caption = '';
                    field("BCLicenseNumber"; BCLicenseNumberText)
                    {
                        ApplicationArea = Basic, Suite;
                        Visible = true;
                        Enabled = true;
                        Editable = false;
                        AssistEdit = false;
                        Caption = 'License';
                        ToolTip = 'License number of Business Central for AMC Banking';
                    }
                }
                group(General_Admin)
                {
                    ShowCaption = false;
                    Editable = false;
                    field(AdminUserName; AdminUserName)
                    {
                        Caption = 'Admin signup user';
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the admin user name of the Webservice signup.';
                    }
                    field(AdminEmail; AdminEmail)
                    {
                        Caption = 'Admin signup E-mail';
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                        ExtendedDatatype = EMail;
                        ToolTip = 'Specifies the admin E-mail of Webservice signup.';
                    }
                }
            }
            group(CompanyGroup)
            {
                Caption = 'Company Information for the webservice';

                group(ChoseCompany)
                {
                    ShowCaption = false;
                    field(Company; CompanyDisplayName)
                    {
                        ApplicationArea = All;
                        Caption = 'Use information from company';
                        Editable = false;
                        ToolTip = 'Specifies the company that you want to use for registration on the Webservice.';

                        trigger OnAssistEdit()
                        var
                            SelectedCompany: Record Company;
                            AllowedCompanies: Page "Accessible Companies";

                        begin
                            AllowedCompanies.Initialize();

                            if SelectedCompany.Get(CompanyName) then
                                AllowedCompanies.SetRecord(SelectedCompany);

                            AllowedCompanies.LookupMode(true);

                            if AllowedCompanies.RunModal() = ACTION::LookupOK then begin
                                AllowedCompanies.GetRecord(SelectedCompany);
                                VarCompany := SelectedCompany.Name;
                                SetCompanyDisplayName();
                                rec.ChangeCompany(VarCompany);
                                if rec.Get() then;

                            end;
                        end;
                    }
                }
            }
        }
    }


    var
        AMCBankingSetup: Record "AMC Banking Setup";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        AMCBankRESTRequestMgt: codeunit "AMC Bank REST Request Mgt.";
        CompanyCurrency: Code[10];
        CompanyDisplayName: Text[250];
        VarCompany: Text;
        Solution: Text;
        BCLicenseNumberText: Text;
        AdminUserName: Text;
        AdminEmail: Text;

    trigger OnOpenPage()
    var
    begin
        AMCBankingSetup.Get();
        Solution := AMCBankingSetup.Solution;
        BCLicenseNumberText := AMCBankingMgt.GetLicenseNumber();
        VarCompany := CurrentCompany();
        SetCompanyDisplayName();

        rec.ChangeCompany(VarCompany);
        if rec.Get() then;

        GetAdminUserInfo(AdminUserName, AdminEmail);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        RegistrationURL: Text;
    begin
        if (CloseAction = CloseAction::OK) then
            RegistrationURL := GetLoginURL();

        if (RegistrationURL <> '') then
            Hyperlink(RegistrationURL);

    end;

    local procedure SetCompanyDisplayName()
    var
        SelectedCompany: Record Company;
        GeneralLedgerSetup: Record "General Ledger Setup";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        if SelectedCompany.Get(VarCompany) then
            CompanyDisplayName := CompanyInformationMgt.GetCompanyDisplayNameDefaulted(SelectedCompany);

        Clear(CompanyCurrency);
        GeneralLedgerSetup.ChangeCompany(VarCompany);
        if (GeneralLedgerSetup.Get()) then
            CompanyCurrency := GeneralLedgerSetup."LCY Code";
    end;

    local procedure GetAdminUserInfo(var adminUser: Text; var adminEmail: Text)
    var
        User: Record User;
        UserGUID: Guid;
    begin
        UserGUID := DelChr(LowerCase(Format(UserSecurityId())), '=', '{}');
        User.SetRange("User Security ID", UserSecurityId());
        if (User.FindFirst()) then begin
            if (User."Full Name" <> '') then
                adminUser := User."Full Name"
            else
                adminUser := User."User Name";

            if (User."Authentication Email" <> '') then
                adminEmail := User."Authentication Email"
            else
                adminEmail := User."Contact Email";
        end;
    end;


    local procedure GetLoginURL(): Text
    var
        CountryRegion: Record "Country/Region";
        EnvironmentInformation: Codeunit "Environment Information";
        JSONManagement: Codeunit "JSON Management";
        EasyRegistrationTempBlob: Codeunit "Temp Blob";
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
        JObject: DotNet JObject;
        ResponseJsonObject: DotNet JObject;
        Handled: Boolean;
        restcall: text;
        ResponseResult: Text;
    begin

        restcall := AMCBankRESTRequestMgt.GetEasyRegistartionURLRestCall();
        AMCBankingSetup.Get();

        AMCBankRESTRequestMgt.InitializeHttp(HttpRequestMessage, AMCBankingSetup."Sign-up URL", 'POST');

        if (CountryRegion.Get(rec."Country/Region Code")) then;

        JSONManagement.InitializeEmptyObject();
        JSONManagement.GetJSONObject(JObject);
        JSONManagement.AddJPropertyToJObject(JObject, 'companyname', rec.name);
        JSONManagement.AddJPropertyToJObject(JObject, 'address1', rec.Address);
        JSONManagement.AddJPropertyToJObject(JObject, 'address2', rec."Address 2");
        JSONManagement.AddJPropertyToJObject(JObject, 'zipcode', rec."Post Code");
        JSONManagement.AddJPropertyToJObject(JObject, 'city', rec.City);
        JSONManagement.AddJPropertyToJObject(JObject, 'country', CountryRegion."ISO Code");
        JSONManagement.AddJPropertyToJObject(JObject, 'state', rec.County);
        JSONManagement.AddJPropertyToJObject(JObject, 'vatid', GetVatIdwithCountryId(CountryRegion));
        JSONManagement.AddJPropertyToJObject(JObject, 'currency', CompanyCurrency);
        JSONManagement.AddJPropertyToJObject(JObject, 'fullname', AdminUserName);
        JSONManagement.AddJPropertyToJObject(JObject, 'email', AdminEmail);
        JSONManagement.AddJPropertyToJObject(JObject, 'phone', rec."Phone No.");
        JSONManagement.AddJPropertyToJObject(JObject, 'erp', 'Dyn. Nav');
        JSONManagement.AddJPropertyToJObject(JObject, 'moduleguid', DelStr(AMCBankingMgt.GetLicenseNumber(), 1, 2));
        JSONManagement.AddJPropertyToJObject(JObject, 'moduleprefix', 'BC');
        JSONManagement.AddJPropertyToJObject(JObject, 'modulepostfix', GetModulePostFix(AMCBankingSetup));
        JSONManagement.AddJPropertyToJObject(JObject, 'sandbox', EnvironmentInformation.IsSandbox());
        JSONManagement.AddJPropertyToJObject(JObject, 'businessappinstalled', AMCBankingMgt.IsAMCBusinessInstalled());

        HttpContent.WriteFrom(JSONManagement.WriteObjectToString());
        HttpRequestMessage.Content(HttpContent);

        //Set Content-Type header
        AMCBankRESTRequestMgt.SetHttpContentsDefaults(HttpRequestMessage);

        //Send Request to webservice
        Handled := false;
        AMCBankRESTRequestMgt.OnBeforeSendRestRequest(Handled, HttpRequestMessage, HttpResponseMessage, restcall, AMCBankingMgt.GetAppCaller(), true);
        AMCBankRESTRequestMgt.SendRestRequest(Handled, HttpRequestMessage, HttpResponseMessage, restcall, AMCBankingMgt.GetAppCaller(), true);
        AMCBankRESTRequestMgt.GetRestResponse(HttpResponseMessage, EasyRegistrationTempBlob);
        if (not AMCBankRESTRequestMgt.HasResponseErrors(EasyRegistrationTempBlob, restcall, 'syslog', ResponseResult, AMCBankingMgt.GetAppCaller())) then begin
            AMCBankRESTRequestMgt.GetJsonObjectFromBlob(EasyRegistrationTempBlob, ResponseJsonObject);
            JSONManagement.InitializeObjectFromJObject(ResponseJsonObject);
            if (JSONManagement.GetValue('modulepassword') <> '') then begin
                AMCBankingSetup."User Name" := CopyStr(BCLicenseNumberText, 1, 50);
                AMCBankingSetup.SavePassword(JSONManagement.GetValue('modulepassword'));
                AMCBankingSetup.Modify();
            end;
            exit(JSONManagement.GetValue('url'));
        end
        else
            AMCBankRESTRequestMgt.ShowResponseError(ResponseResult);

        exit('');
    end;

    local procedure GetModulePostFix(AMCBankingSetup: Record "AMC Banking Setup"): Text
    var
        PostFixValue: Text;
    begin

        PostFixValue := '';
        AMCBankingMgt.OnGetModulePostFix(PostFixValue, AMCBankingSetup);

        exit(PostFixValue);
    end;



    local procedure GetVatIdwithCountryId(CountryRegion: Record "Country/Region"): Text[30]
    var
        CompanyInfomation_RecordRef: RecordRef;
        TaxField_fieldRef: FieldRef;
        TaxValue: Text[30];
    begin

        if (rec."VAT Registration No." <> '') then
            TaxValue := Rec."VAT Registration No."
        else begin
            CompanyInfomation_RecordRef.OPEN(DATABASE::"Company Information");
            if (CompanyInfomation_RecordRef.FIELDEXIST(10016)) then begin //Use Federal ID if exists
                TaxField_fieldRef := CompanyInfomation_RecordRef.FIELD(10016);
                TaxValue := TaxField_fieldRef.Value();
            end
        end;

        if (TaxValue <> '') then
            if (CopyStr(TaxValue, 1, 2) <> CountryRegion."ISO Code") then
                TaxValue := CopyStr(CountryRegion."ISO Code" + TaxValue, 1, 30);

        exit(TaxValue);

    end;

}
