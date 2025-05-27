namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using System.Environment;
using Microsoft.Foundation.Company;
using System.Globalization;
using Microsoft.Foundation.Address;
using System.EMail;
using Microsoft.eServices.EDocument;
using Microsoft.Foundation.Reporting;
using System.Automation;

table 6414 "ForNAV Peppol Setup"
{
    DataClassification = CustomerContent;
    Caption = 'ForNAV Peppol Setup', Locked = true;
    Permissions = tabledata "ForNAV Peppol Role" = RIMD;
    fields
    {
        field(1; PK; Guid)
        {
            Caption = 'PK', Locked = true;
            DataClassification = SystemMetadata;
            Access = Internal;
        }

        field(2; Name; Text[100])
        {
            Caption = 'Name', Locked = true;
            NotBlank = true;
            Editable = false;
            DataClassification = CustomerContent;
            Access = Internal;
        }
        field(7; "Phone No."; Text[30])
        {
            Caption = 'Phone No.', Locked = true;
            ExtendedDatatype = PhoneNo;
            Editable = false;
            DataClassification = CustomerContent;
            Access = Internal;
        }
        field(8; TermsAccepted; Boolean)
        {
            Caption = 'Terms accepted', Locked = true;
            DataClassification = EndUserPseudonymousIdentifiers;
            Access = Internal;
        }
        field(9; Authorized; Boolean)
        {
            Caption = 'Authenticated', Locked = true;
            DataClassification = EndUserPseudonymousIdentifiers;
            Access = Internal;
        }
        field(10; "Client Id"; Text[100])
        {
            Caption = 'Client Id', Locked = true;
            DataClassification = EndUserPseudonymousIdentifiers;
            Access = Internal;

            trigger OnValidate()
            var
                PeppolOauth: Codeunit "ForNAV Peppol Oauth";
            begin
                if not IsTemporary() then
                    PeppolOauth.ValidateClientID("Client Id");
            end;
        }
        field(17; "Oauth Setup Request Sent"; Date)
        {
            Caption = 'Oauth Setup Request Sent', Locked = true;
            DataClassification = SystemMetadata;
            Access = Internal;
        }
        field(34; "E-Mail"; Text[80])
        {
            Caption = 'Email', Locked = true;
            ExtendedDatatype = EMail;
            NotBlank = true;
            Editable = false;
            DataClassification = CustomerContent;
            Access = Internal;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
#pragma warning disable AA0139
                MailManagement.ValidateEmailAddressField("E-Mail");
#pragma warning restore AA0139
            end;
        }
        field(35; "Home Page"; Text[255])
        {
            Caption = 'Home Page', Locked = true;
            ExtendedDatatype = URL;
            NotBlank = true;
            Editable = false;
            DataClassification = CustomerContent;
            Access = Internal;
        }
        field(36; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code', Locked = true;
            TableRelation = "Country/Region";
            NotBlank = true;
            Editable = false;
            DataClassification = CustomerContent;
            Access = Internal;
        }

        field(50; "Add contact information"; Boolean)
        {
            Caption = 'Add contact information to business card', Locked = true;
            DataClassification = CustomerContent;
            Access = Internal;
        }

        field(51; "Contact Person"; Text[50])
        {
            Caption = 'Contact Person', Locked = true;
            NotBlank = true;
            Editable = false;
            DataClassification = CustomerContent;
            Access = Internal;
        }
        field(102; Status; Option)
        {
            OptionMembers = "Not published","Published","Published in another company or installation",Offline,Unlicensed,"Published by another AP","Waiting for approval","Published by ForNAV using another AAD tenant";
            OptionCaption = 'Not Published,Published,Published in another company or installation,Offline,Unlicensed,Published by another access point,Waiting for approval by ForNAV,Published by ForNAV using another AAD tenant', Locked = true;
            DataClassification = CustomerContent;
            Access = Internal;
        }
        field(103; "Demo Company"; Boolean)
        {
            Caption = 'Demo Company', Locked = true;
            DataClassification = SystemMetadata;
            Access = Internal;
        }
        field(999; Test; Boolean)
        {
            Caption = 'Test', Locked = true;
            DataClassification = CustomerContent;
            Access = Internal;
        }
        field(1000; "Identification Code"; Code[10])
        {
            Caption = 'Identification Code', Locked = true;
            DataClassification = CustomerContent;
            NotBlank = true;
            Editable = false;
            Access = Internal;
        }
        field(1001; "Identification Value"; Text[50])
        {
            Caption = 'Identification Value', Locked = true;
            DataClassification = CustomerContent;
            NotBlank = true;
            Editable = false;
            Access = Internal;
        }

        field(1003; Address; Text[500])
        {
            Caption = 'Address', Locked = true;
            DataClassification = CustomerContent;
            NotBlank = true;
            Editable = false;
            Access = Internal;
        }

        field(1004; "Language"; Text[2])
        {
            Caption = 'Language', Locked = true;
            DataClassification = CustomerContent;
            NotBlank = true;
            Editable = false;
            Access = Internal;
            trigger OnValidate()
            begin
                Language := Language.ToLower();
            end;
        }
        field(1100; PublishMsg; Blob)
        {
            Caption = 'Address', Locked = true;
            DataClassification = CustomerContent;
            Access = Internal;
        }

        field(1101; SetupNotification; Blob)
        {
            Caption = 'Address', Locked = true;
            DataClassification = CustomerContent;
            Access = Internal;
        }
        field(1102; SetupNotificationUrl; Text[50])
        {
            Caption = 'SetupNotificationUrl', Locked = true;
            DataClassification = CustomerContent;
            Access = Internal;
        }
    }

    keys
    {
        key(PK; PK)
        {
            Clustered = true;
        }
    }

    var
        CannotGetSetupErr: Label 'Cannot get setup from Peppol API. Contact your ForNAV partner.', Locked = true;

    internal procedure SetValues(Values: JsonObject)
    var
        ValueText: BigText;
        ValueKey: Text;
        ValueToken: JsonToken;
        OutStr: OutStream;
    begin
        foreach ValueKey in Values.Keys do begin
            Values.Get(ValueKey, ValueToken);
            Clear(ValueText);
            ValueText.AddText(ValueToken.AsValue().AsText());
            case ValueKey of
                'publishmsg':
                    begin
                        PublishMsg.CreateOutStream(OutStr, TextEncoding::UTF8);
                        ValueText.Write(OutStr);
                    end;
                'setupnotification':
                    begin
                        SetupNotification.CreateOutStream(OutStr, TextEncoding::UTF8);
                        ValueText.Write(OutStr);
                    end;
                'setupnotificationurl':
                    SetupNotificationUrl := CopyStr(ValueToken.AsValue().AsText(), 1, MaxStrLen((SetupNotificationUrl)));
            end;
        end;
    end;

    internal procedure GetSetupNotification(): Text;
    var
        ValueText: BigText;
        InStr: InStream;
    begin
        if SetupNotification.HasValue then begin
            Rec.CalcFields(SetupNotification);
            SetupNotification.CreateInStream(InStr, TextEncoding::UTF8);
            ValueText.Read(InStr);
        end;
        exit(Format(ValueText));
    end;

    internal procedure GetPublishMsg(): Text;
    var
        ValueText: BigText;
        InStr: InStream;
    begin
        if PublishMsg.HasValue then begin
            Rec.CalcFields(PublishMsg);
            PublishMsg.CreateInStream(InStr, TextEncoding::UTF8);
            ValueText.Read(InStr);
        end;
        exit(Format(ValueText));
    end;

    internal procedure SetupOauth()
    var
        Setup: Codeunit "ForNAV Peppol Setup";
        PeppolOauth: Codeunit "ForNAV Peppol Oauth";
        EnvironmentInformation: Codeunit "Environment Information";
        IsSaaS: Boolean;
    begin
        Setup.ClearAccessToken();
        if PeppolOauth.GetClientID() <> '' then
            if PeppolOauth.TestOAuth() then begin
                Authorized := true;
                Modify();
                exit;
            end;

        ResetForSetup();
        PeppolOauth.SetSetupKey();
        IsSaaS := EnvironmentInformation.IsSaaS();

        Commit();

        if not PeppolOauth.SendSetupRequest(IsSaas) then
            Error(CannotGetSetupErr);

        SelectLatestVersion();
        FindFirst();
        "Oauth Setup Request Sent" := Today();
        Modify();

        if IsSaaS then
            ValidateConnection();
    end;

    internal procedure ProcessStoredOauthRequest(PassCode: SecretText)
    var
        PeppolOauth: Codeunit "ForNAV Peppol Oauth";
    begin
        if not PeppolOauth.GetSetupFile(PassCode, "Identification Value") then
            Error(CannotGetSetupErr);

        ValidateConnection();
    end;

    internal procedure RotateClientSecret()
    var
        PeppolOauth: Codeunit "ForNAV Peppol Oauth";
    begin
        if PeppolOauth.GetSecretValidFrom() > CreateDateTime(CalcDate('<-1w>', Today), Time) then
            exit;

        PeppolOauth.GetNewSecurityKey();
        ValidateConnection();
    end;

    local procedure ValidateConnection()
    var
        PeppolOauth: Codeunit "ForNAV Peppol Oauth";
    begin
        if PeppolOauth.TestOAuth() then begin
            Authorized := true;
            PeppolOauth.ResetSetupKey();
        end else
            Authorized := false;

        Modify();
    end;

    internal procedure ResetForSetup()
    var
        PeppolOauth: Codeunit "ForNAV Peppol Oauth";
    begin
        PeppolOauth.ResetForSetup();
        Clear("Oauth Setup Request Sent");
        Authorized := false;
        Modify();
    end;

    internal procedure UpdateFromCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
        WindowsLanguage: Record "Windows Language";
        Country: Record "Country/Region";
        Addr: Text;
    begin
        CompanyInformation.Get();
        if CompanyInformation."Use GLN in Electronic Document" then begin
            "Identification Code" := '0088';
            "Identification Value" := CompanyInformation.GLN;
        end else begin
            if Country.Get(CompanyInformation.GetCompanyCountryRegionCode()) then;
            "Identification Code" := Country."VAT Scheme";
            "Identification Value" := CompanyInformation."VAT Registration No.";
        end;

        "Identification Value" := CompanyInformation."VAT Registration No.";

        Name := CompanyInformation.Name;
        "Phone No." := CompanyInformation."Phone No.";
        "E-mail" := CompanyInformation."E-Mail";
#pragma warning disable AL0432
        "Home Page" := CopyStr(CompanyInformation."Home Page", 1, MaxStrLen("Home Page"));
#pragma warning restore AL0432
        "Country/Region Code" := CompanyInformation."Country/Region Code";
        "Contact Person" := CompanyInformation."Contact Person";

        Addr := CompanyInformation.Address;
        if CompanyInformation."Address 2" <> '' then
            Addr += ', ' + CompanyInformation."Address 2";
        if CompanyInformation.County <> '' then
            Addr += ', ' + CompanyInformation.County;
        Addr += ', ' + CompanyInformation."Post Code" + ' ' + CompanyInformation.City;
        Address := CopyStr(Addr, 1, MaxStrLen(Address));
        WindowsLanguage.Get(System.WindowsLanguage);
        Rec.Language := WindowsLanguage."Language Tag".Substring(1, 2);
    end;

    internal procedure InitSetup()
    var
        CompanyInformation: Record "Company Information";
    begin
        if not FindFirst() then begin
            SetupDocumentSendingProfile();
            UpdateFromCompanyInformation();
            Rec.PK := CreateGuid();
            CompanyInformation.Get();
            Rec."Demo Company" := CompanyInformation."Demo Company";
            Rec.Test := Rec."Demo Company";
            Rec.Insert();
        end;
    end;

    local procedure SetupDocumentSendingProfile()
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        EDocumentService: Record "E-Document Service";
        EDocServiceSupportedType: Record "E-Doc. Service Supported Type";
        Workflow: Record Workflow;
        WorkflowStep: Record "Workflow Step";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        if EDocumentService.Get('FORNAV') then
            exit;

        EDocumentService.Code := 'FORNAV';
        EDocumentService.Description := 'ForNAV Service';
        EDocumentService."Service Integration V2" := EDocumentService.ForNAVServiceIntegration();
        EDocumentService."Document Format" := "E-Document Format"::"PEPPOL BIS 3.0";
        EDocumentService."Use Batch Processing" := false;
        EDocumentService.Insert();

        EDocServiceSupportedType.SetRange(EDocServiceSupportedType."E-Document Service Code", 'FORNAV');
        EDocServiceSupportedType.DeleteAll();
        EDocServiceSupportedType."E-Document Service Code" := 'FORNAV';
        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Invoice";
        EDocServiceSupportedType.Insert();
        EDocServiceSupportedType."Source Document Type" := EDocServiceSupportedType."Source Document Type"::"Sales Credit Memo";
        EDocServiceSupportedType.Insert();

        if DocumentSendingProfile.Get('FORNAV') then
            exit;
        DocumentSendingProfile.Code := 'FORNAV';
        DocumentSendingProfile.Description := 'ForNAV eDocument';
        DocumentSendingProfile."Electronic Format" := 'PEPPOL BIS3';
        DocumentSendingProfile."Electronic Document" := "Doc. Sending Profile Elec.Doc."::"Extended E-Document Service Flow";
        DocumentSendingProfile."Electronic Service Flow" := 'ForNAV';
        DocumentSendingProfile.Default := true;
        DocumentSendingProfile.Insert();

        IF Workflow.Get('FORNAV') then
            Workflow.Delete();
        Workflow.Code := 'FORNAV';
        Workflow.Description := 'ForNAV eDocument workflow';
        Workflow.Category := 'EDOC';
        Workflow.Enabled := true;
        Workflow.Insert();

        WorkflowStep.SetRange("Workflow Code", 'FORNAV');
        WorkflowStep.DeleteAll();
        WorkflowStep.Init();
        WorkflowStep."Sequence No." := 1;
        WorkflowStep."Workflow Code" := 'FORNAV';
        WorkflowStep.Type := WorkflowStep.Type::"Event";
        WorkflowStep."Function Name" := 'EDOCCREATEDEVENT';
        WorkflowStep."Entry Point" := true;
        WorkflowStep.Insert();

        WorkflowStep."Previous Workflow Step ID" := WorkflowStep.ID;
        WorkflowStep.ID += 1;
        WorkflowStep."Sequence No." := 0;
        WorkflowStep."Workflow Code" := 'FORNAV';
        WorkflowStep.Type := WorkflowStep.Type::"Response";
        WorkflowStep."Function Name" := 'EDOCSENDEDOCRESPONSE';
        WorkflowStep."Entry Point" := false;

        WorkflowStepArgument.SetRange("Response Function Name", 'EDOCSENDEDOCRESPONSE');
        WorkflowStepArgument.SetRange("E-Document Service", 'FORNAV');
        WorkflowStepArgument.DeleteAll();

        WorkflowStepArgument.Init();
        WorkflowStepArgument."Table No." := Database::"E-Document";
        WorkflowStepArgument."Response Function Name" := 'EDOCSENDEDOCRESPONSE';
        WorkflowStepArgument."E-Document Service" := 'FORNAV';
        WorkflowStepArgument.ID := CreateGuid();
        WorkflowStepArgument.Insert();

        WorkflowStep.Argument := WorkflowStepArgument.ID;
        WorkflowStep.Insert();
    end;

    internal procedure PeppolId(): Text
    begin
        exit(Rec."Identification Code" + ':' + Rec."Identification Value");
    end;

    internal procedure IsTest(): Boolean
    begin
        exit(Test);
    end;

    internal procedure CreateBusinessEntity() BusinessEntity: JsonObject;
    begin
        BusinessEntity.Add('ParticipantIdentifier', PeppolId());
        BusinessEntity.Add('Name', Name);
        BusinessEntity.Add('CountryCode', "Country/Region Code");
        BusinessEntity.Add('GeographicalInformation', Address);
    end;

    procedure IsAuthorized(): Boolean
    begin
        exit(Rec.Authorized);
    end;

    internal procedure ID(): Text
    begin
        exit(Format(Rec.PK).TrimStart('{').TrimEnd('}'));
    end;

}