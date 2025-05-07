namespace Microsoft.SubscriptionBilling;

codeunit 8075 "Extend Sub. Contract Mgt."
{
    var
        HideDialog: Boolean;
        ExtensionCompletedMsg: Label 'Contract Extension completed.';

    internal procedure ExtendContract(var ServiceObject: Record "Subscription Header"; var TempServiceCommitmentPackage: Record "Subscription Package" temporary; ExtendCustomerContract: Boolean; var CustomerContract: Record "Customer Subscription Contract"; ExtendVendorContract: Boolean; var VendorContract: Record "Vendor Subscription Contract"; UsageBasedBillingPackageLinesOnly: Boolean; SupplierReferenceEntryNo: Integer)
    var
        ServiceCommitment: Record "Subscription Line";
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        VendorContractLine: Record "Vend. Sub. Contract Line";
        ServiceCommitmentPackage: Record "Subscription Package";
        ItemServCommitmentPackage: Record "Item Subscription Package";
    begin
        // insert Subscription Lines from standard item Subscription Package
        ServiceCommitmentPackage.FilterCodeOnPackageFilter(ItemServCommitmentPackage.GetAllStandardPackageFilterForItem(ServiceObject."Source No.", ServiceObject."Customer Price Group"));
        ServiceObject.InsertServiceCommitmentsFromServCommPackage(ServiceObject."Provision Start Date", 0D, ServiceCommitmentPackage, UsageBasedBillingPackageLinesOnly);
        // insert Subscription Lines from additionally selected Subscription Package(s)
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
                OnAfterAssignSubscriptionLineToContractOnBeforeModify(ServiceCommitment);
                ServiceCommitment.Modify(false);
            until ServiceCommitment.Next() = 0;
        if not HideDialog then
            Message(ExtensionCompletedMsg);
    end;

    local procedure UpdateUsageDataSubscriptionWithServiceCommitment(ServiceCommitment: Record "Subscription Line")
    var
        UsageDataSubscription: Record "Usage Data Supp. Subscription";
        UsageDataSubscription2: Record "Usage Data Supp. Subscription";
    begin
        UsageDataSubscription.SetRange("Supplier Reference Entry No.", ServiceCommitment."Supplier Reference Entry No.");
        UsageDataSubscription.SetFilter("Subscription Header No.", '');
        UsageDataSubscription.SetRange("Subscription Line Entry No.", 0);
        if UsageDataSubscription.FindSet(true) then
            repeat
                UsageDataSubscription2 := UsageDataSubscription;
                UsageDataSubscription2."Subscription Header No." := ServiceCommitment."Subscription Header No.";
                UsageDataSubscription2."Subscription Line Entry No." := ServiceCommitment."Entry No.";
                UsageDataSubscription2.Modify(false);
                UsageDataSubscription2.UpdateServiceObjectNoForUsageDataGenericImport();
            until UsageDataSubscription.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAssignSubscriptionLineToContractOnBeforeModify(var SubscriptionLine: Record "Subscription Line")
    begin
    end;
}
