table 1361 "MS - WorldPay Std. Template"
{
    Caption = 'WorldPay Payments Standard Account Template';
    DrillDownPageID = 1361;
    LookupPageID = 1361;
    ReplicateData = false;

    fields
    {
        field(1; "Code"; Code[10]) { }
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
        field(14; "Logo Last Update DateTime"; DateTime) { }
        field(15; "Logo Update Frequency"; Duration) { }
    }

    keys
    {
        key(Key1; "Code") { }
    }

    fieldgroups
    {
        fieldgroup(Description; Description) { }
    }

    var
        UpdatingWorldPayLogoFailedTxt: Label 'Cannot update the WorldPay logo.';
        WorldPayContextTxt: Label 'WorldPay Standard';

    procedure GetTargetURL(): Text
    var
        InStream: InStream;
        TargetURL: Text;
    begin
        TargetURL := '';
        CALCFIELDS("Target URL");
        IF "Target URL".HASVALUE() THEN BEGIN
            "Target URL".CREATEINSTREAM(InStream);
            InStream.READ(TargetURL);
        END;
        EXIT(TargetURL);
    end;

    procedure SetTargetURL(TargetURL: Text)
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        OutStream: OutStream;
    begin
        WebRequestHelper.IsValidUri(TargetURL);
        WebRequestHelper.IsHttpUrl(TargetURL);
        WebRequestHelper.IsSecureHttpUrl(TargetURL);

        "Target URL".CREATEOUTSTREAM(OutStream);
        OutStream.WRITE(TargetURL);
        MODIFY();
    end;

    procedure GetLogoURL(): Text
    var
        InStream: InStream;
        LogoURL: Text;
    begin
        LogoURL := '';
        CALCFIELDS("Logo URL");
        IF "Logo URL".HASVALUE() THEN BEGIN
            "Logo URL".CREATEINSTREAM(InStream);
            InStream.READ(LogoURL);
        END;
        EXIT(LogoURL);
    end;

    procedure SetLogoURL(LogoURL: Text)
    var
        WebRequestHelper: Codeunit "Web Request Helper";
        OutStream: OutStream;
    begin
        WebRequestHelper.IsValidUri(LogoURL);
        WebRequestHelper.IsHttpUrl(LogoURL);
        WebRequestHelper.IsSecureHttpUrl(LogoURL);

        "Logo URL".CREATEOUTSTREAM(OutStream);
        OutStream.WRITE(LogoURL);
        MODIFY();
    end;

    procedure RefreshLogoIfNeeded()
    begin
        IF ("Logo Last Update DateTime" <= (CURRENTDATETIME() - "Logo Update Frequency")) AND ("Logo Update Frequency" <> 0) THEN
            IF UpdateLogoFromURL(GetLogoURL()) THEN
                EXIT;

        CALCFIELDS(Logo);
    end;

    procedure UpdateLogoFromURL(LogoURL: Text): Boolean
    var
        ActivityLog: Record "Activity Log";
    begin
        IF LogoURL = '' THEN
            EXIT(FALSE);

        IF NOT DownloadLogo(LogoURL) THEN BEGIN
            ActivityLog.LogActivity(Rec, ActivityLog.Status::Failed, WorldPayContextTxt, UpdatingWorldPayLogoFailedTxt, GETLASTERRORTEXT());
            EXIT(FALSE);
        END;
        "Logo Last Update DateTime" := CURRENTDATETIME();
        MODIFY(TRUE);
        EXIT(TRUE);
    end;

    local procedure DownloadLogo(LogoURL: Text): Boolean
    var
        TempBlob: Codeunit "Temp Blob";
        LogoHttpClient: HttpClient;
        ResponseHttpResponseMessage: HttpResponseMessage;
        ResponseInStream: InStream;
        LogoOutStream: OutStream;
    begin
        if not LogoHttpClient.Get(LogoURL, ResponseHttpResponseMessage) then
            exit(FALSE);
        if not ResponseHttpResponseMessage.IsSuccessStatusCode() then
            exit(FALSE);

        TempBlob.CreateInStream(ResponseInStream);

        ResponseHttpResponseMessage.Content().ReadAs(ResponseInStream);
        Logo.CREATEOUTSTREAM(LogoOutStream);
        exit(COPYSTREAM(LogoOutStream, ResponseInStream));
    end;
}

