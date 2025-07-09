namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using System.Environment.Configuration;

table 8053 "Subscription Contract Type"
{
    DataClassification = CustomerContent;
    LookupPageId = "Contract Types";
    DrillDownPageId = "Contract Types";
    Caption = 'Subscription Contract Type';

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
            Caption = 'Harmonized Billing Customer Subscription Contracts';
            trigger OnValidate()
            begin
                TestIfCustomerContractsForContractTypeExists();
            end;
        }
#if not CLEANSCHEMA30
        field(4; "Def. Without Contr. Deferrals"; Boolean)
        {
            ObsoleteReason = 'Removed in favor of Create Contract Deferrals.';
#if not CLEAN27
            ObsoleteState = Pending;
            ObsoleteTag = '27.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '30.0';
#endif
            Caption = 'Default Without Contract Deferrals';
        }
#endif
        field(5; "Create Contract Deferrals"; Boolean)
        {
            Caption = 'Create Contract Deferrals';
            InitValue = true;
            trigger OnValidate()
            var
                NotificationLifecycleMgt: Codeunit "Notification Lifecycle Mgt.";
                CurrentContractsNotAffectedNotification: Notification;
            begin
                if CustomerContractsExist() or VendorContractsExist() then begin
                    CurrentContractsNotAffectedNotification.Id := GetCurrentContractsNotAffectedNotificationId();
                    CurrentContractsNotAffectedNotification.Message := StrSubstNo(CurrentContractsNotAffectedMsg, Code, Description);
                    CurrentContractsNotAffectedNotification.Scope := NotificationScope::LocalScope;
                    NotificationLifecycleMgt.SendNotification(CurrentContractsNotAffectedNotification, RecordId);
                end;
            end;
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
        CustomerContract: Record "Customer Subscription Contract";
        VendorContract: Record "Vendor Subscription Contract";
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

    var
        ConfirmManagement: Codeunit "Confirm Management";
        CannotDeleteErr: Label 'You cannot delete %1 %2 because one or more contract are associated with this %1.', Comment = '%1 = Table, %2 = Table Caption';
        CustomerContractWithContractTypeExistsQst: Label 'The Customer Subscription Contracts with contract type %1 may be set so that all contract elements are billed on the same key date. If you deselect this checkbox, Subscription Lines that are added will not be automatically harmonized with regard to billing and the information on harmonized billing will be removed from the contracts. Do you want to continue?', Comment = 'Code = %1';
        CurrentContractsNotAffectedMsg: Label 'The changed default for the creation of contract deferrals only applies to new contracts. For existing contracts the setting must be changed manually, if required. Contract Type = %1 %2', Comment = '%1= Code, %2 = Description';

    procedure CustomerContractsExist(): Boolean
    var
        CustomerSubscriptionContract: Record "Customer Subscription Contract";
    begin
        CustomerSubscriptionContract.SetRange("Contract Type", Rec.Code);
        exit(not CustomerSubscriptionContract.IsEmpty());
    end;

    procedure VendorContractsExist(): Boolean
    var
        VendorSubscriptionContract: Record "Vendor Subscription Contract";
    begin
        VendorSubscriptionContract.SetRange("Contract Type", Rec.Code);
        exit(not VendorSubscriptionContract.IsEmpty());
    end;

    local procedure TestIfCustomerContractsForContractTypeExists()
    var
        CustomerContract: Record "Customer Subscription Contract";
        xContractType: Record "Subscription Contract Type";
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

    local procedure ResetCustomerContractsHarmonizedBillingFields(var CustomerContract: Record "Customer Subscription Contract")
    begin
        if CustomerContract.FindSet() then
            repeat
                CustomerContract.ResetHarmonizedBillingFields();
                CustomerContract.Modify(false);
            until CustomerContract.Next() = 0;
    end;

    internal procedure GetDescription(ContractTypeCode: Code[10]): Text[50]
    var
        ContractType: Record "Subscription Contract Type";
    begin
        if not ContractType.Get(ContractTypeCode) then
            exit('');
        exit(ContractType.Description);
    end;

    local procedure GetCurrentContractsNotAffectedNotificationId(): Guid
    begin
        exit('AD8AAAEA-B5bA-49C3-858F-63074D6368DD');
    end;

}