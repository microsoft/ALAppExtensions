namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item.Catalog;

codeunit 8025 "Import And Process Usage Data"
{
    TableNo = "Usage Data Import";
    SingleInstance = true;

    var
        UsageDataProcessing: Interface "Usage Data Processing";

    trigger OnRun()
    begin
        case Rec."Processing Step" of
            Enum::"Processing Step"::"Create Imported Lines":
                ImportUsageData(Rec);
            Enum::"Processing Step"::"Process Imported Lines":
                ProcessUsageData(Rec);
        end;
    end;

    local procedure ImportUsageData(var UsageDataImport: Record "Usage Data Import")
    var
        UsageDataSupplier: Record "Usage Data Supplier";
    begin
        UsageDataSupplier.Get(UsageDataImport."Supplier No.");
        UsageDataProcessing := UsageDataSupplier.Type;
        UsageDataProcessing.ImportUsageData(UsageDataImport);
    end;

    local procedure ProcessUsageData(var UsageDataImport: Record "Usage Data Import")
    var
        UsageDataSupplier: Record "Usage Data Supplier";
    begin
        UsageDataSupplier.Get(UsageDataImport."Supplier No.");
        UsageDataProcessing := UsageDataSupplier.Type;
        UsageDataProcessing.ProcessUsageData(UsageDataImport);
    end;

    procedure CreateUsageDataCustomer(CustomerId: Text[80]; UsageDataSupplierReference: Record "Usage Data Supplier Reference"; SupplierNo: Code[20])
    var
        UsageDataCustomer: Record "Usage Data Supp. Customer";
    begin
        UsageDataCustomer.SetRange("Supplier No.", SupplierNo);
        UsageDataCustomer.SetRange("Supplier Reference", CustomerId);
        if UsageDataCustomer.IsEmpty() then begin
            UsageDataCustomer.Init();
            UsageDataCustomer."Entry No." := 0;
            UsageDataCustomer.Validate("Supplier No.", SupplierNo);
            UsageDataCustomer.Validate("Supplier Reference", CustomerId);
            UsageDataSupplierReference.CreateSupplierReference(UsageDataCustomer."Supplier No.", UsageDataCustomer."Supplier Reference", Enum::"Usage Data Reference Type"::Customer);
            UsageDataCustomer."Supplier Reference Entry No." := UsageDataSupplierReference."Entry No.";
            UsageDataCustomer.Insert(true);
        end;
    end;

    procedure CreateUsageDataSubscription(SubscriptionID: Text[80]; CustomerID: Text[80]; ProductID: Text[80]; ProductName: Text[100]; Unit: Text[80];
                                                    Quantity: Decimal; SubscriptionStartDate: Date; SubscriptionEndDate: Date;
                                                    UsageDataSupplierReference: Record "Usage Data Supplier Reference"; SupplierNo: Code[20])
    var
        UsageDataSubscription: Record "Usage Data Supp. Subscription";
        UsageDataCustomer: Record "Usage Data Supp. Customer";
    begin
        if UsageDataSubscription.FindForSupplierReference(SupplierNo, SubscriptionID) then begin
            UsageDataCustomer.SetRange("Supplier No.", SupplierNo);
            UsageDataCustomer.SetRange("Supplier Reference", CustomerID);
            if UsageDataCustomer.FindFirst() then begin
                UsageDataSubscription.Validate("Customer No.", UsageDataCustomer."Customer No.");
                UsageDataSubscription.Modify(true);
            end;
        end else begin
            UsageDataSubscription.Init();
            UsageDataSubscription."Entry No." := 0;
            UsageDataSubscription.Validate("Supplier No.", SupplierNo);
            UsageDataSubscription.Validate("Supplier Reference", SubscriptionID);
            UsageDataSubscription.Validate("Customer ID", CustomerID);
            UsageDataSubscription.Validate("Product ID", ProductID);
            UsageDataSubscription.Validate("Product Name", ProductName);
            UsageDataSubscription.Validate("Unit Type", Unit);
            UsageDataSubscription.Validate(Quantity, Quantity);
            UsageDataSubscription.Validate("Start Date", SubscriptionStartDate);
            UsageDataSubscription.Validate("End Date", SubscriptionEndDate);
            UsageDataSupplierReference.CreateSupplierReference(SupplierNo, UsageDataSubscription."Supplier Reference", Enum::"Usage Data Reference Type"::Subscription);
            UsageDataSubscription."Supplier Reference Entry No." := UsageDataSupplierReference."Entry No.";
            if UsageDataSubscription."Product ID" <> '' then
                UsageDataSupplierReference.CreateSupplierReference(SupplierNo, UsageDataSubscription."Product ID", Enum::"Usage Data Reference Type"::Product);
            UsageDataSubscription.Insert(true);
        end;
    end;

    procedure GetServiceCommitmentForSubscription(SupplierNo: Code[20]; SubscriptionReference: Text[80]; var ServiceCommitment: Record "Subscription Line"): Boolean
    var
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
    begin
        UsageDataSupplierReference.FilterUsageDataSupplierReference(SupplierNo, SubscriptionReference, Enum::"Usage Data Reference Type"::Subscription);
        if not UsageDataSupplierReference.FindFirst() then
            exit;

        ServiceCommitment.Reset();
        ServiceCommitment.SetCurrentKey(ServiceCommitment."Subscription Line Start Date");
        ServiceCommitment.SetRange("Supplier Reference Entry No.", UsageDataSupplierReference."Entry No.");
        ServiceCommitment.SetRange(Partner, Enum::"Service Partner"::Vendor);
        ServiceCommitment.SetRange("Subscription Line End Date", 0D);

        if ServiceCommitment.IsEmpty() then
            ServiceCommitment.SetRange("Subscription Line End Date");

        if ServiceCommitment.IsEmpty() then
            ServiceCommitment.SetRange(Partner);
        exit(ServiceCommitment.FindLast());
    end;

    internal procedure SetError(var UsageDataImport: Record "Usage Data Import"; Reason: Text)
    begin
        UsageDataImport."Processing Status" := UsageDataImport."Processing Status"::Error;
        UsageDataImport.SetReason(Reason);
    end;

    internal procedure AvailableServiceObjectExist(var UsageDataImport: Record "Usage Data Import"; SubscriptionID: Text[80]): Boolean
    var
        UsageDataSubscription: Record "Usage Data Supp. Subscription";
        UsageDataSupplier: Record "Usage Data Supplier";
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        ItemReference: Record "Item Reference";
        SubscriptionLineWithoutReference: Record "Subscription Line";
        SubscriptionLineWithReference: Record "Subscription Line";
    begin
        if not UsageDataSupplier.Get(UsageDataImport."Supplier No.") then
            exit(false);

        if not UsageDataSubscription.FindForSupplierReference(UsageDataImport."Supplier No.", SubscriptionID) then
            exit(false);

        if not UsageDataSupplierReference.FindSupplierReference(UsageDataImport."Supplier No.", UsageDataSubscription."Product ID", Enum::"Usage Data Reference Type"::Product) then
            exit(false);

        if not ItemReference.FindForVendorAndSupplierReference(UsageDataSupplier."Vendor No.", UsageDataSupplierReference."Entry No.") then
            exit(false);

        SubscriptionLineWithoutReference.SetRange("Source Type", Enum::"Service Object Type"::Item);
        SubscriptionLineWithoutReference.SetRange("Source No.", ItemReference."Item No.");
        SubscriptionLineWithoutReference.SetRange("Supplier Reference Entry No.", 0);
        SubscriptionLineWithReference.SetRange("Source Type", Enum::"Service Object Type"::Item);
        SubscriptionLineWithReference.SetRange("Source No.", ItemReference."Item No.");
        SubscriptionLineWithReference.SetFilter("Supplier Reference Entry No.", '<>0');
        exit(not SubscriptionLineWithoutReference.IsEmpty() and SubscriptionLineWithReference.IsEmpty());
    end;
}