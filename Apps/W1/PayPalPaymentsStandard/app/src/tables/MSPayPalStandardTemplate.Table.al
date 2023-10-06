namespace Microsoft.Bank.PayPal;

using Microsoft.Utilities;
using System.Utilities;

table 1071 "MS - PayPal Standard Template"
{
    Caption = 'PayPal Payments Standard Account Template';
    DrillDownPageID = 1071;
    LookupPageID = 1071;
    ReplicateData = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
        }
        field(2; Name; Text[250])
        {
            NotBlank = true;
        }
        field(3; Description; Text[250])
        {
            NotBlank = true;
        }
        field(8; "Terms of Service"; Text[250])
        {
            ExtendedDatatype = URL;
        }
        field(11; Logo; BLOB)
        {
            SubType = Bitmap;
        }
        field(12; "Target URL"; BLOB)
        {
            Caption = 'Service URL';
        }
        field(13; "Logo URL"; BLOB)
        {
            SubType = Bitmap;
        }
        field(14; "Logo Last Update DateTime"; DateTime)
        {
        }
        field(15; "Logo Update Frequency"; Duration)
        {
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(Description; Description)
        {
        }
    }

    var
        UpdatingPayPalLogoFailedTxt: Label 'Updating PayPal logo failed.', Locked = true;
        PayPalContextTxt: Label 'PayPal Standard', Locked = true;
        InvalidTargetURLErr: Label 'The target URL is not valid.';
        PayPalTelemetryCategoryTok: Label 'AL Paypal', Locked = true;
        InvalidLogoURLErr: Label 'The logo URL is not valid.';
        LogoFailedResponseTxt: Label 'Error while getting the logo. Response status code %1.', Locked = true;
        LogoCannotReadResponseTxt: Label 'Cannot read response on getting logo.', Locked = true;

    procedure GetTargetURL(): Text;
    var
        InStream: InStream;
        TargetURL: Text;
    begin
        TargetURL := '';
        CALCFIELDS("Target URL");
        if "Target URL".HASVALUE() then begin
            "Target URL".CREATEINSTREAM(InStream);
            InStream.READ(TargetURL);
        end;
        exit(TargetURL);
    end;

    procedure SetTargetURL(TargetURL: Text);
    var
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
        OutStream: OutStream;
    begin
        if not MSPayPalStandardMgt.IsValidAndSecureURL(TargetURL) then
            Error(InvalidTargetURLErr);

        "Target URL".CREATEOUTSTREAM(OutStream);
        OutStream.WRITE(TargetURL);
        MODIFY();
    end;

    procedure SetTargetURLNoVerification(TargetURL: Text);
    var
        OutStream: OutStream;
    begin
        "Target URL".CREATEOUTSTREAM(OutStream);
        OutStream.WRITE(TargetURL);
        MODIFY();
    end;

    procedure GetLogoURL(): Text;
    var
        InStream: InStream;
        LogoURL: Text;
    begin
        LogoURL := '';
        CALCFIELDS("Logo URL");
        if "Logo URL".HASVALUE() then begin
            "Logo URL".CREATEINSTREAM(InStream);
            InStream.READ(LogoURL);
        end;
        exit(LogoURL);
    end;

    procedure SetLogoURL(LogoURL: Text);
    var
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
        OutStream: OutStream;
    begin
        if not MSPayPalStandardMgt.IsValidAndSecureURL(LogoURL) then
            Error(InvalidLogoURLErr);

        "Logo URL".CREATEOUTSTREAM(OutStream);
        OutStream.WRITE(LogoURL);
        MODIFY();
    end;

    procedure SetLogoURLNoVerification(LogoURL: Text);
    var
        OutStream: OutStream;
    begin
        "Logo URL".CREATEOUTSTREAM(OutStream);
        OutStream.WRITE(LogoURL);
        MODIFY();
    end;

    procedure RefreshLogoIfNeeded();
    begin
        if ("Logo Last Update DateTime" <= (CURRENTDATETIME() - "Logo Update Frequency")) and ("Logo Update Frequency" <> 0) then
            if UpdateLogoFromURL(GetLogoURL()) then
                exit;

        CALCFIELDS(Logo);
    end;

    procedure UpdateLogoFromURL(LogoURL: Text): Boolean;
    var
        ActivityLog: Record "Activity Log";
    begin
        if LogoURL = '' then
            exit(false);

        if not DownloadLogo(LogoURL) then begin
            ActivityLog.LogActivity(Rec, ActivityLog.Status::Failed, PayPalContextTxt, UpdatingPayPalLogoFailedTxt, GETLASTERRORTEXT());
            exit(false);
        end;
        "Logo Last Update DateTime" := CURRENTDATETIME();
        MODIFY(true);
        exit(true);
    end;

    local procedure DownloadLogo(LogoURL: Text): Boolean;
    var
        TempBlob: Codeunit "Temp Blob";
        LogoHttpClient: HttpClient;
        ResponseHttpResponseMessage: HttpResponseMessage;
        ResponseInStream: InStream;
        LogoOutStream: OutStream;
    begin
        if not LogoHttpClient.Get(LogoURL, ResponseHttpResponseMessage) then begin
            Session.LogMessage('00008II', StrSubstNo(LogoFailedResponseTxt, ResponseHttpResponseMessage.HttpStatusCode()), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            exit(false);
        end;
        if not ResponseHttpResponseMessage.IsSuccessStatusCode() then begin
            Session.LogMessage('00008IJ', StrSubstNo(LogoFailedResponseTxt, ResponseHttpResponseMessage.HttpStatusCode()), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            exit(false);
        end;

        TempBlob.CreateInStream(ResponseInStream);

        if not ResponseHttpResponseMessage.Content().ReadAs(ResponseInStream) then begin
            Session.LogMessage('00008IK', LogoCannotReadResponseTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            exit(false);
        end;
        Logo.CREATEOUTSTREAM(LogoOutStream);
        exit(COPYSTREAM(LogoOutStream, ResponseInStream));
    end;
}

