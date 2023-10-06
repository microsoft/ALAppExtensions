namespace Microsoft.API.V1;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.Period;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Integration.Graph;

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
                field(id; Rec.SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(displayName; Rec.Name)
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
                field(phoneNumber; Rec."Phone No.")
                {
                    Caption = 'phoneNumber', Locked = true;
                }
                field(faxNumber; Rec."Fax No.")
                {
                    Caption = 'faxNumber', Locked = true;
                }
                field(email; Rec."E-Mail")
                {
                    Caption = 'email', Locked = true;
                }
                field(website; Rec."Home Page")
                {
                    Caption = 'website', Locked = true;
                }
                field(taxRegistrationNumber; Rec."VAT Registration No.")
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
                field(industry; Rec."Industrial Classification")
                {
                    Caption = 'industry', Locked = true;
                }
                field(picture; Rec.Picture)
                {
                    Caption = 'picture', Locked = true;
                    Editable = false;
                }
                field(lastModifiedDateTime; Rec."Last Modified Date Time")
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
        CompanyInformation.GetBySystemId(Rec.SystemId);
        ProcessComplexTypes(Rec, PostalAddressJSON);
        Rec.Modify(true);

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

        GeneralLedgerSetup.Get();
        LCYCurrencyCode := GeneralLedgerSetup."LCY Code";

        AccountingPeriod.SetRange("New Fiscal Year", true);
        if AccountingPeriod.FindLast() then
            FiscalYearStart := AccountingPeriod."Starting Date";
    end;

    local procedure PostalAddressToJSON(CompanyInformation: Record "Company Information") JSON: Text
    var
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
    begin
        GraphMgtComplexTypes.GetPostalAddressJSON(CompanyInformation.Address, CompanyInformation."Address 2", CompanyInformation.City, CompanyInformation.County, CompanyInformation."Country/Region Code", CompanyInformation."Post Code", JSON);
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(Rec.SystemId);
        Clear(PostalAddressJSON);
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

        RecordRef.GetTable(CompanyInformation);
        GraphMgtComplexTypes.ApplyPostalAddressFromJSON(LocalPostalAddressJSON, RecordRef,
          CompanyInformation.FieldNo(CompanyInformation.Address), CompanyInformation.FieldNo(CompanyInformation."Address 2"), CompanyInformation.FieldNo(CompanyInformation.City), CompanyInformation.FieldNo(CompanyInformation.County), CompanyInformation.FieldNo(CompanyInformation."Country/Region Code"), CompanyInformation.FieldNo(CompanyInformation."Post Code"));
        RecordRef.SetTable(CompanyInformation);
    end;
}


