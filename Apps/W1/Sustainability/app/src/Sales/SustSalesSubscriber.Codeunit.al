namespace Microsoft.Sustainability.Sales;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Posting;

codeunit 6253 "Sust. Sales Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignGLAccountValues', '', false, false)]
    local procedure OnAfterAssignGLAccountValues(var SalesLine: Record "Sales Line"; GLAccount: Record "G/L Account")
    begin
        SalesLine.Validate("Sust. Account No.", GLAccount."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure OnAfterAssignItemValues(var SalesLine: Record "Sales Line"; Item: Record Item)
    begin
        SalesLine.Validate("Sust. Account No.", Item."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignResourceValues', '', false, false)]
    local procedure OnAfterAssignResourceValues(var SalesLine: Record "Sales Line"; Resource: Record Resource)
    begin
        SalesLine.Validate("Sust. Account No.", Resource."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterAssignItemChargeValues', '', false, false)]
    local procedure OnAfterAssignItemChargeValues(var SalesLine: Record "Sales Line"; ItemCharge: Record "Item Charge")
    begin
        SalesLine.Validate("Sust. Account No.", ItemCharge."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateQuantityOnBeforeResetAmounts', '', false, false)]
    local procedure OnValidateQuantityOnBeforeResetAmounts(var SalesLine: Record "Sales Line")
    begin
        SalesLine.UpdateSustainabilityEmission(SalesLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnPostSalesLineOnBeforePostItemTrackingLine', '', false, false)]
    local procedure OnAfterPostSalesLine(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; SrcCode: Code[10]; GenJnlLineDocNo: Code[20])
    begin
        if (SalesLine."Qty. to Invoice" <> 0) then
            PostSustainabilityLine(SalesHeader, SalesLine, SrcCode, GenJnlLineDocNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnPostItemTrackingForShipmentConditionOnBeforeUpdateBlanketOrderLine', '', false, false)]
    local procedure OnPostUpdateOrderLineOnBeforeUpdateBlanketOrderLine(var SalesHeader: Record "Sales Header"; var TempSalesLine: Record "Sales Line" temporary)
    begin
        if SalesHeader.Invoice then
            UpdatePostedSustainabilityEmissionOrderLine(SalesHeader, TempSalesLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesShptLineInsert', '', false, false)]
    local procedure OnBeforeSalesShptLineInsert(SalesLine: Record "Sales Line"; var SalesShptLine: Record "Sales Shipment Line")
    begin
        UpdatePostedSustainabilityEmission(SalesLine, SalesShptLine.Quantity, 1, SalesShptLine."Total CO2e");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeReturnRcptLineInsert', '', false, false)]
    local procedure OnBeforeReturnRcptLineInsert(SalesLine: Record "Sales Line"; var ReturnRcptLine: Record "Return Receipt Line")
    begin
        UpdatePostedSustainabilityEmission(SalesLine, ReturnRcptLine.Quantity, 1, ReturnRcptLine."Total CO2e");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvLineInsert', '', false, false)]
    local procedure OnBeforeSalesInvLineInsert(SalesLine: Record "Sales Line"; var SalesInvLine: Record "Sales Invoice Line")
    begin
        UpdatePostedSustainabilityEmission(SalesLine, SalesInvLine.Quantity, 1, SalesInvLine."Total CO2e");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesCrMemoLineInsert', '', false, false)]
    local procedure OnBeforeSalesCrMemoLineInsert(SalesLine: Record "Sales Line"; var SalesCrMemoLine: Record "Sales Cr.Memo Line")
    begin
        UpdatePostedSustainabilityEmission(SalesLine, SalesCrMemoLine.Quantity, 1, SalesCrMemoLine."Total CO2e");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostUpdateOrderLineModifyTempLine', '', false, false)]
    local procedure OnBeforePostUpdateOrderLineModifyTempLine(var TempSalesLine: Record "Sales Line" temporary)
    begin
        TempSalesLine.UpdateSustainabilityEmission(TempSalesLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnPostItemJnlLineOnAfterPrepareItemJnlLine', '', false, false)]
    local procedure OnPostItemJnlLineOnAfterPrepareItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    begin
        if (ItemJournalLine.Quantity <> 0) or (ItemJournalLine."Invoiced Quantity" <> 0) then
            UpdateSustainabilityItemJournalLine(ItemJournalLine, SalesHeader, SalesLine);
    end;

    local procedure UpdateSustainabilityItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        GHGCredit: Boolean;
        Sign: Integer;
        CO2eToPost: Decimal;
    begin
        GHGCredit := IsGHGCreditLine(SalesLine);

        Sign := GetPostingSign(SalesHeader, GHGCredit);

        if ItemJournalLine."Invoiced Quantity" <> 0 then
            CO2eToPost := SalesLine."CO2e per Unit" * Abs(ItemJournalLine."Invoiced Quantity") * SalesLine."Qty. per Unit of Measure"
        else
            CO2eToPost := SalesLine."CO2e per Unit" * Abs(ItemJournalLine.Quantity) * SalesLine."Qty. per Unit of Measure";

        CO2eToPost := CO2eToPost * Sign;

        if not CanPostSustainabilityJnlLine(SalesLine."Sust. Account No.", SalesLine."Sust. Account Category", SalesLine."Sust. Account Subcategory", CO2eToPost) then
            exit;

        ItemJournalLine."Sust. Account No." := SalesLine."Sust. Account No.";
        ItemJournalLine."Sust. Account Name" := SalesLine."Sust. Account Name";
        ItemJournalLine."Sust. Account Category" := SalesLine."Sust. Account Category";
        ItemJournalLine."Sust. Account Subcategory" := SalesLine."Sust. Account Subcategory";
        ItemJournalLine."CO2e per Unit" := SalesLine."CO2e per Unit";
        ItemJournalLine."Total CO2e" := CO2eToPost;
    end;

    local procedure UpdatePostedSustainabilityEmissionOrderLine(SalesHeader: Record "Sales Header"; var TempSalesLine: Record "Sales Line" temporary)
    var
        PostedEmissionCO2e: Decimal;
        GHGCredit: Boolean;
        Sign: Integer;
    begin
        GHGCredit := IsGHGCreditLine(TempSalesLine);
        Sign := GetPostingSign(SalesHeader, GHGCredit);

        UpdatePostedSustainabilityEmission(TempSalesLine, TempSalesLine."Qty. to Invoice", Sign, PostedEmissionCO2e);
        TempSalesLine."Posted Total CO2e" += PostedEmissionCO2e;
    end;

    local procedure UpdatePostedSustainabilityEmission(SalesLine: Record "Sales Line"; Quantity: Decimal; Sign: Integer; var PostedEmissionCO2e: Decimal)
    begin
        PostedEmissionCO2e := (SalesLine."CO2e per Unit" * Abs(Quantity) * SalesLine."Qty. per Unit of Measure") * Sign;
    end;

    local procedure PostSustainabilityLine(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; SrcCode: Code[10]; GenJnlLineDocNo: Code[20])
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        GHGCredit: Boolean;
        Sign: Integer;
        CO2eToPost: Decimal;
    begin
        GHGCredit := IsGHGCreditLine(SalesLine);

        Sign := GetPostingSign(SalesHeader, GHGCredit);

        CO2eToPost := SalesLine."CO2e per Unit" * Abs(SalesLine."Qty. to Invoice") * SalesLine."Qty. per Unit of Measure" * Sign;

        if not (SalesHeader.Invoice) then
            exit;

        if not CanPostSustainabilityJnlLine(SalesLine."Sust. Account No.", SalesLine."Sust. Account Category", SalesLine."Sust. Account Subcategory", CO2eToPost) then
            exit;

        SustainabilityJnlLine.Init();
        SustainabilityJnlLine."Journal Template Name" := SalesHeader."Journal Templ. Name";
        SustainabilityJnlLine."Journal Batch Name" := '';
        SustainabilityJnlLine."Source Code" := SrcCode;
        SustainabilityJnlLine.Validate("Posting Date", SalesHeader."Posting Date");

        if GHGCredit then
            SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::"GHG Credit")
        else
            if SalesHeader."Document Type" in [SalesHeader."Document Type"::"Credit Memo", SalesHeader."Document Type"::"Return Order"] then
                SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::"Credit Memo")
            else
                SustainabilityJnlLine.Validate("Document Type", SustainabilityJnlLine."Document Type"::Invoice);

        SustainabilityJnlLine.Validate("Document No.", GenJnlLineDocNo);
        SustainabilityJnlLine.Validate("Account No.", SalesLine."Sust. Account No.");
        SustainabilityJnlLine.Validate("Responsibility Center", SalesHeader."Responsibility Center");
        SustainabilityJnlLine.Validate("Reason Code", SalesHeader."Reason Code");
        SustainabilityJnlLine.Validate("Account Category", SalesLine."Sust. Account Category");
        SustainabilityJnlLine.Validate("Account Subcategory", SalesLine."Sust. Account Subcategory");
        SustainabilityJnlLine.Validate("Unit of Measure", SalesLine."Unit of Measure Code");
        SustainabilityJnlLine."Dimension Set ID" := SalesLine."Dimension Set ID";
        SustainabilityJnlLine."Shortcut Dimension 1 Code" := SalesLine."Shortcut Dimension 1 Code";
        SustainabilityJnlLine."Shortcut Dimension 2 Code" := SalesLine."Shortcut Dimension 2 Code";
        SustainabilityJnlLine.Validate("CO2e Emission", CO2eToPost);
        SustainabilityJnlLine.Validate("Country/Region Code", SalesHeader."Sell-to Country/Region Code");
        SustainabilityPostMgt.InsertLedgerEntry(SustainabilityJnlLine, SalesLine);
    end;

    local procedure GetPostingSign(SalesHeader: Record "Sales Header"; GHGCredit: Boolean): Integer
    var
        Sign: Integer;
    begin
        Sign := 1;

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Invoice, SalesHeader."Document Type"::Order:
                if not GHGCredit then
                    Sign := -1;
            else
                if GHGCredit then
                    Sign := -1;
        end;

        exit(Sign);
    end;

    local procedure IsGHGCreditLine(SalesLine: Record "Sales Line"): Boolean
    var
        Item: Record Item;
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit(false);

        if SalesLine."No." = '' then
            exit(false);

        Item.Get(SalesLine."No.");

        exit(Item."GHG Credit");
    end;

    local procedure CanPostSustainabilityJnlLine(AccountNo: Code[20]; AccountCategory: Code[20]; AccountSubCategory: Code[20]; CO2eToPost: Decimal): Boolean
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
                if (CO2eToPost = 0) then
                    Error(EmissionMustNotBeZeroErr);

        if (CO2eToPost <> 0) then
            exit(true);
    end;

    var
        EmissionMustNotBeZeroErr: Label 'The Emission fields must have a value that is not 0.';
        NotAllowedToPostSustLedEntryForWaterOrWasteErr: Label 'It is not allowed to post Sustainability Ledger Entry for water or waste in sales document for Account No. %1', Comment = '%1 = Sustainability Account No.';
}