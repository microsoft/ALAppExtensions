// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Service;

using Microsoft.Inventory;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Resources.Journal;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Posting;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

codeunit 6285 "Sust. Service Subscriber"
{
    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignItemValues', '', false, false)]
    local procedure OnAfterAssignItemValues(var ServiceLine: Record "Service Line"; Item: Record Item)
    begin
        if SustainabilitySetup.IsValueChainTrackingEnabled() then
            ServiceLine.Validate("Sust. Account No.", Item."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnAfterAssignResourceValues', '', false, false)]
    local procedure OnAfterAssignResourceValues(var ServiceLine: Record "Service Line"; Resource: Record Resource)
    begin
        if SustainabilitySetup.IsValueChainTrackingEnabled() then
            ServiceLine.Validate("Sust. Account No.", Resource."Default Sust. Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Line", 'OnValidateQuantityOnBeforeResetAmounts', '', false, false)]
    local procedure OnValidateQuantityOnBeforeResetAmounts(var ServiceLine: Record "Service Line")
    begin
        ServiceLine.UpdateSustainabilityEmission(ServiceLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Documents Mgt.", 'OnUpdateServLinesOnPostOrderOnBeforeServLineLoop', '', false, false)]
    local procedure OnUpdateServLinesOnPostOrderOnBeforeServLineLoop(var ServiceLine: Record "Service Line"; Invoice: Boolean; Consume: Boolean)
    begin
        if Invoice or Consume then
            UpdatePostedSustainabilityEmissionOrderLine(ServiceLine, Invoice, Consume);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv. Undo Posting Mgt.", 'OnUpdateServLineCnsmOnBeforeServLineModify', '', false, false)]
    local procedure OnUpdateServLineCnsmOnBeforeServLineModify(var ServiceLine: Record "Service Line"; UndoQty: Decimal)
    begin
        UpdatePostedSustainabilityEmissionOrderLine(ServiceLine, UndoQty);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Documents Mgt.", 'OnBeforeServShptLineInsert', '', false, false)]
    local procedure OnBeforeServShptLineInsert(ServiceLine: Record "Service Line"; var ServiceShipmentLine: Record "Service Shipment Line")
    begin
        UpdatePostedSustainabilityEmission(ServiceLine, ServiceShipmentLine.Quantity, 1, ServiceShipmentLine."Total CO2e");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Service Shipment Line", 'OnBeforeNewServiceShptLineInsert', '', false, false)]
    local procedure OnBeforeNewServiceShptLineInsertForUndoServiceShipment(OldServiceShipmentLine: Record "Service Shipment Line"; var NewServiceShipmentLine: Record "Service Shipment Line")
    begin
        UpdatePostedSustainabilityEmission(OldServiceShipmentLine, NewServiceShipmentLine.Quantity, -1, NewServiceShipmentLine."Total CO2e");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Service Consumption Line", 'OnInsertCorrectiveShipmentLineOnBeforeInsert', '', false, false)]
    local procedure OnInsertCorrectiveShipmentLineOnBeforeInsertForUndoServiceConsumption(OldServiceShipmentLine: Record "Service Shipment Line"; var NewServiceShipmentLine: Record "Service Shipment Line")
    begin
        UpdatePostedSustainabilityEmission(OldServiceShipmentLine, NewServiceShipmentLine.Quantity, -1, NewServiceShipmentLine."Total CO2e");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Documents Mgt.", 'OnBeforeServInvLineInsert', '', false, false)]
    local procedure OnBeforeServInvLineInsert(ServiceLine: Record "Service Line"; var ServiceInvoiceLine: Record "Service Invoice Line")
    begin
        UpdatePostedSustainabilityEmission(ServiceLine, ServiceInvoiceLine.Quantity, 1, ServiceInvoiceLine."Total CO2e");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Documents Mgt.", 'OnBeforeServCrMemoLineInsert', '', false, false)]
    local procedure OnBeforeServCrMemoLineInsert(ServiceLine: Record "Service Line"; var ServiceCrMemoLine: Record "Service Cr.Memo Line")
    begin
        UpdatePostedSustainabilityEmission(ServiceLine, ServiceCrMemoLine.Quantity, 1, ServiceCrMemoLine."Total CO2e");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Documents Mgt.", 'OnPostDocumentLinesOnAfterFillInvPostingBuffer', '', false, false)]
    local procedure OnPostDocumentLinesOnAfterFillInvPostingBuffer(var TempServiceLine: Record "Service Line" temporary)
    begin
        TempServiceLine.UpdateSustainabilityEmission(TempServiceLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Posting Journals Mgt.", 'OnBeforePostItemJnlLine', '', false, false)]
    local procedure OnBeforePostItemJnlLine(var ItemJournalLine: Record "Item Journal Line"; ServiceLine: Record "Service Line")
    begin
        if (ItemJournalLine.Quantity <> 0) or (ItemJournalLine."Invoiced Quantity" <> 0) then
            UpdateSustainabilityItemJournalLine(ItemJournalLine, ServiceLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Posting Journals Mgt.", 'OnBeforeResJnlPostLine', '', false, false)]
    local procedure OnBeforeResJnlPostLine(var ResJnlLine: Record "Res. Journal Line"; ServiceLine: Record "Service Line")
    begin
        if (ServiceLine."Qty. to Consume" <> 0) or ((ServiceLine."Qty. to Invoice" <> 0) and (ResJnlLine."Entry Type" = ResJnlLine."Entry Type"::Sale)) then
            UpdateSustainabilityResourceJournalLine(ResJnlLine, ServiceLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Serv-Posting Journals Mgt.", 'OnAfterTransferValuesToJobJnlLine', '', false, false)]
    local procedure OnAfterTransferValuesToJobJnlLine(var JobJournalLine: Record "Job Journal Line"; ServiceLine: Record "Service Line")
    begin
        JobJournalLine."Sust. Account No." := ServiceLine."Sust. Account No.";
        JobJournalLine."Sust. Account Name" := ServiceLine."Sust. Account Name";
        JobJournalLine."Sust. Account Category" := ServiceLine."Sust. Account Category";
        JobJournalLine."Sust. Account Subcategory" := ServiceLine."Sust. Account Subcategory";
        JobJournalLine."CO2e per Unit" := ServiceLine."CO2e per Unit";
        JobJournalLine."Total CO2e" := ServiceLine."Total CO2e";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Service Shipment Line", 'OnAfterCopyItemJnlLineFromServShpt', '', false, false)]
    local procedure OnAfterCopyItemJnlLineFromServShptForUndoServiceShipment(var ItemJournalLine: Record "Item Journal Line"; ServiceShipmentLine: Record "Service Shipment Line")
    begin
        if (ItemJournalLine.Quantity <> 0) or (ItemJournalLine."Invoiced Quantity" <> 0) then
            UpdateSustainabilityItemJournalLine(ItemJournalLine, ServiceShipmentLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Service Consumption Line", 'OnAfterCopyItemJnlLineFromServShpt', '', false, false)]
    local procedure OnAfterCopyItemJnlLineFromServShptForUndoServiceConsumption(var ItemJournalLine: Record "Item Journal Line"; ServiceShipmentLine: Record "Service Shipment Line")
    begin
        if (ItemJournalLine.Quantity <> 0) or (ItemJournalLine."Invoiced Quantity" <> 0) then
            UpdateSustainabilityItemJournalLine(ItemJournalLine, ServiceShipmentLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Undo Service Consumption Line", 'OnPostResourceJnlLineOnBeforeResJnlPostLine', '', false, false)]
    local procedure OnPostResourceJnlLineOnBeforeResJnlPostLine(var ResJournalLine: Record "Res. Journal Line"; ServiceShipmentLine: Record "Service Shipment Line")
    begin
        if (ResJournalLine.Quantity <> 0) then
            UpdateSustainabilityResourceJournalLine(ResJournalLine, ServiceShipmentLine);
    end;

    local procedure UpdateSustainabilityItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; var ServiceLine: Record "Service Line")
    var
        ServiceHeader: Record "Service Header";
        GHGCredit: Boolean;
        Sign: Integer;
        CO2eToPost: Decimal;
    begin
        ServiceHeader := ServiceLine.GetServHeader();
        GHGCredit := IsGHGCreditLine(ServiceLine);

        Sign := GetPostingSign(ServiceHeader, GHGCredit);

        if ItemJournalLine."Invoiced Quantity" <> 0 then
            CO2eToPost := ServiceLine."CO2e per Unit" * Abs(ItemJournalLine."Invoiced Quantity") * ServiceLine."Qty. per Unit of Measure"
        else
            CO2eToPost := ServiceLine."CO2e per Unit" * Abs(ItemJournalLine.Quantity) * ServiceLine."Qty. per Unit of Measure";

        CO2eToPost := CO2eToPost * Sign;

        if not CanPostSustainabilityJnlLine(ServiceLine."Sust. Account No.", ServiceLine."Sust. Account Category", ServiceLine."Sust. Account Subcategory", CO2eToPost) then
            exit;

        ItemJournalLine."Sust. Account No." := ServiceLine."Sust. Account No.";
        ItemJournalLine."Sust. Account Name" := ServiceLine."Sust. Account Name";
        ItemJournalLine."Sust. Account Category" := ServiceLine."Sust. Account Category";
        ItemJournalLine."Sust. Account Subcategory" := ServiceLine."Sust. Account Subcategory";
        ItemJournalLine."CO2e per Unit" := ServiceLine."CO2e per Unit";
        ItemJournalLine."Total CO2e" := CO2eToPost;
    end;

    local procedure UpdateSustainabilityItemJournalLine(var ItemJournalLine: Record "Item Journal Line"; ServiceShipmentLine: Record "Service Shipment Line")
    var
        GHGCredit: Boolean;
        Sign: Integer;
        CO2eToPost: Decimal;
    begin
        Sign := 1;
        GHGCredit := IsGHGCreditLine(ServiceShipmentLine);
        if GHGCredit then
            Sign := -1;

        if ItemJournalLine."Invoiced Quantity" <> 0 then
            CO2eToPost := ServiceShipmentLine."CO2e per Unit" * Abs(ItemJournalLine."Invoiced Quantity") * ServiceShipmentLine."Qty. per Unit of Measure"
        else
            CO2eToPost := ServiceShipmentLine."CO2e per Unit" * Abs(ItemJournalLine.Quantity) * ServiceShipmentLine."Qty. per Unit of Measure";

        CO2eToPost := CO2eToPost * Sign;

        if not CanPostSustainabilityJnlLine(ServiceShipmentLine."Sust. Account No.", ServiceShipmentLine."Sust. Account Category", ServiceShipmentLine."Sust. Account Subcategory", CO2eToPost) then
            exit;

        ItemJournalLine."Sust. Account No." := ServiceShipmentLine."Sust. Account No.";
        ItemJournalLine."Sust. Account Name" := ServiceShipmentLine."Sust. Account Name";
        ItemJournalLine."Sust. Account Category" := ServiceShipmentLine."Sust. Account Category";
        ItemJournalLine."Sust. Account Subcategory" := ServiceShipmentLine."Sust. Account Subcategory";
        ItemJournalLine."CO2e per Unit" := ServiceShipmentLine."CO2e per Unit";
        ItemJournalLine."Total CO2e" := CO2eToPost;
    end;

    local procedure UpdateSustainabilityResourceJournalLine(var ResJournalLine: Record "Res. Journal Line"; ServiceShipmentLine: Record "Service Shipment Line")
    var
        GHGCredit: Boolean;
        Sign: Integer;
        CO2eToPost: Decimal;
    begin
        Sign := 1;
        GHGCredit := IsGHGCreditLine(ServiceShipmentLine);
        if GHGCredit then
            Sign := -1;

        CO2eToPost := ServiceShipmentLine."CO2e per Unit" * Abs(ResJournalLine.Quantity) * ServiceShipmentLine."Qty. per Unit of Measure";

        CO2eToPost := CO2eToPost * Sign;

        if not CanPostSustainabilityJnlLine(ServiceShipmentLine."Sust. Account No.", ServiceShipmentLine."Sust. Account Category", ServiceShipmentLine."Sust. Account Subcategory", CO2eToPost) then
            exit;

        ResJournalLine."Sust. Account No." := ServiceShipmentLine."Sust. Account No.";
        ResJournalLine."Sust. Account Name" := ServiceShipmentLine."Sust. Account Name";
        ResJournalLine."Sust. Account Category" := ServiceShipmentLine."Sust. Account Category";
        ResJournalLine."Sust. Account Subcategory" := ServiceShipmentLine."Sust. Account Subcategory";
        ResJournalLine."CO2e per Unit" := ServiceShipmentLine."CO2e per Unit";
        ResJournalLine."Total CO2e" := CO2eToPost;
    end;

    local procedure UpdateSustainabilityResourceJournalLine(var ResJnlLine: Record "Res. Journal Line"; var ServiceLine: Record "Service Line")
    var
        ServiceHeader: Record "Service Header";
        GHGCredit: Boolean;
        Sign: Integer;
        CO2eToPost: Decimal;
    begin
        ServiceHeader := ServiceLine.GetServHeader();
        GHGCredit := IsGHGCreditLine(ServiceLine);

        Sign := GetPostingSign(ServiceHeader, GHGCredit);

        CO2eToPost := ServiceLine."CO2e per Unit" * Abs(ResJnlLine.Quantity) * ServiceLine."Qty. per Unit of Measure";
        CO2eToPost := CO2eToPost * Sign;

        if not CanPostSustainabilityJnlLine(ServiceLine."Sust. Account No.", ServiceLine."Sust. Account Category", ServiceLine."Sust. Account Subcategory", CO2eToPost) then
            exit;

        ResJnlLine."Sust. Account No." := ServiceLine."Sust. Account No.";
        ResJnlLine."Sust. Account Name" := ServiceLine."Sust. Account Name";
        ResJnlLine."Sust. Account Category" := ServiceLine."Sust. Account Category";
        ResJnlLine."Sust. Account Subcategory" := ServiceLine."Sust. Account Subcategory";
        ResJnlLine."CO2e per Unit" := ServiceLine."CO2e per Unit";
        ResJnlLine."Total CO2e" := CO2eToPost;
    end;

    local procedure UpdatePostedSustainabilityEmissionOrderLine(var ServiceLine: Record "Service Line"; Invoice: Boolean; Consume: Boolean)
    var
        ServiceHeader: Record "Service Header";
        PostedEmissionCO2e: Decimal;
        GHGCredit: Boolean;
        Sign: Integer;
    begin
        ServiceHeader := ServiceLine.GetServHeader();

        GHGCredit := IsGHGCreditLine(ServiceLine);
        Sign := GetPostingSign(ServiceHeader, GHGCredit);

        if Invoice then
            UpdatePostedSustainabilityEmission(ServiceLine, ServiceLine."Qty. to Invoice", Sign, PostedEmissionCO2e);

        if Consume then
            UpdatePostedSustainabilityEmission(ServiceLine, ServiceLine."Qty. to Consume", Sign, PostedEmissionCO2e);

        ServiceLine."Posted Total CO2e" += PostedEmissionCO2e;
    end;

    local procedure UpdatePostedSustainabilityEmissionOrderLine(var ServiceLine: Record "Service Line"; UndoQty: Decimal)
    var
        ServiceHeader: Record "Service Header";
        PostedEmissionCO2e: Decimal;
        GHGCredit: Boolean;
        Sign: Integer;
    begin
        ServiceHeader := ServiceLine.GetServHeader();

        GHGCredit := IsGHGCreditLine(ServiceLine);
        Sign := GetPostingSign(ServiceHeader, GHGCredit);

        UpdatePostedSustainabilityEmission(ServiceLine, UndoQty, -Sign, PostedEmissionCO2e);

        ServiceLine."Posted Total CO2e" += PostedEmissionCO2e;
    end;

    local procedure UpdatePostedSustainabilityEmission(ServiceLine: Record "Service Line"; Quantity: Decimal; Sign: Integer; var PostedEmissionCO2e: Decimal)
    begin
        PostedEmissionCO2e := (ServiceLine."CO2e per Unit" * Abs(Quantity) * ServiceLine."Qty. per Unit of Measure") * Sign;
    end;

    local procedure UpdatePostedSustainabilityEmission(ServiceShipmentLine: Record "Service Shipment Line"; Quantity: Decimal; Sign: Integer; var PostedEmissionCO2e: Decimal)
    begin
        PostedEmissionCO2e := (ServiceShipmentLine."CO2e per Unit" * Abs(Quantity) * ServiceShipmentLine."Qty. per Unit of Measure") * Sign;
    end;

    local procedure GetPostingSign(ServiceHeader: Record "Service Header"; GHGCredit: Boolean): Integer
    var
        Sign: Integer;
    begin
        Sign := 1;

        case ServiceHeader."Document Type" of
            ServiceHeader."Document Type"::Invoice, ServiceHeader."Document Type"::Order:
                if not GHGCredit then
                    Sign := -1;
            else
                if GHGCredit then
                    Sign := -1;
        end;

        exit(Sign);
    end;

    local procedure IsGHGCreditLine(ServiceLine: Record "Service Line"): Boolean
    var
        Item: Record Item;
    begin
        if ServiceLine.Type <> ServiceLine.Type::Item then
            exit(false);

        if ServiceLine."No." = '' then
            exit(false);

        Item.Get(ServiceLine."No.");

        exit(Item."GHG Credit");
    end;

    local procedure IsGHGCreditLine(ServiceShipmentLine: Record "Service Shipment Line"): Boolean
    var
        Item: Record Item;
    begin
        if ServiceShipmentLine.Type <> ServiceShipmentLine.Type::Item then
            exit(false);

        if ServiceShipmentLine."No." = '' then
            exit(false);

        Item.Get(ServiceShipmentLine."No.");

        exit(Item."GHG Credit");
    end;

    local procedure CanPostSustainabilityJnlLine(AccountNo: Code[20]; AccountCategory: Code[20]; AccountSubCategory: Code[20]; CO2eToPost: Decimal): Boolean
    var
        SustAccountCategory: Record "Sustain. Account Category";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
    begin
        if AccountNo = '' then
            exit(false);

        if not SustainabilitySetup.IsValueChainTrackingEnabled() then
            exit(false);

        if SustAccountCategory.Get(AccountCategory) then
            if SustAccountCategory."Water Intensity" or SustAccountCategory."Waste Intensity" or SustAccountCategory."Discharged Into Water" then
                Error(NotAllowedToPostSustLedEntryForWaterOrWasteErr, AccountNo);

        if SustainAccountSubcategory.Get(AccountCategory, AccountSubCategory) then
            if not SustainAccountSubcategory."Renewable Energy" then
                if (CO2eToPost = 0) then
                    Error(CO2eMustNotBeZeroErr);

        if (CO2eToPost <> 0) then
            exit(true);
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        CO2eMustNotBeZeroErr: Label 'The CO2e fields must have a value that is not 0.';
        NotAllowedToPostSustLedEntryForWaterOrWasteErr: Label 'It is not allowed to post Sustainability Ledger Entry for water or waste in sales document for Account No. %1', Comment = '%1 = Sustainability Account No.';
}