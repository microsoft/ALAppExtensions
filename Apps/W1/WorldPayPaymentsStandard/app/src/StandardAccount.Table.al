table 1360 "MS - WorldPay Standard Account"
{
    Caption = 'WorldPay Payments Standard Account';
    DrillDownPageID = 1360;
    LookupPageID = 1360;
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

            trigger OnValidate()
            begin
                VerifyAccountID();
            end;
        }
        field(5; "Always Include on Documents"; Boolean)
        {

            trigger OnValidate()
            var
                MSWorldPayStandardAccount: Record "MS - WorldPay Standard Account";
                SalesHeader: Record "Sales Header";
            begin
                IF NOT "Always Include on Documents" THEN
                    EXIT;

                MSWorldPayStandardAccount.SETRANGE("Always Include on Documents", TRUE);
                MSWorldPayStandardAccount.SETFILTER("Primary Key", '<>%1', "Primary Key");
                MSWorldPayStandardAccount.MODIFYALL("Always Include on Documents", FALSE, TRUE);

                IF NOT GUIALLOWED() THEN
                    EXIT;

                SalesHeader.SETFILTER("Document Type", '%1|%2|%3',
                    SalesHeader."Document Type"::Invoice,
                    SalesHeader."Document Type"::Order,
                    SalesHeader."Document Type"::Quote);

                IF NOT SalesHeader.IsEmpty() AND NOT HideDialogs THEN
                    MESSAGE(UpdateOpenInvoicesManuallyMsg);
            end;
        }
        field(8; "Terms of Service"; Text[250])
        {
            ExtendedDatatype = URL;
        }
        field(10; "Account ID"; Text[250])
        {

            trigger OnValidate()
            begin
                VerifyAccountID();
            end;
        }
        field(12; "Target URL"; BLOB)
        {
            Caption = 'Service URL';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        AccountIDCannotBeBlankErr: Label 'You must specify an account ID for this payment service.';
        UpdateOpenInvoicesManuallyMsg: Label 'A link for the WorldPay payment service will be included for new sales documents. To add it to existing sales documents, you must manually select it in the Payment Service field on the sales document.';
        HideDialogs: Boolean;

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

    local procedure VerifyAccountID()
    begin
        IF Enabled THEN
            IF "Account ID" = '' THEN
                IF HideDialogs THEN
                    "Account ID" := ''
                ELSE
                    ERROR(AccountIDCannotBeBlankErr);
    end;

    procedure HideAllDialogs()
    begin
        HideDialogs := TRUE;
    end;
}

