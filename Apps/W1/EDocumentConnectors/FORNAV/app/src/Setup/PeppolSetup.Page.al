namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using System.EMail;
using System.Utilities;
using Microsoft.eServices.EDocument;
using System.Environment;
using System.Azure.Identity;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;

page 6413 "ForNAV Peppol Setup"
{
    PageType = Card;
    Caption = 'ForNAV E-Document Connector Setup';
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "ForNAV Peppol Setup";
    DataCaptionExpression = Rec.Authorized ? Format(Rec.Status) : AuthorizeLbl;
    AdditionalSearchTerms = 'ForNAV Peppol Setup';
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Identification)
            {
                Caption = 'Identification';
                Editable = Rec.Status <> Rec.Status::Published;
                field(Code; Rec."Identification Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Identification Code.', Locked = true;
                }
                field(Value; Rec."Identification Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Identification Value.', Locked = true;
                }
                field(Test; Rec.Test)
                {
                    Caption = 'Test';
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the setup is for testing purposes.', Locked = true;
                    Editable = not Rec."Demo Company";
                }
            }
            group("Business Card")
            {
                Editable = Rec.Status <> Rec.Status::Published;
                Caption = 'Business Card', Locked = true;
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the company.', Locked = true;
                }

                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the address of the company.', Locked = true;
                }

                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country/region code of the company.', Locked = true;
                }

                field(Language; Rec.Language)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the two letter ISO 639-1 language code', Locked = true;
                }

                field("Home Page"; Rec."Home Page")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the home page of the company.', Locked = true;
                }
            }
            group(ConnectionSetup)
            {
                Caption = 'Connection Setup';
                field(ClientId; ClientId)
                {
                    Caption = 'Client Id', Locked = true;
                    ApplicationArea = All;
                    Editable = ShowConnectionSetup;
                    ToolTip = 'Specifies the Oauth Client Id. You can get this from your ForNAV partner.';

                    trigger OnValidate()
                    begin
                        PeppolOauth.ValidateClientID(ClientId);
                    end;
                }
                field(PeppolEndpoint; PeppolEndpoint)
                {
                    Caption = 'Peppol Endpoint', Locked = true;
                    ApplicationArea = All;
                    Editable = ShowConnectionSetup;
                    ToolTip = 'Specifies the Peppol Endpoint. You can get this from your ForNAV partner.';

                    trigger OnValidate()
                    begin
                        PeppolOauth.ValidateEndpoint(PeppolEndpoint, true);
                    end;
                }
                field(ForNAVTenantId; ForNAVTenantId)
                {
                    Caption = 'ForNAV Tenant Id', Locked = true;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Oauth Tenant Id. You can get this from your ForNAV partner.';
                    Visible = ShowConnectionSetup;
                    Editable = ShowConnectionSetup;

                    trigger OnValidate()
                    begin
                        PeppolOauth.ValidateForNAVTenantID(ForNAVTenantId);
                    end;
                }
                field(ClientSecret; ClientSecret)
                {
                    Caption = 'Client Secret', Locked = true;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Oauth Client Secret. You can get this from your ForNAV partner.';
                    ExtendedDatatype = Masked;
                    Visible = ShowConnectionSetup;
                    Editable = ShowConnectionSetup;

                    trigger OnValidate()
                    begin
                        PeppolOauth.ValidateSecret(ClientSecret);
                    end;
                }
                field(Scope; Scope)
                {
                    Caption = 'Scope', Locked = true;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Oauth Scope. You can get this from your ForNAV partner.';
                    ExtendedDatatype = Masked;
                    Visible = ShowConnectionSetup;
                    Editable = ShowConnectionSetup;

                    trigger OnValidate()
                    begin
                        PeppolOauth.ValidateScope(Scope);
                    end;
                }
                field(SecretValidFrom; SecretValidFrom)
                {
                    Caption = 'Secret Valid From', Locked = true;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Oauth Secret Valid From. The secret will renew automatically, if a secret is expired please contact your ForNAV partner.';
                    Editable = false;
                    Visible = ShowConnectionSetup;
                }
                field(SecretValidTo; SecretValidTo)
                {
                    Caption = 'Secret Expiration', Locked = true;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Oauth Secret Expiration. The secret will renew automatically, if a secret is expired please contact your ForNAV partner.';
                    Visible = ShowConnectionSetup;
                    Editable = false;
                    trigger OnValidate()
                    begin
                        PeppolOauth.ValidateSecretValidTo(SecretValidTo);
                    end;
                }

            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(PromoteAuthorize; Authorize)
            {
            }
            actionref(PromotePublish; Publish)
            {
            }
        }
        area(Processing)
        {
            action(Authorize)
            {
                ApplicationArea = All;
                Enabled = not Rec.Authorized;
                Caption = 'Authorize', Locked = true;
                Image = ApprovalSetup;
                ToolTip = 'Authorize the company to use the ForNAV Peppol endpoints.';
                trigger OnAction()
                var
                    SMP: Codeunit "ForNAV Peppol SMP";
                begin
                    Page.RunModal(Page::"ForNAV Peppol Setup Wizard", Rec);
                    Rec.InitSetup();
                    if Rec.Authorized then begin
                        SMP.ParticipantExists(Rec);
                        ShowNotification();
                    end;

                    SetGlobals();
                    CurrPage.Update();
                end;
            }
            action(Publish)
            {
                ApplicationArea = All;
                Enabled = Rec.Authorized and (Rec.Status = Rec.Status::"Not published");
                Caption = 'Publish', Locked = true;
                Image = Approve;
                ToolTip = 'Publish the company to the ForNAV Peppol SMP.';
                trigger OnAction()
                var
                    SMP: Codeunit "ForNAV Peppol SMP";
                begin
                    if not Rec.TermsAccepted and Rec.PublishMsg.HasValue then
                        if not Confirm(Rec.GetPublishMsg(), true) then
                            exit;

                    Rec.TermsAccepted := true;
                    SMP.CreateParticipant(Rec);
                    if (Rec.Status = Rec.Status::Published) and Rec.IsTest() then
                        CreateTestSetup();
                end;
            }
            action(CompanyInformationFld)
            {
                Enabled = Rec.Status <> Rec.Status::Published;
                ApplicationArea = All;
                Image = CompanyInformation;
                Caption = 'Edit Company Information', Locked = true;
                ToolTip = 'Edit company information', Locked = true;
                trigger OnAction()
                begin
                    if Page.RunModal(Page::"Company Information") = Action::LookupOK then begin
                        Rec.UpdateFromCompanyInformation();
                        Rec.Modify();
                        Update();
                    end;
                end;
            }
            action(TestConnection)
            {
                Caption = 'Test Connection';
                Visible = ShowConnectionSetup;
                ApplicationArea = All;
                Image = TestDatabase;
                ToolTip = 'Test the connection to the ForNAV Peppol endpoints.';
                trigger OnAction()
                var
                    ConnectionFailedErr: Label 'Connection failed', Locked = true;
                    ConnectionOkMsg: Label 'Connection succeeded', Locked = true;
                begin
                    if not PeppolOauth.TestOAuth() then
                        Error(ConnectionFailedErr);

                    Rec.Authorized := true;
                    Message(ConnectionOkMsg);
                end;
            }
            action(RotateSecret)
            {
                Caption = 'Rotate Client Secret';
                Visible = ShowConnectionSetup;
                ApplicationArea = All;
                Image = RedoFluent;
                ToolTip = 'Gets a new client secret and deletes the old one. May take a long time to run.';
                trigger OnAction()
                var
                    SureQst: Label 'Are you sure you want to rotate the client secret? This process may run a long time and will delete the old secret.', Locked = true;
                    CannotRotateErr: Label 'Cannot rotate secret if it is less than one week old.', Locked = true;
                begin
                    if PeppolOauth.GetSecretValidFrom() > CreateDateTime(CalcDate('<-1w>', Today), Time) then
                        Error(CannotRotateErr);

                    if not Confirm(SureQst) then
                        exit;

                    Rec.RotateClientSecret();
                    CurrPage.Update();
                end;
            }
            action(ServiceSetup)
            {
                ApplicationArea = All;
                Image = ServiceSetup;
                Caption = 'Service Setup', Locked = true;
                RunPageView = where(Code = const('FORNAV'));
                RunObject = page "E-Document Service";
                ToolTip = 'Setup the E-Document service for the company.';
            }
            action(OrderLicense)
            {
                ApplicationArea = All;
                Visible = Rec.Status = Rec.Status::Unlicensed;
                Image = MakeOrder;
                Caption = 'Order License', Locked = true;
                ToolTip = 'Send mail to order a license from ForNAV';
                trigger OnAction()
                begin
                    SendEmail();
                end;
            }
            action(Roles)
            {
                ApplicationArea = All;
                Visible = Rec.Authorized;
                Image = Permission;
                Caption = 'Roles', Locked = true;
                ToolTip = 'Setup the roles for the ForNAV Peppol setup.';
                RunObject = page "ForNAV Peppol Roles";
            }
            Action(RecreateJobQueue)
            {
                ApplicationArea = All;
                Visible = Rec.Authorized;
                Image = Task;
                Caption = 'Recreate Job Queue', Locked = true;
                ToolTip = 'Recreate the job queue for the ForNAV Peppol setup.';
                trigger OnAction()
                var
                    PeppolJobQueue: Codeunit "ForNAV Peppol Job Queue";
                begin
                    PeppolJobQueue.SetupJobQueue();
                end;
            }
            action(Unpublish)
            {
                ApplicationArea = All;
                Enabled = (Rec.Status = Rec.Status::Published) or (Rec.Status = Rec.Status::"Published in another company or installation");
                Caption = 'Unpublish', Locked = true;
                Image = Undo;
                ToolTip = 'Unpublish the company from the ForNAV Peppol SMP.';
                trigger OnAction()
                var
                    SMP: Codeunit "ForNAV Peppol SMP";
                begin
                    SMP.DeleteParticipant(Rec);
                end;
            }
            action(Unauthorize)
            {
                Caption = 'Unauthorize';
                Visible = EnableUnauthorize;
                ApplicationArea = All;
                Image = Delete;
                ToolTip = 'Unauthorize the company to use the ForNAV Peppol endpoints.';
                trigger OnAction()
                var
                    SureQst: Label 'Are you sure you want to reset the setup request? You will need to redo the authorization setup. Too many setup requests may result in blocked service.', Locked = true;
                begin
                    if not Confirm(SureQst) then
                        exit;

                    Rec.ResetForSetup();
                    SetGlobals();
                    CurrPage.Update();
                end;
            }
        }
    }
    var
        Setup: Codeunit "ForNAV Peppol Setup";
        PeppolOauth: Codeunit "ForNAV Peppol Oauth";
        ClientId: Text;
        PeppolEndpoint: Text;
        ForNAVTenantId: Text;
        ClientSecret: Text;
        Scope: Text;
        SecretValidFrom: DateTime;
        SecretValidTo: DateTime;
        ShowConnectionSetup: Boolean;
        EnableUnauthorize: Boolean;
        AuthorizeLbl: Label 'Please Authorize', Locked = true;

    trigger OnInit()
    begin
        Setup.Init(Rec);
    end;

    trigger OnClosePage()
    begin
        Setup.Close();
    end;

    trigger OnOpenPage()
    var
    begin
        ShowNotification();
        SetGlobals();
    end;

    local procedure ShowNotification()
    var
        Notification: Notification;
        Info: ModuleInfo;
    begin
        if Rec.SetupNotification.HasValue and not NavApp.GetModuleInfo('9a217e38-6091-4d50-9169-672a2896b5d4', Info) then begin// Peppol app
            Notification.Message := Rec.GetSetupNotification();
            Notification.Scope := NotificationScope::LocalScope;
            Notification.AddAction('Link', Codeunit::"ForNAV Peppol Setup", 'NotificationLink');
            Notification.Send();
        end;
    end;

    procedure SendEmail()
    var
        TempEmailItem: Record "Email Item" temporary;
        CompanyInformation: Record "Company Information";
        Country: Record "Country/Region";
        TempBlob: Codeunit "Temp Blob";
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        BodyText: BigText;
        OutStr: OutStream;
        InStr: InStream;
        CRLF: Text;
        BodyTextLbl: Label 'Please order a license for %1 %2', Locked = true;
        Attachment: JsonObject;
    begin
        CompanyInformation.Get();
        if not Country.Get(CompanyInformation.GetCompanyCountryRegionCode()) then
            Country.Name := CompanyInformation.GetCompanyCountryRegionCode();
        TempEmailItem."Send to" := '';
        TempEmailItem.Subject := 'ForNAV License for ' + CompanyName;
        TempEmailItem."Plaintext Formatted" := true;

        CRLF := '</br></br>';
        BodyText.AddText('Hi' + CRLF);

        if EnvironmentInformation.IsSaaSInfrastructure() then
            BodyText.AddText(StrSubstNo(BodyTextLbl, 'AadTenantId', AzureADTenant.GetAadTenantId()) + CRLF)
        else
            BodyText.AddText(StrSubstNo(BodyTextLbl, 'SerialNumber', Database.SerialNumber) + CRLF);

        BodyText.AddText('Participant ID ' + Rec.PeppolId() + CRLF);
        BodyText.AddText(CompanyInformation.Name + CRLF);
        BodyText.AddText(CompanyInformation.Address + CRLF);
        BodyText.AddText(CompanyInformation."Post Code" + ' ' + CompanyInformation.City + CRLF);
        BodyText.AddText(Country.Name + CRLF);
        BodyText.AddText(CompanyInformation.GetVATRegistrationNumber() + CRLF);

        TempEmailItem.SetBodyText(Format(BodyText));

        Attachment.Add('BusinessEntity', Rec.CreateBusinessEntity());
        Attachment.Add('License', Setup.GetJLicense());
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        Attachment.WriteTo(OutStr);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        TempEmailItem.AddAttachment(InStr, 'license.json');

        TempEmailItem.Send(false, "Email Scenario"::Default);
    end;

    local procedure SetGlobals()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        ShowConnectionSetup := not EnvironmentInformation.IsSaaSInfrastructure();
        EnableUnauthorize := Rec.Authorized or (Rec."Oauth Setup Request Sent" <> 0D);
        ClientId := PeppolOauth.GetClientID();
        PeppolEndpoint := PeppolOauth.GetEndpoint();
        ForNAVTenantId := PeppolOauth.GetForNAVTenantID();
        ClientSecret := GetSecret();
        Scope := GetSecret();
        SecretValidFrom := PeppolOauth.GetSecretValidFrom();
        SecretValidTo := PeppolOauth.GetSecretValidTo();
    end;

    local procedure GetSecret(): Text
    begin
        if Rec.Authorized then
            exit('********');
    end;

    [BusinessEvent(false)]
    procedure CreateTestSetup()
    begin

    end;
}
