namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Document;
using Microsoft.Finance.Dimension;
using Microsoft.Inventory.Item;

tableextension 8065 "Purchase Line" extends "Purchase Line"
{
    fields
    {
        field(8053; "Recurring Billing from"; Date)
        {
            Caption = 'Recurring Billing from';
            DataClassification = CustomerContent;
        }
        field(8054; "Recurring Billing to"; Date)
        {
            Caption = 'Recurring Billing to';
            DataClassification = CustomerContent;
        }
        field(8055; "Discount"; Boolean)
        {
            Caption = 'Discount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(8056; "Attached to Sub. Contract line"; Boolean)
        {
            Caption = 'Attached to Subscription Contract line';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Billing Line" where("Document Type" = filter(Invoice), "Document No." = field("Document No."), "Document Line No." = field("Line No.")));
        }
    }

    var
        DimMgt: Codeunit DimensionManagement;

    internal procedure GetCombinedDimensionSetID(DimSetID1: Integer; DimSetID2: Integer)
    var
        DimSetIDArr: array[10] of Integer;
    begin
        DimSetIDArr[1] := DimSetID1;
        DimSetIDArr[2] := DimSetID2;
        "Dimension Set ID" := DimMgt.GetCombinedDimensionSetID(DimSetIDArr, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    internal procedure GetPurchaseDocumentSign(): Integer
    begin
        if Rec."Document Type" = "Purchase Document Type"::"Credit Memo" then
            exit(-1);
        exit(1);
    end;

    internal procedure IsLineAttachedToBillingLine(): Boolean
    var
        BillingLine: Record "Billing Line";
    begin
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(Rec."Document Type"), Rec."Document No.", Rec."Line No.");
        exit(not BillingLine.IsEmpty());
    end;

    internal procedure CreateContractDeferrals(): Boolean
    var
        VendorSubscriptionContract: Record "Vendor Subscription Contract";
        SubscriptionLine: Record "Subscription Line";
        BillingLine: Record "Billing Line";
    begin
        BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(Rec."Document Type"), Rec."Document No.", Rec."Line No.");
        if not BillingLine.FindFirst() then
            exit;

        if not SubscriptionLine.Get(BillingLine."Subscription Line Entry No.") then
            exit;

        case SubscriptionLine."Create Contract Deferrals" of
            Enum::"Create Contract Deferrals"::"Contract-dependent":
                begin
                    VendorSubscriptionContract.Get(BillingLine."Subscription Contract No.");
                    exit(VendorSubscriptionContract."Create Contract Deferrals");
                end;
            Enum::"Create Contract Deferrals"::Yes:
                exit(true);
            Enum::"Create Contract Deferrals"::No:
                exit(false);
        end;
    end;

    internal procedure IsContractLineAssignable(): Boolean
    var
        Item: Record Item;
    begin
        if not (Rec.Type = Enum::"Purchase Line Type"::Item) then
            exit;
        if not Item.Get(Rec."No.") then
            exit;
        exit((Item."Subscription Option" in [Enum::"Item Service Commitment Type"::"Service Commitment Item", Enum::"Item Service Commitment Type"::"Invoicing Item"])
                                       and (not Rec.IsLineAttachedToBillingLine()));
    end;

    internal procedure AssignVendorContractLine()
    var
        GetVendorContractLines: Page "Get Vendor Contract Lines";
    begin
        GetVendorContractLines.LookupMode(true);
        GetVendorContractLines.SetPurchaseLine(Rec);
        GetVendorContractLines.RunModal();
    end;
}