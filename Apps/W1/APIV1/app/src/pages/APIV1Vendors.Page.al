page 20010 "APIV1 - Vendors"
{
    APIVersion = 'v1.0';
    Caption = 'vendors', Locked = true;
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'vendor';
    EntitySetName = 'vendors';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Vendor;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(number; "No.")
                {
                    Caption = 'number', Locked = true;
                }
                field(displayName; Name)
                {
                    Caption = 'displayName', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Name));
                    end;
                }
                field(address; PostalAddressJSON)
                {
                    Caption = 'address', Locked = true;
                    ODataEDMType = 'POSTALADDRESS';
                    ToolTip = 'Specifies the address for the vendor.';

                    trigger OnValidate()
                    begin
                        PostalAddressSet := TRUE;
                    end;
                }
                field(phoneNumber; "Phone No.")
                {
                    Caption = 'phoneNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Phone No."));
                    end;
                }
                field(email; "E-Mail")
                {
                    Caption = 'email', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("E-Mail"));
                    end;
                }
                field(website; "Home Page")
                {
                    Caption = 'website', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Home Page"));
                    end;
                }
                field(taxRegistrationNumber; "VAT Registration No.")
                {
                    Caption = 'taxRegistrationNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("VAT Registration No."));
                    end;
                }
                field(currencyId; "Currency Id")
                {
                    Caption = 'currencyId', Locked = true;

                    trigger OnValidate()
                    begin
                        IF "Currency Id" = BlankGUID THEN
                            "Currency Code" := ''
                        ELSE BEGIN
                            IF NOT Currency.GetBySystemId("Currency Id") THEN
                                ERROR(CurrencyIdDoesNotMatchACurrencyErr);

                            "Currency Code" := Currency.Code;
                        END;

                        RegisterFieldSet(FIELDNO("Currency Id"));
                        RegisterFieldSet(FIELDNO("Currency Code"));
                    end;
                }
                field(currencyCode; CurrencyCodeTxt)
                {
                    Caption = 'currencyCode', Locked = true;

                    trigger OnValidate()
                    begin
                        "Currency Code" :=
                          GraphMgtGeneralTools.TranslateCurrencyCodeToNAVCurrencyCode(
                            LCYCurrencyCode, COPYSTR(CurrencyCodeTxt, 1, MAXSTRLEN(LCYCurrencyCode)));

                        IF Currency.Code <> '' THEN BEGIN
                            IF Currency.Code <> "Currency Code" THEN
                                ERROR(CurrencyValuesDontMatchErr);
                            EXIT;
                        END;

                        IF "Currency Code" = '' THEN
                            "Currency Id" := BlankGUID
                        ELSE BEGIN
                            IF NOT Currency.GET("Currency Code") THEN
                                ERROR(CurrencyCodeDoesNotMatchACurrencyErr);

                            "Currency Id" := Currency.SystemId;
                        END;

                        RegisterFieldSet(FIELDNO("Currency Id"));
                        RegisterFieldSet(FIELDNO("Currency Code"));
                    end;
                }
                field(irs1099Code; IRS1099VendorCode)
                {
                    Caption = 'IRS1099Code', Locked = true;
                }
                field(paymentTermsId; "Payment Terms Id")
                {
                    Caption = 'paymentTermsId', Locked = true;

                    trigger OnValidate()
                    begin
                        IF "Payment Terms Id" = BlankGUID THEN
                            "Payment Terms Code" := ''
                        ELSE BEGIN
                            IF NOT PaymentTerms.GetBySystemId("Payment Terms Id") THEN
                                ERROR(PaymentTermsIdDoesNotMatchAPaymentTermsErr);

                            "Payment Terms Code" := PaymentTerms.Code;
                        END;

                        RegisterFieldSet(FIELDNO("Payment Terms Id"));
                        RegisterFieldSet(FIELDNO("Payment Terms Code"));
                    end;
                }
                field(paymentMethodId; "Payment Method Id")
                {
                    Caption = 'paymentMethodId', Locked = true;

                    trigger OnValidate()
                    begin
                        IF "Payment Method Id" = BlankGUID THEN
                            "Payment Method Code" := ''
                        ELSE BEGIN
                            IF NOT PaymentMethod.GetBySystemId("Payment Method Id") THEN
                                ERROR(PaymentMethodIdDoesNotMatchAPaymentMethodErr);

                            "Payment Method Code" := PaymentMethod.Code;
                        END;

                        RegisterFieldSet(FIELDNO("Payment Method Id"));
                        RegisterFieldSet(FIELDNO("Payment Method Code"));
                    end;
                }
                field(taxLiable; "Tax Liable")
                {
                    Caption = 'taxLiable', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Tax Liable"));
                    end;
                }
                field(blocked; Blocked)
                {
                    Caption = 'blocked', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Blocked));
                    end;
                }
                field(balance; "Balance (LCY)")
                {
                    Caption = 'balance', Locked = true;
                }
                field(lastModifiedDateTime; "Last Modified Date Time")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
                part(picture; "APIV1 - Pictures")
                {
                    Caption = 'picture';
                    EntityName = 'picture';
                    EntitySetName = 'picture';
                    SubPageLink = Id = FIELD(SystemId);
                }
                part(defaultDimensions; "APIV1 - Default Dimensions")
                {
                    Caption = 'DefaultDimensions', Locked = true;
                    EntityName = 'defaultDimensions';
                    EntitySetName = 'defaultDimensions';
                    SubPageLink = ParentId = FIELD(SystemId);
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Vendor: Record Vendor;
        RecRef: RecordRef;
    begin
        Vendor.SETRANGE("No.", "No.");
        IF NOT Vendor.ISEMPTY() THEN
            INSERT();

        INSERT(TRUE);

        ProcessPostalAddress();
        RecRef.GETTABLE(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecRef, TempFieldSet, CURRENTDATETIME());
        RecRef.SETTABLE(Rec);

        MODIFY(TRUE);
        SetCalculatedFields();
        EXIT(FALSE);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Vendor: Record Vendor;
    begin
        Vendor.GetBySystemId(SystemId);

        ProcessPostalAddress();

        IF "No." = Vendor."No." THEN
            MODIFY(TRUE)
        ELSE BEGIN
            Vendor.TRANSFERFIELDS(Rec, FALSE);
            Vendor.RENAME("No.");
            TRANSFERFIELDS(Vendor);
        END;

        SetCalculatedFields();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    var
        Currency: Record Currency;
        PaymentTerms: Record "Payment Terms";
        PaymentMethod: Record "Payment Method";
        TempFieldSet: Record 2000000041 temporary;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;
        PostalAddressJSON: Text;
        IRS1099VendorCode: Code[10];
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.', Locked = true;
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Locked = true;
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Locked = true;
        PaymentTermsIdDoesNotMatchAPaymentTermsErr: Label 'The "paymentTermsId" does not match to a Payment Terms.', Locked = true;
        PaymentMethodIdDoesNotMatchAPaymentMethodErr: Label 'The "paymentMethodId" does not match to a Payment Method.', Locked = true;
        BlankGUID: Guid;
        PostalAddressSet: Boolean;

    local procedure SetCalculatedFields()
    var
        GraphMgtVendor: Codeunit "Graph Mgt - Vendor";
    begin
        PostalAddressJSON := GraphMgtVendor.PostalAddressToJSON(Rec);

        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, "Currency Code");
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(SystemId);
        CLEAR(PostalAddressJSON);
        CLEAR(IRS1099VendorCode);
        CLEAR(PostalAddressSet);
        TempFieldSet.DELETEALL();
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        IF TempFieldSet.GET(DATABASE::Vendor, FieldNo) THEN
            EXIT;

        TempFieldSet.INIT();
        TempFieldSet.TableNo := DATABASE::Vendor;
        TempFieldSet.VALIDATE("No.", FieldNo);
        TempFieldSet.INSERT(TRUE);
    end;

    local procedure ProcessPostalAddress()
    var
        GraphMgtVendor: Codeunit "Graph Mgt - Vendor";
    begin
        IF NOT PostalAddressSet THEN
            EXIT;

        GraphMgtVendor.UpdatePostalAddress(PostalAddressJSON, Rec);

        IF xRec.Address <> Address THEN
            RegisterFieldSet(FIELDNO(Address));

        IF xRec."Address 2" <> "Address 2" THEN
            RegisterFieldSet(FIELDNO("Address 2"));

        IF xRec.City <> City THEN
            RegisterFieldSet(FIELDNO(City));

        IF xRec."Country/Region Code" <> "Country/Region Code" THEN
            RegisterFieldSet(FIELDNO("Country/Region Code"));

        IF xRec."Post Code" <> "Post Code" THEN
            RegisterFieldSet(FIELDNO("Post Code"));

        IF xRec.County <> County THEN
            RegisterFieldSet(FIELDNO(County));
    end;
}

