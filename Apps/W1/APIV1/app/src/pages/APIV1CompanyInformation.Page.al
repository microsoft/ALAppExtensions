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
                    ODataEDMType = 'POSTALADDRESS';
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
        GraphMgtCompanyInfo: Codeunit "Graph Mgt - Company Info.";
    begin
        CompanyInformation.GetBySystemId(SystemId);
        GraphMgtCompanyInfo.ProcessComplexTypes(Rec, PostalAddressJSON);
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
        GraphMgtCompanyInfo: Codeunit "Graph Mgt - Company Info.";
    begin
        PostalAddressJSON := GraphMgtCompanyInfo.PostalAddressToJSON(Rec);

        GeneralLedgerSetup.GET();
        LCYCurrencyCode := GeneralLedgerSetup."LCY Code";

        AccountingPeriod.SETRANGE("New Fiscal Year", TRUE);
        IF AccountingPeriod.FINDLAST() THEN
            FiscalYearStart := AccountingPeriod."Starting Date";
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(SystemId);
        CLEAR(PostalAddressJSON);
    end;
}

