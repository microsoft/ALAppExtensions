pageextension 1078 "MS - PayPal Payment Services" extends "BC O365 Payment Services"
{
    layout
    {
        addfirst(Control75)
        {
            group("PaypalGroup")
            {
                Visible = IsPaypalEnabledAndDefault;
                ShowCaption = false;
                group(UserIsNotAdminGroup)
                {
                    ShowCaption = false;
                    Visible = not UserHasPermissions;
                    InstructionalText = 'Ask your Office 365 administrator to change the settings for PayPal.';
                }
                group(UserIsAdminGroup)
                {
                    Visible = UserHasPermissions;
                    ShowCaption = false;

                    field(PaypalAccountIdControl; PaypalAccountId)
                    {
                        ApplicationArea = Invoicing, Basic, Suite;
                        Caption = 'PayPal email address';
                        Editable = UserHasPermissions;
                        ExtendedDatatype = EMail;
                        ToolTip = 'Specifies the PayPal email address.';

                        trigger OnValidate();
                        begin
                            MSPayPalStandardMgt.SetPaypalAccount(PaypalAccountId, false);
                            CurrPage.Update();
                        end;
                    }
                    field("Terms of Service"; TermsOfServiceLbl)
                    {
                        ApplicationArea = Invoicing, Basic, Suite;
                        Caption = 'PayPal Terms of Service';
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Specifies PayPal terms of service.';

                        trigger OnDrillDown();
                        begin
                            Hyperlink(PaypalTermsOfServiceLink);
                        end;
                    }
                }
            }
        }
    }

    var
        MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
        PaypalAccountId: Text[250];
        PaypalTermsOfServiceLink: Text[250];
        IsPaypalEnabledAndDefault: Boolean;
        UserHasPermissions: Boolean;
        TermsOfServiceLbl: Label 'Terms of service';
        PayPalTelemetryCategoryTok: Label 'AL Paypal', Locked = true;
        UserWithoutPermissionsTelemetryMsg: Label 'An Invoicing user without permissions saw PayPal settings page.', Locked = true;

    trigger OnOpenPage();
    var
        TempPaymentServiceSetup: Record 1060 temporary;
        MSPayPalStandardTemplate: Record "MS - PayPal Standard Template";
    begin
        UserHasPermissions := CheckUserPermissions();

        if not UserHasPermissions then begin
            Session.LogMessage('00006ZK', UserWithoutPermissionsTelemetryMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            exit;
        end;

        with MSPayPalStandardAccount do
            if IsEmpty() then begin
                MSPayPalStandardMgt.RegisterPayPalStandardTemplate(TempPaymentServiceSetup);

                MSPayPalStandardMgt.GetTemplate(MSPayPalStandardTemplate);
                MSPayPalStandardTemplate.RefreshLogoIfNeeded();
                TransferFields(MSPayPalStandardTemplate, false);
                Insert(true);
            end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetPaypalFields();
    end;

    local procedure SetPaypalFields()
    begin
        if not MSPayPalStandardAccount.FindFirst() then
            exit;

        PaypalTermsOfServiceLink := MSPayPalStandardAccount."Terms of Service";
        PaypalAccountId := MSPayPalStandardAccount."Account ID";
        IsPaypalEnabledAndDefault := MSPayPalStandardAccount.Enabled and MSPayPalStandardAccount."Always Include on Documents"
            and (MSPayPalStandardAccount."Account ID" <> '');
    end;

    local procedure CheckUserPermissions(): Boolean
    var
        DummyMSPayPalStandardAccount: Record "MS - PayPal Standard Account";
        AzureADUserManagement: Codeunit "Azure AD User Management";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit(DummyMSPayPalStandardAccount.WritePermission());

        if AzureADUserManagement.IsUserTenantAdmin() then
            exit(true);

        exit(false);
    end;
}
