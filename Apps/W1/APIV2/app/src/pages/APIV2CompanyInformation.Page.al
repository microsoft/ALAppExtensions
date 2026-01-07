namespace Microsoft.API.V2;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.Period;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Environment.Configuration;

page 30011 "APIV2 - Company Information"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Company Information';
    EntitySetCaption = 'Company Information';
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
    AboutText = 'Exposes company profile data including name, address, contact details, tax registration numbers, banking information, and branding attributes. Supports read-only access for retrieving company metadata, enabling external applications to automate document generation, compliance validation, and ensure consistent company information across integrated business systems. Ideal for scenarios requiring company-level context in multi-system integrations and administrative workflows.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name';
                }
                field(addressLine1; Rec.Address)
                {
                    Caption = 'Address Line 1';
                }
                field(addressLine2; Rec."Address 2")
                {
                    Caption = 'Address Line 2';
                }
                field(city; Rec.City)
                {
                    Caption = 'City';
                }
                field(state; Rec.County)
                {
                    Caption = 'State';
                }
                field(country; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code';
                }
                field(postalCode; Rec."Post Code")
                {
                    Caption = 'Post Code';
                }
                field(phoneNumber; Rec."Phone No.")
                {
                    Caption = 'Phone No.';
                }
                field(faxNumber; Rec."Fax No.")
                {
                    Caption = 'Fax No.';
                }
                field(email; Rec."E-Mail")
                {
                    Caption = 'Email';
                }
                field(website; Rec."Home Page")
                {
                    Caption = 'Website';
                }
                field(taxRegistrationNumber; TaxRegistrationNumber)
                {
                    Caption = 'Tax Registration No.';

                    trigger OnValidate()
                    var
                        EnterpriseNoFieldRef: FieldRef;
                    begin
                        if IsEnterpriseNumber(EnterpriseNoFieldRef) then begin
                            EnterpriseNoFieldRef.Validate(TaxRegistrationNumber);
                            EnterpriseNoFieldRef.Record().SetTable(Rec);
                        end else
                            Rec.Validate("VAT Registration No.", TaxRegistrationNumber);
                    end;
                }
                field(currencyCode; LCYCurrencyCode)
                {
                    Caption = 'Currency Code';
                    Editable = false;
                }
                field(currentFiscalYearStartDate; FiscalYearStart)
                {
                    Caption = 'Current Fiscal Year Start Date';
                    Editable = false;
                }
                field(industry; Rec."Industrial Classification")
                {
                    Caption = 'Industry';
                }
                field(picture; Rec.Picture)
                {
                    Caption = 'Picture';
                    Editable = false;
                }
                field(experience; Experience)
                {
                    Caption = 'Experience';

                    trigger OnValidate()
                    begin
                        ExperienceUpdated := true;
                    end;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
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
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CompanyInformation.GetBySystemId(Rec.SystemId);
        if ExperienceUpdated then
            if not ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(Experience) then
                Error(SaveExperienceTierFailedErr);

        Rec.Modify(true);

        SetCalculatedFields();
    end;

    var
        LCYCurrencyCode: Code[10];
        TaxRegistrationNumber: Text[50];
        FiscalYearStart: Date;
        Experience: Text;
        ExperienceUpdated: Boolean;
        SaveExperienceTierFailedErr: Label 'Failed to save experience tier for the current company.';

    local procedure SetCalculatedFields()
    var
        AccountingPeriod: Record "Accounting Period";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        EnterpriseNoFieldRef: FieldRef;
    begin
        GeneralLedgerSetup.Get();
        LCYCurrencyCode := GeneralLedgerSetup."LCY Code";

        AccountingPeriod.SetRange("New Fiscal Year", true);
        if AccountingPeriod.FindLast() then
            FiscalYearStart := AccountingPeriod."Starting Date";

        if IsEnterpriseNumber(EnterpriseNoFieldRef) then
            TaxRegistrationNumber := EnterpriseNoFieldRef.Value()
        else
            TaxRegistrationNumber := Rec."VAT Registration No.";

        ApplicationAreaMgmtFacade.GetExperienceTierCurrentCompany(Experience);
        ExperienceUpdated := false;
    end;

    procedure IsEnterpriseNumber(var EnterpriseNoFieldRef: FieldRef): Boolean
    var
        CompanyInformationRecordRef: RecordRef;
    begin
        CompanyInformationRecordRef.GetTable(Rec);
        if CompanyInformationRecordRef.FieldExist(11310) then begin
            EnterpriseNoFieldRef := CompanyInformationRecordRef.Field(11310);
            exit((EnterpriseNoFieldRef.Type = FieldType::Text) and (EnterpriseNoFieldRef.Name = 'Enterprise No.'));
        end else
            exit(false);
    end;
}

