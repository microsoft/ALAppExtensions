namespace Microsoft.SubscriptionBilling;

codeunit 8075 "Extend Contract Mgt."
{
    Access = Internal;

    var
        HideDialog: Boolean;
        ExtensionCompletedMsg: Label 'Contract Extension completed.';

    procedure ExtendContract(var ServiceObject: Record "Service Object"; var TempServiceCommitmentPackage: Record "Service Commitment Package" temporary; ExtendCustomerContract: Boolean; var CustomerContract: Record "Customer Contract"; ExtendVendorContract: Boolean; var VendorContract: Record "Vendor Contract"; UsageBasedBillingPackageLinesOnly: Boolean; SupplierReferenceEntryNo: Integer)
    var
        ServiceCommitment: Record "Service Commitment";
        CustomerContractLine: Record "Customer Contract Line";
        VendorContractLine: Record "Vendor Contract Line";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
    begin
        // insert service commitments from standard item service commitment package
        ServiceCommitmentPackage.FilterCodeOnPackageFilter(ItemServCommitmentPackage.GetAllStandardPackageFilterForItem(ServiceObject."Item No.", ServiceObject."Customer Price Group"));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceObject."Provision Start Date", 0D, ServiceCommitmentPackage, UsageBasedBillingPackageLinesOnly);
        // insert service commitments from additionally selected service commitment package(s)
        TempServiceCommitmentPackage.SetRange(Selected, true);
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceObject."Provision Start Date", 0D, TempServiceCommitmentPackage, UsageBasedBillingPackageLinesOnly);

        ServiceObject.FilterServiceCommitmentsWithoutContract(ServiceCommitment);
        if ServiceCommitment.FindSet(true) then
            repeat
                if ExtendCustomerContract and ServiceCommitment.IsPartnerCustomer() then
                    CustomerContract.CreateCustomerContractLineFromServiceCommitment(ServiceCommitment, CustomerContract."No.", CustomerContractLine);
                if ExtendVendorContract and ServiceCommitment.IsPartnerVendor() then
                    VendorContract.CreateVendorContractLineFromServiceCommitment(ServiceCommitment, VendorContract."No.", VendorContractLine);
                if SupplierReferenceEntryNo <> 0 then begin
                    ServiceCommitment."Supplier Reference Entry No." := SupplierReferenceEntryNo;
                    UpdateUsageDataSubscriptionWithServiceCommitment(ServiceCommitment);
                end;
                OnAfterAssignServiceCommitmentToContractOnBeforeModify(ServiceCommitment);
                ServiceCommitment.Modify(false);
            until ServiceCommitment.Next() = 0;
        if not HideDialog then
            Message(ExtensionCompletedMsg);
    end;

    local procedure UpdateUsageDataSubscriptionWithServiceCommitment(ServiceCommitment: Record "Service Commitment")
    var
        UsageDataSubscription: Record "Usage Data Subscription";
    begin
        UsageDataSubscription.SetRange("Supplier Reference Entry No.", ServiceCommitment."Supplier Reference Entry No.");
        UsageDataSubscription.SetFilter("Service Object No.", '');
        UsageDataSubscription.SetRange("Service Commitment Entry No.", 0);
        if UsageDataSubscription.FindSet() then
            repeat
                UsageDataSubscription."Service Object No." := ServiceCommitment."Service Object No.";
                UsageDataSubscription."Service Commitment Entry No." := ServiceCommitment."Entry No.";
                UsageDataSubscription.Modify(false);
            until UsageDataSubscription.Next() = 0;
    end;

    procedure SetHideDialog(NewHideDialog: Boolean)
    begin
        HideDialog := NewHideDialog;
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterAssignServiceCommitmentToContractOnBeforeModify(var ServiceCommitment: Record "Service Commitment")
    begin
    end;
}
