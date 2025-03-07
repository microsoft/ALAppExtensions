namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Document;
using Microsoft.Finance.Dimension;

tableextension 8054 "Sales Line" extends "Sales Line"
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
        field(8055; "Subscription Lines"; Integer)
        {
            Caption = 'Subscription Lines';
            FieldClass = FlowField;
            CalcFormula = count("Sales Subscription Line" where("Document Type" = field("Document Type"), "Document No." = field("Document No."), "Document Line No." = field("Line No.")));
            Editable = false;
        }
        field(8057; "Subscription Option"; Enum "Item Service Commitment Type")
        {
            Caption = 'Subscription Option';
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Subscription Option" where("No." = field("No.")));
            Editable = false;
        }
        field(8058; "Discount"; Boolean)
        {
            Caption = 'Discount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(8059; "Exclude from Doc. Total"; Boolean)
        {
            Caption = 'Exclude from Document Total';
            DataClassification = CustomerContent;
        }
        modify(Type)
        {
            trigger OnBeforeValidate()
            begin
                ErrorIfServiceObjectTypeCannotBeSelectedManually();
            end;

            trigger OnAfterValidate()
            begin
                CheckAndDeleteServiceCommitmentsForSalesLine(Rec, xRec);
            end;
        }
        modify("No.")
        {
            TableRelation = if (Type = const("Service Object")) "Subscription Header";

            trigger OnAfterValidate()
            var
                SalesServiceCommitmentMgmt: Codeunit "Sales Subscription Line Mgmt.";
            begin
                SetExcludeFromDocTotal();
                if xRec."No." = Rec."No." then
                    exit;
                CheckAndDeleteServiceCommitmentsForSalesLine(Rec, xRec);
                SalesServiceCommitmentMgmt.AddSalesServiceCommitmentsForSalesLine(Rec, false);
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                UpdateSalesServiceCommitmentCalculationBaseAmount(Rec, xRec);
            end;
        }
        modify("Unit Price")
        {
            trigger OnAfterValidate()
            begin
                UpdateSalesServiceCommitmentCalculationBaseAmount(Rec, xRec);
            end;
        }
        modify("Unit Cost (LCY)")
        {
            trigger OnAfterValidate()
            begin
                UpdateSalesServiceCommitmentCalculationBaseAmount(Rec, xRec);
            end;
        }
        modify("Line Discount %")
        {
            trigger OnAfterValidate()
            var
                SalesServiceCommitmentMgmt: Codeunit "Sales Subscription Line Mgmt.";
            begin
                UpdateSalesServiceCommitmentCalculationBaseAmount(Rec, xRec);
                if Rec."Line Discount %" <> xRec."Line Discount %" then
                    SalesServiceCommitmentMgmt.NotifyIfDiscountIsNotTransferredFromSalesLine(Rec);
            end;
        }
        modify("Customer Price Group")
        {
            trigger OnAfterValidate()
            var
                SalesServiceCommitment: Record "Sales Subscription Line";
            begin
                if xRec."Customer Price Group" = Rec."Customer Price Group" then
                    exit;
                SalesServiceCommitment.FilterOnSalesLine(Rec);
                SalesServiceCommitment.ModifyAll("Customer Price Group", Rec."Customer Price Group", false);
            end;
        }
        modify("Unit Cost")
        {
            trigger OnAfterValidate()
            begin
                UpdateSalesServiceCommitmentCalculationBaseAmount(Rec, xRec);
            end;
        }
        modify("Allow Invoice Disc.")
        {
            trigger OnAfterValidate()
            var
                Item: Record Item;
            begin
                if Rec."Allow Invoice Disc." then
                    if IsServiceCommitmentItem() then
                        Error(Item.GetDoNotAllowInvoiceDiscountForServiceCommitmentItemErrorText());
            end;
        }
    }
    var
        BillingLineexist, IsBillingLineCached : Boolean;
    trigger OnDelete()
    begin
        DeleteSalesServiceCommitment();
    end;

    procedure InitCachedVar()
    begin
        IsBillingLineCached := false;
    end;

    procedure IsSalesDocumentTypeWithServiceCommitments(): Boolean
    begin
        exit(
            Rec."Document Type" in
                [Rec."Document Type"::Quote,
                 Rec."Document Type"::Order,
                 Rec."Document Type"::"Blanket Order"]);
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        TypeCannotBeSelectedManuallyErr: Label 'Type "%1" cannot be selected manually.', Comment = '%1 = Sales Line Type';

    internal procedure InitFromSalesHeader(SourceSalesHeader: Record "Sales Header")
    begin
        Rec.Init();
        Rec."Document Type" := SourceSalesHeader."Document Type";
        Rec."Document No." := SourceSalesHeader."No.";
        Rec."Line No." := SourceSalesHeader.GetNextLineNo();
    end;

    internal procedure DeleteSalesServiceCommitment()
    var
        SalesServiceCommitment: Record "Sales Subscription Line";
    begin
        if Rec.IsTemporary() then
            exit;
        if not Rec.IsSalesDocumentTypeWithServiceCommitments() then
            exit;
        SalesServiceCommitment.FilterOnSalesLine(Rec);
        if SalesServiceCommitment.IsEmpty() then
            exit;

        SalesServiceCommitment.DeleteAll(false);
    end;

    internal procedure GetCombinedDimensionSetID(DimSetID1: Integer; DimSetID2: Integer)
    var
        DimSetIDArr: array[10] of Integer;
    begin
        DimSetIDArr[1] := DimSetID1;
        DimSetIDArr[2] := DimSetID2;
        "Dimension Set ID" := DimMgt.GetCombinedDimensionSetID(DimSetIDArr, "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    local procedure CheckAndDeleteServiceCommitmentsForSalesLine(SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    begin
        if (SalesLine."No." <> xSalesLine."No.") or
            (SalesLine.Type <> xSalesLine.Type)
        then
            SalesLine.DeleteSalesServiceCommitment();
    end;

    local procedure UpdateSalesServiceCommitmentCalculationBaseAmount(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    var
        SalesServiceCommitment: Record "Sales Subscription Line";
    begin
        if SalesLine.IsTemporary() then
            exit;
        if (xSalesLine.Quantity = SalesLine.Quantity) and
            (xSalesLine."Unit Price" = SalesLine."Unit Price") and
            (xSalesLine."Line Discount %" = SalesLine."Line Discount %") and
            (xSalesLine."Unit Cost" = SalesLine."Unit Cost") and
            (xSalesLine."Unit Cost (LCY)" = SalesLine."Unit Cost (LCY)")
        then
            exit;

        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        if SalesServiceCommitment.IsEmpty() then
            exit;

        if SalesServiceCommitment.FindSet() then begin
            SalesLine.Modify(false);
            repeat
                SalesServiceCommitment.CalculateCalculationBaseAmount();
            until SalesServiceCommitment.Next() = 0;
        end;
    end;

    internal procedure IsServiceCommitmentItem(): Boolean
    begin
        if (Rec.Type <> Rec.Type::Item) or ("No." = '') then
            exit(false);
        if Rec."Subscription Option".AsInteger() = 0 then
            Rec.CalcFields("Subscription Option");
        exit(Rec."Subscription Option" = "Item Service Commitment Type"::"Service Commitment Item");
    end;

    local procedure ErrorIfServiceObjectTypeCannotBeSelectedManually()
    begin
        if CurrFieldNo = 0 then
            exit;
        if Rec.Type = Enum::"Sales Line Type"::"Service Object" then
            Error(TypeCannotBeSelectedManuallyErr, Rec.Type);
    end;

    internal procedure SetExcludeFromDocTotal()
    var
        ItemManagement: Codeunit "Sub. Contracts Item Management";
        IsContractRenewalLocal: Boolean;
        IsHandled: Boolean;
    begin
        OnBeforeSetExcludeFromDocTotal(Rec, IsHandled);
        if IsHandled then
            exit;
        IsContractRenewalLocal := Rec.IsContractRenewal();

        if IsContractRenewalLocal then begin
            if Rec.Type = Rec.Type::"Service Object" then
                Rec.Validate("Exclude from Doc. Total", IsContractRenewalLocal);
        end else
            if (Rec.Type = Rec.Type::Item) and (Rec."No." <> '') and (not Rec.IsLineAttachedToBillingLine()) then
                Rec.Validate("Exclude from Doc. Total", ItemManagement.IsServiceCommitmentItem(Rec."No."));
    end;

    internal procedure IsLineWithServiceObject(): Boolean
    begin
        exit((Rec.Type = "Sales Line Type"::"Service Object") and (Rec."No." <> ''));
    end;

    internal procedure InsertDescriptionSalesLine(SourceSalesHeader: Record "Sales Header"; NewDescription: Text; AttachedToLineNo: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.InitFromSalesHeader(SourceSalesHeader);
        SalesLine."Attached to Line No." := AttachedToLineNo;
        SalesLine.Description := CopyStr(NewDescription, 1, MaxStrLen(SalesLine.Description));
        SalesLine.Insert(false);
    end;

    internal procedure RetrieveFirstContractNo(ServicePartner: Enum "Service Partner"; Process: Enum Process): Code[20]
    var
        SalesServiceCommitment: Record "Sales Subscription Line";
    begin
        SalesServiceCommitment.SetRange("Document Type", Rec."Document Type");
        SalesServiceCommitment.SetRange("Document No.", Rec."Document No.");
        SalesServiceCommitment.SetRange("Document Line No.", Rec."Line No.");
        SalesServiceCommitment.SetRange(Partner, ServicePartner);
        SalesServiceCommitment.SetRange(Process, Process);
        if not SalesServiceCommitment.FindFirst() then
            SalesServiceCommitment.Init();
        exit(SalesServiceCommitment."Linked to No.");
    end;

    internal procedure IsLineAttachedToBillingLine(): Boolean
    var
        BillingLine: Record "Billing Line";
    begin
        if not IsBillingLineCached then begin
            BillingLine.FilterBillingLineOnDocumentLine(BillingLine.GetBillingDocumentTypeFromSalesDocumentType(Rec."Document Type"), Rec."Document No.", Rec."Line No.");
            BillingLineexist := not BillingLine.IsEmpty();
            IsBillingLineCached := true;
        end;

        exit(BillingLineexist);
    end;

    internal procedure IsContractRenewalQuote(): Boolean
    begin
        if Rec."Document Type" <> Rec."Document Type"::Quote then
            exit(false);
        exit(Rec.IsContractRenewal());
    end;

    internal procedure IsContractRenewal(): Boolean
    var
        SalesServiceCommitment: Record "Sales Subscription Line";
    begin
        SalesServiceCommitment.FilterOnSalesLine(Rec);
        SalesServiceCommitment.SetRange(Process, Enum::Process::"Contract Renewal");
        exit(not SalesServiceCommitment.IsEmpty());
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeSetExcludeFromDocTotal(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;
}