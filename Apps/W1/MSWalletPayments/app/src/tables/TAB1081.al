table 1081 "MS - Wallet Merchant Template"
{
    Caption = 'Microsoft Pay Payments Account Template';
    DrillDownPageID = 1081;
    LookupPageID = 1081;
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

    var
        InvalidPaymentRequestURLErr: Label 'The payment request URL is not valid.';

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
        MSWalletMgt: Codeunit 1080;
        OutStream: OutStream;
    begin
        if not MSWalletMgt.IsValidAndSecureURL(PaymentRequestURL) then
            Error(InvalidPaymentRequestURLErr);

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
        MediaResources: Record 2000000182;
        DummyPaymentReportingArgument: Record 1062;
    begin
        IF NOT MediaResources.GET(DummyPaymentReportingArgument.GetMSWalletLogoFile()) THEN
            EXIT(FALSE);
        MediaResources.CALCFIELDS(Blob);
        VALIDATE(Logo, MediaResources.Blob);
        MODIFY(TRUE);
        EXIT(TRUE);
    end;
}

