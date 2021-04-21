pageextension 4703 "VAT Report Setup Extension" extends "VAT Report Setup"
{
    layout
    {
        addlast(content)
        {
            group(VATGroup)
            {
                Caption = 'VAT Group Management';

                field(VATGroupRole; Rec."VAT Group Role")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies what kind of role the current user has in the VAT group.';
                }
                group(AuthenticationTypeControlOnPrem)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Member) and not IsSaas;
                    ShowCaption = false;
                    field(VATGroupAuthenticationType; Rec."Authentication Type")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies which authentication type will be used to send data to the group representative.';
                    }
                }
                group(AuthenticationTypeControlOnSaas)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Member) and IsSaas;
                    ShowCaption = false;
                    field(VATGroupAuthenticationTypeSaas; AuthenticationTypeSaas)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Authentication Type';
                        ToolTip = 'Specifies which authentication type will be used to send data to the group representative.';
                        trigger OnValidate()
                        begin
                            case AuthenticationTypeSaas of
                                AuthenticationTypeSaas::WebServiceAccessKey:
                                    Rec."Authentication Type" := Rec."Authentication Type"::WebServiceAccessKey;
                                AuthenticationTypeSaas::OAuth2:
                                    Rec."Authentication Type" := Rec."Authentication Type"::OAuth2;
                            end;
                        end;
                    }
                }
                group(MemberIdentifierControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Member);
                    ShowCaption = false;
                    field(MemberIdentifier; Rec."Group Member ID")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the current ID of the group member.';
                    }
                }
                group(APIURLControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Member);
                    ShowCaption = false;
                    field(GroupRepresentativeBCVersion; Rec."VAT Group BC Version")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the product version that the group representative uses.';
                    }
                    field(APIURL; Rec."Group Representative API URL")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the API URL of the group representative tenant.';
                    }
                }
                group(GroupRepresentativeComapanyControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Member);
                    ShowCaption = false;
                    field(GroupRepresentativeCompany; Rec."Group Representative Company")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the company name of the group representative tenant to which the VAT returns will be sent.';
                    }
                }
                group(UserNameControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Member) and (Rec."Authentication Type" = Rec."Authentication Type"::WebServiceAccessKey);
                    ShowCaption = false;
                    field(UserName; UserNameText)
                    {
                        ApplicationArea = Basic, Suite;
                        ExtendedDatatype = Masked;
                        Caption = 'User Name';
                        ToolTip = 'Specifies the web service access key of the user in the group representative company.';

                        trigger OnValidate()
                        begin
                            Rec."User Name Key" := Rec.SetSecret(Rec."User Name Key", UserNameText);
                        end;
                    }
                }
                group(WebserviceAccessKeyControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Member) and (Rec."Authentication Type" = Rec."Authentication Type"::WebServiceAccessKey);
                    ShowCaption = false;
                    field(WebserviceAccessKey; WebServiceAccessKeyText)
                    {
                        ApplicationArea = Basic, Suite;
                        ExtendedDatatype = Masked;
                        Caption = 'Web Service Access Key';
                        ToolTip = 'Specifies the web service access key of the user in the group representative company.';

                        trigger OnValidate()
                        begin
                            Rec."Web Service Access Key Key" := Rec.SetSecret(Rec."Web Service Access Key Key", WebServiceAccessKeyText);
                        end;
                    }
                }
                group(GroupRepresentativeOnBCOnlineControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Member) and (Rec."Authentication Type" = Rec."Authentication Type"::OAuth2) and IsSaas;
                    ShowCaption = false;
                    field(GroupRepresentativeOnBCOnline; Rec."Group Representative On SaaS")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether the group representative is using Business Central Online.';
                    }
                }
                group(ClientIdControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Member) and (Rec."Authentication Type" = Rec."Authentication Type"::OAuth2) and (not Rec."Group Representative On SaaS");
                    ShowCaption = false;
                    field(ClientId; ClientIDText)
                    {
                        ApplicationArea = Basic, Suite;
                        ExtendedDatatype = Masked;
                        Caption = 'Client ID';
                        ToolTip = 'Specifies the client ID of the Azure AD application used to access the API.';

                        trigger OnValidate()
                        begin
                            Rec."Client ID Key" := Rec.SetSecret(Rec."Client ID Key", ClientIDText);
                        end;
                    }
                }
                group(ClientSecretControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Member) and (Rec."Authentication Type" = Rec."Authentication Type"::OAuth2) and (not Rec."Group Representative On SaaS");
                    ShowCaption = false;
                    field(ClientSecret; ClientSecretText)
                    {
                        ApplicationArea = Basic, Suite;
                        ExtendedDatatype = Masked;
                        Caption = 'Client Secret';
                        ToolTip = 'Specifies the client secret of the Azure AD application used to access the API.';

                        trigger OnValidate()
                        begin
                            Rec."Client Secret Key" := Rec.SetSecret(Rec."Client Secret Key", ClientSecretText);
                        end;
                    }
                }
                group(AuthorityURLControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Member) and (Rec."Authentication Type" = Rec."Authentication Type"::OAuth2) and (not Rec."Group Representative On SaaS");
                    ShowCaption = false;
                    field(AuthorityURL; Rec."Authority URL")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the authority URL of the OAuth authority used to grant access tokens.';
                    }
                }
                group(ResourceURLControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Member) and (Rec."Authentication Type" = Rec."Authentication Type"::OAuth2) and (not Rec."Group Representative On SaaS");
                    ShowCaption = false;
                    field(ResourceURL; Rec."Resource URL")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the resource URL of the Azure AD application to which access will be granted.';
                    }
                }
                group(RedirectURLControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Member) and (Rec."Authentication Type" = Rec."Authentication Type"::OAuth2) and (not Rec."Group Representative On SaaS");
                    ShowCaption = false;
                    field(RedirectURL; Rec."Redirect URL")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the OAuth2 redirect URL of the Azure AD application used to access the API.';
                    }
                }

                group(ApprovedMembersControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Representative);
                    ShowCaption = false;

                    field(ApprovedMembers; Rec."Approved Members")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the number of approved members that are allowed to submit their VAT returns. Clicking on this number will open the Approved Members page.';
                        DrillDown = true;
                        DrillDownPageId = "VAT Group Approved Member List";
                    }
                }
                group(GroupSettlementAccountControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Representative);
                    ShowCaption = false;
                    field(GroupSettlementAccount; Rec."Group Settlement Account")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the settlement account for the VAT group member amounts.';
                    }
                }
                group(VATSettlementAccountControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Representative);
                    ShowCaption = false;
                    field(VATSettlementAccount; Rec."VAT Settlement Account")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the normal VAT settlement account.';
                    }
                }
                group(VATDueBoxNoControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Representative);
                    ShowCaption = false;
                    field(VATDueBoxNo; Rec."VAT Due Box No.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the number of the box on the form from the tax authority that should contain the total VAT amount due for a VAT group submission.';
                    }
                }
                group(GroupSettlementGenJnlTemplControl)
                {
                    Visible = (Rec."VAT Group Role" = Rec."VAT Group Role"::Representative);
                    ShowCaption = false;
                    field(GroupSettlementGenJnlTempl; Rec."Group Settle. Gen. Jnl. Templ.")
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies the general journal template used for the document to post VAT for the VAT group to the settlement account.';
                    }
                }
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(RenewToken)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Renew OAuth2 Token';
                ToolTip = 'Initiates a new OAuth2 authetication flow which will result in getting a new token. This should be used if the the previous token has expired or can no longer be used.';
                Promoted = true;
                PromotedCategory = Process;
                Image = AuthorizeCreditCard;
                Visible = (Rec."Authentication Type" = Rec."Authentication Type"::OAuth2) and (Rec."VAT Group Role" = Rec."VAT Group Role"::Member);

                trigger OnAction()
                var
                    VATGroupCommunication: Codeunit "VAT Group Communication";
                begin
                    VATGroupCommunication.GetBearerToken(Rec.GetSecret(Rec."Client ID Key"), Rec.GetSecret(Rec."Client Secret Key"), Rec."Authority URL", Rec."Redirect URL", Rec."Resource URL");
                end;
            }
        }
    }

    var
        EnvironmentInformation: Codeunit "Environment Information";
        OAuth2: Codeunit OAuth2;
        AuthenticationTypeSaas: Enum "VAT Group Authentication Type Saas";
        [NonDebuggable]
        ClientSecretText, ClientIDText, UserNameText, WebServiceAccessKeyText : Text;
        IsSaas: Boolean;

    trigger OnOpenPage()
    var
        RedirectURLText: Text;
    begin
        ClientSecretText := Rec.GetSecret(Rec."Client Secret Key");
        ClientIDText := Rec.GetSecret(Rec."Client ID Key");
        UserNameText := Rec.GetSecret(Rec."User Name Key");
        WebServiceAccessKeyText := Rec.GetSecret(Rec."Web Service Access Key Key");
        IsSaas := EnvironmentInformation.IsSaaSInfrastructure();

        if (Rec."VAT Group Role" = Rec."VAT Group Role"::Member) and IsNullGuid(Rec."Group Member ID") then
            Rec."Group Member ID" := CreateGuid();

        if Rec."Redirect URL" = '' then begin
            OAuth2.GetDefaultRedirectUrl(RedirectURLText);
            Rec."Redirect URL" := CopyStr(RedirectURLText, 1, MaxStrLen(Rec."Redirect URL"));
        end;

        if IsSaas then
            ConvertAuthenticationTypeToSaaS(Rec."Authentication Type", AuthenticationTypeSaas);
        Rec.Modify();
    end;

    local procedure ConvertAuthenticationTypeToSaaS(AuthenticationType: Enum "VAT Group Authentication Type OnPrem"; var AuthenticationTypeSaaS: Enum "VAT Group Authentication Type Saas")
    begin
        case AuthenticationType of
            AuthenticationType::OAuth2:
                AuthenticationTypeSaaS := AuthenticationTypeSaaS::OAuth2;
            AuthenticationType::WebServiceAccessKey:
                AuthenticationTypeSaaS := AuthenticationTypeSaaS::WebServiceAccessKey;
        end;
    end;
}