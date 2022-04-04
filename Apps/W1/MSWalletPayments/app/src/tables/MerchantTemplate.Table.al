table 1081 "MS - Wallet Merchant Template"
{
#if not CLEAN20
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';
    DrillDownPageID = 1081;
    LookupPageID = 1081;
#else
    ObsoleteState = Removed;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '23.0';
#endif 
    Caption = 'Microsoft Pay Payments Account Template';
    ReplicateData = false;

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
        field(12; "Payment Request URL"; BLOB)
        {
            Caption = 'Service URL';
        }
        field(13; "Payment Request URL Modified"; DateTime)
        {
            Caption = 'Service URL Modified';
        }
        field(17; "Accept Terms of Service"; Boolean)
        {
        }
        field(18; "Accept Terms of Service date"; DateTime)
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

    procedure GetPaymentRequestURL(): Text;
    var
        InStream: InStream;
        PaymentRequestURL: Text;
    begin
        PaymentRequestURL := '';
        CALCFIELDS("Payment Request URL");
        IF "Payment Request URL".HASVALUE() THEN BEGIN
            "Payment Request URL".CREATEINSTREAM(InStream);
            InStream.READ(PaymentRequestURL);
        END;
        EXIT(PaymentRequestURL);
    end;

    procedure SetPaymentRequestURL(PaymentRequestURL: Text);
    var
        OutStream: OutStream;
    begin
        "Payment Request URL Modified" := CurrentDateTime();
        "Payment Request URL".CREATEOUTSTREAM(OutStream);
        OutStream.WRITE(PaymentRequestURL);
        MODIFY();
    end;

    procedure RefreshLogoIfNeeded();
    begin
        CALCFIELDS(Logo);
    end;

    procedure UpdateLogo(): Boolean;
    var
        MediaResources: Record "Media Resources";
        DummyPaymentReportingArgument: Record "Payment Reporting Argument";
    begin
        IF NOT MediaResources.GET(DummyPaymentReportingArgument.GetMSWalletLogoFile()) THEN
            EXIT(FALSE);
        MediaResources.CALCFIELDS(Blob);
        VALIDATE(Logo, MediaResources.Blob);
        MODIFY(TRUE);
        EXIT(TRUE);
    end;
}
