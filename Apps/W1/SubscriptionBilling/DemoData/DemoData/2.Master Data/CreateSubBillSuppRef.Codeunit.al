namespace Microsoft.SubscriptionBilling;

using Microsoft.DemoData.Purchases;
using Microsoft.DemoData.Common;

codeunit 8114 "Create Sub. Bill. Supp. Ref."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        InsertUsageDataSupplierReferences();
        InsertItemVendors();
        InsertItemReferences();
    end;

    procedure InsertUsageDataSupplierReferences();
    var
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
        CreateSubBillSupplier: Codeunit "Create Sub. Bill. Supplier";
    begin
        ContosoSubscriptionBilling.InsertUsageDataSupplierReference(CreateSubBillSupplier.Generic(), Enum::"Usage Data Reference Type"::Product, SB1105Reference());
        ContosoSubscriptionBilling.InsertUsageDataSupplierReference(CreateSubBillSupplier.Generic(), Enum::"Usage Data Reference Type"::Product, SB1106Reference());
        ContosoSubscriptionBilling.InsertUsageDataSupplierReference(CreateSubBillSupplier.Generic(), Enum::"Usage Data Reference Type"::Product, SB1107Reference());
    end;

    local procedure InsertItemVendors()
    var
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        CreateVendor: Codeunit "Create Vendor";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
        CreateSubBillItem: Codeunit "Create Sub. Bill. Item";
        CreateSubBillSupplier: Codeunit "Create Sub. Bill. Supplier";
    begin
        UsageDataSupplierReference.FindSupplierReference(CreateSubBillSupplier.Generic(), SB1105Reference(), UsageDataSupplierReference.Type::Product);
        ContosoSubscriptionBilling.InsertItemVendor(CreateSubBillItem.SB1105(), CreateVendor.DomesticWorldImporter(), UsageDataSupplierReference."Entry No.");
        UsageDataSupplierReference.FindSupplierReference(CreateSubBillSupplier.Generic(), SB1106Reference(), UsageDataSupplierReference.Type::Product);
        ContosoSubscriptionBilling.InsertItemVendor(CreateSubBillItem.SB1106(), CreateVendor.DomesticWorldImporter(), UsageDataSupplierReference."Entry No.");
        UsageDataSupplierReference.FindSupplierReference(CreateSubBillSupplier.Generic(), SB1107Reference(), UsageDataSupplierReference.Type::Product);
        ContosoSubscriptionBilling.InsertItemVendor(CreateSubBillItem.SB1107(), CreateVendor.DomesticWorldImporter(), UsageDataSupplierReference."Entry No.");
    end;

    local procedure InsertItemReferences()
    var
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        CreateVendor: Codeunit "Create Vendor";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
        CommonUOM: Codeunit "Create Common Unit Of Measure";
        CreateSubBillItem: Codeunit "Create Sub. Bill. Item";
        CreateSubBillSupplier: Codeunit "Create Sub. Bill. Supplier";
    begin
        UsageDataSupplierReference.FindSupplierReference(CreateSubBillSupplier.Generic(), SB1105Reference(), UsageDataSupplierReference.Type::Product);
        ContosoSubscriptionBilling.InsertItemReference(CreateSubBillItem.SB1105(), CommonUOM.Piece(), CreateVendor.DomesticWorldImporter(), UsageDataSupplierReference."Entry No.");
        UsageDataSupplierReference.FindSupplierReference(CreateSubBillSupplier.Generic(), SB1106Reference(), UsageDataSupplierReference.Type::Product);
        ContosoSubscriptionBilling.InsertItemReference(CreateSubBillItem.SB1106(), CommonUOM.Piece(), CreateVendor.DomesticWorldImporter(), UsageDataSupplierReference."Entry No.");
        UsageDataSupplierReference.FindSupplierReference(CreateSubBillSupplier.Generic(), SB1107Reference(), UsageDataSupplierReference.Type::Product);
        ContosoSubscriptionBilling.InsertItemReference(CreateSubBillItem.SB1107(), CommonUOM.Piece(), CreateVendor.DomesticWorldImporter(), UsageDataSupplierReference."Entry No.");
    end;

    var
        SB1105ReferenceTok: Label 'prd-wwi-1105-001', MaxLength = 20, Locked = true;
        SB1106ReferenceTok: Label 'prd-wwi-1106-001', MaxLength = 20, Locked = true;
        SB1107ReferenceTok: Label 'prd-wwi-1107-001', MaxLength = 20, Locked = true;

    procedure SB1105Reference(): Text[80]
    begin
        exit(SB1105ReferenceTok);
    end;

    procedure SB1106Reference(): Text[80]
    begin
        exit(SB1106ReferenceTok);
    end;

    procedure SB1107Reference(): Text[80]
    begin
        exit(SB1107ReferenceTok);
    end;
}