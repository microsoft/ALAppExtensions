namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Item.Catalog;

page 8002 "Extend Contract"
{
    ApplicationArea = All;
    Caption = 'Extend Subscription Contract';
    LinksAllowed = false;
    PageType = Card;
    UsageCategory = Tasks;
    SaveValues = true;

    layout
    {
        area(content)
        {
            group(Vendor)
            {
                Caption = 'Vendor';

                field(ExtendVendorContract; ExtendVendorContract)
                {
                    Caption = 'Extend Vendor Subscription Contract';
                    ToolTip = 'Specifies whether Vendor Subscription Contract should be extended with provided Subscription Line.';

                    trigger OnValidate()
                    begin
                        ValidateExtendVendorContract();
                    end;
                }
                field(UsageDataSupplierNo; UsageDataSupplierNo)
                {
                    ApplicationArea = All;
                    Caption = 'Usage Data Supplier No.';
                    ToolTip = 'Specifies the usage data supplier based on which a subscription can be selected.';
                    TableRelation = "Usage Data Supplier";

                    trigger OnValidate()
                    begin
                        ValidateUsageSupplierNo();
                    end;
                }
                field(SubscriptionDescription; SubscriptionDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Subscription';
                    ToolTip = 'Specifies the subscription for which the Subscription and Subscription Lines are created.';
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        UsageDataSubscription: Record "Usage Data Supp. Subscription";
                        UsageDataCustomer: Record "Usage Data Supp. Customer";
                    begin
                        if SubscriptionEntryNo <> 0 then
                            UsageDataSubscription.Get(SubscriptionEntryNo);
                        if UsageDataSupplierNo <> '' then
                            UsageDataSubscription.SetRange("Supplier No.", UsageDataSupplierNo);

                        UsageDataCustomer.SetRange("Supplier No.", UsageDataSupplierNo);
                        if UsageDataCustomer.FindFirst() then
                            UsageDataSubscription.SetRange("Customer ID", UsageDataCustomer."Supplier Reference");

                        LookupUsageDataSubscription(UsageDataSubscription);
                        CurrPage.Update();
                    end;
                }
                field(VendorContractNo; VendorContractNo)
                {
                    Caption = 'Vendor Subscription Contract No.';
                    ToolTip = 'Specifies the Vendor Subscription Contract that will be extended.';
                    Editable = ExtendVendorContract;
                    TableRelation = "Vendor Subscription Contract";

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupVendorContract();
                    end;

                    trigger OnValidate()
                    begin
                        GetVendorContract();
                    end;
                }
                field("Buy-from Vendor Name"; VendorContract."Buy-from Vendor Name")
                {
                    Caption = 'Buy-from Vendor Name';
                    ToolTip = 'Specifies to which vendor the selected Vendor Subscription Contract is created.';
                    Editable = false;
                    Enabled = false;
                }
            }
            group(Customer)
            {
                Caption = 'Customer';
                field(ExtendCustomerContract; ExtendCustomerContract)
                {
                    Caption = 'Extend Customer Subscription Contract';
                    ToolTip = 'Specifies whether Customer Subscription Contract should be extended with provided Subscription Line.';

                    trigger OnValidate()
                    begin
                        ValidateExtendCustomerContract();
                    end;
                }
                field("Customer Name"; CustomerContract."Sell-to Customer Name")
                {
                    Caption = 'Customer Name';
                    ToolTip = 'Specifies the customer to whom the Customer Subscription Contract to be extended is created.';
                    Editable = false;
                }
                field(CustomerContractNo; CustomerContractNo)
                {
                    Caption = 'Customer Subscription Contract No.';
                    ToolTip = 'Specifies the Customer Subscription Contract to be extended.';
                    Editable = ExtendCustomerContract;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupCustomerContract();
                    end;

                    trigger OnValidate()
                    begin
                        GetCustomerContract();
                    end;
                }
                field("Sell-to Customer Name"; CustomerContract."Sell-to Customer Name")
                {
                    Caption = 'Sell-to Customer Name';
                    ToolTip = 'Specifies the customer to whom the Customer Subscription Contract to be extended is created.';
                    Editable = ExtendCustomerContract;
                    Enabled = false;
                }
                field("Contract Type"; CustomerContract."Contract Type")
                {
                    Caption = 'Contract Type';
                    ToolTip = 'Shows the Subscription Contract Type of the selected Customer Subscription Contract.';
                    Editable = false;
                    Enabled = false;
                    Visible = false;
                }
            }
            group(Item)
            {
                Caption = 'Item';
                field(ItemNo; ItemNo)
                {
                    Caption = 'Item No.';
                    ToolTip = 'Specifies the item number for the Subscription Line to be created.';
                    TableRelation = Item where("Subscription Option" = const("Service Commitment Item"));

                    trigger OnValidate()
                    begin
                        ValidateItemNo();
                        ItemDescription := ContractItemMgt.GetItemTranslation(ItemNo, '', SellToCustomerNo);
                        CurrPage.Update();
                    end;
                }
                field(ItemDescription; ItemDescription)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the item description for the Subscription Item to be created.';
                    Editable = false;
                }
                field(AdditionalServiceCommitments; StrSubstNo(NoOfSelectedPackagesLbl, SelectedServiceCommitmentPackages, TotalServiceCommitmentPackage))
                {
                    Caption = 'Additional Subscription Lines';
                    ToolTip = 'Specifies if Subscription Lines (in addition to those marked as "Default") have been selected. AssistEdit allows the selection of additional Subscription Lines.';
                    Editable = false;

                    trigger OnAssistEdit()
                    begin
                        GetAdditionalServiceCommitments();
                        CurrPage.Update();
                    end;
                }
                field(Quantity; QuantityDecimal)
                {
                    Caption = 'Quantity';
                    ToolTip = 'Specifies the quantity for the Subscription Item to be created.';

                    trigger OnValidate()
                    begin
                        GetItemCost();
                        ContractItemMgt.GetSalesPriceForItem(UnitPrice, ItemNo, QuantityDecimal, CustomerContract."Currency Code", CustomerContract."Sell-to Customer No.", CustomerContract."Bill-to Customer No.");
                    end;
                }
                field(UnitCostLCY; UnitCostLCY)
                {
                    Caption = 'Unit Cost (LCY)';
                    ToolTip = 'Specifies the cost price in customer currency for the selected item.';
                    DecimalPlaces = 2 : 5;
                    Editable = false;
                }
                field(UnitPrice; UnitPrice)
                {
                    Caption = 'Unit Price';
                    ToolTip = 'Specifies the sales price for the selected item.';
                    DecimalPlaces = 2 : 5;
                    Editable = false;
                }
                field(ProvisionStartDate; ProvisionStartDate)
                {
                    Caption = 'Provision Start Date';
                    ToolTip = 'Specifies the date on which the Subscription Item and Subscription Lines will be provided.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Perform Extension")
            {
                Caption = 'Perform Extension';
                ToolTip = 'Performs the creation of a Subscription and the extension of the contracts as specified.';
                Image = AddAction;
                Visible = not IsLookupMode;

                trigger OnAction()
                begin
                    ExtendContract();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Perform Extension_Promoted"; "Perform Extension")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        IsLookupMode := CurrPage.LookupMode;

        SetGlobalsFromParameters();

        if ItemNo <> '' then
            if not Item.Get(ItemNo) then begin
                Clear(ItemNo);
                Clear(ItemDescription);
            end;
        if CustomerContractNo <> '' then
            if not CustomerContract.Get(CustomerContractNo) then
                Clear(CustomerContractNo);
        if VendorContractNo <> '' then
            if not VendorContract.Get(VendorContractNo) then
                Clear(VendorContractNo);

        FillTempServiceCommitmentPackage();
        ValidateExtendCustomerContract();
        ValidateExtendVendorContract();
        ValidateItemNo();
        ValidateUsageSupplierNo();
        ValidateSubscriptionEntryNo();

        CountTotalServiceCommitmentPackage();
        CurrPage.Update();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CurrPage.LookupMode and (CloseAction = Action::LookupOK) then
            ExtendContract();

        exit(true);
    end;

    local procedure ExtendContract()
    var
        ServiceObject: Record "Subscription Header";
        ServiceCommitment: Record "Subscription Line";
    begin
        OnBeforeExtendContract();
        if SupplierReferenceEntryNo <> 0 then begin
            ServiceCommitment.SetRange("Supplier Reference Entry No.", SupplierReferenceEntryNo);
            if ServiceCommitment.FindFirst() then
                Error(SubscriptionIsLinkedToServiceCommitmentErr, ServiceCommitment."Subscription Header No.");
        end;
        if ExtendCustomerContract then
            CustomerContract.TestField("No.");
        if ExtendVendorContract then
            VendorContract.TestField("No.");

        Item.TestField("No.");
        ErrorIfItemServCommPackageMissingForItem();

        if ProvisionStartDate = 0D then
            Error(ProvisionStartDateEmptyErr);

        ServiceObject.InsertFromItemNoAndCustomerContract(ServiceObject, ItemNo, QuantityDecimal, ProvisionStartDate, CustomerContract);
        ServiceObject.SetUnitPriceAndUnitCostFromExtendContract(UnitPrice, UnitCostLCY);
        ExtendContractMgt.ExtendContract(ServiceObject, TempServiceCommitmentPackage, ExtendCustomerContract, CustomerContract, ExtendVendorContract, VendorContract, false, SupplierReferenceEntryNo);
        ServiceObject.ResetCalledFromExtendContract();
    end;

    local procedure ValidateSellToCustomerNo()
    begin
        if (SellToCustomerNo = '') or (CustomerContractNo = '') then
            exit;
        CustomerContract.Get(CustomerContractNo);
        if CustomerContract."Sell-to Customer No." <> SellToCustomerNo then begin
            CustomerContractNo := '';
            Clear(CustomerContract);
        end;
    end;

    local procedure ValidateExtendVendorContract()
    begin
        if not ExtendVendorContract then
            VendorContractNo := '';
        GetVendorContract();
    end;

    local procedure ValidateExtendCustomerContract()
    begin
        if not ExtendCustomerContract then begin
            CustomerContractNo := '';
            SellToCustomerNo := '';
        end;
        GetCustomerContract();
        ValidateSellToCustomerNo();
    end;

    local procedure LookupCustomerContract()
    begin
        if SellToCustomerNo <> '' then
            CustomerContract.SetRange("Sell-to Customer No.", SellToCustomerNo);

        if Page.RunModal(0, CustomerContract) = Action::LookupOK then begin
            CustomerContractNo := CustomerContract."No.";
            GetCustomerContract();
        end;
    end;

    local procedure GetCustomerContract()
    begin
        if CustomerContractNo = '' then
            Clear(CustomerContract)
        else begin
            CustomerContract.Get(CustomerContractNo);
            SellToCustomerNo := CustomerContract."Sell-to Customer No.";
            ItemDescription := ContractItemMgt.GetItemTranslation(ItemNo, '', SellToCustomerNo);
        end;
        ContractItemMgt.GetSalesPriceForItem(UnitPrice, ItemNo, QuantityDecimal, CustomerContract."Currency Code", CustomerContract."Sell-to Customer No.", CustomerContract."Bill-to Customer No.");
    end;

    local procedure LookupVendorContract()
    begin
        if Page.RunModal(0, VendorContract) = Action::LookupOK then begin
            VendorContractNo := VendorContract."No.";
            GetVendorContract();
        end;
    end;

    local procedure GetVendorContract()
    begin
        if VendorContractNo = '' then
            Clear(VendorContract)
        else
            VendorContract.Get(VendorContractNo);
        GetItemCost();
    end;

    local procedure ValidateItemNo()
    begin
        if ItemNo = '' then begin
            UnitPrice := 0;
            UnitCostLCY := 0;
            Clear(Item);
            exit;
        end;

        if ItemNo = Item."No." then
            exit;

        FillTempServiceCommitmentPackage();

        Item.Get(ItemNo);
        ErrorIfItemServCommPackageMissingForItem();

        GetItemCost();
        ContractItemMgt.GetSalesPriceForItem(UnitPrice, ItemNo, QuantityDecimal, CustomerContract."Currency Code", CustomerContract."Sell-to Customer No.", CustomerContract."Bill-to Customer No.");
        CountTotalServiceCommitmentPackage();
        ShowNotificationIfStandardSubscriptionPackageDoesNotContainUBBLine(ItemNo);
        OnAfterValidateItemNo(ItemNo);
    end;

    local procedure ShowNotificationIfStandardSubscriptionPackageDoesNotContainUBBLine(ItemNo: Code[20])
    var
        SubscriptionPackage: Record "Subscription Package";
        ItemSubscriptionPackage: Record "Item Subscription Package";
        NoUBBServiceCommitmentPackFoundMsg: Label 'No standard Subscription Package for usage-based billing is assigned to the item %1.';
    begin
        if UsageDataSupplierNo = '' then
            exit;
        SubscriptionPackage.FilterCodeOnPackageFilter(ItemSubscriptionPackage.GetAllStandardPackageFilterForItem(ItemNo, ''));
        ShowNoStandardSubscriptionPackageNotification(SubscriptionPackage, StrSubstNo(NoUBBServiceCommitmentPackFoundMsg, ItemNo), GetNoUBBSubscriptionPackageFound2NotificationId());
    end;

    local procedure ShowNotificationIfNoUBBSubscriptionPackageIsSelected(var TempSubscriptionPackage: Record "Subscription Package" temporary; ItemNo: Code[20])
    var
        NoUBBServiceCommitmentPackFoundMsg: Label 'None of the selected Subscription Package are intended for usage-based billing.';
    begin
        if UsageDataSupplierNo = '' then
            exit;
        TempSubscriptionPackage.SetRange(Selected, true);
        if TempSubscriptionPackage.IsEmpty() then begin
            ShowNotificationIfStandardSubscriptionPackageDoesNotContainUBBLine(ItemNo);
            exit;
        end;
        ShowNoStandardSubscriptionPackageNotification(TempSubscriptionPackage, NoUBBServiceCommitmentPackFoundMsg, GetNoUBBSubscriptionPackageFoundNotificationId());
        TempSubscriptionPackage.SetRange(Selected);
    end;

    local procedure ShowNoStandardSubscriptionPackageNotification(var TempSubscriptionPackage: Record "Subscription Package"; NotificationMsg: Text; NotificationId: Guid)
    var
        Notification: Notification;
    begin
        if TempSubscriptionPackage.FindSet() then
            repeat
                if TempSubscriptionPackage.ServCommPackageLineExists() then
                    exit; // Found a valid package, no need to show notification
            until TempSubscriptionPackage.Next() = 0;

        Notification.Id := NotificationId;
        Notification.Recall(); //Make sure that notification is not shown multiple times
        Notification.Message := NotificationMsg;
        Notification.Scope := NotificationScope::LocalScope;
        Notification.Send();
    end;

    local procedure GetNoUBBSubscriptionPackageFoundNotificationId(): Guid
    begin
        exit('e42bd3b9-12a0-47aa-b577-feaa442897b3');
    end;

    local procedure GetNoUBBSubscriptionPackageFound2NotificationId(): Guid
    begin
        exit('0301564b-e9d8-490a-99e4-fc88c5cec48d');
    end;

    local procedure ErrorIfItemServCommPackageMissingForItem()
    var
        ItemServCommitmentPackage: Record "Item Subscription Package";
        ItemPackageMissingErrorInfo: ErrorInfo;
    begin
        ItemServCommitmentPackage.SetRange("Item No.", Item."No.");
        if ItemServCommitmentPackage.IsEmpty then begin
            ItemPackageMissingErrorInfo.Title(ItemMissingServCommPackageTxt);
            ItemPackageMissingErrorInfo.Message(AssignServCommPackageToItemTxt);
            ItemPackageMissingErrorInfo.RecordId := Item.RecordId;
            ItemPackageMissingErrorInfo.PageNo := Page::"Item Card";
            ItemPackageMissingErrorInfo.AddNavigationAction(OpenItemCardTxt);
            Error(ItemPackageMissingErrorInfo);
        end;
    end;

    local procedure ValidateUsageSupplierNo()
    begin
        if UsageDataSupplierNo = '' then begin
            Clear(UsageDataSupplier);
            exit;
        end;

        ExtendVendorContract := true;
        ValidateExtendVendorContract();
    end;

    local procedure ValidateSubscriptionEntryNo()
    var
        UsageDataSubscription: Record "Usage Data Supp. Subscription";
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        UsageDataCustomer: Record "Usage Data Supp. Customer";
        ItemVendor: Record "Item Vendor";
        ServiceCommitment: Record "Subscription Line";
        SubscriptionAlreadyConnectedErr: Label 'This Subscription is already connected to Subscription %1 Subscription Line %2. Contract extension is not possible.', Comment = '%1 = SubscriptionLine."Subscription No.",  %2 = SubscriptionLine."Line No."';
    begin
        SubscriptionDescription := '';
        if SubscriptionEntryNo <> 0 then begin
            UsageDataSubscription.Get(SubscriptionEntryNo);
            UsageDataSupplierNo := UsageDataSubscription."Supplier No.";
            SubscriptionDescription := UsageDataSubscription."Product Name";

            ValidateUsageSupplierNo();
            QuantityDecimal := UsageDataSubscription.Quantity;
            Clear(ItemNo);
            ValidateItemNo();
            if UsageDataSupplierReference.FindSupplierReference(UsageDataSupplierNo, UsageDataSubscription."Product ID", UsageDataSupplierReference.Type::Product) then begin
                ItemVendor.SetRange("Supplier Ref. Entry No.", UsageDataSupplierReference."Entry No.");
                if ItemVendor.FindFirst() then begin
                    ItemNo := ItemVendor."Item No.";
                    ValidateItemNo();
                end;
            end;
            if ExtendCustomerContract then
                if UsageDataSupplierReference.FindSupplierReference(UsageDataSupplierNo, UsageDataSubscription."Customer ID", UsageDataSupplierReference.Type::Customer) then begin
                    UsageDataCustomer.SetRange("Supplier Reference Entry No.", UsageDataSupplierReference."Entry No.");
                    if UsageDataCustomer.FindFirst() then begin
                        SellToCustomerNo := UsageDataCustomer."Customer No.";
                        ValidateSellToCustomerNo();
                    end;
                end;

            if (UsageDataSupplierNo <> '') and (UsageDataSubscription."Supplier Reference Entry No." <> 0) then
                if ImportAndProcessUsageData.GetServiceCommitmentForSubscription(UsageDataSupplierNo, UsageDataSubscription."Supplier Reference", ServiceCommitment) then
                    Error(SubscriptionAlreadyConnectedErr, ServiceCommitment."Subscription Header No.", ServiceCommitment."Entry No.");

            SupplierReferenceEntryNo := UsageDataSubscription."Supplier Reference Entry No.";
        end;
    end;

    local procedure GetItemCost()
    begin
        UnitCostLCY := ContractItemMgt.CalculateUnitCost(ItemNo);
    end;

    local procedure GetAdditionalServiceCommitments()
    begin
        TempServiceCommitmentPackage.Reset();
        if not TempServiceCommitmentPackage.IsEmpty() then
            Page.RunModal(Page::"Assign Service Comm. Packages", TempServiceCommitmentPackage);

        CountSelectedServiceCommitmentPackages();
        ShowNotificationIfNoUBBSubscriptionPackageIsSelected(TempServiceCommitmentPackage, ItemNo);
        OnAfterGetAdditionalServiceCommitments(TempServiceCommitmentPackage, ItemNo);
    end;

    local procedure FilterNonStandardServiceCommitmentPackage(var ServiceCommitmentPackage: Record "Subscription Package")
    var
        Cust: Record Customer;
        ItemServCommitmentPackage: Record "Item Subscription Package";
        PackageFilter: Text;
    begin
        if SellToCustomerNo <> '' then begin
            Cust.Get(SellToCustomerNo);
            ServiceCommitmentPackage.SetRange("Price Group", Cust."Customer Price Group");
        end;
        if ServiceCommitmentPackage.IsEmpty then
            ServiceCommitmentPackage.SetRange("Price Group");

        PackageFilter := ItemServCommitmentPackage.GetPackageFilterForItem(ItemNo, '', true);
        ServiceCommitmentPackage.FilterCodeOnPackageFilter(PackageFilter);
    end;

    local procedure CountTotalServiceCommitmentPackage()
    begin
        TempServiceCommitmentPackage.Reset();
        TotalServiceCommitmentPackage := TempServiceCommitmentPackage.Count();
        CountSelectedServiceCommitmentPackages();
    end;

    local procedure SetGlobalsFromParameters()
    begin
        SellToCustomerNo := SellToCustomerNoParam;
        CustomerContractNo := CustomerContractNoParam;
        ProvisionStartDate := ProvisionStartDateParam;
        ExtendCustomerContract := ExtendCustomerContractParam;
        UsageDataSupplierNo := UsageDataSupplierNoParam;
        SubscriptionEntryNo := SubscriptionEntryNoParam;
    end;

    local procedure FillTempServiceCommitmentPackage()
    var
        ServiceCommitmentPackage: Record "Subscription Package";
    begin
        TempServiceCommitmentPackage.Reset();
        TempServiceCommitmentPackage.DeleteAll(false);
        FilterNonStandardServiceCommitmentPackage(ServiceCommitmentPackage);
        if ServiceCommitmentPackage.FindSet() then
            repeat
                TempServiceCommitmentPackage.TransferFields(ServiceCommitmentPackage);
                TempServiceCommitmentPackage.Insert(false);
            until ServiceCommitmentPackage.Next() = 0;
    end;

    local procedure CountSelectedServiceCommitmentPackages()
    begin
        TempServiceCommitmentPackage.SetRange(Selected, true);
        SelectedServiceCommitmentPackages := TempServiceCommitmentPackage.Count();
        TempServiceCommitmentPackage.SetRange(Selected);
    end;

    internal procedure SetParameters(NewCustomerNo: Code[20]; NewCustomerContractNo: Code[20]; NewProvisionStartDate: Date; NewExtendCustomerContract: Boolean)
    begin
        SellToCustomerNoParam := NewCustomerNo;
        CustomerContractNoParam := NewCustomerContractNo;
        ProvisionStartDateParam := NewProvisionStartDate;
        ExtendCustomerContractParam := NewExtendCustomerContract;
    end;

    local procedure LookupUsageDataSubscription(var UsageDataSubscription: Record "Usage Data Supp. Subscription")
    begin
        if Page.RunModal(0, UsageDataSubscription) = Action::LookupOK then begin
            SubscriptionEntryNo := UsageDataSubscription."Entry No.";
            ValidateSubscriptionEntryNo();
        end;
    end;

    internal procedure SetUsageBasedParameters(SupplierNo: Code[20]; NewSubscriptionEntryNo: Integer)
    begin
        UsageDataSupplierNoParam := SupplierNo;
        SubscriptionEntryNoParam := NewSubscriptionEntryNo;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExtendContract()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetAdditionalServiceCommitments(var TempServiceCommitmentPackage: Record "Subscription Package" temporary; ItemNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateItemNo(ItemNo: Code[20])
    begin
    end;

    var
        CustomerContract: Record "Customer Subscription Contract";
        VendorContract: Record "Vendor Subscription Contract";
        Item: Record Item;
        TempServiceCommitmentPackage: Record "Subscription Package" temporary;
        UsageDataSupplier: Record "Usage Data Supplier";
        ContractItemMgt: Codeunit "Sub. Contracts Item Management";
        ExtendContractMgt: Codeunit "Extend Sub. Contract Mgt.";
        ImportAndProcessUsageData: Codeunit "Import And Process Usage Data";
        CustomerContractNo: Code[20];
        VendorContractNo: Code[20];
        UnitPrice: Decimal;
        UnitCostLCY: Decimal;
        ProvisionStartDate: Date;
        ProvisionStartDateEmptyErr: Label 'Provision Start Date cannot be empty.';
        NoOfSelectedPackagesLbl: Label '%1 of %2';
        SelectedServiceCommitmentPackages: Integer;
        IsLookupMode: Boolean;
        TotalServiceCommitmentPackage: Integer;
        SellToCustomerNoParam: Code[20];
        CustomerContractNoParam: Code[20];
        ProvisionStartDateParam: Date;
        ExtendCustomerContractParam: Boolean;
        UsageDataSupplierNo: Code[20];
        UsageDataSupplierNoParam: Code[20];
        SubscriptionDescription: Text[100];
        SubscriptionEntryNo: Integer;
        SubscriptionEntryNoParam: Integer;
        SupplierReferenceEntryNo: Integer;
        SubscriptionIsLinkedToServiceCommitmentErr: Label 'The action can only be called for Subscriptions that are not yet linked to a Subscription Line. The Subscription is already connected to Subscription %1. If necessary, detach the Subscription(s) from the Subscription Line(s).';
        OpenItemCardTxt: Label 'Open Item Card.';
        ItemMissingServCommPackageTxt: Label 'No Subscription Package is available for this item.';
        AssignServCommPackageToItemTxt: Label 'In order to extend the contract properly, please make sure that at least one package is assigned.';
        ItemDescription: Text[100];

    protected var
        ItemNo: Code[20];
        QuantityDecimal: Decimal;
        ExtendCustomerContract: Boolean;
        ExtendVendorContract: Boolean;
        SellToCustomerNo: Code[20];
}
