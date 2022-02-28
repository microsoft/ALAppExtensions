table 1080 "MS - Wallet Merchant Account"
{
#if not CLEAN20
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';
    DrillDownPageID = 1080;
    LookupPageID = 1080;
#else
    ObsoleteState = Removed;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '23.0';
#endif
    Caption = 'Microsoft Pay Payments Account';
    Permissions = TableData "Webhook Subscription" = rimd;
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; Name; Text[250])
        {
            NotBlank = true;
        }
        field(3; Description; Text[250])
        {
            NotBlank = true;
        }
        field(4; Enabled; Boolean)
        {

            trigger OnValidate();
            begin
                VerifyAccountID();
            end;
        }
        field(5; "Always Include on Documents"; Boolean)
        {

            trigger OnValidate();
            var
#if not CLEAN20
                MSWalletMerchantAccount: Record "MS - Wallet Merchant Account";
#endif
                SalesHeader: Record "Sales Header";
            begin
                IF NOT "Always Include on Documents" THEN
                    EXIT;
#if not CLEAN20
                MSWalletMerchantAccount.SETRANGE("Always Include on Documents", TRUE);
                MSWalletMerchantAccount.SETFILTER("Primary Key", '<>%1', "Primary Key");
                MSWalletMerchantAccount.MODIFYALL("Always Include on Documents", FALSE, TRUE);
#endif
                IF NOT GUIALLOWED() THEN
                    EXIT;

                SalesHeader.SETFILTER("Document Type", STRSUBSTNO('%1|%2|%3',
                    SalesHeader."Document Type"::Invoice,
                    SalesHeader."Document Type"::Order,
                    SalesHeader."Document Type"::Quote));

                IF not SalesHeader.IsEmpty() AND NOT HideDialogs THEN
                    MESSAGE(UpdateOpenInvoicesManuallyMsg);
            end;
        }
        field(8; "Terms of Service"; Text[250])
        {
            ExtendedDatatype = URL;
        }
        field(10; "Merchant ID"; Text[250])
        {

            trigger OnValidate();
            begin
                VerifyAccountID();
                "Merchant ID" := LOWERCASE("Merchant ID");
            end;
        }
        field(12; "Payment Request URL"; BLOB)
        {
            Caption = 'Service URL';
        }
        field(16; "Test Mode"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }


    trigger OnInsert();
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        IF NOT ISTEMPORARY() THEN
            IF FINDFIRST() THEN
                ERROR(MSWalletSingeltonErr);
        "Test Mode" := CompanyInformationMgt.IsDemoCompany();
    end;

    var
        merchantIDCannotBeBlankErr: Label 'You must set up your merchant account before enabling this payment service.';
        UpdateOpenInvoicesManuallyMsg: Label 'A link for the Microsoft Pay Payments payment service will be included on new sales documents. To add it to existing sales documents, you must manually select it in the Payment Service field on the sales document.';
        HideDialogs: Boolean;
        MSWalletSingeltonErr: Label 'You can only have one Microsoft Pay Payments setup. To add more payment accounts to your merchant profile, edit the existing Microsoft Pay Payments setup.';
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
        OutStream: OutStream;
    begin
        if not IsValidURL(PaymentRequestURL) then
            Error(InvalidPaymentRequestURLErr);

        "Payment Request URL".CREATEOUTSTREAM(OutStream);
        OutStream.WRITE(PaymentRequestURL);
        MODIFY();
    end;

    local procedure IsValidURL(URL: Text): Boolean;
    var
        WebRequestHelper: Codeunit "Web Request Helper";
    begin
        if WebRequestHelper.IsValidUri(URL) then
            if WebRequestHelper.IsHttpUrl(URL) then
                if WebRequestHelper.IsSecureHttpUrl(URL) then
                    exit(true);
        exit(false);
    end;

    local procedure VerifyAccountID();
    begin
        IF Enabled THEN
            IF "Merchant ID" = '' THEN
                IF HideDialogs THEN
                    "Merchant ID" := ''
                ELSE
                    ERROR(merchantIDCannotBeBlankErr);
    end;

    procedure HideAllDialogs();
    begin
        HideDialogs := TRUE;
    end;


    procedure GetBaseURL(): Text;
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        EXIT(TypeHelper.UriGetAuthority(GetPaymentRequestURL()));
    end;
}
