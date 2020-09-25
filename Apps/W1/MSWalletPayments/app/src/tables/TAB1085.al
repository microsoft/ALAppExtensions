table 1085 "MS - Wallet Payment"
{
    ReplicateData = false;

    fields
    {
        field(1; "Invoice No"; Code[20])
        {
        }
        field(2; "Merchant ID"; Text[250])
        {
        }
        field(3; "Payment URL"; BLOB)
        {
        }
        field(4; "Payment URL Expiry"; DateTime)
        {
        }
    }

    keys
    {
        key(Key1; "Invoice No")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        InvalidPaymentURLErr: Label 'The payment URL is not valid.';

    procedure GetPaymentURL(): Text;
    var
        InStream: InStream;
        PaymentURL: Text;
    begin
        PaymentURL := '';
        CALCFIELDS("Payment URL");
        IF "Payment URL".HASVALUE() THEN BEGIN
            "Payment URL".CREATEINSTREAM(InStream);
            InStream.READ(PaymentURL);
        END;
        EXIT(PaymentURL);
    end;

    procedure SetPaymentURL(PaymentURL: Text);
    var
        MSWalletMgt: Codeunit 1080;
        OutStream: OutStream;
    begin
        if not MSWalletMgt.IsValidAndSecureURL(PaymentURL) then
            Error(InvalidPaymentURLErr);


        "Payment URL".CREATEOUTSTREAM(OutStream);
        OutStream.WRITE(PaymentURL);
        MODIFY();
    end;
}

