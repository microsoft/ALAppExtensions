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
        field(8052; "Subscription Option"; Enum "Item Service Commitment Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Subscription Option';

            trigger OnValidate()
            var
                ItemReference: Record "Item Reference";
            begin
                ErrorIfItemIsNonInventory();
                AskToRemoveAssignedItemServiceCommPackages();
                ErrorIfPackageLineInvoicedViaContractWithoutInvoicingItemExist();
                UpdateItemPriceList();

                if xRec."Subscription Option" = Enum::"Item Service Commitment Type"::"Service Commitment Item" then begin
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
        ItemTypeErr: Label 'The value "%1" can only be set if the option "%2" is selected in the "%3" field.', Comment = '%1 = Subscription option, %2 = Item type, %3 = Field name';
        ItemServiceCommitmentPackageQst: Label 'Subscription Packages can only be stored for items with the subscription option "%1" or "%2". You want to change the value to "%3". In doing so, the stored Subscription Packages will be deleted. Do you want to continue?', Comment = '%1 = Subscription Option, %2 = Subscription Option, %3 = Subscription Option';
        ServiceCommitmentErr: Label 'Subscription Packages can be assigned only to items with Subscription Option "%1" or "%2". The current value is "%3".', Comment = '%1 = Subscription Option, %2 = Subscription Option, %3 = Subscription Option';
        DoNotAllowInvoiceDiscountForServiceCommitmentItemErr: Label 'Subscription Items cannot be included in an invoice discount.';
        UsageDataReferenceEntryNoExistsErr: Label 'The Subscription Option cannot be changed because for this Item Usage Data Supplier Reference Entry No. (see Actions "Suppliers" or "Item references") is defined for this Item.';

    internal procedure OpenItemServCommitmentPackagesPage()
    var
        ItemServCommitmentPackage: Record "Item Subscription Package";
    begin
        ErrorIfServiceCommitmentOptionIsNotValidForServiceCommitmentPackage();
        ItemServCommitmentPackage.FilterGroup(2);
        ItemServCommitmentPackage.SetRange("Item No.", "No.");
        Page.Run(Page::"Item Serv. Commitment Packages", ItemServCommitmentPackage);
    end;

    internal procedure IsServiceCommitmentItem(): Boolean
    begin
        exit(Rec."Subscription Option" = Rec."Subscription Option"::"Service Commitment Item");
    end;

    local procedure ErrorIfItemIsServiceCommitmentItem()
    begin
        if Rec."Allow Invoice Disc." and Rec.IsServiceCommitmentItem() then
            Error(DoNotAllowInvoiceDiscountForServiceCommitmentItemErr);
    end;

    local procedure ErrorIfServiceCommitmentOptionIsNotValidForServiceCommitmentPackage()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeErrorIfServiceCommitmentOptionIsNotValidForServiceCommitmentPackage(Rec, IsHandled);
        if IsHandled then
            exit;

        if not ("Subscription Option" in [Enum::"Item Service Commitment Type"::"Sales with Service Commitment", Enum::"Item Service Commitment Type"::"Service Commitment Item"]) then
            Error(ServiceCommitmentErr, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", Enum::"Item Service Commitment Type"::"Service Commitment Item", "Subscription Option");
    end;

    local procedure ErrorIfItemIsNonInventory()
    begin
        if "Subscription Option" in [Enum::"Item Service Commitment Type"::"Service Commitment Item", Enum::"Item Service Commitment Type"::"Invoicing Item"] then
            if Type <> Type::"Non-Inventory" then
                Error(ItemTypeErr, "Subscription Option", Format(Type::"Non-Inventory"), FieldCaption(Type));
    end;

    local procedure AskToRemoveAssignedItemServiceCommPackages()
    var
        ItemServCommitmentPackage: Record "Item Subscription Package";
    begin
        if not ("Subscription Option" in [Enum::"Item Service Commitment Type"::"Sales with Service Commitment", Enum::"Item Service Commitment Type"::"Service Commitment Item"]) then begin
            ItemServCommitmentPackage.SetRange("Item No.", "No.");
            if not ItemServCommitmentPackage.IsEmpty() then
                if ConfirmManagement.GetResponse(StrSubstNo(ItemServiceCommitmentPackageQst, "Item Service Commitment Type"::"Sales with Service Commitment", "Item Service Commitment Type"::"Service Commitment Item", "Subscription Option"), true) then
                    ItemServCommitmentPackage.DeleteAll(false)
                else
                    Error('');
        end;
    end;

    local procedure UpdateItemPriceList()
    var
#if not CLEAN25
#pragma warning disable AL0432
        SalesPrice: Record "Sales Price";
#pragma warning restore AL0432
#endif
        PriceListLine: Record "Price List Line";
#if not CLEAN25
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
#endif
    begin
        if Rec."Subscription Option" = xRec."Subscription Option" then
            exit;

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
    end;

    internal procedure GetDoNotAllowInvoiceDiscountForServiceCommitmentItemErrorText(): Text
    begin
        exit(DoNotAllowInvoiceDiscountForServiceCommitmentItemErr);
    end;

    procedure HasSNSpecificItemTracking(): Boolean
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if Rec."Item Tracking Code" <> '' then begin
            ItemTrackingCode.Get(Rec."Item Tracking Code");
            exit(ItemTrackingCode."SN Specific Tracking");
        end;
        exit(false);
    end;

    local procedure ErrorIfPackageLineInvoicedViaContractWithoutInvoicingItemExist()
    var
        ItemSubscriptionPackage: Record "Item Subscription Package";
    begin
        // Only when changed from "Service Commitment Item" to "Sales with Service Commitment"
        if xRec."Subscription Option" <> Enum::"Item Service Commitment Type"::"Service Commitment Item" then
            exit;

        if Rec."Subscription Option" <> Enum::"Item Service Commitment Type"::"Sales with Service Commitment" then
            exit;

        if Rec.IsTemporary then
            exit;

        ItemSubscriptionPackage.SetRange("Item No.", "No.");
        if ItemSubscriptionPackage.FindSet(false) then
            repeat
                ItemSubscriptionPackage.ErrorIfPackageLineInvoicedViaContractWithoutInvoicingItemExist();
            until ItemSubscriptionPackage.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeErrorIfServiceCommitmentOptionIsNotValidForServiceCommitmentPackage(Rec: Record Item; var IsHandled: Boolean)
    begin
    end;
}