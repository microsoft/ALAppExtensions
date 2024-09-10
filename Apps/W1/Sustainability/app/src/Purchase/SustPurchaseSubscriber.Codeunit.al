namespace Microsoft.Sustainability.Purchase;

using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Posting;

codeunit 6225 "Sust. Purchase Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnValidateQuantityOnBeforeResetAmounts', '', false, false)]
    local procedure OnValidateQuantityOnBeforeResetAmounts(var PurchaseLine: Record "Purchase Line")
    begin
        PurchaseLine.UpdateSustainabilityEmission(PurchaseLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchLine', '', false, false)]
    local procedure OnAfterPostPurchLine(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; SrcCode: Code[10]; GenJnlLineDocNo: Code[20])
    begin
        PostSustainabilityLine(PurchaseHeader, PurchaseLine, SrcCode, GenJnlLineDocNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPurchInvLineInsert', '', false, false)]
    local procedure OnAfterPurchInvLineInsert(PurchHeader: Record "Purchase Header"; PurchLine: Record "Purchase Line"; var PurchInvLine: Record "Purch. Inv. Line")
    begin
        UpdateSustainabilityInformation(PurchHeader, PurchLine, PurchInvLine);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostUpdateOrderLineOnBeforeInitOutstanding', '', false, false)]
    local procedure OnPostUpdateOrderLineOnBeforeInitOutstanding(var PurchaseHeader: Record "Purchase Header"; var TempPurchaseLine: Record "Purchase Line" temporary)
    begin
        UpdatePostedSustainabilityEmission(PurchaseHeader, TempPurchaseLine);
    end;

    local procedure UpdatePostedSustainabilityEmission(var PurchaseHeader: Record "Purchase Header"; var TempPurchaseLine: Record "Purchase Line" temporary)
    begin
        if not PurchaseHeader.Invoice then
            exit;

        TempPurchaseLine."Posted Emission CO2" += TempPurchaseLine."Emission CO2";
        TempPurchaseLine."Posted Emission CH4" += TempPurchaseLine."Emission CH4";
        TempPurchaseLine."Posted Emission N2O" += TempPurchaseLine."Emission N2O";
    end;

    local procedure UpdateSustainabilityInformation(PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"; var PurchInvLine: Record "Purch. Inv. Line")
    var
        CO2ToPost: Decimal;
        CH4ToPost: Decimal;
        N2OToPost: Decimal;
    begin
        CO2ToPost := PurchaseLine."Emission CO2" - PurchaseLine."Posted Emission CO2";
        CH4ToPost := PurchaseLine."Emission CH4" - PurchaseLine."Posted Emission CH4";
        N2OToPost := PurchaseLine."Emission N2O" - PurchaseLine."Posted Emission N2O";
        if not CanPostSustainabilityJnlLine(PurchaseHeader, PurchaseLine, CO2ToPost, CH4ToPost, N2OToPost) then
            exit;

        PurchInvLine."Emission CO2" := CO2ToPost;
        PurchInvLine."Emission CH4" := CH4ToPost;
        PurchInvLine."Emission N2O" := N2OToPost;
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
        GHGCredit := IfGHGCreditLine(PurchaseLine);

        if GHGCredit then begin
            PurchaseLine.TestField("Emission CH4 Per Unit", 0);
            PurchaseLine.TestField("Emission N2O Per Unit", 0);
        end;

        Sign := GetPostingSign(PurchaseHeader, GHGCredit);

        CO2ToPost := PurchaseLine."Emission CO2" - PurchaseLine."Posted Emission CO2";
        CH4ToPost := PurchaseLine."Emission CH4" - PurchaseLine."Posted Emission CH4";
        N2OToPost := PurchaseLine."Emission N2O" - PurchaseLine."Posted Emission N2O";

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

    local procedure IfGHGCreditLine(PurchaseLine: Record "Purchase Line"): Boolean
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
    begin
        if not PurchaseHeader.Invoice then
            exit(false);

        if PurchaseLine."Sust. Account No." = '' then
            exit(false);

        if (CO2ToPost <> 0) or (CH4ToPost <> 0) or (N2OToPost <> 0) then
            exit(true);
    end;

    var
        SustPreviewPostingHandler: Codeunit "Sust. Preview Posting Handler";
        SustPreviewPostInstance: Codeunit "Sust. Preview Post Instance";
}