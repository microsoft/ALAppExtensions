page 20009 "APIV1 - Customers"
{
    APIVersion = 'v1.0';
    Caption = 'customers', Locked = true;
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'customer';
    EntitySetName = 'customers';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Customer;
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
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        IF Name = '' THEN
                            ERROR(BlankCustomerNameErr);
                        RegisterFieldSet(FIELDNO(Name));
                    end;
                }
                field(type; "Contact Type")
                {
                    Caption = 'type', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Contact Type"));
                    end;
                }
                field(address; PostalAddressJSON)
                {
                    Caption = 'address', Locked = true;
                    ODataEDMType = 'POSTALADDRESS';
                    ToolTip = 'Specifies the address for the customer.';

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
                field(taxLiable; "Tax Liable")
                {
                    Caption = 'taxLiable', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Tax Liable"));
                    end;
                }
                field(taxAreaId; "Tax Area ID")
                {
                    Caption = 'taxAreaId', Locked = true;

                    trigger OnValidate()
                    var
                        GeneralLedgerSetup: Record "General Ledger Setup";
                    begin
                        RegisterFieldSet(FIELDNO("Tax Area ID"));

                        IF NOT GeneralLedgerSetup.UseVat() THEN
                            RegisterFieldSet(FIELDNO("Tax Area Code"))
                        ELSE
                            RegisterFieldSet(FIELDNO("VAT Bus. Posting Group"));
                    end;
                }
                field(taxAreaDisplayName; TaxAreaDisplayNameGlobal)
                {
                    Caption = 'taxAreaDisplayName', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the display name of the tax area.';
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
                field(shipmentMethodId; "Shipment Method Id")
                {
                    Caption = 'shipmentMethodId', Locked = true;

                    trigger OnValidate()
                    begin
                        IF "Shipment Method Id" = BlankGUID THEN
                            "Shipment Method Code" := ''
                        ELSE BEGIN
                            IF NOT ShipmentMethod.GetBySystemId("Shipment Method Id") THEN
                                ERROR(ShipmentMethodIdDoesNotMatchAShipmentMethodErr);

                            "Shipment Method Code" := ShipmentMethod.Code;
                        END;

                        RegisterFieldSet(FIELDNO("Shipment Method Id"));
                        RegisterFieldSet(FIELDNO("Shipment Method Code"));
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
                field(blocked; Blocked)
                {
                    Caption = 'blocked', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Blocked));
                    end;
                }
                part(customerFinancialDetails; "Customer Financial Details")
                {
                    Caption = 'Customer Financial Details', Locked = true;
                    EntityName = 'customerFinancialDetail';
                    EntitySetName = 'customerFinancialDetails';
                    SubPageLink = SystemId = FIELD(SystemId);
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
                    Caption = 'Default Dimensions', Locked = true;
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
        Customer: Record Customer;
        RecRef: RecordRef;
    begin
        IF Name = '' THEN
            ERROR(NotProvidedCustomerNameErr);

        Customer.SETRANGE("No.", "No.");
        IF NOT Customer.ISEMPTY() THEN
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
        Customer: Record Customer;
    begin
        Customer.GetBySystemId(SystemId);

        ProcessPostalAddress();

        IF "No." = Customer."No." THEN
            MODIFY(TRUE)
        ELSE BEGIN
            Customer.TRANSFERFIELDS(Rec, FALSE);
            Customer.RENAME("No.");
            TRANSFERFIELDS(Customer);
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
        ShipmentMethod: Record "Shipment Method";
        PaymentMethod: Record "Payment Method";
        TempFieldSet: Record 2000000041 temporary;
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        LCYCurrencyCode: Code[10];
        CurrencyCodeTxt: Text;
        PostalAddressJSON: Text;
        TaxAreaDisplayNameGlobal: Text;
        CurrencyValuesDontMatchErr: Label 'The currency values do not match to a specific Currency.', Locked = true;
        CurrencyIdDoesNotMatchACurrencyErr: Label 'The "currencyId" does not match to a Currency.', Locked = true;
        CurrencyCodeDoesNotMatchACurrencyErr: Label 'The "currencyCode" does not match to a Currency.', Locked = true;
        PaymentTermsIdDoesNotMatchAPaymentTermsErr: Label 'The "paymentTermsId" does not match to a Payment Terms.', Locked = true;
        ShipmentMethodIdDoesNotMatchAShipmentMethodErr: Label 'The "shipmentMethodId" does not match to a Shipment Method.', Locked = true;
        PaymentMethodIdDoesNotMatchAPaymentMethodErr: Label 'The "paymentMethodId" does not match to a Payment Method.', Locked = true;
        BlankGUID: Guid;
        NotProvidedCustomerNameErr: Label 'A "displayName" must be provided.', Locked = true;
        BlankCustomerNameErr: Label 'The blank "displayName" is not allowed.', Locked = true;
        PostalAddressSet: Boolean;

    local procedure SetCalculatedFields()
    var
        TaxAreaBuffer: Record "Tax Area Buffer";
        GraphMgtCustomer: Codeunit "Graph Mgt - Customer";
    begin
        PostalAddressJSON := GraphMgtCustomer.PostalAddressToJSON(Rec);

        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, "Currency Code");
        TaxAreaDisplayNameGlobal := TaxAreaBuffer.GetTaxAreaDisplayName("Tax Area ID");
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(SystemId);
        CLEAR(TaxAreaDisplayNameGlobal);
        CLEAR(PostalAddressJSON);
        CLEAR(PostalAddressSet);
        TempFieldSet.DELETEALL();
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        IF TempFieldSet.GET(DATABASE::Customer, FieldNo) THEN
            EXIT;

        TempFieldSet.INIT();
        TempFieldSet.TableNo := DATABASE::Customer;
        TempFieldSet.VALIDATE("No.", FieldNo);
        TempFieldSet.INSERT(TRUE);
    end;

    local procedure ProcessPostalAddress()
    var
        GraphMgtCustomer: Codeunit "Graph Mgt - Customer";
    begin
        IF NOT PostalAddressSet THEN
            EXIT;

        GraphMgtCustomer.UpdatePostalAddress(PostalAddressJSON, Rec);

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

