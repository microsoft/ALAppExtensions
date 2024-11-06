namespace Microsoft.Sustainability.Purchase;

using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Posting;

codeunit 6225 "Sust. Purchase Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnValidateQuantityOnBeforeResetAmounts', '', false, false)]
    local procedure OnValidateQuantityOnBeforeResetAmounts(var PurchaseLine: Record "Purchase Line")
    begin
        PurchaseLine.UpdateSustainabilityEmission(PurchaseLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Qty. to Invoice', false, false)]
    local procedure OnValidateQtyToInvoice(var Rec: Record "Purchase Line")
    begin
        Rec.UpdateSustainabilityEmission(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'Qty. to Receive', false, false)]
    local procedure OnValidateQtyToReceive(var Rec: Record "Purchase Line")
    begin
        Rec.UpdateSustainabilityEmission(Rec);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchLine', '', false, false)]
    local procedure OnAfterPostPurchLine(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; SrcCode: Code[10]; GenJnlLineDocNo: Code[20])
    begin
        PostSustainabilityLine(PurchaseHeader, PurchaseLine, SrcCode, GenJnlLineDocNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostUpdateOrderLineOnBeforeLoop', '', false, false)]
    local procedure OnPostUpdateOrderLineOnBeforeLoop(PurchHeader: Record "Purchase Header"; var TempPurchLine: Record "Purchase Line" temporary)
    begin
        if PurchHeader.Invoice then begin
            UpdatePostedSustainabilityEmission(PurchHeader, TempPurchLine);
            InitEmissionOnPurchLine(TempPurchLine);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterBindSubscription', '', false, false)]
    local procedure OnAfterBindSubscription()
    begin
        SustPreviewPostInstance.Initialize();
        BindSubscription(SustPreviewPostingHandler);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterUnbindSubscription', '', false, false)]
    local procedure OnAfterUnbindSubscription()
    begin
        UnbindSubscription(SustPreviewPostingHandler);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostUpdateOrderLineModifyTempLine', '', false, false)]
    local procedure OnBeforePostUpdateOrderLineModifyTempLine(var TempPurchaseLine: Record "Purchase Line" temporary)
    begin
        TempPurchaseLine.UpdateSustainabilityEmission(TempPurchaseLine);
    end;

    local procedure InitEmissionOnPurchLine(var PurchaseLine: Record "Purchase Line")
    begin
        if IsGHGCreditLine(PurchaseLine) then
            exit;

        PurchaseLine."Emission CO2 Per Unit" := 0;
        PurchaseLine."Emission CH4 Per Unit" := 0;
        PurchaseLine."Emission N2O Per Unit" := 0;

        PurchaseLine."Emission CO2" := 0;
        PurchaseLine."Emission CH4" := 0;
        PurchaseLine."Emission N2O" := 0;
    end;

    local procedure UpdatePostedSustainabilityEmission(var PurchaseHeader: Record "Purchase Header"; var TempPurchaseLine: Record "Purchase Line" temporary)
    var
        GHGCredit: Boolean;
        Sign: Integer;
    begin
        if not PurchaseHeader.Invoice then
            exit;

        GHGCredit := IsGHGCreditLine(TempPurchaseLine);
        Sign := GetPostingSign(PurchaseHeader, GHGCredit);

        TempPurchaseLine."Posted Emission CO2" += (TempPurchaseLine."Emission CO2 Per Unit" * Abs(TempPurchaseLine."Qty. to Invoice") * TempPurchaseLine."Qty. per Unit of Measure") * Sign;
        TempPurchaseLine."Posted Emission CH4" += (TempPurchaseLine."Emission CH4 Per Unit" * Abs(TempPurchaseLine."Qty. to Invoice") * TempPurchaseLine."Qty. per Unit of Measure") * Sign;
        TempPurchaseLine."Posted Emission N2O" += (TempPurchaseLine."Emission N2O Per Unit" * Abs(TempPurchaseLine."Qty. to Invoice") * TempPurchaseLine."Qty. per Unit of Measure") * Sign;
    end;

    local procedure PostSustainabilityLine(PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; SrcCode: Code[10]; GenJnlLineDocNo: Code[20])
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        GHGCredit: Boolean;
        Sign: Integer;
        CO2ToPost: Decimal;
        CH4ToPost: Decimal;
        N2OToPost: Decimal;
    begin
        if PurchaseLine."Qty. to Invoice" = 0 then
            exit;

        GHGCredit := IsGHGCreditLine(PurchaseLine);

        if GHGCredit then begin
            PurchaseLine.TestField("Emission CH4 Per Unit", 0);
            PurchaseLine.TestField("Emission N2O Per Unit", 0);
        end;

        Sign := GetPostingSign(PurchaseHeader, GHGCredit);

        CO2ToPost := PurchaseLine."Emission CO2 Per Unit" * Abs(PurchaseLine."Qty. to Invoice") * PurchaseLine."Qty. per Unit of Measure";
        CH4ToPost := PurchaseLine."Emission CH4 Per Unit" * Abs(PurchaseLine."Qty. to Invoice") * PurchaseLine."Qty. per Unit of Measure";
        N2OToPost := PurchaseLine."Emission N2O Per Unit" * Abs(PurchaseLine."Qty. to Invoice") * PurchaseLine."Qty. per Unit of Measure";

        CO2ToPost := CO2ToPost * Sign;
        CH4ToPost := CH4ToPost * Sign;
        N2OToPost := N2OToPost * Sign;

        if not CanPostSustainabilityJnlLine(PurchaseHeader, PurchaseLine, CO2ToPost, CH4ToPost, N2OToPost) then
            exit;

        SustainabilityJnlLine.Init();
        SustainabilityJnlLine."Journal Template Name" := PurchaseHeader."Journal Templ. Name";
        SustainabilityJnlLine."Journal Batch Name" := '';
        SustainabilityJnlLine."Source Code" := SrcCode;
        SustainabilityJnlLine.Validate("Posting Date", PurchaseHeader."Posting Date");

        if GHGCredit then
            SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::"GHG Credit")
        else
            if PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Document Type"::"Return Order"] then
                SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::"Credit Memo")
            else
                SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::Invoice);

        SustainabilityJnlLine.Validate("Document No.", GenJnlLineDocNo);
        SustainabilityJnlLine.Validate("Account No.", PurchaseLine."Sust. Account No.");
        SustainabilityJnlLine.Validate("Responsibility Center", PurchaseHeader."Responsibility Center");
        SustainabilityJnlLine.Validate("Reason Code", PurchaseHeader."Reason Code");
        SustainabilityJnlLine.Validate("Account Category", PurchaseLine."Sust. Account Category");
        SustainabilityJnlLine.Validate("Account Subcategory", PurchaseLine."Sust. Account Subcategory");
        SustainabilityJnlLine.Validate("Unit of Measure", PurchaseLine."Unit of Measure Code");
        SustainabilityJnlLine."Dimension Set ID" := PurchaseLine."Dimension Set ID";
        SustainabilityJnlLine."Shortcut Dimension 1 Code" := PurchaseLine."Shortcut Dimension 1 Code";
        SustainabilityJnlLine."Shortcut Dimension 2 Code" := PurchaseLine."Shortcut Dimension 2 Code";
        SustainabilityJnlLine.Validate("Emission CO2", CO2ToPost);
        SustainabilityJnlLine.Validate("Emission CH4", CH4ToPost);
        SustainabilityJnlLine.Validate("Emission N2O", N2OToPost);
        SustainabilityJnlLine.Validate("Country/Region Code", PurchaseHeader."Buy-from Country/Region Code");
        SustainabilityPostMgt.InsertLedgerEntry(SustainabilityJnlLine);
    end;

    local procedure GetPostingSign(PurchaseHeader: Record "Purchase Header"; GHGCredit: Boolean): Integer
    var
        Sign: Integer;
    begin
        Sign := 1;

        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Document Type"::"Return Order":
                if not GHGCredit then
                    Sign := -1;
            else
                if GHGCredit then
                    Sign := -1;
        end;

        exit(Sign);
    end;

    local procedure IsGHGCreditLine(PurchaseLine: Record "Purchase Line"): Boolean
    var
        Item: Record Item;
    begin
        if PurchaseLine.Type <> PurchaseLine.Type::Item then
            exit(false);

        if PurchaseLine."No." = '' then
            exit(false);

        Item.Get(PurchaseLine."No.");

        exit(Item."GHG Credit");
    end;

    local procedure CanPostSustainabilityJnlLine(PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"; CO2ToPost: Decimal; CH4ToPost: Decimal; N2OToPost: Decimal): Boolean
    var
        SustAccountCategory: Record "Sustain. Account Category";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        if not PurchaseHeader.Invoice then
            exit(false);

        if PurchaseLine."Sust. Account No." = '' then
            exit(false);

        if SustAccountCategory.Get(PurchaseLine."Sust. Account Category") then
            if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                Error(NotAllowedToPostSustLedEntryForWaterOrWasteErr, PurchaseLine."Sust. Account No.");

        if SustainAccountSubcategory.Get(PurchaseLine."Sust. Account Category", PurchaseLine."Sust. Account Subcategory") then
            if not SustainAccountSubcategory."Renewable Energy" then
                if (CO2ToPost = 0) and (CH4ToPost = 0) and (N2OToPost = 0) then
                    Error(EmissionMustNotBeZeroErr);

        if (CO2ToPost <> 0) or (CH4ToPost <> 0) or (N2OToPost <> 0) then
            exit(true);
    end;

    var
        SustPreviewPostingHandler: Codeunit "Sust. Preview Posting Handler";
        SustPreviewPostInstance: Codeunit "Sust. Preview Post Instance";
        EmissionMustNotBeZeroErr: Label 'The Emission fields must have a value that is not 0.';
        NotAllowedToPostSustLedEntryForWaterOrWasteErr: Label 'It is not allowed to post Sustainability Ledger Entry for water or waste in purchase document for Account No. %1', Comment = '%1 = Sustainability Account No.';
}