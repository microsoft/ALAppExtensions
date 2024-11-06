namespace Microsoft.SubscriptionBilling;

using System.Utilities;
#if not CLEAN25
using Microsoft.Sales.Pricing;
#endif
using Microsoft.Pricing.PriceList;
#if not CLEAN25
using Microsoft.Pricing.Calculation;
#endif
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Inventory.Tracking;

tableextension 8052 Item extends Item
{
    fields
    {
        field(8052; "Service Commitment Option"; Enum "Item Service Commitment Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Service Commitment Option';

            trigger OnValidate()
            var
                ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
#if not CLEAN25
                SalesPrice: Record "Sales Price";
#endif
                PriceListLine: Record "Price List Line";
                ItemReference: Record "Item Reference";
#if not CLEAN25
                PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
#endif
            begin
                if "Service Commitment Option" in [Enum::"Item Service Commitment Type"::"Service Commitment Item", Enum::"Item Service Commitment Type"::"Invoicing Item"] then
                    if Type <> Type::"Non-Inventory" then
                        Error(ItemTypeErr, "Service Commitment Option", Format(Type::"Non-Inventory"), FieldCaption(Type));

                if not ("Service Commitment Option" in [Enum::"Item Service Commitment Type"::"Sales with Service Commitment", Enum::"Item Service Commitment Type"::"Service Commitment Item"]) then begin
                    ItemServCommitmentPackage.SetRange("Item No.", "No.");
                    if not ItemServCommitmentPackage.IsEmpty() then
                        if ConfirmManagement.GetResponse(StrSubstNo(ItemServiceCommitmentPackageQst, "Item Service Commitment Type"::"Sales with Service Commitment", "Item Service Commitment Type"::"Service Commitment Item", "Service Commitment Option"), true) then
                            ItemServCommitmentPackage.DeleteAll(false)
                        else
                            Error('');
                end;
                if IsServiceCommitmentItem() then begin
                    Rec.Validate("Allow Invoice Disc.", false);
#if not CLEAN25
                    if PriceCalculationMgt.IsExtendedPriceCalculationEnabled() then begin
#endif
                        PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);
                        PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
                        PriceListLine.SetRange("Asset No.", Rec."No.");
                        PriceListLine.ModifyAll("Allow Invoice Disc.", false, false);
#if not CLEAN25
                    end else begin
                        SalesPrice.SetRange("Item No.", Rec."No.");
                        SalesPrice.ModifyAll("Allow Invoice Disc.", false, false);
                    end;
#endif
                end else begin
                    Rec.Validate("Allow Invoice Disc.", true);
#if not CLEAN25
                    if PriceCalculationMgt.IsExtendedPriceCalculationEnabled() then begin
#endif
                        PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);
                        PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Item);
                        PriceListLine.SetRange("Asset No.", Rec."No.");
                        PriceListLine.ModifyAll("Allow Invoice Disc.", true, false);
#if not CLEAN25
                    end else begin
                        SalesPrice.SetRange("Item No.", Rec."No.");
                        SalesPrice.ModifyAll("Allow Invoice Disc.", true, false);
                    end;
#endif
                end;
                if xRec."Service Commitment Option" = Enum::"Item Service Commitment Type"::"Service Commitment Item" then begin
                    ItemReference.SetRange("Item No.", Rec."No.");
                    ItemReference.SetFilter("Supplier Ref. Entry No.", '<>%1', 0);
                    Rec.CalcFields("Usage Data Suppl. Ref. Exists");
                    if Rec."Usage Data Suppl. Ref. Exists" or (not ItemReference.IsEmpty()) then
                        Error(UsageDataReferenceEntryNoExistsErr);
                end;
            end;
        }
        modify("Allow Invoice Disc.")
        {
            trigger OnAfterValidate()
            begin
                ErrorIfItemIsServiceCommitmentItem();
            end;
        }
        field(8020; "Usage Data Suppl. Ref. Exists"; Boolean)
        {
            Caption = 'Usage Data Supplier Reference Exists';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = exist("Item Vendor" where("Item No." = field("No."), "Supplier Ref. Entry No." = filter(<> 0)));
        }
    }
    var
        ConfirmManagement: Codeunit "Confirm Management";
        ItemTypeErr: Label 'The value "%1" can only be set if the option "%2" is selected in the "%3" field.';
        ItemServiceCommitmentPackageQst: Label 'Service commitment packages can only be stored for items with the service option "%1" or "%2". You want to change the value to "%3". In doing so, the stored service commitment packages will be deleted. Do you want to continue?';
        ServiceCommitmentErr: Label 'Service commitment packages can be assigned only to items with service commitment option "%1" or "%2". The current value is "%3".';
        DoNotAllowInvoiceDiscountForServiceCommitmentItemErr: Label 'Service Commitment Items cannot be included in an invoice discount.';
        UsageDataReferenceEntryNoExistsErr: Label 'The Service Commitment Option cannot be changed because for this Item Usage Data Supplier Reference Entry No. (see Actions "Suppliers" or "Item references") is defined for this Item.';

    internal procedure OpenItemServCommitmentPackagesPage()
    var
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
    begin
        if not ("Service Commitment Option" in [Enum::"Item Service Commitment Type"::"Sales with Service Commitment", Enum::"Item Service Commitment Type"::"Service Commitment Item"]) then
            Error(ServiceCommitmentErr, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", Enum::"Item Service Commitment Type"::"Service Commitment Item", "Service Commitment Option");
        ItemServCommitmentPackage.FilterGroup(2);
        ItemServCommitmentPackage.SetRange("Item No.", "No.");
        Page.Run(Page::"Item Serv. Commitment Packages", ItemServCommitmentPackage);
    end;

    internal procedure IsServiceCommitmentItem(): Boolean
    begin
        exit(Rec."Service Commitment Option" = Rec."Service Commitment Option"::"Service Commitment Item");
    end;

    local procedure ErrorIfItemIsServiceCommitmentItem()
    begin
        if Rec."Allow Invoice Disc." and Rec.IsServiceCommitmentItem() then
            Error(DoNotAllowInvoiceDiscountForServiceCommitmentItemErr);
    end;

    internal procedure GetDoNotAllowInvoiceDiscountForServiceCommitmentItemErrorText(): Text
    begin
        exit(DoNotAllowInvoiceDiscountForServiceCommitmentItemErr);
    end;

    internal procedure HasSNSpecificItemTracking(): Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if Rec."Item Tracking Code" <> '' then begin
            ItemTrackingCode.Get(Rec."Item Tracking Code");
            exit(ItemTrackingCode."SN Specific Tracking");
        end;
        exit(false);
    end;
}