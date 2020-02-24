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

                        trigger OnValidate();
                        begin
                            MSPayPalStandardManagement.SetPaypalAccount(PaypalAccountId, false);
                            CurrPage.Update();
                        end;
                    }
                    field("Terms of Service"; TermsOfServiceLbl)
                    {
                        ApplicationArea = Invoicing, Basic, Suite;
                        Editable = false;
                        ShowCaption = false;

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
        MSPayPalStandardAccount: Record 1070;
        MSPayPalStandardManagement: Codeunit 1070;
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
        MSPayPalStandardTemplate: Record 1071;
        MSPayPalStandardMgt: Codeunit 1070;
    begin
        UserHasPermissions := CheckUserPermissions();

        if not UserHasPermissions then begin
            SendTraceTag('00006ZK', PayPalTelemetryCategoryTok, Verbosity::Normal, UserWithoutPermissionsTelemetryMsg, DataClassification::SystemMetadata);
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
        DummyMSPayPalStandardAccount: Record 1070;
        AzureADUserManagement: Codeunit 9010;
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if not EnvironmentInfo.IsSaaS() then
            exit(DummyMSPayPalStandardAccount.WritePermission());

        if AzureADUserManagement.IsUserTenantAdmin() then
            exit(true);

        exit(false);
    end;
}