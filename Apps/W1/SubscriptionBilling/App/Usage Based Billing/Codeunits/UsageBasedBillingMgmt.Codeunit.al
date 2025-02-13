namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using Microsoft.Inventory.Item;

codeunit 8029 "Usage Based Billing Mgmt."
{
    Access = Internal;

    var
        ExtendContractMgt: Codeunit "Extend Contract Mgt.";
        ConfirmManagement: Codeunit "Confirm Management";
        NoMatchingServiceCommitmentFoundErr: Label 'No %1 was found that matches the following criteria: %2', Comment = '%1 = Service Commitment, %2 = Service Commitment Filters';
        NoContractFoundErr: Label 'No %1 was found for Service Object: %2.', Comment = '%1 = Customer/Vendor Contract, %2 = Service Object No.';
        FieldMustBeFilledErr: Label 'The Field "%1" must contain a value.', Comment = '%1 = Field name';
        ProgressLbl: Label '#1###################################### \Progress @2@@@@@@@@@@@@@@@@@@';
        ProcessingInterruptedTxt: Label 'Processing interrupted.';
        ItemBlockedErr: Label 'You cannot connect Subscription to Service Object %1 because Item %2 from Service Object is blocked.', Comment = '%1 = Service Object No., %2 = Item No.';
        MultipleServiceObjectsQst: Label 'Service Object %1 is to be connected with the entry %2 and other subscriptions. Continue?', Comment = '%1 = Service Object No., %2 = Usage Data Subscription Entry No.';
        NoReferenceCommitmentFoundErr: Label 'For Item "%1" no Service Commitment with %2 was found.', Comment = '%1 = Item No., %2 = Usage Based Billing flag';
        DisconnectFromSubscriptionQst: Label 'Do you want to disconnect from the subscription?';
        SubscriptionCannotBeConnectedErr: Label 'The Subscription cannot be linked via "Existing Service Commitments" because the Service Commitments are not charged based on usage. Instead, select Link via=New Service Commitments.';

    internal procedure ConnectSubscriptionsToServiceObjects(var UsageDataSubscription: Record "Usage Data Subscription")
    var
        ServiceObject: Record "Service Object";
        i: Integer;
        ProgressBox: Dialog;
        TotalCount: Integer;
    begin
        UsageDataSubscription.SetRange("Service Commitment Entry No.", 0);
        UsageDataSubscription.SetFilter("Connect to SO Method", '<>%1', "Connect To SO Method"::None);
        if UsageDataSubscription.FindSet(true) then begin
            TotalCount := UsageDataSubscription.Count;
            ProgressBox.Open(ProgressLbl);
            ProgressBox.Update(1, UsageDataSubscription.TableCaption);
            repeat
                if i mod 10 = 0 then
                    ProgressBox.Update(2, Round(i / TotalCount * 10000, 1));

                TestUsageDataSubscription(UsageDataSubscription);
                if UsageDataSubscription."Processing Status" <> "Processing Status"::Error then begin
                    AskToProceedIfServiceObjectIsAssignedToMultipleSubscriptions(UsageDataSubscription);
                    ServiceObject.Get(UsageDataSubscription."Connect to Service Object No.");
                    ErrorIfServiceObjectItemIsBlocked(ServiceObject, UsageDataSubscription);
                end;

                if UsageDataSubscription."Processing Status" <> "Processing Status"::Error then
                    case UsageDataSubscription."Connect to SO Method" of
                        "Connect To SO Method"::"New Service Commitments":
                            ConnectSubscriptionToServiceObjectWithNewServiceCommitments(UsageDataSubscription);
                        "Connect To SO Method"::"Existing Service Commitments":
                            ConnectSubscriptionToServiceObjectWithExistingServiceCommitments(UsageDataSubscription);
                    end;
                i += 1;
                UsageDataSubscription.Modify(false);
            until UsageDataSubscription.Next() = 0;
            ProgressBox.Close();
        end;
    end;

    internal procedure DisconnectServiceCommitmentFromSubscription(var ServiceCommitment: Record "Service Commitment")
    var
        UsageDataSubscription: Record "Usage Data Subscription";
    begin
        ServiceCommitment.TestField("Supplier Reference Entry No.");
        UsageDataSubscription.SetRange("Supplier Reference Entry No.", ServiceCommitment."Supplier Reference Entry No.");
        if UsageDataSubscription.FindFirst() then
            if ConfirmManagement.GetResponse(StrSubstNo(DisconnectFromSubscriptionQst), true) then begin
                ResetSupplierReferenceEntryNoForServiceObject(ServiceCommitment."Service Object No.", ServiceCommitment."Supplier Reference Entry No.");
                UsageDataSubscription.ResetServiceObjectAndServiceCommitment();
            end;
    end;

    local procedure ResetSupplierReferenceEntryNoForServiceObject(ServiceObjectNo: Code[20]; SupplierReferenceEntryNo: Integer)
    var
        ServiceCommitments: Record "Service Commitment";
    begin
        ServiceCommitments.SetRange("Service Object No.", ServiceObjectNo);
        ServiceCommitments.SetRange("Supplier Reference Entry No.", SupplierReferenceEntryNo);
        ServiceCommitments.ModifyAll("Supplier Reference Entry No.", 0, false);
    end;

    procedure ConnectSubscriptionToServiceObjectWithExistingServiceCommitments(var UsageDataSubscription: Record "Usage Data Subscription")
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        ServiceCommitment.SetRange("Service Object No.", UsageDataSubscription."Connect to Service Object No.");
        ServiceCommitment.SetRange("Usage Based Billing", true);
        ServiceCommitment.SetRange("Supplier Reference Entry No.", 0);
        if ServiceCommitment.FindSet(true) then
            repeat
                CheckAndConnectServiceCommitmentToUsageDataSubscription(UsageDataSubscription, ServiceCommitment);
            until ServiceCommitment.Next() = 0
        else begin
            UsageDataSubscription.SetErrorReason(StrSubstNo(NoMatchingServiceCommitmentFoundErr, ServiceCommitment.TableCaption, ServiceCommitment.GetFilters));
            exit;
        end;
        if UsageDataSubscription."Processing Status" <> UsageDataSubscription."Processing Status"::Error then begin
            UsageDataSubscription.Validate("Service Object No.", ServiceCommitment."Service Object No.");
            UsageDataSubscription.Validate("Service Commitment Entry No.", ServiceCommitment."Entry No.");
            UsageDataSubscription.Validate("Processing Status", UsageDataSubscription."Processing Status"::Ok);
        end;
    end;

    local procedure CheckAndConnectServiceCommitmentToUsageDataSubscription(var UsageDataSubscription: Record "Usage Data Subscription"; var ServiceCommitment: Record "Service Commitment")
    begin
        if not ServiceCommitment."Usage Based Billing" then begin
            UsageDataSubscription.SetErrorReason(SubscriptionCannotBeConnectedErr);
            UsageDataSubscription.Modify(false);
        end;
        if UsageDataSubscription."Processing Status" <> UsageDataSubscription."Processing Status"::Error then begin
            ServiceCommitment."Supplier Reference Entry No." := UsageDataSubscription."Supplier Reference Entry No.";
            ServiceCommitment.Modify(false);
        end;
    end;

    local procedure CloseExistingServiceCommitments(var ServiceObject: Record "Service Object"; var ServiceCommitment: Record "Service Commitment"; var UsageDataSubscription: Record "Usage Data Subscription"; var EndingDate: Date; var VendorContractNo: Code[20])
    begin
        ServiceCommitment.FindSet(true);
        repeat
            EndingDate := UsageDataSubscription."Connect to SO at Date" - 1;
            ServiceCommitment."Service End Date" := EndingDate;
            ServiceCommitment."Next Billing Date" := CalcDate('<+1D>', EndingDate);
            ServiceCommitment.Modify(false);
            if ((VendorContractNo = '') and ServiceCommitment.IsPartnerVendor()) then
                VendorContractNo := ServiceCommitment."Contract No.";
        until ServiceCommitment.Next() = 0;
        ServiceObject.UpdateServicesDates();
    end;

    local procedure FindCustomerServiceCommitmentFromServiceObject(var ServiceCommitment: Record "Service Commitment"; ServiceObjectNo: Code[20]; var UsageDataSubscription: Record "Usage Data Subscription"): Boolean
    begin
        ServiceCommitment.SetRange("Service Object No.", ServiceObjectNo);
        ServiceCommitment.SetRange(Partner, "Service Partner"::Customer);
        ServiceCommitment.SetFilter("Contract No.", '<>%1', '');
        ServiceCommitment.SetFilter("Service End Date", '%1|>=%2', 0D, UsageDataSubscription."Connect to SO at Date");
        exit(ServiceCommitment.FindFirst());
    end;

    local procedure AssignVendorContractNoFromServiceCommitment(var ServiceCommitment: Record "Service Commitment"; var VendorContractNo: Code[20])
    begin
        ServiceCommitment.SetRange(Partner, ServiceCommitment.Partner::Vendor);
        if ServiceCommitment.FindFirst() then
            VendorContractNo := ServiceCommitment."Contract No.";
        ServiceCommitment.SetRange(Partner);
    end;

    local procedure CheckIfServiceCommPackageHasUsageBasedReference(var UsageDataSubscription: Record "Usage Data Subscription"; ItemNo: Code[20]; VendorContractNo: Code[20]; ServiceObjectNo: Code[20]; CustomerPriceGroup: Code[10]): Boolean
    var
        VendorContract: Record "Vendor Contract";
        ServiceCommitmentPackage: Record "Service Commitment Package";
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        ServiceCommitmentPackageLine: Record "Service Comm. Package Line";
        ReferenceCommitmentFound: Boolean;
    begin
        ServiceCommitmentPackage.FilterCodeOnPackageFilter(ItemServCommitmentPackage.GetAllStandardPackageFilterForItem(ItemNo, CustomerPriceGroup));
        if ServiceCommitmentPackage.FindSet() then begin
            repeat
                ServiceCommitmentPackageLine.SetRange("Package Code", ServiceCommitmentPackage."Code");
                if ServiceCommitmentPackageLine.FindSet() then
                    repeat
                        if ServiceCommitmentPackageLine.IsPartnerVendor() and (VendorContractNo = '') then begin
                            UsageDataSubscription.SetErrorReason(StrSubstNo(NoContractFoundErr, VendorContract.TableCaption(), ServiceObjectNo));
                            exit(false);
                        end;
                        if ServiceCommitmentPackageLine."Usage Based Billing" then
                            ReferenceCommitmentFound := true;
                    until ServiceCommitmentPackageLine.Next() = 0;
            until ServiceCommitmentPackage.Next() = 0;
            if not ReferenceCommitmentFound then
                UsageDataSubscription.SetErrorReason(StrSubstNo(NoReferenceCommitmentFoundErr, ItemNo, ServiceCommitmentPackageLine.FieldCaption("Usage Based Billing")));
            exit(ReferenceCommitmentFound);
        end;
    end;

    local procedure CheckIfUsageDataSubscriptionIsSetToNewServiceCommitments(var UsageDataSubscription: Record "Usage Data Subscription")
    begin
        if UsageDataSubscription."Connect to SO Method" = Enum::"Connect To SO Method"::"New Service Commitments" then
            UsageDataSubscription.SetErrorReason(StrSubstNo(FieldMustBeFilledErr, UsageDataSubscription.FieldCaption("Connect to SO at Date")));
    end;

    local procedure TestUsageDataSubscription(var UsageDataSubscription: Record "Usage Data Subscription")
    begin
        if UsageDataSubscription."Connect to SO at Date" = 0D then
            CheckIfUsageDataSubscriptionIsSetToNewServiceCommitments(UsageDataSubscription);

        if UsageDataSubscription."Connect to Service Object No." = '' then
            UsageDataSubscription.SetErrorReason(StrSubstNo(FieldMustBeFilledErr, UsageDataSubscription.FieldCaption("Connect to Service Object No.")));
    end;

    local procedure AskToProceedIfServiceObjectIsAssignedToMultipleSubscriptions(var UsageDataSubscription: Record "Usage Data Subscription")
    var
        UsageDataSubscription2: Record "Usage Data Subscription";
    begin
        UsageDataSubscription2.Reset();
        UsageDataSubscription2.CopyFilters(UsageDataSubscription);
        UsageDataSubscription2.SetRange("Connect to Service Object No.", UsageDataSubscription."Connect to Service Object No.");
        UsageDataSubscription2.SetFilter("Entry No.", '<>%1', UsageDataSubscription."Entry No.");
        if UsageDataSubscription2.FindFirst() then
            if not ConfirmManagement.GetResponse(StrSubstNo(MultipleServiceObjectsQst, UsageDataSubscription."Connect to Service Object No.", UsageDataSubscription2."Entry No."), false) then
                Error(ProcessingInterruptedTxt);
    end;

    local procedure ErrorIfServiceObjectItemIsBlocked(ServiceObject: Record "Service Object"; var UsageDataSubscription: Record "Usage Data Subscription")
    var
        Item: Record Item;
    begin
        if Item.Get(ServiceObject."Item No.") then
            if Item.Blocked then
                UsageDataSubscription.SetErrorReason(StrSubstNo(ItemBlockedErr, ServiceObject."No.", ServiceObject."Item No."));
    end;

    procedure ConnectSubscriptionToServiceObjectWithNewServiceCommitments(var UsageDataSubscription: Record "Usage Data Subscription")
    var
        ServiceObject: Record "Service Object";
        CustomerContract: Record "Customer Contract";
        ServiceCommitment: Record "Service Commitment";
        Item: Record Item;
        UsageDataSubscription2: Record "Usage Data Subscription";
        TempServiceCommitmentPackage: Record "Service Commitment Package" temporary;
        VendorContract: Record "Vendor Contract";
        CustomerContractNo: Code[20];
        VendorContractNo: Code[20];
        EndingDate: Date;
    begin
        ServiceObject.Get(UsageDataSubscription."Connect to Service Object No.");
        Item.Get(ServiceObject."Item No.");

        if FindCustomerServiceCommitmentFromServiceObject(ServiceCommitment, ServiceObject."No.", UsageDataSubscription) then
            CustomerContractNo := ServiceCommitment."Contract No."
        else begin
            UsageDataSubscription.SetErrorReason(StrSubstNo(NoContractFoundErr, CustomerContract.TableCaption(), ServiceObject."No."));
            exit;
        end;

        AssignVendorContractNoFromServiceCommitment(ServiceCommitment, VendorContractNo);

        CustomerContract.Get(CustomerContractNo);
        if not CheckIfServiceCommPackageHasUsageBasedReference(UsageDataSubscription, Item."No.", VendorContractNo, ServiceObject."No.", ServiceObject."Customer Price Group") then
            exit;

        CloseExistingServiceCommitments(ServiceObject, ServiceCommitment, UsageDataSubscription, EndingDate, VendorContractNo);

        if VendorContractNo <> '' then
            VendorContract.Get(VendorContractNo);

        ExtendContractMgt.ExtendContract(ServiceObject, TempServiceCommitmentPackage, CustomerContractNo <> '', CustomerContract, VendorContractNo <> '', VendorContract, true, UsageDataSubscription."Supplier Reference Entry No.");

        UsageDataSubscription2.Get(UsageDataSubscription."Entry No.");
        UsageDataSubscription.Validate("Service Object No.", UsageDataSubscription2."Service Object No.");
        UsageDataSubscription.Validate("Service Commitment Entry No.", UsageDataSubscription2."Service Commitment Entry No.");
        UsageDataSubscription.Validate("Processing Status", UsageDataSubscription."Processing Status"::Ok);
    end;
}
