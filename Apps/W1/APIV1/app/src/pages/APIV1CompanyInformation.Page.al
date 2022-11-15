page 20011 "APIV1 - Company Information"
{
    APIVersion = 'v1.0';
    Caption = 'companyInformation', Locked = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'companyInformation';
    EntitySetName = 'companyInformation';
    InsertAllowed = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SaveValues = true;
    SourceTable = "Company Information";
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
                field(displayName; Name)
                {
                    Caption = 'displayName', Locked = true;
                }
                field(address; PostalAddressJSON)
                {
                    Caption = 'address', Locked = true;
#pragma warning disable AL0667
                    ODataEDMType = 'POSTALADDRESS';
#pragma warning restore
                    ToolTip = 'Specifies the company''s primary business address.';
                }
                field(phoneNumber; "Phone No.")
                {
                    Caption = 'phoneNumber', Locked = true;
                }
                field(faxNumber; "Fax No.")
                {
                    Caption = 'faxNumber', Locked = true;
                }
                field(email; "E-Mail")
                {
                    Caption = 'email', Locked = true;
                }
                field(website; "Home Page")
                {
                    Caption = 'website', Locked = true;
                }
                field(taxRegistrationNumber; "VAT Registration No.")
                {
                    Caption = 'taxRegistrationNumber', Locked = true;
                }
                field(currencyCode; LCYCurrencyCode)
                {
                    Caption = 'currencyCode', Locked = true;
                    Editable = false;
                }
                field(currentFiscalYearStartDate; FiscalYearStart)
                {
                    Caption = 'currentFiscalYearStartDate', Locked = true;
                    Editable = false;
                }
                field(industry; "Industrial Classification")
                {
                    Caption = 'industry', Locked = true;
                }
                field(picture; Picture)
                {
                    Caption = 'picture', Locked = true;
                    Editable = false;
                }
                field(lastModifiedDateTime; "Last Modified Date Time")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
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

    trigger OnModifyRecord(): Boolean
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.GetBySystemId(SystemId);
        ProcessComplexTypes(Rec, PostalAddressJSON);
        MODIFY(TRUE);

        SetCalculatedFields();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    var
        LCYCurrencyCode: Code[10];
        FiscalYearStart: Date;
        PostalAddressJSON: Text;

    local procedure SetCalculatedFields()
    var
        AccountingPeriod: Record "Accounting Period";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        PostalAddressJSON := PostalAddressToJSON(Rec);

        GeneralLedgerSetup.GET();
        LCYCurrencyCode := GeneralLedgerSetup."LCY Code";

        AccountingPeriod.SETRANGE("New Fiscal Year", TRUE);
        IF AccountingPeriod.FINDLAST() THEN
            FiscalYearStart := AccountingPeriod."Starting Date";
    end;

    local procedure PostalAddressToJSON(CompanyInformation: Record "Company Information") JSON: Text
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
    begin
        with CompanyInformation do
            GraphMgtComplexTypes.GetPostalAddressJSON(Address, "Address 2", City, County, "Country/Region Code", "Post Code", JSON);
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(SystemId);
        CLEAR(PostalAddressJSON);
    end;

    local procedure ProcessComplexTypes(var CompanyInformation: Record "Company Information"; LocalPostalAddressJSON: Text)
    begin
        UpdatePostalAddress(LocalPostalAddressJSON, CompanyInformation);
    end;

    local procedure UpdatePostalAddress(LocalPostalAddressJSON: Text; var CompanyInformation: Record "Company Information")
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
        RecordRef: RecordRef;
    begin
        if PostalAddressJSON = '' then
            exit;

        with CompanyInformation do begin
            RecordRef.GetTable(CompanyInformation);
            GraphMgtComplexTypes.ApplyPostalAddressFromJSON(LocalPostalAddressJSON, RecordRef,
              FieldNo(Address), FieldNo("Address 2"), FieldNo(City), FieldNo(County), FieldNo("Country/Region Code"), FieldNo("Post Code"));
            RecordRef.SetTable(CompanyInformation);
        end;
    end;
}

