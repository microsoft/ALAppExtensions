namespace Microsoft.Finance.VAT.Reporting;

using System.Integration;
using System.Privacy;
using System.Security.Encryption;
using System.Telemetry;

table 13605 "Elec. VAT Decl. Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {

        }
        field(2; "Client Certificate Code"; Code[20])
        {
            TableRelation = "Isolated Certificate";

            trigger OnValidate()
            begin
                CheckCertHasPrivateKey(Rec."Client Certificate Code", true);
            end;
        }
        field(3; "Server Certificate Code"; Code[20])
        {
            TableRelation = "Isolated Certificate";

            trigger OnValidate()
            begin
                CheckCertHasPrivateKey(Rec."Server Certificate Code", false);
            end;
        }
        field(4; "Get Periods Enpdoint"; Text[250])
        {
            Caption = 'Get VAT Return Periods Enpdoint';

            trigger OnValidate()
            begin
                CheckUrl(Rec."Get Periods Enpdoint");
            end;
        }
        field(5; "Submit VAT Return Endpoint"; Text[250])
        {
            trigger OnValidate()
            begin
                CheckUrl(Rec."Submit VAT Return Endpoint");
            end;
        }
        field(6; "Check Status Endpoint"; Text[250])
        {
            Caption = 'Check VAT Return Status Endpoint';

            trigger OnValidate()
            begin
                CheckUrl(Rec."Check Status Endpoint");
            end;
        }
        field(7; "ERP See Number"; Text[250])
        {
            trigger OnValidate()
            begin
                EnsureConsent();
            end;
        }
        field(8; "Consent Given"; Boolean)
        {
            Editable = false;
        }
        field(9; "Consent User ID"; Text[250])
        {

        }
        field(10; "Use Azure Key Vault"; Boolean)
        {
            InitValue = true;
        }
    }
    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        ConsentNotGivenErr: Label 'You must agree to the terms and conditions before you can use the VAT Return Electronic Submission functionality.';
        FeatureNameTxt: Label 'Electronic VAT Declaration DK', Locked = true;

    internal procedure GetSeeNumber(): Text[250]
    begin
        Rec.Get();
        Rec.TestField(Rec."ERP See Number");
        exit(Rec."ERP See Number");
    end;

    internal procedure GetEndpointForType(RequestType: enum "Elec. VAT Decl. Request Type"): Text
    var
        ElecVATDeclAzKeyVault: Codeunit "Elec. VAT Decl. Az. Key Vault";
    begin
        Rec.Get();
        if Rec."Use Azure Key Vault" then
            exit(ElecVATDeclAzKeyVault.GetEndpointURLForRequestType(RequestType));

        case RequestType of
            RequestType::"Get VAT Return Periods":
                begin
                    TestField(Rec."Get Periods Enpdoint");
                    exit(Rec."Get Periods Enpdoint");
                end;
            RequestType::"Submit VAT Return":
                begin
                    TestField(Rec."Submit VAT Return Endpoint");
                    exit(Rec."Submit VAT Return Endpoint");
                end;
            RequestType::"Check VAT Return Status":
                begin
                    TestField(Rec."Check Status Endpoint");
                    exit(Rec."Check Status Endpoint");
                end;
        end;
    end;

    local procedure GetConsent(): Boolean
    var
        CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        Rec.Validate("Consent Given", CustomerConsentMgt.ConfirmUserConsent());
        if Rec."Consent Given" then begin
            Rec.Validate("Consent User ID", CopyStr(UserId(), 1, 250));
            FeatureTelemetry.LogUptake('0000LRD', FeatureNameTxt, "Feature Uptake Status"::"Set up");
        end;
        Rec.Modify();
        exit(Rec."Consent Given");
    end;

    local procedure EnsureConsent()
    begin
        if Rec."Consent Given" then
            exit;
        if not GetConsent() then
            Error(ConsentNotGivenErr);
    end;

    local procedure CheckUrl(Url: Text[250])
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
    begin
        HttpWebRequestMgt.CheckUrl(Url);
    end;

    local procedure CheckCertHasPrivateKey(CertificateCode: Code[20]; ExpectedValue: Boolean)
    var
        IsolatedCertificate: Record "Isolated Certificate";
    begin
        IsolatedCertificate.Get(CertificateCode);
        IsolatedCertificate.TestField("Has Private Key", ExpectedValue);
    end;
}