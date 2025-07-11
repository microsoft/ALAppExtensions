namespace Microsoft.API.V1;

using Microsoft.Purchases.Vendor;
using Microsoft.Finance.Currency;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Bank.BankAccount;
using Microsoft.Integration.Graph;

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
                field(id; Rec.SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'number', Locked = true;
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'displayName', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Name));
                    end;
                }
                field(address; PostalAddressJSON)
                {
                    Caption = 'address', Locked = true;
#pragma warning disable AL0667
                    ODataEDMType = 'POSTALADDRESS';
#pragma warning restore
                    ToolTip = 'Specifies the address for the vendor.';

                    trigger OnValidate()
                    begin
                        PostalAddressSet := true;
                    end;
                }
                field(phoneNumber; Rec."Phone No.")
                {
                    Caption = 'phoneNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Phone No."));
                    end;
                }
                field(email; Rec."E-Mail")
                {
                    Caption = 'email', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("E-Mail"));
                    end;
                }
                field(website; Rec."Home Page")
                {
                    Caption = 'website', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Home Page"));
                    end;
                }
                field(taxRegistrationNumber; Rec."VAT Registration No.")
                {
                    Caption = 'taxRegistrationNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("VAT Registration No."));
                    end;
                }
                field(currencyId; Rec."Currency Id")
                {
                    Caption = 'currencyId', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Currency Id" = BlankGUID then
                            Rec."Currency Code" := ''
                        else begin
                            if not Currency.GetBySystemId(Rec."Currency Id") then
                                error(CurrencyIdDoesNotMatchACurrencyErr);

                            Rec."Currency Code" := Currency.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Currency Id"));
                        RegisterFieldSet(Rec.FieldNo("Currency Code"));
                    end;
                }
                field(currencyCode; CurrencyCodeTxt)
                {
                    Caption = 'currencyCode', Locked = true;

                    trigger OnValidate()
                    begin
                        Rec."Currency Code" :=
                          GraphMgtGeneralTools.TranslateCurrencyCodeToNAVCurrencyCode(
                            LCYCurrencyCode, COPYSTR(CurrencyCodeTxt, 1, MAXSTRLEN(LCYCurrencyCode)));

                        if Currency.Code <> '' then begin
                            if Currency.Code <> Rec."Currency Code" then
                                error(CurrencyValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Currency Code" = '' then
                            Rec."Currency Id" := BlankGUID
                        else begin
                            if not Currency.GET(Rec."Currency Code") then
                                error(CurrencyCodeDoesNotMatchACurrencyErr);

                            Rec."Currency Id" := Currency.SystemId;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Currency Id"));
                        RegisterFieldSet(Rec.FieldNo("Currency Code"));
                    end;
                }
                field(irs1099Code; IRS1099VendorCode)
                {
                    Caption = 'IRS1099Code', Locked = true;
                }
                field(paymentTermsId; Rec."Payment Terms Id")
                {
                    Caption = 'paymentTermsId', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Payment Terms Id" = BlankGUID then
                            Rec."Payment Terms Code" := ''
                        else begin
                            if not PaymentTerms.GetBySystemId(Rec."Payment Terms Id") then
                                error(PaymentTermsIdDoesNotMatchAPaymentTermsErr);

                            Rec."Payment Terms Code" := PaymentTerms.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Payment Terms Id"));
                        RegisterFieldSet(Rec.FieldNo("Payment Terms Code"));
                    end;
                }
                field(paymentMethodId; Rec."Payment Method Id")
                {
                    Caption = 'paymentMethodId', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Payment Method Id" = BlankGUID then
                            Rec."Payment Method Code" := ''
                        else begin
                            if not PaymentMethod.GetBySystemId(Rec."Payment Method Id") then
                                error(PaymentMethodIdDoesNotMatchAPaymentMethodErr);

                            Rec."Payment Method Code" := PaymentMethod.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Payment Method Id"));
                        RegisterFieldSet(Rec.FieldNo("Payment Method Code"));
                    end;
                }
                field(taxLiable; Rec."Tax Liable")
                {
                    Caption = 'taxLiable', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Tax Liable"));
                    end;
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'blocked', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Blocked));
                    end;
                }
                field(balance; Rec."Balance (LCY)")
                {
                    Caption = 'balance', Locked = true;
                }
                field(lastModifiedDateTime; Rec."Last Modified Date Time")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
                part(picture; "APIV1 - Pictures")
                {
                    Caption = 'picture';
                    EntityName = 'picture';
                    EntitySetName = 'picture';
                    SubPageLink = Id = field(SystemId);
                }
                part(defaultDimensions; "APIV1 - Default Dimensions")
                {
                    Caption = 'DefaultDimensions', Locked = true;
                    EntityName = 'defaultDimensions';
                    EntitySetName = 'defaultDimensions';
                    SubPageLink = ParentId = field(SystemId);
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
        RecordRef: RecordRef;
    begin
        Vendor.SETRANGE("No.", Rec."No.");
        if not Vendor.ISEMPTY() then
            Rec.insert();

        Rec.insert(true);

        ProcessPostalAddress();
        RecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecordRef, TempFieldSet, CURRENTDATETIME());
        RecordRef.SetTable(Rec);

        Rec.Modify(true);
        SetCalculatedFields();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Vendor: Record Vendor;
    begin
        Vendor.GetBySystemId(Rec.SystemId);

        ProcessPostalAddress();

        if Rec."No." = Vendor."No." then
            Rec.Modify(true)
        else begin
            Vendor.TransferFields(Rec, false);
            Vendor.Rename(Rec."No.");
            Rec.TransferFields(Vendor);
        end;

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

        CurrencyCodeTxt := GraphMgtGeneralTools.TranslateNAVCurrencyCodeToCurrencyCode(LCYCurrencyCode, Rec."Currency Code");
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(Rec.SystemId);
        CLEAR(PostalAddressJSON);
        CLEAR(IRS1099VendorCode);
        CLEAR(PostalAddressSet);
        TempFieldSet.DELETEALL();
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.GET(DATABASE::Vendor, FieldNo) then
            exit;

        TempFieldSet.INIT();
        TempFieldSet.TableNo := DATABASE::Vendor;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.insert(true);
    end;

    local procedure ProcessPostalAddress()
    var
        GraphMgtVendor: Codeunit "Graph Mgt - Vendor";
    begin
        if not PostalAddressSet then
            exit;

        GraphMgtVendor.UpdatePostalAddress(PostalAddressJSON, Rec);

        if xRec.Address <> Rec.Address then
            RegisterFieldSet(Rec.FieldNo(Address));

        if xRec."Address 2" <> Rec."Address 2" then
            RegisterFieldSet(Rec.FieldNo("Address 2"));

        if xRec.City <> Rec.City then
            RegisterFieldSet(Rec.FieldNo(City));

        if xRec."Country/Region Code" <> Rec."Country/Region Code" then
            RegisterFieldSet(Rec.FieldNo("Country/Region Code"));

        if xRec."Post Code" <> Rec."Post Code" then
            RegisterFieldSet(Rec.FieldNo("Post Code"));

        if xRec.County <> Rec.County then
            RegisterFieldSet(Rec.FieldNo(County));
    end;
}


