namespace Microsoft.Sustainability.Purchase;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Posting;
using Microsoft.Sustainability.Setup;

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
        if (PurchaseHeader.Invoice) and (PurchaseLine."Qty. to Invoice" <> 0) then
            PostSustainabilityLine(PurchaseHeader, PurchaseLine, SrcCode, GenJnlLineDocNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostUpdateOrderLineOnBeforeUpdateBlanketOrderLine', '', false, false)]
    local procedure OnPostUpdateOrderLineOnBeforeUpdateBlanketOrderLine(var PurchaseHeader: Record "Purchase Header"; var TempPurchaseLine: Record "Purchase Line" temporary)
    begin
        if PurchaseHeader.Invoice then
            UpdatePostedSustainabilityEmissionOrderLine(PurchaseHeader, TempPurchaseLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnInsertReceiptLineOnAfterInitPurchRcptLine', '', false, false)]
    local procedure OnInsertReceiptLineOnAfterInitPurchRcptLine(PurchLine: Record "Purchase Line"; var PurchRcptLine: Record "Purch. Rcpt. Line")
    begin
        UpdatePostedSustainabilityEmission(PurchLine, PurchRcptLine.Quantity, 1, PurchRcptLine."Emission CO2", PurchRcptLine."Emission CH4", PurchRcptLine."Emission N2O");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnInsertReturnShipmentLineOnAfterReturnShptLineInit', '', false, false)]
    local procedure OnInsertReturnShipmentLineOnAfterReturnShptLineInit(PurchLine: Record "Purchase Line"; var ReturnShptLine: Record "Return Shipment Line")
    begin
        UpdatePostedSustainabilityEmission(PurchLine, ReturnShptLine.Quantity, 1, ReturnShptLine."Emission CO2", ReturnShptLine."Emission CH4", ReturnShptLine."Emission N2O");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchInvLineInsert', '', false, false)]
    local procedure OnBeforePurchInvLineInsert(var PurchaseLine: Record "Purchase Line"; var PurchInvLine: Record "Purch. Inv. Line")
    begin
        UpdatePostedSustainabilityEmission(PurchaseLine, PurchInvLine.Quantity, 1, PurchInvLine."Emission CO2", PurchInvLine."Emission CH4", PurchInvLine."Emission N2O");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchCrMemoLineInsert', '', false, false)]
    local procedure OnBeforePurchCrMemoLineInsert(PurchLine: Record "Purchase Line"; var PurchCrMemoLine: Record "Purch. Cr. Memo Line")
    begin
        UpdatePostedSustainabilityEmission(PurchLine, PurchCrMemoLine.Quantity, 1, PurchCrMemoLine."Emission CO2", PurchCrMemoLine."Emission CH4", PurchCrMemoLine."Emission N2O");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterBindSubscription', '', false, false)]
    local procedure OnAfterBindSubscription()
    begin
        TryBindPostingPreviewHandler();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnAfterUnbindSubscription', '', false, false)]
    local procedure OnAfterUnbindSubscription()
    begin
        TryUnbindPostingPreviewHandler();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostItemJnlLineOnAfterPrepareItemJnlLine', '', false, false)]
    local procedure OnPostItemJnlLineOnAfterPrepareItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line")
    begin
        if (ItemJournalLine.Quantity <> 0) or (ItemJournalLine."Invoiced Quantity" <> 0) then
            CheckAndUpdateSustainabilityItemJournalLine(ItemJournalLine, PurchaseHeader, PurchaseLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnNotHandledCopyFromGLAccount', '', false, false)]
    local procedure OnAfterAssignGLAccountValues(var PurchaseLine: Record "Purchase Line"; GLAccount: Record "G/L Account")
    begin
        PurchaseLine.Validate("Sust. Account No.", GLAccount."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure OnAfterAssignItemValues(var PurchLine: Record "Purchase Line"; Item: Record Item)
    begin
        PurchLine.Validate("Sust. Account No.", Item."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignResourceValues', '', false, false)]
    local procedure OnAfterAssignResourceValues(var PurchaseLine: Record "Purchase Line"; Resource: Record Resource)
    begin
        PurchaseLine.Validate("Sust. Account No.", Resource."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemChargeValues', '', false, false)]
    local procedure OnAfterAssignItemChargeValues(var PurchLine: Record "Purchase Line"; ItemCharge: Record "Item Charge")
    begin
        PurchLine.Validate("Sust. Account No.", ItemCharge."Default Sust. Account");
    end;

    local procedure CheckAndUpdateSustainabilityItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line")
    var
        GHGCredit: Boolean;
        Sign: Integer;
        CO2ToPost: Decimal;
        CH4ToPost: Decimal;
        N2OToPost: Decimal;
    begin
        GHGCredit := IsGHGCreditLine(PurchaseLine);

        if GHGCredit then begin
            PurchaseLine.TestField("Emission CH4 Per Unit", 0);
            PurchaseLine.TestField("Emission N2O Per Unit", 0);
        end;

        Sign := GetPostingSign(PurchaseHeader, GHGCredit);

        if ItemJournalLine."Invoiced Quantity" <> 0 then begin
            CO2ToPost := PurchaseLine."Emission CO2 Per Unit" * Abs(ItemJournalLine."Invoiced Quantity") * PurchaseLine."Qty. per Unit of Measure";
            CH4ToPost := PurchaseLine."Emission CH4 Per Unit" * Abs(ItemJournalLine."Invoiced Quantity") * PurchaseLine."Qty. per Unit of Measure";
            N2OToPost := PurchaseLine."Emission N2O Per Unit" * Abs(ItemJournalLine."Invoiced Quantity") * PurchaseLine."Qty. per Unit of Measure";
        end else begin
            CO2ToPost := PurchaseLine."Emission CO2 Per Unit" * Abs(ItemJournalLine.Quantity) * PurchaseLine."Qty. per Unit of Measure";
            CH4ToPost := PurchaseLine."Emission CH4 Per Unit" * Abs(ItemJournalLine.Quantity) * PurchaseLine."Qty. per Unit of Measure";
            N2OToPost := PurchaseLine."Emission N2O Per Unit" * Abs(ItemJournalLine.Quantity) * PurchaseLine."Qty. per Unit of Measure";
        end;

        CO2ToPost := CO2ToPost * Sign;
        CH4ToPost := CH4ToPost * Sign;
        N2OToPost := N2OToPost * Sign;

        if not SustainabilitySetup.IsValueChainTrackingEnabled() then
            exit;

        if not CanPostSustainabilityJnlLine(PurchaseLine."Sust. Account No.", PurchaseLine."Sust. Account Category", PurchaseLine."Sust. Account Subcategory", CO2ToPost, CH4ToPost, N2OToPost) then
            exit;

        ItemJournalLine."Sust. Account No." := PurchaseLine."Sust. Account No.";
        ItemJournalLine."Sust. Account Name" := PurchaseLine."Sust. Account Name";
        ItemJournalLine."Sust. Account Category" := PurchaseLine."Sust. Account Category";
        ItemJournalLine."Sust. Account Subcategory" := PurchaseLine."Sust. Account Subcategory";
        ItemJournalLine."Emission CO2" := CO2ToPost;
        ItemJournalLine."Emission CH4" := CH4ToPost;
        ItemJournalLine."Emission N2O" := N2OToPost;
    end;

    local procedure UpdatePostedSustainabilityEmissionOrderLine(PurchHeader: Record "Purchase Header"; var TempPurchLine: Record "Purchase Line" temporary)
    var
        PostedEmissionCO2: Decimal;
        PostedEmissionCH4: Decimal;
        PostedEmissionN2O: Decimal;
        GHGCredit: Boolean;
        Sign: Integer;
    begin
        GHGCredit := IsGHGCreditLine(TempPurchLine);
        Sign := GetPostingSign(PurchHeader, GHGCredit);

        UpdatePostedSustainabilityEmission(TempPurchLine, TempPurchLine."Qty. to Invoice", Sign, PostedEmissionCO2, PostedEmissionCH4, PostedEmissionN2O);
        TempPurchLine."Posted Emission CO2" += PostedEmissionCO2;
        TempPurchLine."Posted Emission CH4" += PostedEmissionCH4;
        TempPurchLine."Posted Emission N2O" += PostedEmissionN2O;
    end;

    local procedure UpdatePostedSustainabilityEmission(PurchaseLine: Record "Purchase Line"; Quantity: Decimal; Sign: Integer; var PostedEmissionCO2: Decimal; var PostedEmissionCH4: Decimal; var PostedEmissionN2O: Decimal)
    begin
        PostedEmissionCO2 := (PurchaseLine."Emission CO2 Per Unit" * Abs(Quantity) * PurchaseLine."Qty. per Unit of Measure") * Sign;
        PostedEmissionCH4 := (PurchaseLine."Emission CH4 Per Unit" * Abs(Quantity) * PurchaseLine."Qty. per Unit of Measure") * Sign;
        PostedEmissionN2O := (PurchaseLine."Emission N2O Per Unit" * Abs(Quantity) * PurchaseLine."Qty. per Unit of Measure") * Sign;
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

        if not CanPostSustainabilityJnlLine(PurchaseLine."Sust. Account No.", PurchaseLine."Sust. Account Category", PurchaseLine."Sust. Account Subcategory", CO2ToPost, CH4ToPost, N2OToPost) then
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
        OnPostSustainabilityLineOnBeforeInsertLedgerEntry(SustainabilityJnlLine, PurchaseHeader, PurchaseLine);
        SustainabilityPostMgt.InsertLedgerEntry(SustainabilityJnlLine);

        UpdateDefaultEmissionOnMaster(PurchaseLine);
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

    local procedure CanPostSustainabilityJnlLine(AccountNo: Code[20]; AccountCategory: Code[20]; AccountSubCategory: Code[20]; CO2ToPost: Decimal; CH4ToPost: Decimal; N2OToPost: Decimal): Boolean
    var
        SustAccountCategory: Record "Sustain. Account Category";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        if AccountNo = '' then
            exit(false);

        if SustAccountCategory.Get(AccountCategory) then
            if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                Error(NotAllowedToPostSustLedEntryForWaterOrWasteErr, AccountNo);

        if SustainAccountSubcategory.Get(AccountCategory, AccountSubCategory) then
            if not SustainAccountSubcategory."Renewable Energy" then
                if (CO2ToPost = 0) and (CH4ToPost = 0) and (N2OToPost = 0) then
                    Error(EmissionMustNotBeZeroErr);

        if (CO2ToPost <> 0) or (CH4ToPost <> 0) or (N2OToPost <> 0) then
            exit(true);
    end;

    local procedure UpdateDefaultEmissionOnMaster(PurchaseLine: Record "Purchase Line")
    var
        Item: Record Item;
        Resource: Record Resource;
        ItemCharge: Record "Item Charge";
    begin
        case PurchaseLine.Type of
            PurchaseLine.Type::Item:
                begin
                    Item.Get(PurchaseLine."No.");
                    if (Item."Default Sust. Account" = '') or (Item."Replenishment System" <> Item."Replenishment System"::Purchase) then
                        exit;

                    Item.Validate("Default CO2 Emission", PurchaseLine."Emission CO2 Per Unit");
                    if not Item."GHG Credit" then begin
                        Item.Validate("Default CH4 Emission", PurchaseLine."Emission CH4 Per Unit");
                        Item.Validate("Default N2O Emission", PurchaseLine."Emission N2O Per Unit");
                    end;

                    Item.Modify();
                end;
            PurchaseLine.Type::Resource:
                begin
                    Resource.Get(PurchaseLine."No.");
                    if (Resource."Default Sust. Account" = '') then
                        exit;

                    Resource.Validate("Default CO2 Emission", PurchaseLine."Emission CO2 Per Unit");
                    Resource.Validate("Default CH4 Emission", PurchaseLine."Emission CH4 Per Unit");
                    Resource.Validate("Default N2O Emission", PurchaseLine."Emission N2O Per Unit");
                    Resource.Modify();
                end;
            PurchaseLine.Type::"Charge (Item)":
                begin
                    ItemCharge.Get(PurchaseLine."No.");
                    if (ItemCharge."Default Sust. Account" = '') then
                        exit;

                    ItemCharge.Validate("Default CO2 Emission", PurchaseLine."Emission CO2 Per Unit");
                    ItemCharge.Validate("Default CH4 Emission", PurchaseLine."Emission CH4 Per Unit");
                    ItemCharge.Validate("Default N2O Emission", PurchaseLine."Emission N2O Per Unit");
                    ItemCharge.Modify();
                end;
        end
    end;

    local procedure TryBindPostingPreviewHandler(): Boolean
    var
        SustPreviewPostingHandler: Codeunit "Sust. Preview Posting Handler";
        SustPreviewPostInstance: Codeunit "Sust. Preview Post Instance";
    begin
        SustPreviewPostInstance.Initialize();
        exit(SustPreviewPostingHandler.TryBindPostingPreviewHandler());
    end;

    local procedure TryUnbindPostingPreviewHandler(): Boolean
    var
        SustPreviewPostingHandler: Codeunit "Sust. Preview Posting Handler";
    begin
        exit(SustPreviewPostingHandler.TryUnbindPostingPreviewHandler());
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        EmissionMustNotBeZeroErr: Label 'The Emission fields must have a value that is not 0.';
        NotAllowedToPostSustLedEntryForWaterOrWasteErr: Label 'It is not allowed to post Sustainability Ledger Entry for water or waste in purchase document for Account No. %1', Comment = '%1 = Sustainability Account No.';

    [IntegrationEvent(false, false)]
    local procedure OnPostSustainabilityLineOnBeforeInsertLedgerEntry(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line")
    begin
    end;
}