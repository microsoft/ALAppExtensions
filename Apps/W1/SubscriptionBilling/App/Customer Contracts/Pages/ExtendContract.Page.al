namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Item.Catalog;

page 8002 "Extend Contract"
{
    ApplicationArea = All;
    Caption = 'Extend Contract';
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
                    Caption = 'Extend Vendor Contract';
                    ToolTip = 'Specifies whether Vendor Contract should be extended with provided service commitment.';

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
                    ToolTip = 'Specifies the subscription for which the Service Object and Service Commitments are created.';
                    Editable = false;

                    trigger OnAssistEdit()
                    var
                        UsageDataSubscription: Record "Usage Data Subscription";
                        UsageDataCustomer: Record "Usage Data Customer";
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
                    Caption = 'Vendor Contract No.';
                    ToolTip = 'Specifies the vendor contract that will be extended.';
                    Editable = ExtendVendorContract;
                    TableRelation = "Vendor Contract";

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
                    ToolTip = 'Specifies to which vendor the selected vendor contract is created.';
                    Editable = false;
                    Enabled = false;
                }
            }
            group(Customer)
            {
                Caption = 'Customer';
                field(ExtendCustomerContract; ExtendCustomerContract)
                {
                    Caption = 'Extend Customer Contract';
                    ToolTip = 'Specifies whether Customer Contract should be extended with provided Service Commitment.';

                    trigger OnValidate()
                    begin
                        ValidateExtendCustomerContract();
                    end;
                }
                field("Customer Name"; CustomerContract."Sell-to Customer Name")
                {
                    Caption = 'Customer Name';
                    ToolTip = 'Specifies the customer to whom the customer contract to be extended is created.';
                    Editable = false;
                }
                field(CustomerContractNo; CustomerContractNo)
                {
                    Caption = 'Customer Contract No.';
                    ToolTip = 'Specifies the customer contract to be extended.';
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
                    ToolTip = 'Specifies the customer to whom the customer contract to be extended is created.';
                    Editable = ExtendCustomerContract;
                    Enabled = false;
                }

                field("Contract Type"; CustomerContract."Contract Type")
                {
                    Caption = 'Contract Type';
                    ToolTip = 'Shows the contract type of the selected customer contract.';
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
                    ToolTip = 'Specifies the item number for the service commitment to be created.';
                    TableRelation = Item where("Service Commitment Option" = const("Service Commitment Item"));

                    trigger OnValidate()
                    begin
                        ValidateItemNo();
                        CurrPage.Update();
                    end;
                }
                field(ItemDescription; Item.Description)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the item description for the service commitment item to be created.';
                    Editable = false;
                }
                field(AdditionalServiceCommitments; StrSubstNo(NoOfSelectedPackagesLbl, SelectedServiceCommitmentPackages, TotalServiceCommitmentPackage))
                {
                    Caption = 'Additional Service Commitments';
                    ToolTip = 'Specifies if services (in addition to those marked as "Default") have been selected. AssistEdit allows the selection of additional services.';
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
                    ToolTip = 'Specifies the quantity for the service commitment item to be created.';

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
                    ToolTip = 'Specifies the date on which the service commitment item and services will be provided.';
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
                ToolTip = 'Performs the creation of a service object and the extension of the contracts as specified.';
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
            if not Item.Get(ItemNo) then
                Clear(ItemNo);
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
        ServiceObject: Record "Service Object";
        ServiceCommitment: Record "Service Commitment";
    begin
        if SupplierReferenceEntryNo <> 0 then begin
            ServiceCommitment.SetRange("Supplier Reference Entry No.", SupplierReferenceEntryNo);
            if ServiceCommitment.FindFirst() then
                Error(SubscriptionIsLinkedToServiceCommitmentErr, ServiceCommitment."Service Object No.");
        end;
        if ExtendCustomerContract then
            CustomerContract.TestField("No.");
        if ExtendVendorContract then
            VendorContract.TestField("No.");

        Item.TestField("No.");
        ErrorIfItemServCommPackageMissingForItem();

        if ProvisionStartDate = 0D then
            Error(ProvisionStartDateEmptyErr);

        ServiceObject.InsertFromItemNoAndSelltoCustomerNo(ServiceObject, ItemNo, QuantityDecimal, CustomerContract."Sell-to Customer No.", ProvisionStartDate);
        ServiceObject.SetUnitPriceAndUnitCostFromExtendContract(UnitPrice, UnitCostLCY);
        ExtendContractMgt.ExtendContract(ServiceObject, TempServiceCommitmentPackage, ExtendCustomerContract, CustomerContract, ExtendVendorContract, VendorContract, false, SupplierReferenceEntryNo);
        ServiceObject.ResetCalledFromExtendContract();
    end;

    internal procedure ValidateSellToCustomerNo()
    begin
        if (SellToCustomerNo = '') or (CustomerContractNo = '') then
            exit;
        CustomerContract.Get(CustomerContractNo);
        if CustomerContract."Sell-to Customer No." <> SellToCustomerNo then begin
            CustomerContractNo := '';
            Clear(CustomerContract);
        end;
    end;

    internal procedure ValidateExtendVendorContract()
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

    internal procedure ValidateItemNo()
    begin
        if ItemNo = Item."No." then
            exit;

        if ItemNo = '' then begin
            Clear(Item);
            exit;
        end;

        FillTempServiceCommitmentPackage();

        Item.Get(ItemNo);
        ErrorIfItemServCommPackageMissingForItem();

        GetItemCost();
        ContractItemMgt.GetSalesPriceForItem(UnitPrice, ItemNo, QuantityDecimal, CustomerContract."Currency Code", CustomerContract."Sell-to Customer No.", CustomerContract."Bill-to Customer No.");
        CountTotalServiceCommitmentPackage();
    end;

    local procedure ErrorIfItemServCommPackageMissingForItem()
    var
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
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
        UsageDataSubscription: Record "Usage Data Subscription";
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        UsageDataCustomer: Record "Usage Data Customer";
        ItemVendor: Record "Item Vendor";
        ServiceCommitment: Record "Service Commitment";
        SubscriptionAlreadyConnectedErr: Label 'This Subscription is already connected to Service Object %1 Service Commitment %2. Contract extension is not possible.', Comment = '%1 = ServiceCommitment."Service Object No.",  %2 = ServiceCommitment."Line No."';
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
                if GenericUsageDataImport.GetServiceCommitmentForSubscription(UsageDataSupplierNo, UsageDataSubscription."Supplier Reference", ServiceCommitment) then
                    Error(SubscriptionAlreadyConnectedErr, ServiceCommitment."Service Object No.", ServiceCommitment."Entry No.");

            SupplierReferenceEntryNo := UsageDataSubscription."Supplier Reference Entry No.";
        end;
    end;

    local procedure GetItemCost()
    var
        TempSalesLine: Record "Sales Line" temporary;
    begin
        UnitCostLCY := 0;
        if (VendorContract."No." = '') or (ItemNo = '') then
            exit;

        TempSalesLine.Type := "Sales Line Type"::Item;
        TempSalesLine."No." := ItemNo;
        TempSalesLine.Quantity := QuantityDecimal;
        TempSalesLine."Unit of Measure Code" := Item."Base Unit of Measure";
        UnitCostLCY := Item."Last Direct Cost" * TempSalesLine."Qty. per Unit of Measure";
    end;

    local procedure GetAdditionalServiceCommitments()
    begin
        TempServiceCommitmentPackage.Reset();
        if not TempServiceCommitmentPackage.IsEmpty() then
            Page.RunModal(Page::"Assign Service Comm. Packages", TempServiceCommitmentPackage);

        CountSelectedServiceCommitmentPackages();
    end;

    local procedure FilterNonStandardServiceCommitmentPackage(var ServiceCommitmentPackage: Record "Service Commitment Package")
    var
        Cust: Record Customer;
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
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
        ServiceCommitmentPackage: Record "Service Commitment Package";
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

    local procedure LookupUsageDataSubscription(var UsageDataSubscription: Record "Usage Data Subscription")
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

    [InternalEvent(false, false)]
    local procedure OnBeforeExtendContract()
    begin
    end;

    var
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        Item: Record Item;
        TempServiceCommitmentPackage: Record "Service Commitment Package" temporary;
        UsageDataSupplier: Record "Usage Data Supplier";
        ContractItemMgt: Codeunit "Contracts Item Management";
        ExtendContractMgt: Codeunit "Extend Contract Mgt.";
        GenericUsageDataImport: Codeunit "Generic Usage Data Import";
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
        SubscriptionIsLinkedToServiceCommitmentErr: Label 'The action can only be called for Subscriptions that are not yet linked to a Service Commitment. The Subscription is already connected to Service Object %1. If necessary, detach the Subscription(s) from the Service Commitment(s).';
        OpenItemCardTxt: Label 'Open Item Card.';
        ItemMissingServCommPackageTxt: Label 'No Service Commitment Package is available for this item.';
        AssignServCommPackageToItemTxt: Label ' In order to extend the contract properly, please make sure that at least one package is assigned.';

    protected var
        ItemNo: Code[20];
        QuantityDecimal: Decimal;
        ExtendCustomerContract: Boolean;
        ExtendVendorContract: Boolean;
        SellToCustomerNo: Code[20];
}
