namespace Microsoft.SubscriptionBilling;

using System.Threading;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.Dimension;

codeunit 8051 "Sub. Billing Installation"
{
    Subtype = Install;
    Access = Internal;
    Permissions = tabledata "Job Queue Entry" = rim;

    trigger OnInstallAppPerCompany()
    begin
        InitializeSetupTables();
        InitializeJobQueueEntries();
        InitializeBillingTemplates();
    end;

    procedure InitializeSetupTables()
    begin
        InitServiceContractSetup();
        InitGeneralLedgerSetup();
        InitSourceCodeSetup();
    end;

    procedure InitializeJobQueueEntries()
    begin
        InitUpdateServicesDatesJobQueueEntry();
    end;

    procedure InitServiceContractSetup()
    var
        ServiceContractSetup: Record "Service Contract Setup";
        ServiceContractSetupModified: Boolean;
    begin
        if not ServiceContractSetup.Get() then begin
            ServiceContractSetup.Init();
            ServiceContractSetup."Default Period Calculation" := ServiceContractSetup."Default Period Calculation"::"Align to End of Month";
            ServiceContractSetup.Insert(false);
        end;
        ServiceContractSetupModified := false;
        if ServiceContractSetup."Customer Contract Nos." = '' then begin
            ServiceContractSetup."Customer Contract Nos." :=
              CreateNoSeries(CustomerContractCodeLbl, CustomerContractDescriptionLbl, CustomerContractNoSeriesLineLbl);
            ServiceContractSetupModified := true;
        end;
        if ServiceContractSetup."Vendor Contract Nos." = '' then begin
            ServiceContractSetup."Vendor Contract Nos." :=
              CreateNoSeries(VendorContractCodeLbl, VendorContractDescriptionLbl, VendorContractNoSeriesLineLbl);
            ServiceContractSetupModified := true;
        end;
        if ServiceContractSetup."Service Object Nos." = '' then begin
            ServiceContractSetup."Service Object Nos." :=
              CreateNoSeries(ServiceObjectCodeLbl, ServiceObjectDescriptionLbl, ServiceObjectNoSeriesLineLbl);
            ServiceContractSetupModified := true;
        end;
        if not ServiceContractSetup."Aut. Insert C. Contr. DimValue" then begin
            ServiceContractSetup."Aut. Insert C. Contr. DimValue" := true;
            ServiceContractSetupModified := true;
        end;
        if (ServiceContractSetup."Contract Invoice Description" = ServiceContractSetup."Contract Invoice Description"::" ") or
           ((ServiceContractSetup."Contract Invoice Description" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
            (ServiceContractSetup."Contract Invoice Add. Line 1" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
            (ServiceContractSetup."Contract Invoice Add. Line 2" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
            (ServiceContractSetup."Contract Invoice Add. Line 3" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
            (ServiceContractSetup."Contract Invoice Add. Line 4" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
            (ServiceContractSetup."Contract Invoice Add. Line 5" <> Enum::"Contract Invoice Text Type"::"Billing Period"))
        then begin
            ServiceContractSetup.ContractTextsCreateDefaults();
            ServiceContractSetupModified := true;
        end;
        if ServiceContractSetupModified then
            ServiceContractSetup.Modify(false);
    end;

    local procedure CreateNoSeries(NoSeriesCode: Code[20]; NoSeriesDescription: Text[100]; NoSeriesLinePrefix: Code[14]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeries.Get(NoSeriesCode) then
            exit(NoSeries.Code);

        NoSeries.Init();
        NoSeries.Code := NoSeriesCode;
        NoSeries.Description := NoSeriesDescription;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := true;
        NoSeries.Insert(false);

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Validate("Starting No.", NoSeriesLinePrefix + '000001');
        NoSeriesLine.Insert(true);

        exit(NoSeries.Code);
    end;

    local procedure InitGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if not GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup.Init();
            GeneralLedgerSetup.Insert(false);
        end;
        if GeneralLedgerSetup."Dimension Code Cust. Contr." = '' then begin
            CreateDimension(CustContractDimensionCodeLbl, CustContractDimensionDescriptionLbl, CustContractDimensionDescriptionLbl, CustContractDimensionDescriptionLbl);
            GeneralLedgerSetup."Dimension Code Cust. Contr." := CustContractDimensionCodeLbl;
            GeneralLedgerSetup.Modify(false);
        end;
    end;

    internal procedure CreateDimension(DimensionCode: Code[20]; DimensionName: Text; DimensionCodeCaption: Text; DimensionFilterCaption: Text)
    var
        Dimension: Record Dimension;
    begin
        if Dimension.Get(DimensionCode) then
            exit;

        Dimension.Init();
        Dimension.Validate(Code, DimensionCode);
        Dimension.Name := CopyStr(DimensionName, 1, MaxStrLen(Dimension.Name));
        Dimension."Code Caption" := CopyStr(DimensionCodeCaption, 1, MaxStrLen(Dimension."Code Caption"));
        Dimension."Filter Caption" := CopyStr(DimensionFilterCaption, 1, MaxStrLen(Dimension."Filter Caption"));
        Dimension.Insert(true);
    end;

    local procedure InitUpdateServicesDatesJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        NextRunDateFormula: DateFormula;
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Update Serv. Comm. Term. Dates");
        if not JobQueueEntry.IsEmpty then
            exit;

        JobQueueEntry.Init();
        JobQueueEntry.Validate("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.Validate("Object ID to Run", Codeunit::"Update Serv. Comm. Term. Dates");
        JobQueueEntry.Insert(true);
        JobQueueEntry.Validate("Earliest Start Date/Time", CurrentDateTime());
        Evaluate(NextRunDateFormula, '<1D>');
        JobQueueEntry.Validate("Next Run Date Formula", NextRunDateFormula);
        JobQueueEntry.Validate("Starting Time", 010000T);
        JobQueueEntry.Modify(true);
        JobQueueEntry.SetStatus(JobQueueEntry.Status::Ready);
    end;

    local procedure InitSourceCodeSetup()
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if not SourceCodeSetup.Get() then begin
            SourceCodeSetup.Init();
            SourceCodeSetup.Insert(false);
        end;
        if SourceCodeSetup."Contract Deferrals Release" = '' then begin
            SourceCodeSetup."Contract Deferrals Release" := FindOrCreateSourceCode();
            SourceCodeSetup.Modify(false);
        end;
    end;

    local procedure FindOrCreateSourceCode(): Code[10]
    var
        SourceCode: Record "Source Code";
    begin
        if not SourceCode.Get(ContractDeferralReleaseCodeLbl) then begin
            SourceCode.Init();
            SourceCode.Code := ContractDeferralReleaseCodeLbl;
            SourceCode.Description := ContractDeferralsReleaseDescriptionLbl;
            SourceCode.Insert(false);
        end;
        exit(SourceCode.Code)
    end;

    local procedure InitializeBillingTemplates()
    var
        BillingTemplate: Record "Billing Template";
    begin
        if not BillingTemplate.IsEmpty then
            exit;

        BillingTemplate.Init();
        BillingTemplate.Code := CustomerLbl;
        BillingTemplate.Description := CustomerBillingTemplateDescriptionTxt;
        BillingTemplate.Partner := "Service Partner"::Customer;
        BillingTemplate.Insert(false);

        BillingTemplate.Init();
        BillingTemplate.Code := VendorLbl;
        BillingTemplate.Description := VendorBillingTemplateDescriptionTxt;
        BillingTemplate.Partner := "Service Partner"::Vendor;
        BillingTemplate.Insert(false);
    end;

    var
        CustomerLbl: Label 'Customer';
        CustomerBillingTemplateDescriptionTxt: Label 'Sample template for customer billing';
        CustomerContractCodeLbl: Label 'CUSTCONTR', MaxLength = 20;
        CustomerContractDescriptionLbl: Label 'Customer Contracts';
        CustomerContractNoSeriesLineLbl: Label 'CUC', MaxLength = 14;
        VendorLbl: Label 'Vendor';
        VendorBillingTemplateDescriptionTxt: Label 'Sample template for vendor billing';
        VendorContractCodeLbl: Label 'VENDCONTR', MaxLength = 20;
        VendorContractDescriptionLbl: Label 'Vendor Contracts';
        VendorContractNoSeriesLineLbl: Label 'VEC', MaxLength = 14;
        ServiceObjectCodeLbl: Label 'SERVOBJECT', MaxLength = 20;
        ServiceObjectDescriptionLbl: Label 'Service Objects';
        ServiceObjectNoSeriesLineLbl: Label 'SOBJ', MaxLength = 14;
        CustContractDimensionCodeLbl: Label 'CUSTOMERCONTRACT';
        CustContractDimensionDescriptionLbl: Label 'Customer Contract Dimension';
        ContractDeferralReleaseCodeLbl: Label 'CONTDEFREL', MaxLength = 10;
        ContractDeferralsReleaseDescriptionLbl: Label 'Contract Deferrals Release';
}