namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using Microsoft.Inventory.Item;

codeunit 8029 "Usage Based Billing Mgmt."
{
    var
        ExtendContractMgt: Codeunit "Extend Sub. Contract Mgt.";
        ConfirmManagement: Codeunit "Confirm Management";
        NoMatchingServiceCommitmentFoundErr: Label 'No %1 was found that matches the following criteria: %2', Comment = '%1 = Subscription Line, %2 = Subscription Line Filters';
        NoContractFoundErr: Label 'No %1 was found for Subscription: %2.', Comment = '%1 = Customer/Vendor Contract, %2 = Subscription No.';
        FieldMustBeFilledErr: Label 'The Field "%1" must contain a value.', Comment = '%1 = Field name';
        ProgressLbl: Label '#1###################################### \Progress @2@@@@@@@@@@@@@@@@@@', Comment = '%1 = Progress, %2 = Table Name';
        ProcessingInterruptedTxt: Label 'Processing interrupted.';
        ItemBlockedErr: Label 'You cannot connect Supplier Subscription to Subscription %1 because Item %2 from Subscription is blocked.', Comment = '%1 = Subscription No., %2 = Item No.';
        MultipleServiceObjectsQst: Label 'Subscription %1 is to be connected with the entry %2 and other subscriptions. Continue?', Comment = '%1 = Subscription No., %2 = Usage Data Subscription Entry No.';
        NoReferenceCommitmentFoundErr: Label 'For Item "%1" no Subscription Line with %2 was found.', Comment = '%1 = Item No., %2 = Usage Based Billing flag';
        DisconnectFromSubscriptionQst: Label 'Do you want to disconnect from the subscription?';
        SubscriptionCannotBeConnectedErr: Label 'The Subscription cannot be linked via "Existing Subscription Lines" because the Subscription Lines are not charged based on usage. Instead, select Link via=New Subscription Lines.';

    procedure ConnectSubscriptionsToServiceObjects(var UsageDataSubscription: Record "Usage Data Supp. Subscription")
    var
        UsageDataSubscription2: Record "Usage Data Supp. Subscription";
        i: Integer;
        ProgressBox: Dialog;
        TotalCount: Integer;
    begin
        UsageDataSubscription.SetRange("Subscription Line Entry No.", 0);
        UsageDataSubscription.SetFilter("Connect to Sub. Header Method", '<>%1', "Connect To SO Method"::None);
        if UsageDataSubscription.FindSet(true) then begin
            i := 0;
            TotalCount := UsageDataSubscription.Count;
            ProgressBox.Open(ProgressLbl);
            ProgressBox.Update(1, UsageDataSubscription.TableCaption);
            repeat
                if i mod 10 = 0 then
                    ProgressBox.Update(2, Round(i / TotalCount * 10000, 1));

                UsageDataSubscription2 := UsageDataSubscription;
                TestUsageDataSubscription(UsageDataSubscription2);
                if UsageDataSubscription2."Processing Status" <> "Processing Status"::Error then begin
                    AskToProceedIfServiceObjectIsAssignedToMultipleSubscriptions(UsageDataSubscription2);
                    ErrorIfServiceObjectItemIsBlocked(UsageDataSubscription);
                end;

                if UsageDataSubscription2."Processing Status" <> "Processing Status"::Error then
                    case UsageDataSubscription2."Connect to Sub. Header Method" of
                        "Connect To SO Method"::"New Service Commitments":
                            ConnectSubscriptionToServiceObjectWithNewServiceCommitments(UsageDataSubscription2);
                        "Connect To SO Method"::"Existing Service Commitments":
                            ConnectSubscriptionToServiceObjectWithExistingServiceCommitments(UsageDataSubscription2);
                    end;
                i += 1;
                UsageDataSubscription2.Modify(false);
                UsageDataSubscription2.UpdateServiceObjectNoForUsageDataGenericImport();
            until UsageDataSubscription.Next() = 0;
            ProgressBox.Close();
        end;
    end;

    procedure DisconnectServiceCommitmentFromSubscription(var ServiceCommitment: Record "Subscription Line")
    var
        UsageDataSubscription: Record "Usage Data Supp. Subscription";
    begin
        ServiceCommitment.TestField("Supplier Reference Entry No.");
        UsageDataSubscription.SetRange("Supplier Reference Entry No.", ServiceCommitment."Supplier Reference Entry No.");
        if UsageDataSubscription.FindFirst() then
            if ConfirmManagement.GetResponse(StrSubstNo(DisconnectFromSubscriptionQst), true) then begin
                ResetSupplierReferenceEntryNoForServiceObject(ServiceCommitment."Subscription Header No.", ServiceCommitment."Supplier Reference Entry No.");
                UsageDataSubscription.ResetServiceObjectAndServiceCommitment();
            end;
    end;

    local procedure ResetSupplierReferenceEntryNoForServiceObject(ServiceObjectNo: Code[20]; SupplierReferenceEntryNo: Integer)
    var
        ServiceCommitments: Record "Subscription Line";
    begin
        ServiceCommitments.SetRange("Subscription Header No.", ServiceObjectNo);
        ServiceCommitments.SetRange("Supplier Reference Entry No.", SupplierReferenceEntryNo);
        ServiceCommitments.ModifyAll("Supplier Reference Entry No.", 0, false);
    end;

    internal procedure ConnectSubscriptionToServiceObjectWithExistingServiceCommitments(var UsageDataSubscription: Record "Usage Data Supp. Subscription")
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        ServiceCommitment.SetRange("Subscription Header No.", UsageDataSubscription."Connect to Sub. Header No.");
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
            UsageDataSubscription.Validate("Subscription Header No.", ServiceCommitment."Subscription Header No.");
            UsageDataSubscription.Validate("Subscription Line Entry No.", ServiceCommitment."Entry No.");
            UsageDataSubscription.Validate("Processing Status", UsageDataSubscription."Processing Status"::Ok);
        end;
    end;

    local procedure CheckAndConnectServiceCommitmentToUsageDataSubscription(var UsageDataSubscription: Record "Usage Data Supp. Subscription"; var ServiceCommitment: Record "Subscription Line")
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

    local procedure CloseExistingServiceCommitments(var ServiceObject: Record "Subscription Header"; var ServiceCommitment: Record "Subscription Line"; var UsageDataSubscription: Record "Usage Data Supp. Subscription"; var EndingDate: Date; var VendorContractNo: Code[20])
    begin
        ServiceCommitment.FindSet(true);
        repeat
            EndingDate := UsageDataSubscription."Connect to Sub. Header at Date" - 1;
            ServiceCommitment."Subscription Line End Date" := EndingDate;
            ServiceCommitment."Next Billing Date" := CalcDate('<+1D>', EndingDate);
            ServiceCommitment.Modify(false);
            if ((VendorContractNo = '') and ServiceCommitment.IsPartnerVendor()) then
                VendorContractNo := ServiceCommitment."Subscription Contract No.";
        until ServiceCommitment.Next() = 0;
        ServiceObject.UpdateServicesDates();
    end;

    local procedure FindCustomerServiceCommitmentFromServiceObject(var ServiceCommitment: Record "Subscription Line"; ServiceObjectNo: Code[20]; var UsageDataSubscription: Record "Usage Data Supp. Subscription"): Boolean
    begin
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObjectNo);
        ServiceCommitment.SetRange(Partner, "Service Partner"::Customer);
        ServiceCommitment.SetFilter("Subscription Contract No.", '<>%1', '');
        ServiceCommitment.SetFilter("Subscription Line End Date", '%1|>=%2', 0D, UsageDataSubscription."Connect to Sub. Header at Date");
        exit(ServiceCommitment.FindFirst());
    end;

    local procedure AssignVendorContractNoFromServiceCommitment(var ServiceCommitment: Record "Subscription Line"; var VendorContractNo: Code[20])
    begin
        ServiceCommitment.SetRange(Partner, ServiceCommitment.Partner::Vendor);
        if ServiceCommitment.FindFirst() then
            VendorContractNo := ServiceCommitment."Subscription Contract No.";
        ServiceCommitment.SetRange(Partner);
    end;

    local procedure CheckIfServiceCommPackageHasUsageBasedReference(var UsageDataSubscription: Record "Usage Data Supp. Subscription"; ItemNo: Code[20]; VendorContractNo: Code[20]; ServiceObjectNo: Code[20]; CustomerPriceGroup: Code[10]): Boolean
    var
        VendorContract: Record "Vendor Subscription Contract";
        ServiceCommitmentPackage: Record "Subscription Package";
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ServiceCommitmentPackageLine: Record "Subscription Package Line";
        ReferenceCommitmentFound: Boolean;
    begin
        ServiceCommitmentPackage.FilterCodeOnPackageFilter(ItemServCommitmentPackage.GetAllStandardPackageFilterForItem(ItemNo, CustomerPriceGroup));
        if ServiceCommitmentPackage.FindSet() then begin
            repeat
                ServiceCommitmentPackageLine.SetRange("Subscription Package Code", ServiceCommitmentPackage."Code");
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

    local procedure CheckIfUsageDataSubscriptionIsSetToNewServiceCommitments(var UsageDataSubscription: Record "Usage Data Supp. Subscription")
    begin
        if UsageDataSubscription."Connect to Sub. Header Method" = Enum::"Connect To SO Method"::"New Service Commitments" then
            UsageDataSubscription.SetErrorReason(StrSubstNo(FieldMustBeFilledErr, UsageDataSubscription.FieldCaption("Connect to Sub. Header at Date")));
    end;

    local procedure TestUsageDataSubscription(var UsageDataSubscription: Record "Usage Data Supp. Subscription")
    begin
        if UsageDataSubscription."Connect to Sub. Header at Date" = 0D then
            CheckIfUsageDataSubscriptionIsSetToNewServiceCommitments(UsageDataSubscription);

        if UsageDataSubscription."Connect to Sub. Header No." = '' then
            UsageDataSubscription.SetErrorReason(StrSubstNo(FieldMustBeFilledErr, UsageDataSubscription.FieldCaption("Connect to Sub. Header No.")));
    end;

    local procedure AskToProceedIfServiceObjectIsAssignedToMultipleSubscriptions(var UsageDataSubscription: Record "Usage Data Supp. Subscription")
    var
        UsageDataSubscription2: Record "Usage Data Supp. Subscription";
    begin
        UsageDataSubscription2.Reset();
        UsageDataSubscription2.CopyFilters(UsageDataSubscription);
        UsageDataSubscription2.SetRange("Connect to Sub. Header No.", UsageDataSubscription."Connect to Sub. Header No.");
        UsageDataSubscription2.SetFilter("Entry No.", '<>%1', UsageDataSubscription."Entry No.");
        if UsageDataSubscription2.FindFirst() then
            if not ConfirmManagement.GetResponse(StrSubstNo(MultipleServiceObjectsQst, UsageDataSubscription."Connect to Sub. Header No.", UsageDataSubscription2."Entry No."), false) then
                Error(ProcessingInterruptedTxt);
    end;

    local procedure ErrorIfServiceObjectItemIsBlocked(var UsageDataSubscription: Record "Usage Data Supp. Subscription")
    var
        ServiceObject: Record "Subscription Header";
        Item: Record Item;
    begin
        ServiceObject.Get(UsageDataSubscription."Connect to Sub. Header No.");
        ServiceObject.TestField(Type, ServiceObject.Type::Item);
        if Item.Get(ServiceObject."Source No.") then
            if Item.Blocked then
                UsageDataSubscription.SetErrorReason(StrSubstNo(ItemBlockedErr, ServiceObject."No.", ServiceObject."Source No."));
    end;

    procedure ConnectSubscriptionToServiceObjectWithNewServiceCommitments(var UsageDataSubscription: Record "Usage Data Supp. Subscription")
    var
        ServiceObject: Record "Subscription Header";
        CustomerContract: Record "Customer Subscription Contract";
        ServiceCommitment: Record "Subscription Line";
        Item: Record Item;
        UsageDataSubscription2: Record "Usage Data Supp. Subscription";
        TempServiceCommitmentPackage: Record "Subscription Package" temporary;
        VendorContract: Record "Vendor Subscription Contract";
        CustomerContractNo: Code[20];
        VendorContractNo: Code[20];
        EndingDate: Date;
    begin
        ServiceObject.Get(UsageDataSubscription."Connect to Sub. Header No.");
        ServiceObject.TestField(Type, ServiceObject.Type::Item);
        Item.Get(ServiceObject."Source No.");

        if FindCustomerServiceCommitmentFromServiceObject(ServiceCommitment, ServiceObject."No.", UsageDataSubscription) then
            CustomerContractNo := ServiceCommitment."Subscription Contract No."
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
        UsageDataSubscription.Validate("Subscription Header No.", UsageDataSubscription2."Subscription Header No.");
        UsageDataSubscription.Validate("Subscription Line Entry No.", UsageDataSubscription2."Subscription Line Entry No.");
        UsageDataSubscription.Validate("Processing Status", UsageDataSubscription."Processing Status"::Ok);
    end;
}
