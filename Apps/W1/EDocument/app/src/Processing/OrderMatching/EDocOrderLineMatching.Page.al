namespace Microsoft.eServices.EDocument.OrderMatch;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.OrderMatch.Copilot;
using Microsoft.Purchases.Document;
using System.AI;
using System.Telemetry;
page 6167 "E-Doc. Order Line Matching"
{
    Caption = 'Purchase Order Matching';
    DataCaptionExpression = StrSubstNo(GlobalDataCaptionExpressionTxt, Rec."Order No.");
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "E-Document";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    RefreshOnActivate = true;
    Permissions = tabledata "E-Document" = m;

    layout
    {
        area(Content)
        {
            group("Document Details")
            {
                ShowCaption = false;
                field("Bill-to/Pay-to Name"; Rec."Bill-to/Pay-to Name")
                {
                    Caption = 'Vendor Name';
                    ToolTip = 'Specifies the customer/vendor name of the electronic document.';
                }
                field("Incoming E-Document No."; Rec."Incoming E-Document No.")
                {
                    Caption = 'E-Document No.';
                    ToolTip = 'Specifies the electronic document number.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    Caption = 'E-Document Date';
                    ToolTip = 'Specifies the electronic document date.';
                }
                field("Amount Incl. VAT"; Rec."Amount Incl. VAT")
                {
                    Caption = 'E-Document Amount';
                    ToolTip = 'Specifies the e-document amount including VAT.';
                }
            }
            group(Control8)
            {
                ShowCaption = false;
                part(ImportedLines; "E-Doc. Imported Line Sub")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Imported Lines';
                    SubPageLink = "E-Document Entry No." = field("Entry No");
                    UpdatePropagation = Both;
                }
                part(OrderLines; "E-Doc. Purchase Order Sub")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Order Lines';
                    SubPageLink = "Document Type" = filter("Order"), "Document No." = field("Order No.");
                    UpdatePropagation = Both;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ApplyToPO)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Apply To Purchase Order';
                ToolTip = 'Applies the matching and updates purchase order lines';
                Image = ApplyEntries;

                trigger OnAction()
                begin
                    ApplyToPurchaseOrder();
                end;
            }
            action(MatchManual)
            {
                Caption = 'Match Manually';
                ToolTip = 'Manually match selected lines in both panes to link each imported line to one or more related purchase order lines.';
                ApplicationArea = All;
                Image = CheckRulesSyntax;

                trigger OnAction()
                begin
                    MatchManually();
                    SetUserInteractions();
                end;
            }
            action(MatchAutomatic)
            {
                Caption = 'Match Automatically';
                ToolTip = 'Automatically search and match lines that have same Type, No., Unit Price, Discount and Unit Of Measure.';
                ApplicationArea = All;
                Image = MapAccounts;

                trigger OnAction()
                begin
                    MatchAutomatically();
                    SetUserInteractions();
                end;
            }
            action(RemoveMatch)
            {
                Caption = 'Remove Match';
                ToolTip = 'Remove selection of matched purchase order lines.';
                ApplicationArea = All;
                Image = RemoveLine;

                trigger OnAction()
                begin
                    RemoveMatches();
                    SetUserInteractions();
                end;
            }
            action(RemoveAllMatch)
            {
                Caption = 'Reset Matching';
                ToolTip = 'Removes all matches made for E-Document.';
                ApplicationArea = All;
                Image = ResetStatus;

                trigger OnAction()
                begin
                    EDocMatchOrderLines.RemoveAllMatches(Rec);
                    if CostNotification.Recall() then;
                    SetUserInteractions();
                end;
            }
            action(ShowNonMatched)
            {
                Caption = 'Show Pending Lines';
                ToolTip = 'Show all e-document lines that have not been completely matched.';
                ApplicationArea = All;
                Image = AddWatch;

                trigger OnAction()
                begin
                    CurrPage.ImportedLines.Page.ShowIncompleteMatches();
                    CurrPage.OrderLines.Page.ShowIncompleteMatches();
                end;
            }
            action(ShowAll)
            {
                Caption = 'Show All Lines';
                ToolTip = 'Show all e-document lines.';
                ApplicationArea = All;
                Image = AddWatch;

                trigger OnAction()
                begin
                    CurrPage.ImportedLines.Page.ShowAll();
                    CurrPage.OrderLines.Page.ShowAll();
                end;
            }
        }
        area(Prompting)
        {
            action(MatchCopilot)
            {
                Caption = 'Match with Copilot';
                ToolTip = 'Match e-document lines with the assistance of Copilot';
                ApplicationArea = All;
                Image = SparkleFilled;

                trigger OnAction()
                begin
                    MatchWithCopilot(true);
                    SetUserInteractions();
                end;
            }
        }
        area(Navigation)
        {
            action(PurchaseOrder)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Order';
                ToolTip = 'Opens the Purchase Order page with the related order';
                Image = Document;
                RunObject = page "Purchase Order";
                RunPageLink = "No." = field("Order No.");
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(ApplyToPO_Promoted; ApplyToPO) { }
            }
            group(Document)
            {
                actionref(Open_Promoted; PurchaseOrder) { }
            }
            group(Matching)
            {
                actionref(MatchCopilot_Promoted; MatchCopilot) { }
                actionref(MatchManual_Promoted; MatchManual) { }
                actionref(MatchAuto_Promoted; MatchAutomatic) { }
                actionref(RemoveMatch_Promoted; RemoveMatch) { }
                actionref(RemoveAll_Promoted; RemoveAllMatch) { }
            }
            group(Show)
            {
                actionref(ShowAll_Promoted; ShowAll) { }
                actionref(ShowNonMatched_Promoted; ShowNonMatched) { }
            }
        }
    }

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EDocMatchOrderLines: Codeunit "E-Doc. Line Matching";
        CostNotification: Notification;
        AutoRunCopilot: Boolean;
        LineCostVaryMatchMsg: Label 'Matched e-document lines (%1) has cost different from matched purchase order line. Please verify matches are correct.', Comment = '%1 - Line number';
        NoMatchesFoundMsg: Label 'Copilot could not find any line matches. Please review manually';
        GlobalDataCaptionExpressionTxt: Label 'Purchase Order %1', Comment = '%1 - Purchase order number';

    trigger OnAfterGetRecord()
    var
        EDocOrderMatch: Record "E-Doc. Order Match";
    begin
        CurrPage.OrderLines.Page.SetEDocumentBeingMatched(Rec);
        CurrPage.ImportedLines.Page.SetEDocumentBeingMatched(Rec);
        CurrPage.OrderLines.Page.ResetQtyOnNonMatchedLines();

        OpenPurchaseHeader();

        if AutoRunCopilot then begin
            AutoRunCopilot := false;
            EDocOrderMatch.SetRange("E-Document Entry No.", Rec."Entry No");
            if EDocOrderMatch.IsEmpty() then
                MatchWithCopilot(false);
        end;
    end;

    local procedure OpenPurchaseHeader()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(Rec."Document Record ID");
        Codeunit.Run(Codeunit::"Purchase Manual Reopen", PurchaseHeader);
    end;

    local procedure ApplyToPurchaseOrder()
    var
        TempEDocImportedLines: Record "E-Doc. Imported Line" temporary;
        PurchaseHeader: Record "Purchase Header";
        PurchaseOrderPage: Page "Purchase Order";
    begin
        OpenPurchaseHeader();
        CurrPage.ImportedLines.Page.GetRecords(TempEDocImportedLines);
        EDocMatchOrderLines.ApplyToPurchaseOrder(Rec, TempEDocImportedLines);

        Commit();
        PurchaseHeader.Get(Rec."Document Record ID");
        PurchaseOrderPage.SetRecord(PurchaseHeader);
        PurchaseOrderPage.Run();
        CurrPage.Close();
    end;

    local procedure RemoveMatches()
    var
        TempPurchaseLines: Record "Purchase Line" temporary;
        TempEDocMatches: Record "E-Doc. Order Match" temporary;
    begin
        CurrPage.OrderLines.Page.GetSelectedRecords(TempPurchaseLines);
        EDocMatchOrderLines.FindMatchesToRemove(Rec, TempPurchaseLines, TempEDocMatches);
        if not TempEDocMatches.IsEmpty() then
            EDocMatchOrderLines.PersistsUpdates(TempEDocMatches, true);
    end;

    local procedure MatchManually()
    var
        TempEDocImportedLines: Record "E-Doc. Imported Line" temporary;
        TempPurchaseLines: Record "Purchase Line" temporary;
        TempEDocMatches: Record "E-Doc. Order Match" temporary;
    begin
        CurrPage.ImportedLines.Page.GetSelectedRecords(TempEDocImportedLines);
        CurrPage.OrderLines.Page.GetSelectedRecords(TempPurchaseLines);

        EDocMatchOrderLines.MatchManually(TempEDocImportedLines, TempPurchaseLines, TempEDocMatches);
        if not TempEDocMatches.IsEmpty() then begin
            EDocMatchOrderLines.PersistsUpdates(TempEDocMatches, false);
            NotifyUserIfCostDifference(TempEDocMatches);
        end;
    end;

    local procedure MatchAutomatically()
    var
        TempEDocImportedLines: Record "E-Doc. Imported Line" temporary;
        TempPurchaseLines: Record "Purchase Line" temporary;
        TempEDocMatches: Record "E-Doc. Order Match" temporary;
    begin
        CurrPage.ImportedLines.Page.GetRecords(TempEDocImportedLines);
        CurrPage.OrderLines.Page.GetRecords(TempPurchaseLines);

        EDocMatchOrderLines.AskToOverwrite(Rec, TempEDocImportedLines, TempPurchaseLines);
        EDocMatchOrderLines.MatchAutomatically(Rec, TempEDocImportedLines, TempPurchaseLines, TempEDocMatches);
        if not TempEDocMatches.IsEmpty() then begin
            EDocMatchOrderLines.PersistsUpdates(TempEDocMatches, false);
            NotifyUserIfCostDifference(TempEDocMatches);
        end;
    end;

    local procedure MatchWithCopilot(CheckToOverwrite: Boolean)
    var
        TempEDocImportedLines: Record "E-Doc. Imported Line" temporary;
        TempPurchaseLines: Record "Purchase Line" temporary;
        AzureOpenAI: Codeunit "Azure OpenAI";
        AIMatchingImpl: Codeunit "E-Doc. PO Copilot Matching";
        EDocOrderMatchAIProposal: Page "E-Doc. PO Copilot Prop";
    begin
        if not AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"E-Document Matching Assistance") then
            exit;

        FeatureTelemetry.LogUptake('0000MB0', AIMatchingImpl.FeatureName(), Enum::"Feature Uptake Status"::Discovered);
        FeatureTelemetry.LogUptake('0000MB1', AIMatchingImpl.FeatureName(), Enum::"Feature Uptake Status"::"Set up");

        CurrPage.ImportedLines.Page.GetRecords(TempEDocImportedLines);
        CurrPage.OrderLines.Page.GetRecords(TempPurchaseLines);

        if CheckToOverwrite then
            EDocMatchOrderLines.AskToOverwrite(Rec, TempEDocImportedLines, TempPurchaseLines);
        Commit();
        EDocOrderMatchAIProposal.SetData(Rec, TempEDocImportedLines, TempPurchaseLines);
        EDocOrderMatchAIProposal.SetGenerateMode();
        EDocOrderMatchAIProposal.LookupMode(true);
        if EDocOrderMatchAIProposal.RunModal() = Action::Cancel then
            if ((not EDocOrderMatchAIProposal.WasCopilotMatchesFound()) and EDocOrderMatchAIProposal.IsCopilotRequestSuccessful()) then
                Message(NoMatchesFoundMsg);

        CurrPage.Update();
    end;

    local procedure SetUserInteractions()
    begin
        CurrPage.ImportedLines.Page.SetUserInteractions();
        CurrPage.OrderLines.Page.SetUserInteractions();
    end;

    local procedure NotifyUserIfCostDifference(var TempEDocMatches: Record "E-Doc. Order Match" temporary)
    var
        EDocImportedLine: Record "E-Doc. Imported Line";
        PurchaseLine: Record "Purchase Line";
        DiffCostNos: Text;
        EDocLineAmount, PurchLineAmount : Decimal;
    begin
        if TempEDocMatches.FindSet() then
            repeat
                EDocImportedLine := TempEDocMatches.GetImportedLine();
                PurchaseLine := TempEDocMatches.GetPurchaseLine();
                EDocLineAmount := ((100 - EDocImportedLine."Line Discount %") / 100) * EDocImportedLine."Direct Unit Cost";
                PurchLineAmount := ((100 - PurchaseLine."Line Discount %") / 100) * PurchaseLine."Direct Unit Cost";

                if EDocLineAmount <> PurchLineAmount then
                    DiffCostNos += Format(EDocImportedLine."Line No.") + ','; // Add line number to the list
            until TempEDocMatches.Next() = 0;

        if DiffCostNos.EndsWith(',') then begin
            DiffCostNos := DiffCostNos.Substring(1, StrLen(DiffCostNos) - 1);
            SendNotification(CostNotification, StrSubstNo(LineCostVaryMatchMsg, DiffCostNos));
        end;
    end;

    local procedure SendNotification(SelectionNotification: Notification; Message: Text)
    begin
        SelectionNotification.Scope(NotificationScope::LocalScope);
        SelectionNotification.Message(Message);
        SelectionNotification.Send();
    end;

    internal procedure SetTempRecord(var EDocument: Record "E-Document")
    begin
        Rec.DeleteAll();
        Rec.TransferFields(EDocument);
        Rec.SystemId := EDocument.SystemId;
        Rec.Insert(false);
    end;

    internal procedure SetAutoRunCopilot(CopilotToRun: Boolean)
    begin
        AutoRunCopilot := CopilotToRun;
    end;

}