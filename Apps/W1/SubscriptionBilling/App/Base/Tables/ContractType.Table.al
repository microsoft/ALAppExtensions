namespace Microsoft.SubscriptionBilling;

using System.Utilities;

table 8053 "Contract Type"
{
    DataClassification = CustomerContent;
    LookupPageId = "Contract Types";
    DrillDownPageId = "Contract Types";
    Caption = 'Contract Type';
    Access = Internal;

    fields
    {
        field(1; Code; Code[10])
        {
            NotBlank = true;
            Caption = 'Code';
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(3; HarmonizedBillingCustContracts; Boolean)
        {
            Caption = 'Harmonized Billing Customer Contracts';
            trigger OnValidate()
            begin
                TestIfCustomerContractsForContractTypeExists();
            end;
        }
        field(4; "Def. Without Contr. Deferrals"; Boolean)
        {
            Caption = 'Default Without Contract Deferrals';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Code, Description, HarmonizedBillingCustContracts) { }
    }

    trigger OnDelete()
    var
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        FieldTranslation: Record "Field Translation";
    begin
        CustomerContract.SetRange("Contract Type", Code);
        if not CustomerContract.IsEmpty() then
            Error(CannotDeleteErr, TableCaption(), CustomerContract.TableCaption);
        VendorContract.SetRange("Contract Type", Code);
        if not VendorContract.IsEmpty() then
            Error(CannotDeleteErr, TableCaption(), CustomerContract.TableCaption);
        FieldTranslation.DeleteRelatedTranslations(Rec, Rec.FieldNo(Description));
    end;

    local procedure TestIfCustomerContractsForContractTypeExists()
    var
        CustomerContract: Record "Customer Contract";
        xContractType: Record "Contract Type";
    begin
        if Rec.HarmonizedBillingCustContracts then
            exit;
        xContractType.Get(Rec.Code);
        if not xContractType.HarmonizedBillingCustContracts then
            exit;
        CustomerContract.SetRange("Contract Type", Rec.Code);
        if not CustomerContract.IsEmpty() then
            if ConfirmManagement.GetResponse(StrSubstNo(CustomerContractWithContractTypeExistsQst, Rec.Code), false) then
                ResetCustomerContractsHarmonizedBillingFields(CustomerContract);
    end;

    local procedure ResetCustomerContractsHarmonizedBillingFields(var CustomerContract: Record "Customer Contract")
    begin
        if CustomerContract.FindSet() then
            repeat
                CustomerContract.ResetHarmonizedBillingFields();
                CustomerContract.Modify(false);
            until CustomerContract.Next() = 0;
    end;

    internal procedure GetDescription(ContractTypeCode: Code[10]): Text[50]
    var
        ContractType: Record "Contract Type";
    begin
        if not ContractType.Get(ContractTypeCode) then
            exit('');
        exit(ContractType.Description);
    end;

    var
        ConfirmManagement: Codeunit "Confirm Management";
        CannotDeleteErr: Label 'You cannot delete %1 %2 because one or more contract are associated with this %1.';
        CustomerContractWithContractTypeExistsQst: Label 'The customer contracts with contract type %1 may be set so that all contract elements are billed on the same key date. If you deselect this checkbox, services that are added will not be automatically harmonized with regard to billing and the information on harmonized billing will be removed from the contracts. Do you want to continue?';
}