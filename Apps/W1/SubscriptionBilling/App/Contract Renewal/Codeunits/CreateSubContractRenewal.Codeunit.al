namespace Microsoft.SubscriptionBilling;

using System.IO;
using System.Utilities;
using Microsoft.Sales.Document;
using Microsoft.Finance.Currency;

codeunit 8002 "Create Sub. Contract Renewal"
{
    TableNo = "Sub. Contract Renewal Line";
    SingleInstance = true;

    trigger OnRun()
    begin
        Rec.ModifyAll("Error Message", '', false);
        CreateSingleContractRenewal(Rec);
    end;

    local procedure RunCheck(var ContractRenewalLine: Record "Sub. Contract Renewal Line")
    var
        ContractRenewalLine2: Record "Sub. Contract Renewal Line";
    begin
        ContractRenewalLine2 := ContractRenewalLine;
        ContractRenewalLine.SetAutoCalcFields(Partner, "Planned Sub. Line exists");
        if ContractRenewalLine.FindSet() then
            repeat
                CheckContractRenewalLine(ContractRenewalLine);
            until ContractRenewalLine.Next() = 0;
        ContractRenewalLine := ContractRenewalLine2;
        OnAfterRunCheck(ContractRenewalLine);
    end;

    local procedure CheckContractRenewalLine(var ContractRenewalLine: Record "Sub. Contract Renewal Line")
    var
        ServiceCommitment: Record "Subscription Line";
        ContractRenewalMgt: Codeunit "Sub. Contract Renewal Mgt.";
        ContractRenewalLineIsInSalesQuoteErr: Label 'A Sales Quote already exists for %1 %2, %3 %4.', Comment = '%1=Table Caption, %2=Subscription Header No., %3=Field Caption, %4=Entry No.';
    begin
        ContractRenewalLine.TestField("Subscription Header No.");
        ContractRenewalLine.TestField("Subscription Line Entry No.");
        if ContractRenewalLine."Subscription Line End Date" = 0D then
            ContractRenewalLine.CalcFields("Subscription Line End Date");
        ContractRenewalLine.TestField("Subscription Line End Date");
        ContractRenewalLine.TestField("Renewal Term");
        ContractRenewalLine.TestField("Planned Sub. Line exists", false);
        if ContractRenewalLine.Partner = ContractRenewalLine.Partner::Customer then begin
            ContractRenewalLine.TestField("Subscription Contract No.");
            ContractRenewalLine.TestField("Subscription Contract Line No.");
        end;

        ServiceCommitment.Get(ContractRenewalLine."Subscription Line Entry No.");
        ServiceCommitment.CalcFields("Planned Sub. Line exists");
        ServiceCommitment.TestField("Planned Sub. Line exists", false);
        ServiceCommitment.TestField("Subscription Line End Date");

        if ContractRenewalMgt.ExistsInSalesOrderOrSalesQuote(ContractRenewalLine.Partner, ContractRenewalLine."Subscription Contract No.", ContractRenewalLine."Subscription Contract Line No.") then
            Error(
                ContractRenewalLineIsInSalesQuoteErr,
                ServiceCommitment.TableCaption,
                ServiceCommitment."Subscription Header No.",
                ServiceCommitment.FieldCaption("Entry No."),
                ServiceCommitment."Entry No.");
        OnAfterCheckSubContractRenewalLine(ContractRenewalLine);
    end;

    internal procedure BatchCreateContractRenewal(var ContractRenewalLine: Record "Sub. Contract Renewal Line")
    var
        ContractRenewalLine2: Record "Sub. Contract Renewal Line";
        TempContractRenewalLine: Record "Sub. Contract Renewal Line" temporary;
        ContractNo: Code[20];
        Window: Dialog;
        ProgressTxt: Label 'Creating Sales Quotes ...';
    begin
        CurrentSalesHeader.Reset();
        Clear(CurrentSalesHeader);

        ContractNo := '';
        ContractRenewalLine2.Copy(ContractRenewalLine);
        ContractRenewalLine.SetCurrentKey("Linked to Sub. Contract No.", "Linked to Sub. Contr. Line No.");
        ContractRenewalLine.SetRange(Partner, ContractRenewalLine.Partner::Customer);
        if ContractRenewalLine.FindSet() then begin
            Window.Open(ProgressTxt);
            repeat
                ContractRenewalLine.TestField("Subscription Contract No.");
                ContractRenewalLine.TestField("Subscription Header No.");
                ContractRenewalLine.TestField("Subscription Line Entry No.");
                if ContractNo = '' then
                    ContractNo := ContractRenewalLine."Subscription Contract No.";
                if ContractNo <> ContractRenewalLine."Subscription Contract No." then begin
                    CallCreateSingleContractRenewalFromBatch(TempContractRenewalLine);
                    TempContractRenewalLine.Reset();
                    TempContractRenewalLine.DeleteAll(false);
                    ContractNo := ContractRenewalLine."Subscription Contract No.";
                end;
                TempContractRenewalLine := ContractRenewalLine;
                TempContractRenewalLine.Insert(false);
                ContractRenewalLine2.SetRange("Subscription Header No.", ContractRenewalLine."Subscription Header No.");
                ContractRenewalLine2.SetRange("Linked to Sub. Line Entry No.", ContractRenewalLine."Subscription Line Entry No.");
                if ContractRenewalLine2.FindSet() then
                    repeat
                        TempContractRenewalLine := ContractRenewalLine2;
                        TempContractRenewalLine.Insert(false);
                    until ContractRenewalLine2.Next() = 0;
            until ContractRenewalLine.Next() = 0;
            CallCreateSingleContractRenewalFromBatch(TempContractRenewalLine);
            TempContractRenewalLine.Reset();
            TempContractRenewalLine.DeleteAll(false);
            Window.Close();
        end;

        OpenSalesQuotes();
    end;

    internal procedure OpenSalesQuotes()
    var
        SalesHeader: Record "Sales Header";
        NothingCreatedMsg: Label 'No Documents have been created.';
        OpenSingleQst: Label '%1 %2 has been created.\\Do you want to open the document?', Comment = '%1=Document Type, %2=No.';
        OpenMultipleQst: Label '%1 Sales Quotes have been created. Do you want to open a list of the documents?', Comment = '%1=Count of Sales Quotes';
    begin
        CurrentSalesHeader.MarkedOnly(true);
        if not CurrentSalesHeader.FindFirst() then begin
            Message(NothingCreatedMsg);
            exit;
        end;
        SalesHeader.Get(CurrentSalesHeader."Document Type", CurrentSalesHeader."No.");
        CurrentSalesHeader.FindLast();
        if CurrentSalesHeader."No." = SalesHeader."No." then begin
            if ConfirmManagement.GetResponse(StrSubstNo(OpenSingleQst, SalesHeader."Document Type", SalesHeader."No."), true) then begin
                Commit(); // close transaction before opening page
                Page.Run(Page::"Sales Quote", SalesHeader);
            end;
        end else begin
            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
            SalesHeader.SetRange("No.", SalesHeader."No.", CurrentSalesHeader."No.");
            if ConfirmManagement.GetResponse(StrSubstNo(OpenMultipleQst, SalesHeader.Count()), true) then begin
                Commit(); // close transaction before opening page
                Page.Run(Page::"Sales Quotes", SalesHeader);
            end;
        end;
    end;

    local procedure CallCreateSingleContractRenewalFromBatch(var TempContractRenewalLine: Record "Sub. Contract Renewal Line" temporary)
    var
        ContractRenewalLine: Record "Sub. Contract Renewal Line";
        CreateContractRenewal: Codeunit "Create Sub. Contract Renewal";
        Ok: Boolean;
    begin
        if TempContractRenewalLine.IsEmpty() then
            exit;
        if not TempContractRenewalLine.IsTemporary() then
            Error('Record not temporary!');

        Commit(); // close transaction before Codeunit.Run w. Results
        ClearLastError();
        Clear(CreateContractRenewal);
        Ok := CreateContractRenewal.Run(TempContractRenewalLine);
        if not Ok then begin
            TempContractRenewalLine.FindSet();
            repeat
                ContractRenewalLine.Get(TempContractRenewalLine."Subscription Line Entry No.");
                ContractRenewalLine."Error Message" := CopyStr(GetLastErrorText(), 1, MaxStrLen(ContractRenewalLine."Error Message"));
                ContractRenewalLine.Modify(false);
            until TempContractRenewalLine.Next() = 0;
        end else
            if CurrentSalesHeader.Get(CurrentSalesHeader."Document Type"::Quote, CreateContractRenewal.GetSalesQuoteNo()) then
                CurrentSalesHeader.Mark(true);
    end;

    local procedure CreateSingleContractRenewal(var ContractRenewalLine: Record "Sub. Contract Renewal Line")
    var
        CustomerContract: Record "Customer Subscription Contract";
    begin
        RunCheck(ContractRenewalLine);

        ContractRenewalLine.SetCurrentKey("Linked to Sub. Contract No.", "Linked to Sub. Contr. Line No.");
        ContractRenewalLine.SetRange(Partner, ContractRenewalLine.Partner::Customer);
        ContractRenewalLine.FindFirst();
        CustomerContract.Get(ContractRenewalLine."Subscription Contract No.");
        CreateSalesQuoteHeaderFromCustomerContract(CustomerContract);

        PreviousServiceStartDate := 0D;
        PreviousServiceEndDate := 0D;

        ContractRenewalLine.FindSet();
        repeat
            if ContractRenewalLine.Partner = ContractRenewalLine.Partner::Customer then
                CreateSalesQuoteLineFromContractRenewalLine(ContractRenewalLine);
        until ContractRenewalLine.Next() = 0;
        OnAfterCreateSingleContractRenewal(CurrentSalesHeader, CustomerContract);
    end;

    local procedure CreateSalesQuoteHeaderFromCustomerContract(CustomerContract: Record "Customer Subscription Contract")
    var
        OldSalesHeader: Record "Sales Header";
        SalesDocuments: Codeunit "Sales Documents";
    begin
        SalesDocuments.SetCalledFromContractRenewal(true);

        CurrentSalesHeader.Init();
        CurrentSalesHeader."Document Type" := CurrentSalesHeader."Document Type"::Quote;
        CurrentSalesHeader."No." := '';
        CurrentSalesHeader.Insert(true);
        CurrentSalesHeader.SetHideValidationDialog(true);
        CurrentSalesHeader.Validate("Sell-to Customer No.", CustomerContract."Sell-to Customer No.");
        if CurrentSalesHeader."Bill-to Customer No." <> CustomerContract."Bill-to Customer No." then
            CurrentSalesHeader.Validate("Bill-to Customer No.", CustomerContract."Bill-to Customer No.");
        OldSalesHeader := CurrentSalesHeader;
        CurrentSalesHeader.TransferFields(CustomerContract, false);
        CurrentSalesHeader."Recurring Billing" := false;
        CurrentSalesHeader."No. Series" := OldSalesHeader."No. Series";
        CurrentSalesHeader."Posting No." := OldSalesHeader."Posting No.";
        CurrentSalesHeader."Posting No. Series" := OldSalesHeader."Posting No. Series";
        CurrentSalesHeader."Shipping No." := OldSalesHeader."Shipping No.";
        CurrentSalesHeader."Shipping No. Series" := OldSalesHeader."Shipping No. Series";
        CurrentSalesHeader."No. Printed" := 0;
        CurrentSalesHeader.Validate("Document Date", WorkDate());
        CurrentSalesHeader.Validate("Currency Code");
        CurrentSalesHeader."Assigned User ID" := CopyStr(UserId(), 1, MaxStrLen(CurrentSalesHeader."Assigned User ID"));
        CurrentSalesHeader.SetHideValidationDialog(false);
        CurrentSalesHeader.Modify(false);
        CurrentSalesHeader.Mark(true);

        OnAfterCreateSalesHeaderFromSubscriptionContract(CustomerContract, CurrentSalesHeader);

        CreateDescriptionLines(CustomerContract);
        SalesDocuments.SetCalledFromContractRenewal(false);
    end;

    local procedure CreateSalesQuoteLineFromContractRenewalLine(var ContractRenewalLine: Record "Sub. Contract Renewal Line")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ServiceObject: Record "Subscription Header";
        ServiceCommitment: Record "Subscription Line";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        ContractRenewalLine2: Record "Sub. Contract Renewal Line";
        TranslationHelper: Codeunit "Translation Helper";
    begin
        OnBeforeCreateSalesQuoteLineFromSubContractRenewalLine(ContractRenewalLine);
        ContractRenewalLine.TestField("Subscription Header No.");
        ContractRenewalLine.TestField("Subscription Line Entry No.");
        ServiceObject.Get(ContractRenewalLine."Subscription Header No.");
        ServiceCommitment.Get(ContractRenewalLine."Subscription Line Entry No.");

        InsertTermInfoLine(ContractRenewalLine);

        SalesLine.InitFromSalesHeader(CurrentSalesHeader);
        SalesLine.Type := SalesLine.Type::"Service Object";
        SalesLine.Validate("No.", ServiceObject."No.");
        SalesLine.Validate("Unit of Measure Code", ServiceObject."Unit of Measure");
        SalesLine.Description := ServiceObject.Description;
        SalesLine.Validate(Quantity, ServiceObject.Quantity);
        if SalesLine."Currency Code" = ServiceCommitment."Currency Code" then
            SalesLine.Validate("Unit Price", ServiceCommitment.Price)
        else begin
            SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
            SalesLine.Validate("Unit Price",
                CurrencyExchangeRate.ExchangeAmtFCYToFCY(
                    SalesHeader.GetUseDate(),
                    ServiceCommitment."Currency Code",
                    SalesLine."Currency Code",
                    ServiceCommitment.Price));
        end;
        if ServiceCommitment."Discount %" <> 0 then
            SalesLine.Validate("Line Discount %", ServiceCommitment."Discount %");
        SalesLine.Validate("Unit Cost (LCY)", ServiceCommitment."Unit Cost (LCY)");
        SalesLine.GetCombinedDimensionSetID(SalesLine."Dimension Set ID", ServiceCommitment."Dimension Set ID");
        SalesLine."Exclude from Doc. Total" := true;
        SalesLine.Insert(false);

        SalesLine.DeleteSalesServiceCommitment();
        if ServiceObject."Serial No." <> '' then begin
            TranslationHelper.SetGlobalLanguageByCode(CurrentSalesHeader."Language Code");
            SalesLine.InsertDescriptionSalesLine(CurrentSalesHeader, ServiceObject.GetSerialNoDescription(), SalesLine."Line No.");
            TranslationHelper.RestoreGlobalLanguage();
        end;
        OnAfterInsertSalesQuoteLineFromSubContractRenewalLine(SalesLine, ContractRenewalLine);

        AddServiceCommitment(SalesLine, ContractRenewalLine);
        AddLinkedServiceCommitment(SalesLine, ContractRenewalLine);
        OnAfterAddSubscriptionLinesToSalesLine(SalesLine, ContractRenewalLine);

        if ContractRenewalLine2.Get(ContractRenewalLine."Subscription Line Entry No.") then
            ContractRenewalLine2.Delete(false);
    end;

    local procedure AddLinkedServiceCommitment(var SalesLine: Record "Sales Line"; var ContractRenewalLine: Record "Sub. Contract Renewal Line")
    var
        LinkedContractRenewalLine: Record "Sub. Contract Renewal Line";
        LinkedContractRenewalLine2: Record "Sub. Contract Renewal Line";
    begin
        LinkedContractRenewalLine.Reset();
        LinkedContractRenewalLine.SetRange("Subscription Header No.", ContractRenewalLine."Subscription Header No.");
        LinkedContractRenewalLine.SetRange("Linked to Sub. Line Entry No.", ContractRenewalLine."Subscription Line Entry No.");
        if LinkedContractRenewalLine.FindSet() then
            repeat
                AddServiceCommitment(SalesLine, LinkedContractRenewalLine);
                if LinkedContractRenewalLine2.Get(LinkedContractRenewalLine."Subscription Line Entry No.") then
                    LinkedContractRenewalLine2.Delete(false);
            until LinkedContractRenewalLine.Next() = 0;
    end;

    local procedure AddServiceCommitment(var SalesLine: Record "Sales Line"; var ContractRenewalLine: Record "Sub. Contract Renewal Line")
    var
        ServiceCommitment: Record "Subscription Line";
        SalesServiceCommitment: Record "Sales Subscription Line";
        EmptyDateFormula: DateFormula;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsertSubscriptionLine(SalesLine, ContractRenewalLine, IsHandled);
        if not IsHandled then begin
            ContractRenewalLine.TestField("Subscription Header No.");
            ContractRenewalLine.TestField("Subscription Line Entry No.");
            ContractRenewalLine.TestField("Agreed Sub. Line Start Date");
            ServiceCommitment.Get(ContractRenewalLine."Subscription Line Entry No.");

            SalesServiceCommitment.Init();
            SalesServiceCommitment.InitRecord(SalesLine);
            SalesServiceCommitment.Insert(false);
            SalesServiceCommitment."Invoicing via" := ServiceCommitment."Invoicing via";
            SalesServiceCommitment.Validate("Item No.", ServiceCommitment."Invoicing Item No.");
            SalesServiceCommitment."Customer Price Group" := SalesLine."Customer Price Group";
            SalesServiceCommitment.Validate("Subscription Package Code", ServiceCommitment."Subscription Package Code");
            SalesServiceCommitment.Template := ServiceCommitment.Template;
            SalesServiceCommitment.Description := ServiceCommitment.Description;
            SalesServiceCommitment.Validate("Extension Term", ServiceCommitment."Extension Term");
            SalesServiceCommitment.Validate("Notice Period", ServiceCommitment."Notice Period");
            SalesServiceCommitment.Validate("Initial Term", ContractRenewalLine."Renewal Term");
            SalesServiceCommitment.Partner := ServiceCommitment.Partner;
            if ServiceCommitment."Billing Base Period" <> EmptyDateFormula then
                SalesServiceCommitment.Validate("Billing Base Period", ServiceCommitment."Billing Base Period");
            SalesServiceCommitment."Calculation Base %" := ServiceCommitment."Calculation Base %";
            if ServiceCommitment."Discount %" <> ServiceCommitment."Discount %" then
                SalesServiceCommitment.Validate("Discount %", ServiceCommitment."Discount %");
            SalesServiceCommitment.Validate("Billing Rhythm", ServiceCommitment."Billing Rhythm");
            SalesServiceCommitment.Validate("Agreed Sub. Line Start Date", ContractRenewalLine."Agreed Sub. Line Start Date");
            SalesServiceCommitment."Extension Term" := ServiceCommitment."Extension Term";
            SalesServiceCommitment.Validate("Calculation Base Amount", ServiceCommitment."Calculation Base Amount");
            if SalesServiceCommitment.Price <> ServiceCommitment.Price then
                SalesServiceCommitment.Validate(Price, ServiceCommitment.Price);
            SalesServiceCommitment."Unit Cost" := ServiceCommitment."Unit Cost";
            SalesServiceCommitment."Unit Cost (LCY)" := ServiceCommitment."Unit Cost (LCY)";
            SalesServiceCommitment."Subscription Header No." := ContractRenewalLine."Subscription Header No.";
            SalesServiceCommitment."Subscription Line Entry No." := ContractRenewalLine."Subscription Line Entry No.";
            SalesServiceCommitment."Linked to No." := ContractRenewalLine."Subscription Contract No.";
            SalesServiceCommitment."Linked to Line No." := ContractRenewalLine."Subscription Contract Line No.";
            SalesServiceCommitment.Process := Enum::Process::"Contract Renewal";
            SalesServiceCommitment.Modify(false);
        end;
        OnAfterInsertSubscriptionLine(SalesLine, ContractRenewalLine, SalesServiceCommitment);
    end;

    local procedure InsertTermInfoLine(var ContractRenewalLine: Record "Sub. Contract Renewal Line")
    var
        ServiceCommitment: Record "Subscription Line";
        SalesLine: Record "Sales Line";
        TranslationHelper: Codeunit "Translation Helper";
        ServiceStartDate: Date;
        ServiceEndDate: Date;
        TermDurationTxt: Label '%1 to %2', Comment = '%1=Start Date, %2=End Date';
        LineText: Text;
    begin
        ContractRenewalLine.TestField("Subscription Header No.");
        ContractRenewalLine.TestField("Subscription Line Entry No.");
        ContractRenewalLine.TestField("Renewal Term");
        ServiceCommitment.Get(ContractRenewalLine."Subscription Line Entry No.");

        ServiceStartDate := ContractRenewalLine."Agreed Sub. Line Start Date";
        if ServiceStartDate = 0D then
            ServiceStartDate := CalcDate('<+1D>', ServiceCommitment."Subscription Line End Date");
        ServiceEndDate := CalcDate('<-1D>', CalcDate(ContractRenewalLine."Renewal Term", ServiceStartDate));
        if (ServiceStartDate <> PreviousServiceStartDate) or (ServiceEndDate <> PreviousServiceEndDate) then begin
            TranslationHelper.SetGlobalLanguageByCode(CurrentSalesHeader."Language Code");
            LineText := StrSubstNo(TermDurationTxt, ServiceStartDate, ServiceEndDate);
            SalesLine.InsertDescriptionSalesLine(CurrentSalesHeader, LineText, 0);
            TranslationHelper.RestoreGlobalLanguage();
            PreviousServiceStartDate := ServiceStartDate;
            PreviousServiceEndDate := ServiceEndDate;
        end;
        OnAfterInsertTermInfoLine(CurrentSalesHeader, ContractRenewalLine);
    end;

    local procedure CreateDescriptionLines(var CustomerContract: Record "Customer Subscription Contract")
    var
        SalesLine: Record "Sales Line";
        TranslationHelper: Codeunit "Translation Helper";
        CreateBillingDocuments: Codeunit "Create Billing Documents";
        ContractTypeDescription: Text;
        LineText: Text;
        LineText2: Text;
        IsHandled: Boolean;
        ServicePartner: Enum "Service Partner";
        ContractRenewalTxt: Label 'Contract Renewal';
        ContractNoTxt: Label 'Contract No. %1', Comment = '%1=Contract No.';
    begin
        IsHandled := false;
        OnBeforeInsertSubscriptionContractDescriptionSalesLines(CustomerContract, CurrentSalesHeader, IsHandled);
        if not IsHandled then begin
            TranslationHelper.SetGlobalLanguageByCode(CurrentSalesHeader."Language Code");
            ContractTypeDescription := CreateBillingDocuments.GetContractTypeDescription(CustomerContract."No.", ServicePartner::Customer, CurrentSalesHeader."Language Code");
            LineText := ContractRenewalTxt;
            if ContractTypeDescription <> '' then
                LineText += ' ' + ContractTypeDescription;
            SalesLine.InsertDescriptionSalesLine(CurrentSalesHeader, LineText, 0);
            LineText2 := StrSubstNo(ContractNoTxt, CustomerContract."No.");
            SalesLine.InsertDescriptionSalesLine(CurrentSalesHeader, LineText2, 0);
            TranslationHelper.RestoreGlobalLanguage();
        end;
        OnAfterInsertSubscriptionContractDescriptionSalesLines(CustomerContract, CurrentSalesHeader);
    end;

    procedure GetSalesQuoteNo(): Code[20]
    begin
        exit(CurrentSalesHeader."No.");
    end;

    internal procedure ClearCollectedSalesQuotes()
    begin
        Clear(CurrentSalesHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSalesHeaderFromSubscriptionContract(CustomerSubscriptionContract: Record "Customer Subscription Contract"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSubscriptionContractDescriptionSalesLines(CustomerSubscriptionContract: Record "Customer Subscription Contract"; SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSubscriptionContractDescriptionSalesLines(CustomerSubscriptionContract: Record "Customer Subscription Contract"; SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSalesQuoteLineFromSubContractRenewalLine(var SalesLine: Record "Sales Line"; var SubContractRenewalLine: Record "Sub. Contract Renewal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertTermInfoLine(CurrentSalesHeader: Record "Sales Header"; var SubContractRenewalLine: Record "Sub. Contract Renewal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSubscriptionLine(var SalesLine: Record "Sales Line"; var SubContractRenewalLine: Record "Sub. Contract Renewal Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSubscriptionLine(var SalesLine: Record "Sales Line"; var SubContractRenewalLine: Record "Sub. Contract Renewal Line"; var SalesSubscriptionLine: Record "Sales Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterAddSubscriptionLinesToSalesLine(var SalesLine: Record "Sales Line"; var SubContractRenewalLine: Record "Sub. Contract Renewal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCheckSubContractRenewalLine(var ContractRenewalLine: Record "Sub. Contract Renewal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateSingleContractRenewal(SalesQuoteHeader: Record "Sales Header"; CustomerSubscriptionContract: Record "Customer Subscription Contract")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRunCheck(var SubContractRenewalLine: Record "Sub. Contract Renewal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateSalesQuoteLineFromSubContractRenewalLine(var SubContractRenewalLine: Record "Sub. Contract Renewal Line")
    begin
    end;

    var
        CurrentSalesHeader: Record "Sales Header";
        ConfirmManagement: Codeunit "Confirm Management";
        PreviousServiceStartDate: Date;
        PreviousServiceEndDate: Date;
}