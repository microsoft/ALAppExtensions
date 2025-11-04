namespace Microsoft.Service.Test;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Calendar;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Pricing;
using Microsoft.Service.Comment;
using Microsoft.Service.Contract;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Service.Item;
using Microsoft.Service.Loaner;
using Microsoft.Service.Maintenance;
using Microsoft.Service.Posting;
using Microsoft.Service.Pricing;
using Microsoft.Service.Setup;
using Microsoft.Warehouse.Setup;
using Microsoft.Projects.Project.Planning;
using Microsoft.Projects.Project.Job;
using Microsoft.Inventory.Item;
using Microsoft.Projects.TimeSheet;
using Microsoft.Projects.Resources.Resource;

/// <summary>
/// Provides utility functions for creating and managing service-related entities in test scenarios, including service orders, contracts, and items.
/// </summary>
codeunit 131902 "Library - Service"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibraryResource: Codeunit "Library - Resource";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTimesheet: Codeunit "Library - Time Sheet";
        LibraryCashFlowHelper: Codeunit "Library - Cash Flow Helper";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        ServicePeriodOneMonthTxt: Label '<1M>', Locked = true;
        PaymentChannelTxt: Label 'Payment Channel';
        NonWorkDayWorkDaySequenceNotFoundErr: Label 'No non-working day followed by a working day found within an interval of %1 days.', Locked = true;
        TimeSheetFieldValueErr: Label 'Time Sheet field %1 value is incorrect.', Locked = true;

    procedure CreateBaseCalendar(var BaseCalendar: Record "Base Calendar")
    begin
        BaseCalendar.Init();
        // Use the function GenerateRandomCode to get random and unique value for the Code field.
        BaseCalendar.Validate(Code, LibraryUtility.GenerateRandomCode(BaseCalendar.FieldNo(Code), DATABASE::"Base Calendar"));
        BaseCalendar.Insert(true);
    end;

    procedure CreateContractGroup(var ContractGroup: Record "Contract Group")
    begin
        ContractGroup.Init();

        // Use the function GenerateRandomCode to get random and unique value for the Code field.
        ContractGroup.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(ContractGroup.FieldNo(Code), DATABASE::"Base Calendar"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Base Calendar", ContractGroup.FieldNo(Code))));
        ContractGroup.Insert(true);
    end;

    procedure CreateContractLineCreditMemo(var ServiceContractLine: Record "Service Contract Line"; Deleting: Boolean): Code[20]
    var
        ServContractManagement: Codeunit ServContractManagement;
        CreditMemoNo: Code[20];
    begin
        CreditMemoNo := ServContractManagement.CreateContractLineCreditMemo(ServiceContractLine, Deleting);
        exit(CreditMemoNo);
    end;

    procedure CreateContractServiceDiscount(var ContractServiceDiscount: Record "Contract/Service Discount"; ServiceContractHeader: Record "Service Contract Header"; Type: Enum "Service Contract Discount Type"; No: Code[20])
    begin
        ContractServiceDiscount.Init();
        ContractServiceDiscount.Validate("Contract Type", ServiceContractHeader."Contract Type");
        ContractServiceDiscount.Validate("Contract No.", ServiceContractHeader."Contract No.");
        ContractServiceDiscount.Validate(Type, Type);
        ContractServiceDiscount.Validate("No.", No);
        ContractServiceDiscount.Validate("Starting Date", ServiceContractHeader."Starting Date");
        ContractServiceDiscount.Validate("Discount %", LibraryRandom.RandInt(100));  // Validating as random because value is not important.
        ContractServiceDiscount.Insert(true);
    end;

#if not CLEAN26
    [Obsolete('Moved to codeunit Library Inventory', '26.0')]
    procedure CreateExtendedTextForItem(ItemNo: Code[20]): Text
    begin
        exit(LibraryInventory.CreateExtendedTextForItem(ItemNo));
    end;
#endif

#if not CLEAN26
    [Obsolete('Moved to codeunit Library Inventory', '26.0')]
    procedure CreateExtendedTextHeaderItem(var ExtendedTextHeader: Record Microsoft.Foundation.ExtendedText."Extended Text Header"; ItemNo: Code[20])
    begin
        LibraryInventory.CreateExtendedTextHeaderItem(ExtendedTextHeader, ItemNo);
    end;
#endif

#if not CLEAN26
    [Obsolete('Moved to codeunit Library Inventory', '26.0')]
    procedure CreateExtendedTextLineItem(var ExtendedTextLine: Record Microsoft.Foundation.ExtendedText."Extended Text Line"; ExtendedTextHeader: Record Microsoft.Foundation.ExtendedText."Extended Text Header")
    begin
        LibraryInventory.CreateExtendedTextLineItem(ExtendedTextLine, ExtendedTextHeader);
    end;
#endif

    procedure CreateFaultArea(var FaultArea: Record "Fault Area")
    begin
        FaultArea.Init();
        // Use the function GenerateRandomCode to get random and unique value for the Code field.
        FaultArea.Validate(Code, LibraryUtility.GenerateRandomCode(FaultArea.FieldNo(Code), DATABASE::"Fault Area"));
        FaultArea.Validate(Description, FaultArea.Code);  // Validating Code as Description because value is not important.
        FaultArea.Insert(true);
    end;

    procedure CreateFaultCode(var FaultCode: Record "Fault Code"; FaultAreaCode: Code[10]; SymptomCode: Code[10])
    begin
        FaultCode.Init();
        FaultCode.Validate("Fault Area Code", FaultAreaCode);
        FaultCode.Validate("Symptom Code", SymptomCode);
        FaultCode.Validate(Code, LibraryUtility.GenerateRandomCode(FaultCode.FieldNo(Code), DATABASE::"Fault Code"));
        FaultCode.Validate(Description, FaultCode.Code);  // Validating Code as Description because value is not important.
        FaultCode.Insert(true);
    end;

    procedure CreateFaultReasonCode(var FaultReasonCode: Record "Fault Reason Code"; ExcludeWarrantyDiscount: Boolean; ExcludeContractDiscount: Boolean)
    begin
        FaultReasonCode.Validate(Code, LibraryUtility.GenerateRandomCode(FaultReasonCode.FieldNo(Code), DATABASE::"Fault Reason Code"));
        FaultReasonCode.Validate(Description, FaultReasonCode.Code);
        FaultReasonCode.Validate("Exclude Warranty Discount", ExcludeWarrantyDiscount);
        FaultReasonCode.Validate("Exclude Contract Discount", ExcludeContractDiscount);
        FaultReasonCode.Insert(true);
    end;

    procedure CreateFaultResolCodesRlship(var FaultResolCodRelationship: Record "Fault/Resol. Cod. Relationship"; FaultCode: Record "Fault Code"; ResolutionCode: Code[10]; ServiceItemGroupCode: Code[10])
    begin
        FaultResolCodRelationship.Init();
        FaultResolCodRelationship.Validate("Fault Area Code", FaultCode."Fault Area Code");
        FaultResolCodRelationship.Validate("Symptom Code", FaultCode."Symptom Code");
        FaultResolCodRelationship.Validate("Fault Code", FaultCode.Code);
        FaultResolCodRelationship.Validate("Resolution Code", ResolutionCode);
        FaultResolCodRelationship.Validate("Service Item Group Code", ServiceItemGroupCode);
        FaultResolCodRelationship.Insert(true);
    end;

    procedure CreateLoaner(var Loaner: Record Loaner)
    begin
        Loaner.Init();
        Loaner.Insert(true);
    end;

    procedure CreateReasonCode(var ReasonCode: Record "Reason Code")
    begin
        ReasonCode.Init();
        ReasonCode.Validate(Code, LibraryUtility.GenerateRandomCode(ReasonCode.FieldNo(Code), DATABASE::"Reason Code"));
        ReasonCode.Validate(Description, ReasonCode.Code);  // Validating Code as Description because value is not important.
        ReasonCode.Insert(true);
    end;

    procedure CreateRepairStatus(var RepairStatus: Record "Repair Status")
    begin
        RepairStatus.Init();
        // Use the function GenerateRandomCode to get random and unique value for the Code field.
        RepairStatus.Validate(Code, LibraryUtility.GenerateRandomCode(RepairStatus.FieldNo(Code), DATABASE::"Repair Status"));
        RepairStatus.Validate(Description, RepairStatus.Code);  // Validating Code as Description because value is not important.
        RepairStatus.Insert(true);
    end;

    procedure CreateResolutionCode(var ResolutionCode: Record "Resolution Code")
    begin
        ResolutionCode.Init();
        // Use the function GenerateRandomCode to get random and unique value for the Code field.
        ResolutionCode.Validate(Code, LibraryUtility.GenerateRandomCode(ResolutionCode.FieldNo(Code), DATABASE::"Resolution Code"));
        ResolutionCode.Validate(Description, ResolutionCode.Code);  // Validating Code as Description because value is not important.
        ResolutionCode.Insert(true);
    end;

    procedure CreateResponsibilityCenter(var ResponsibilityCenter: Record "Responsibility Center")
    begin
        ResponsibilityCenter.Init();
        ResponsibilityCenter.Validate(
          Code, LibraryUtility.GenerateRandomCode(ResponsibilityCenter.FieldNo(Code), DATABASE::"Responsibility Center"));
        ResponsibilityCenter.Validate(Name, ResponsibilityCenter.Code);  // Validating Code as Name because value is not important.
        ResponsibilityCenter.Insert(true);
    end;

    procedure CreateServiceCommentLine(var ServiceCommentLine: Record "Service Comment Line"; TableName: Enum "Service Comment Table Name"; TableSubtype: Option; No: Code[20]; Type: Enum "Service Comment Line Type"; TableLineNo: Integer)
    var
        RecRef: RecordRef;
    begin
        ServiceCommentLine.Init();
        ServiceCommentLine.Validate("Table Name", TableName);
        ServiceCommentLine.Validate("Table Subtype", TableSubtype);
        ServiceCommentLine.Validate("No.", No);
        ServiceCommentLine.Validate(Type, Type);
        ServiceCommentLine.Validate("Table Line No.", TableLineNo);
        RecRef.GetTable(ServiceCommentLine);
        ServiceCommentLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ServiceCommentLine.FieldNo("Line No.")));
        ServiceCommentLine.Insert(true);
        // Validate Comment as primary key to enable user to distinguish between comments because value is not important.
        ServiceCommentLine.Validate(
          Comment, Format(ServiceCommentLine."Table Name") + Format(ServiceCommentLine."Table Subtype") + ServiceCommentLine."No." +
          Format(ServiceCommentLine.Type) + Format(ServiceCommentLine."Table Line No.") + Format(ServiceCommentLine."Line No."));
        ServiceCommentLine.Modify(true);
    end;

    procedure CreateCommentLineForServHeader(var ServiceCommentLine: Record "Service Comment Line"; ServiceItemLine: Record "Service Item Line"; Type: Enum "Service Comment Line Type")
    begin
        CreateServiceCommentLine(
          ServiceCommentLine, ServiceCommentLine."Table Name"::"Service Header", ServiceItemLine."Document Type".AsInteger(),
          ServiceItemLine."Document No.", Type, ServiceItemLine."Line No.");
    end;

    procedure CreateCommentLineForServCntrct(var ServiceCommentLine: Record "Service Comment Line"; ServiceContractLine: Record "Service Contract Line"; Type: Enum "Service Comment Line Type")
    begin
        CreateServiceCommentLine(
          ServiceCommentLine, ServiceCommentLine."Table Name"::"Service Contract", ServiceContractLine."Contract Type".AsInteger(),
          ServiceContractLine."Contract No.", Type, ServiceContractLine."Line No.");
    end;

    procedure CreateOrderFromQuote(ServiceHeader: Record "Service Header")
    begin
        CODEUNIT.Run(CODEUNIT::"Service-Quote to Order", ServiceHeader);
    end;

    procedure CreateServiceContractAcctGrp(var ServiceContractAccountGroup: Record "Service Contract Account Group")
    begin
        // Create Service Contract Account Group.
        ServiceContractAccountGroup.Init();
        // Use the function GenerateRandomCode to get random and unique value for the Code field.
        ServiceContractAccountGroup.Validate(
          Code, LibraryUtility.GenerateRandomCode(ServiceContractAccountGroup.FieldNo(Code), DATABASE::"Service Contract Account Group"));
        ServiceContractAccountGroup.Insert(true);

        // Input Accounts as they are mandatory.
        ServiceContractAccountGroup.Validate("Non-Prepaid Contract Acc.", LibraryERM.CreateGLAccountWithSalesSetup());
        ServiceContractAccountGroup.Validate("Prepaid Contract Acc.", LibraryERM.CreateGLAccountWithSalesSetup());
        ServiceContractAccountGroup.Modify(true);
    end;

    procedure CreateServiceContractHeader(var ServiceContractHeader: Record "Service Contract Header"; ContractType: Enum "Service Contract Type"; CustomerNo: Code[20])
    var
        ServiceContractAccountGroup: Record "Service Contract Account Group";
    begin
        ServiceContractHeader.Init();
        ServiceContractHeader.Validate("Contract Type", ContractType);
        ServiceContractHeader.Insert(true);
        if CustomerNo = '' then
            CustomerNo := LibrarySales.CreateCustomerNo();
        ServiceContractHeader.Validate("Customer No.", CustomerNo);
        // Validate one month as the default value of the Service Period.
        Evaluate(ServiceContractHeader."Service Period", ServicePeriodOneMonthTxt);
        // Validate default value of Service Contract Acc. Gr. Code. This field is a mandatory field for signing Contract.
        CreateServiceContractAcctGrp(ServiceContractAccountGroup);
        ServiceContractHeader.Validate("Serv. Contract Acc. Gr. Code", ServiceContractAccountGroup.Code);
        ServiceContractHeader.Validate("Your Reference", ServiceContractHeader."Customer No."); // Value is not important.
        UpdatePaymentChannelContract(ServiceContractHeader);
        ServiceContractHeader.Modify(true);
    end;

    procedure CreateServiceContractLine(var ServiceContractLine: Record "Service Contract Line"; ServiceContractHeader: Record "Service Contract Header"; ServiceItemNo: Code[20])
    var
        RecRef: RecordRef;
    begin
        ServiceContractLine.Init();
        ServiceContractLine.Validate("Contract Type", ServiceContractHeader."Contract Type");
        ServiceContractLine.Validate("Contract No.", ServiceContractHeader."Contract No.");
        RecRef.GetTable(ServiceContractLine);
        // Use the function GetLastLineNo to get the value of the Line No. field.
        ServiceContractLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ServiceContractLine.FieldNo("Line No.")));
        ServiceContractLine.Validate("Customer No.", ServiceContractHeader."Customer No.");
        ServiceContractLine.Validate("Service Item No.", ServiceItemNo);
        ServiceContractLine.Insert(true);
    end;

    procedure CreateServiceContractTemplate(var ServiceContractTemplate: Record "Service Contract Template"; DefaultServicePeriod: DateFormula)
    var
        ServiceContractAccountGroup: Record "Service Contract Account Group";
    begin
        FindContractAccountGroup(ServiceContractAccountGroup);

        ServiceContractTemplate.Init();
        ServiceContractTemplate.Validate("Default Service Period", DefaultServicePeriod);
        // Service Contract Account Group is required for signing Contracts.
        ServiceContractTemplate.Validate("Serv. Contract Acc. Gr. Code", ServiceContractAccountGroup.Code);
        ServiceContractTemplate.Insert(true);
    end;

    procedure CreateServiceCost(var ServiceCost: Record "Service Cost")
    begin
        ServiceCost.Init();
        // Use the function GenerateRandomCode to get random and unique value for the Code field.
        ServiceCost.Validate(Code, LibraryUtility.GenerateRandomCode(ServiceCost.FieldNo(Code), DATABASE::"Service Cost"));
        ServiceCost.Validate(Description, ServiceCost.Code);  // Validating Code as Description because value is not important.
        ServiceCost.Validate("Account No.", LibraryERM.CreateGLAccountWithSalesSetup());
        ServiceCost.Insert(true);
    end;

    procedure CreateServiceCreditMemoHeaderUsingPage() ServiceCreditMemoNo: Code[20]
    var
        ServiceCreditMemo: TestPage "Service Credit Memo";
    begin
        ServiceCreditMemo.OpenNew();
        ServiceCreditMemo."Customer No.".Activate();
        ServiceCreditMemoNo := CopyStr(ServiceCreditMemo."No.".Value(), 1, MaxStrLen(ServiceCreditMemoNo));
        ServiceCreditMemo.OK().Invoke();
    end;

    procedure CreateServiceHeader(var ServiceHeader: Record "Service Header"; DocumentType: Enum "Service Document Type"; CustomerNo: Code[20])
    var
        PaymentMethod: Record "Payment Method";
        PaymentTerms: Record "Payment Terms";
    begin
        ServiceHeader.Init();
        ServiceHeader.Validate("Document Type", DocumentType);
        ServiceHeader.Insert(true);
        if CustomerNo = '' then
            CustomerNo := LibrarySales.CreateCustomerNo();
        ServiceHeader.Validate("Customer No.", CustomerNo);
        ServiceHeader.Validate("Your Reference", ServiceHeader."Customer No.");
        // Input mandatory fields for local builds.
        if ServiceHeader."Payment Terms Code" = '' then begin
            LibraryERM.FindPaymentTerms(PaymentTerms);
            ServiceHeader.Validate("Payment Terms Code", PaymentTerms.Code);
        end;
        if ServiceHeader."Payment Method Code" = '' then begin
            LibraryERM.FindPaymentMethod(PaymentMethod);
            ServiceHeader.Validate("Payment Method Code", PaymentMethod.Code);
        end;
        SetCorrDocNoService(ServiceHeader);
        ServiceHeader.Modify(true);
    end;

    procedure CreateServiceOrder(var ServiceHeader: Record "Service Header"; PostingDate: Date)
    var
        Customer: Record Customer;
        ServiceItemLine: Record "Service Item Line";
        ServiceItem: Record "Service Item";
    begin
        LibrarySales.CreateCustomer(Customer);
        CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Order, Customer."No.");
        ServiceHeader.Validate("Posting Date", PostingDate);
        ServiceHeader.Modify();
        CreateServiceItem(ServiceItem, Customer."No.");
        CreateServiceItemLine(ServiceItemLine, ServiceHeader, ServiceItem."No.");
    end;

    procedure CreateServiceOrderHeaderUsingPage() ServiceOrderNo: Code[20]
    var
        ServiceOrder: TestPage "Service Order";
    begin
        ServiceOrder.OpenNew();
        ServiceOrder."Customer No.".Activate();
        ServiceOrderNo := CopyStr(ServiceOrder."No.".Value(), 1, MaxStrLen(ServiceOrderNo));
        ServiceOrder.OK().Invoke();
    end;

    procedure CreateServiceDocumentWithItemServiceLine(var ServiceHeader: Record "Service Header"; DocumentType: Enum "Service Document Type")
    begin
        CreateServiceDocumentForCustomerNo(ServiceHeader, DocumentType, LibrarySales.CreateCustomerNo());
    end;

    procedure CreateServiceDocumentForCustomerNo(var ServiceHeader: Record "Service Header"; DocumentType: Enum "Service Document Type"; CustomerNo: Code[20])
    var
        ServiceItem: Record "Service Item";
        ServiceItemLine: Record "Service Item Line";
        ServiceLine: Record "Service Line";
    begin
        CreateServiceHeader(ServiceHeader, DocumentType, CustomerNo);

        CreateServiceItem(ServiceItem, ServiceHeader."Bill-to Customer No.");
        ServiceItem.Validate("Response Time (Hours)", LibraryRandom.RandDecInRange(5, 10, 2));
        ServiceItem.Modify(true);

        if ServiceHeader."Document Type" = ServiceHeader."Document Type"::Order then
            CreateServiceItemLine(ServiceItemLine, ServiceHeader, ServiceItem."No.");

        CreateServiceLineWithQuantity(
          ServiceLine, ServiceHeader, ServiceLine.Type::Item, ServiceItem."Item No.", LibraryRandom.RandIntInRange(5, 10));
        ServiceLine.Validate("Service Item Line No.", ServiceItemLine."Line No.");
        ServiceLine.Validate("Unit Price", LibraryRandom.RandIntInRange(3, 5));
        ServiceLine.Modify(true);
    end;

    procedure CreateDefaultServiceHour(var ServiceHour: Record "Service Hour"; Day: Option)
    begin
        ServiceHour.Init();
        // Use a random Starting Time that does not cause Ending Time to fall in the next day.
        ServiceHour.Validate(
          "Starting Time",
          000000T + LibraryRandom.RandInt(LibraryUtility.ConvertHoursToMilliSec(12)));
        // Use a random Ending Time that does not fall in the next day.
        ServiceHour.Validate(
          "Ending Time",
          ServiceHour."Starting Time" + LibraryRandom.RandInt(LibraryUtility.ConvertHoursToMilliSec(12)) - 1);
        ServiceHour.Validate(Day, Day);
        ServiceHour.Insert(true);
    end;

    procedure CreateServiceHour(var ServiceHour: Record "Service Hour"; ServiceContractHeader: Record "Service Contract Header"; Day: Option)
    begin
        ServiceHour.Init();
        ServiceHour.Validate("Service Contract Type", ServiceContractHeader."Contract Type".AsInteger() + 1);
        ServiceHour.Validate("Service Contract No.", ServiceContractHeader."Contract No.");
        ServiceHour.Validate("Starting Date", ServiceContractHeader."Starting Date");
        // Use a random Starting Time that does not cause Ending Time to fall in the next day.
        ServiceHour.Validate(
          "Starting Time",
          000000T + LibraryRandom.RandInt(LibraryUtility.ConvertHoursToMilliSec(12)));
        // Use a random Ending Time that does not fall in the next day.
        ServiceHour.Validate(
          "Ending Time",
          ServiceHour."Starting Time" + LibraryRandom.RandInt(LibraryUtility.ConvertHoursToMilliSec(12)) - 1);
        ServiceHour.Validate(Day, Day);
        ServiceHour.Insert(true);
    end;

    procedure CreateServiceItem(var ServiceItem: Record "Service Item"; CustomerNo: Code[20])
    begin
        ServiceItem.Init();
        ServiceItem.Insert(true);
        if CustomerNo = '' then
            CustomerNo := LibrarySales.CreateCustomerNo();
        ServiceItem.Validate("Customer No.", CustomerNo);
        ServiceItem.Validate(Description, ServiceItem."No.");  // Validating No. as Description because value is not important.
        ServiceItem.Modify(true);
    end;

    procedure CreateServiceItemComponent(var ServiceItemComponent: Record "Service Item Component"; ServiceItemNo: Code[20]; Type: Enum "Service Item Component Type"; No: Code[20])
    var
        RecRef: RecordRef;
    begin
        ServiceItemComponent.Init();
        ServiceItemComponent.Validate(Active, true);
        ServiceItemComponent.Validate("Parent Service Item No.", ServiceItemNo);
        RecRef.GetTable(ServiceItemComponent);
        ServiceItemComponent.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ServiceItemComponent.FieldNo("Line No.")));
        ServiceItemComponent.Validate(Type, Type);
        ServiceItemComponent.Validate("No.", No);
        ServiceItemComponent.Insert(true);
    end;

    procedure CreateServiceItemGroup(var ServiceItemGroup: Record "Service Item Group")
    begin
        ServiceItemGroup.Init();
        // Use the function GenerateRandomCode to get random and unique value for the Code field.
        ServiceItemGroup.Validate(Code, LibraryUtility.GenerateRandomCode(ServiceItemGroup.FieldNo(Code), DATABASE::"Service Item Group"));
        ServiceItemGroup.Validate(Description, ServiceItemGroup.Code);  // Validating Code as Description because value is not important.
        ServiceItemGroup.Insert(true);
    end;

    procedure CreateServiceItemLine(var ServiceItemLine: Record "Service Item Line"; ServiceHeader: Record "Service Header"; ServiceItemNo: Code[20])
    var
        RecRef: RecordRef;
    begin
        ServiceItemLine.Init();
        ServiceItemLine.Validate("Document Type", ServiceHeader."Document Type");
        ServiceItemLine.Validate("Document No.", ServiceHeader."No.");
        RecRef.GetTable(ServiceItemLine);
        // Use the function GetLastLineNo to get the value of the Line No. field.
        ServiceItemLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ServiceItemLine.FieldNo("Line No.")));
        ServiceItemLine.Insert(true);
        ServiceItemLine.Validate("Service Item No.", ServiceItemNo);
        ServiceItemLine.Validate(
          Description, Format(ServiceItemLine."Document Type") + ServiceItemLine."Document No." + Format(ServiceItemLine."Line No."));
        ServiceItemLine.Modify(true);
    end;

    procedure CreateServiceLineWithQuantity(var ServiceLine: Record "Service Line"; ServiceHeader: Record "Service Header"; Type: Enum "Service Line Type"; No: Code[20]; Quantity: Decimal)
    begin
        CreateServiceLine(ServiceLine, ServiceHeader, Type, No);
        ServiceLine.Validate(Quantity, Quantity);
        ServiceLine.Modify(true);
    end;

    procedure CreateServiceLine(var ServiceLine: Record "Service Line"; ServiceHeader: Record "Service Header"; Type: Enum "Service Line Type"; No: Code[20])
    var
        Item: Record Microsoft.Inventory.Item.Item;
        Customer: Record Microsoft.Sales.Customer.Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryJob: Codeunit "Library - Job";
        RecRef: RecordRef;
    begin
        // Create Service Line.
        Clear(ServiceLine);
        ServiceLine.Init();
        ServiceLine.Validate("Document Type", ServiceHeader."Document Type");
        ServiceLine.Validate("Document No.", ServiceHeader."No.");
        RecRef.GetTable(ServiceLine);
        if (Type = ServiceLine.Type::Item) and (Item.Get(No) and Customer.Get(ServiceHeader."Customer No.")) then begin
            VATPostingSetup.SetRange("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
            VATPostingSetup.SetFilter("VAT Bus. Posting Group", Customer."VAT Bus. Posting Group");
            if false = VATPostingSetup.FindFirst() then
                LibraryJob.CreateVATPostingSetup(Customer."VAT Bus. Posting Group", Item."VAT Prod. Posting Group", VATPostingSetup);
            OnBeforeCustomerModifyCreateServiceLine(Customer);
            Customer.Modify(true);
        end;

        // Use the function GetLastLineNo to get the value of the Line No. field.
        ServiceLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ServiceLine.FieldNo("Line No.")));
        ServiceLine.Insert(true);
        ServiceLine.Validate(Type, Type);
        case Type of
            ServiceLine.Type::Item:
                if No = '' then
                    No := LibraryInventory.CreateItemNo();
            ServiceLine.Type::Resource:
                if No = '' then
                    No := LibraryResource.CreateResourceNo();
        end;
        ServiceLine.Validate("No.", No);
        ServiceLine.Modify(true);
    end;

    procedure CreateServiceLineForPlan(JobPlanningLine: Record "Job Planning Line"; UsageLineType: Enum "Job Line Type"; Fraction: Decimal; var ServiceLine: Record "Service Line")
    var
        Job: Record Job;
        JobTask: Record "Job Task";
        ServiceHeader: Record "Service Header";
        ServiceItemLine: Record "Service Item Line";
    begin
        Assert.IsTrue(JobPlanningLine."Usage Link", 'Usage link should be enabled');

        JobTask.Get(JobPlanningLine."Job No.", JobPlanningLine."Job Task No.");
        Job.Get(JobPlanningLine."Job No.");

        CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Order, Job."Bill-to Customer No.");
        CreateServiceItemLine(ServiceItemLine, ServiceHeader, '');
        CreateServiceLine(
          ServiceLine, ServiceHeader, Job2ServiceConsumableType(JobPlanningLine.Type), JobPlanningLine."No.");

        ServiceLine.Validate("Service Item Line No.", ServiceItemLine."Line No.");
        ServiceLine.Validate(Description, LibraryUtility.GenerateGUID());
        ServiceLine.Validate("Location Code", FindLocationForPostingGroup(ServiceLine));
        ServiceLine.Validate(Quantity, Round(Fraction * JobPlanningLine."Remaining Qty."));
        ServiceLine.Validate("Unit of Measure Code", JobPlanningLine."Unit of Measure Code");
        ServiceLine.Validate("Qty. to Consume", ServiceLine.Quantity);
        ServiceLine.Validate("Job No.", JobPlanningLine."Job No.");
        ServiceLine.Validate("Job Task No.", JobPlanningLine."Job Task No.");
        ServiceLine.Validate("Job Line Type", UsageLineType);
        ServiceLine.Validate("Job Planning Line No.", JobPlanningLine."Line No.");
        ServiceLine.Modify(true)
    end;

    procedure CreateServiceOrderFromReport(ServiceContractHeader: Record "Service Contract Header"; StartDate: Date; EndDate: Date; UseRequestPage: Boolean)
    var
        CreateContractServiceOrders: Report "Create Contract Service Orders";
    begin
        CreateContractServiceOrders.SetTableView(ServiceContractHeader);
        CreateContractServiceOrders.InitializeRequest(StartDate, EndDate, 0);
        CreateContractServiceOrders.UseRequestPage(UseRequestPage);
        CreateContractServiceOrders.RunModal();
    end;

    procedure CreateServiceOrderType(var ServiceOrderType: Record "Service Order Type")
    begin
        ServiceOrderType.Init();
        ServiceOrderType.Validate(Code, LibraryUtility.GenerateRandomCode(ServiceOrderType.FieldNo(Code), DATABASE::"Service Order Type"));
        ServiceOrderType.Validate(Description, ServiceOrderType.Code);  // Validating Code as Description because value is not important.
        ServiceOrderType.Insert(true);
    end;

    procedure CreateServicePriceGroup(var ServicePriceGroup: Record "Service Price Group")
    begin
        ServicePriceGroup.Init();
        // Use the function GenerateRandomCode to get random and unique value for the Code field.
        ServicePriceGroup.Validate(
          Code, LibraryUtility.GenerateRandomCode(ServicePriceGroup.FieldNo(Code), DATABASE::"Service Price Group"));
        ServicePriceGroup.Validate(Description, ServicePriceGroup.Code);  // Validating Code as Description because value is not important.
        ServicePriceGroup.Insert(true);
    end;

    procedure CreateServPriceAdjustmntDetail(var ServPriceAdjustmentDetail: Record "Serv. Price Adjustment Detail"; ServPriceAdjmtGrCode: Code[10]; Type: Option; No: Code[20])
    begin
        ServPriceAdjustmentDetail.Init();
        ServPriceAdjustmentDetail.Validate("Serv. Price Adjmt. Gr. Code", ServPriceAdjmtGrCode);
        ServPriceAdjustmentDetail.Validate(Type, Type);
        ServPriceAdjustmentDetail.Validate("No.", No);
        ServPriceAdjustmentDetail.Insert(true);
    end;

    procedure CreateServPriceAdjustmentGroup(var ServicePriceAdjustmentGroup: Record "Service Price Adjustment Group")
    begin
        ServicePriceAdjustmentGroup.Init();
        ServicePriceAdjustmentGroup.Validate(
          Code, LibraryUtility.GenerateRandomCode(ServicePriceAdjustmentGroup.FieldNo(Code), DATABASE::"Service Price Adjustment Group"));
        ServicePriceAdjustmentGroup.Validate(
          Description, ServicePriceAdjustmentGroup.Code);  // Validating Code as Description because value is not important.
        ServicePriceAdjustmentGroup.Insert(true);
    end;

    procedure CreateServPriceGroupSetup(var ServPriceGroupSetup: Record "Serv. Price Group Setup"; ServicePriceGroupCode: Code[10]; FaultAreaCode: Code[10]; CustPriceGroupCode: Code[10])
    begin
        ServPriceGroupSetup.Init();
        ServPriceGroupSetup.Validate("Service Price Group Code", ServicePriceGroupCode);
        ServPriceGroupSetup.Validate("Fault Area Code", FaultAreaCode);
        ServPriceGroupSetup.Validate("Cust. Price Group Code", CustPriceGroupCode);
        ServPriceGroupSetup.Validate("Starting Date", WorkDate());
        ServPriceGroupSetup.Validate(Amount, LibraryRandom.RandInt(100));  // Validating as random because value is not important.
        ServPriceGroupSetup.Insert(true);
    end;

    procedure CreateServiceZone(var ServiceZone: Record "Service Zone")
    begin
        ServiceZone.Init();
        // Use the function GenerateRandomCode to get random and unique value for the Code field.
        ServiceZone.Validate(Code, LibraryUtility.GenerateRandomCode(ServiceZone.FieldNo(Code), DATABASE::"Service Zone"));
        ServiceZone.Insert(true);
    end;

    procedure CreateStandardServiceCode(var StandardServiceCode: Record "Standard Service Code")
    begin
        StandardServiceCode.Init();
        // Use the function GenerateRandomCode to get random and unique value for the Code field.
        StandardServiceCode.Validate(
          Code, LibraryUtility.GenerateRandomCode(StandardServiceCode.FieldNo(Code), DATABASE::"Standard Service Code"));
        // Validating Code as Description because value is not important.
        StandardServiceCode.Validate(Description, StandardServiceCode.Code);
        StandardServiceCode.Insert(true);
    end;

    procedure CreateStandardServiceLine(var StandardServiceLine: Record "Standard Service Line"; StandardServiceCode: Code[10])
    var
        RecRef: RecordRef;
    begin
        StandardServiceLine.Init();
        StandardServiceLine.Validate("Standard Service Code", StandardServiceCode);
        RecRef.GetTable(StandardServiceLine);
        StandardServiceLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, StandardServiceLine.FieldNo("Line No.")));
        StandardServiceLine.Insert(true);
    end;

    procedure CreateStandardServiceItemGr(var StandardServiceItemGrCode: Record "Standard Service Item Gr. Code"; ServiceItemGroupCode: Code[10]; StandardServiceCode: Code[10])
    begin
        StandardServiceItemGrCode.Init();
        StandardServiceItemGrCode.Validate("Service Item Group Code", ServiceItemGroupCode);
        StandardServiceItemGrCode.Validate(Code, StandardServiceCode);
        StandardServiceItemGrCode.Insert(true);
    end;

    procedure CreateSymptomCode(var SymptomCode: Record "Symptom Code")
    begin
        SymptomCode.Init();
        // Use the function GenerateRandomCode to get random and unique value for the Code field.
        SymptomCode.Validate(Code, LibraryUtility.GenerateRandomCode(SymptomCode.FieldNo(Code), DATABASE::"Symptom Code"));
        SymptomCode.Validate(Description, SymptomCode.Code);  // Validating Code as Description because value is not important.
        SymptomCode.Insert(true);
    end;

    procedure CreateTroubleshootingHeader(var TroubleshootingHeader: Record "Troubleshooting Header")
    begin
        TroubleshootingHeader.Init();
        TroubleshootingHeader.Insert(true);
    end;

    procedure CreateTroubleshootingLine(var TroubleshootingLine: Record "Troubleshooting Line"; TroubleshootingHeaderNo: Code[20])
    var
        RecRef: RecordRef;
    begin
        TroubleshootingLine.Init();
        TroubleshootingLine.Validate("No.", TroubleshootingHeaderNo);
        RecRef.GetTable(TroubleshootingLine);
        TroubleshootingLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, TroubleshootingLine.FieldNo("Line No.")));

        // Comment is blank so validate the Comment as a string containing the Troubleshooting Header No. and the Line No. as the
        // text for Comment is not important here. This enables the user to distinguish between different Comments.
        TroubleshootingLine.Validate(Comment, TroubleshootingLine."No." + Format(TroubleshootingLine."Line No."));
        TroubleshootingLine.Insert(true);
    end;

    procedure CreateTroubleshootingSetup(var TroubleshootingSetup: Record "Troubleshooting Setup"; Type: Enum "Troubleshooting Item Type"; No: Code[20]; TroubleshootingNo: Code[20])
    begin
        TroubleshootingSetup.Init();
        TroubleshootingSetup.Validate(Type, Type);
        TroubleshootingSetup.Validate("No.", No);
        TroubleshootingSetup.Validate("Troubleshooting No.", TroubleshootingNo);
        TroubleshootingSetup.Insert(true);
    end;

    procedure ChangeCustomer(ServiceContractHeader: Record "Service Contract Header"; NewCustomerNo: Code[20])
    var
        ServContractManagement: Codeunit ServContractManagement;
    begin
        // Change Customer on Service Contract.
        ServContractManagement.ChangeCustNoOnServContract(NewCustomerNo, '', ServiceContractHeader)
    end;

    procedure CheckServiceTimeSheetLine(TimeSheetHeader: Record "Time Sheet Header"; ServiceHeaderNo: Code[20]; ServiceLineNo: Integer; ServiceLineQuantity: Decimal; Chargeable: Boolean)
    var
        TimeSheetLine: Record "Time Sheet Line";
    begin
        TimeSheetLine.SetRange("Time Sheet No.", TimeSheetHeader."No.");
        TimeSheetLine.SetRange("Service Order No.", ServiceHeaderNo);
        TimeSheetLine.SetRange("Service Order Line No.", ServiceLineNo);
        TimeSheetLine.FindLast();
        TimeSheetLine.CalcFields("Total Quantity");

        Assert.AreEqual(ServiceLineQuantity, TimeSheetLine."Total Quantity",
          StrSubstNo(TimeSheetFieldValueErr, TimeSheetLine.FieldCaption("Total Quantity")));
        Assert.AreEqual(Chargeable, TimeSheetLine.Chargeable,
          StrSubstNo(TimeSheetFieldValueErr, TimeSheetLine.FieldCaption(Chargeable)));
        Assert.AreEqual(TimeSheetLine.Status::Approved, TimeSheetLine.Status,
          StrSubstNo(TimeSheetFieldValueErr, TimeSheetLine.FieldCaption(Status)));
        Assert.IsTrue(TimeSheetLine.Posted, StrSubstNo(TimeSheetFieldValueErr, TimeSheetLine.FieldCaption(Posted)));
    end;

    procedure FindContractAccountGroup(var ServiceContractAccountGroup: Record "Service Contract Account Group")
    begin
        // Filter Service Contract Account Group so that errors are not generated due to mandatory fields.
        ServiceContractAccountGroup.SetFilter("Non-Prepaid Contract Acc.", '<>''''');
        ServiceContractAccountGroup.SetFilter("Prepaid Contract Acc.", '<>''''');

        ServiceContractAccountGroup.FindSet();
    end;

    local procedure FindLocationForPostingGroup(ServiceLine: Record "Service Line"): Code[10]
    var
        InventoryPostingSetup: Record "Inventory Posting Setup";
        Location: Record Location;
    begin
        if ServiceLine.Type <> ServiceLine.Type::Item then
            exit(ServiceLine."Location Code");

        InventoryPostingSetup.SetRange("Invt. Posting Group Code", ServiceLine."Posting Group");
        InventoryPostingSetup.SetFilter("Location Code", '<>%1', '');
        InventoryPostingSetup.FindSet();
        repeat
            Location.Get(InventoryPostingSetup."Location Code");
            if not Location."Use As In-Transit" and not Location."Bin Mandatory" and not Location."Require Shipment" then
                exit(Location.Code)
        until InventoryPostingSetup.Next() = 0;
        exit('');
    end;

    procedure FindServiceCost(var ServiceCost: Record "Service Cost")
    begin
        // Filter Service Cost so that errors are not generated due to mandatory fields.
        ServiceCost.SetFilter("Account No.", '<>''''');
        ServiceCost.SetRange("Service Zone Code", '');

        ServiceCost.FindSet();
    end;

    procedure FindServiceItemGroup(var ServiceItemGroup: Record "Service Item Group")
    begin
        ServiceItemGroup.FindSet();
    end;

    procedure FindResolutionCode(var ResolutionCode: Record "Resolution Code")
    begin
        ResolutionCode.FindSet();
    end;

    procedure FindFaultReasonCode(var FaultReasonCode: Record "Fault Reason Code")
    begin
        FaultReasonCode.FindSet();
    end;

    procedure FindServiceContractLine(var ServiceContractLine: Record "Service Contract Line"; ContractType: Enum "Service Contract Type"; ContractNo: Code[20])
    begin
        ServiceContractLine.SetRange("Contract Type", ContractType);
        ServiceContractLine.SetRange("Contract No.", ContractNo);
        ServiceContractLine.FindFirst();
    end;

    procedure FindServiceInvoiceHeader(var ServiceInvoiceHeader: Record "Service Invoice Header"; PreAssignedNo: Code[20])
    begin
        ServiceInvoiceHeader.SetRange("Pre-Assigned No.", PreAssignedNo);
        ServiceInvoiceHeader.FindFirst();
    end;

    procedure FindServiceCrMemoHeader(var ServiceCrMemoHeader: Record "Service Cr.Memo Header"; PreAssignedNo: Code[20])
    begin
        ServiceCrMemoHeader.SetRange("Pre-Assigned No.", PreAssignedNo);
        ServiceCrMemoHeader.FindFirst();
    end;

    procedure PostServiceOrder(var ServiceHeader: Record "Service Header"; Ship: Boolean; Consume: Boolean; Invoice: Boolean)
    var
        TempServiceLine: Record "Service Line" temporary;
        ServicePost: Codeunit "Service-Post";
    begin
        ServiceHeader.Find();
        SetCorrDocNoService(ServiceHeader);
        OnBeforePostServiceOrder(ServiceHeader);
        ServicePost.PostWithLines(ServiceHeader, TempServiceLine, Ship, Consume, Invoice);
    end;

    procedure PostServiceOrderWithPassedLines(var ServiceHeader: Record "Service Header"; var TempServiceLine: Record "Service Line" temporary; Ship: Boolean; Consume: Boolean; Invoice: Boolean)
    var
        ServicePost: Codeunit "Service-Post";
    begin
        ServiceHeader.Find();
        SetCorrDocNoService(ServiceHeader);
        ServicePost.PostWithLines(ServiceHeader, TempServiceLine, Ship, Consume, Invoice);
    end;

    procedure ReleaseServiceDocument(var ServiceHeader: Record "Service Header")
    var
        ReleaseServiceDoc: Codeunit "Release Service Document";
    begin
        ReleaseServiceDoc.PerformManualRelease(ServiceHeader);
    end;

    procedure ReopenServiceDocument(var ServiceHeader: Record "Service Header")
    var
        ReleaseServiceDoc: Codeunit "Release Service Document";
    begin
        ReleaseServiceDoc.PerformManualReopen(ServiceHeader);
    end;

    procedure SetCorrDocNoService(var ServiceHeader: Record "Service Header")
    begin
        if ServiceHeader."Document Type" = ServiceHeader."Document Type"::"Credit Memo" then;
    end;

    procedure SetShipmentOnInvoice(ShipmentOnInvoice: Boolean)
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
    begin
        ServiceMgtSetup.Get();
        ServiceMgtSetup.Validate("Shipment on Invoice", ShipmentOnInvoice);
        ServiceMgtSetup.Modify(true);
    end;

    procedure SetupServiceMgtNoSeries()
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
        BaseCalender: Record "Base Calendar";
    begin
        // Setup Service Management.
        ServiceMgtSetup.Get();

        // Use GetGlobalNoSeriesCode to get No. Series code.
        if ServiceMgtSetup."Service Item Nos." = '' then
            ServiceMgtSetup.Validate("Service Item Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Service Order Nos." = '' then
            ServiceMgtSetup.Validate("Service Order Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Service Invoice Nos." = '' then
            ServiceMgtSetup.Validate("Service Invoice Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Service Credit Memo Nos." = '' then
            ServiceMgtSetup.Validate("Service Credit Memo Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Posted Service Shipment Nos." = '' then
            ServiceMgtSetup.Validate("Posted Service Shipment Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Posted Service Invoice Nos." = '' then
            ServiceMgtSetup.Validate("Posted Service Invoice Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Posted Serv. Credit Memo Nos." = '' then
            ServiceMgtSetup.Validate("Posted Serv. Credit Memo Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Troubleshooting Nos." = '' then
            ServiceMgtSetup.Validate("Troubleshooting Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Service Contract Nos." = '' then
            ServiceMgtSetup.Validate("Service Contract Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Service Quote Nos." = '' then
            ServiceMgtSetup.Validate("Service Quote Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Contract Invoice Nos." = '' then
            ServiceMgtSetup.Validate("Contract Invoice Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Contract Credit Memo Nos." = '' then
            ServiceMgtSetup.Validate("Contract Credit Memo Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Prepaid Posting Document Nos." = '' then
            ServiceMgtSetup.Validate("Prepaid Posting Document Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Contract Credit Memo Nos." = '' then
            ServiceMgtSetup.Validate("Contract Credit Memo Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Posted Service Shipment Nos." = '' then
            ServiceMgtSetup.Validate("Posted Service Shipment Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Contract Template Nos." = '' then
            ServiceMgtSetup.Validate("Contract Template Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        if ServiceMgtSetup."Loaner Nos." = '' then
            ServiceMgtSetup.Validate("Loaner Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        ServiceMgtSetup.Validate("Contract Serv. Ord.  Max. Days", 365);  // Using Default 365 Days.

        // Create and Validate Base Calendar.
        if ServiceMgtSetup."Base Calendar Code" = '' then begin
            CreateBaseCalendar(BaseCalender);
            ServiceMgtSetup.Validate("Base Calendar Code", BaseCalender.Code);
        end;

        ServiceMgtSetup.Modify(true);

        LibrarySales.SetCreditWarningsToNoWarnings();
    end;

    procedure GetFirstWorkingDay(WorkingDate: Date): Date
    var
        ServiceHour: Record "Service Hour";
    begin
        // Gets the first working day.
        while not (IsWorking(WorkingDate) and GetServiceHourForDate(ServiceHour, WorkingDate)) do
            WorkingDate := CalcDate('<1D>', WorkingDate);
        exit(WorkingDate);
    end;

    procedure GetNextWorkingDay(WorkingDate: Date): Date
    var
        ServiceHour: Record "Service Hour";
    begin
        // Gets the next working day from the specified date.
        repeat
            WorkingDate := CalcDate('<1D>', WorkingDate);
        until (
               IsWorking(WorkingDate) and GetServiceHourForDate(ServiceHour, WorkingDate)) or
              (not IsWorking(WorkingDate) and IsValidOnHolidays(WorkingDate));
        exit(WorkingDate);
    end;

    procedure GetNonWrkngDayFollwdByWrkngDay(): Date
    var
        ServiceHour: Record "Service Hour";
        WorkingDate: Date;
        LoopCounter: Integer;
        MaxLoops: Integer;
    begin
        // Returns a non-working day followed by a working day.
        WorkingDate := WorkDate();
        LoopCounter := 0;
        MaxLoops := 366;
        repeat
            LoopCounter += 1;
            if LoopCounter > MaxLoops then
                Error(NonWorkDayWorkDaySequenceNotFoundErr, MaxLoops);
            WorkingDate := CalcDate('<1D>', WorkingDate);
        until
              not (IsWorking(WorkingDate) or IsValidOnHolidays(WorkingDate)) and
              (IsWorking(CalcDate('<1D>', WorkingDate)) and GetServiceHourForDate(ServiceHour, CalcDate('<1D>', WorkingDate)));
        exit(WorkingDate);
    end;

    procedure GetServiceHourForDate(var ServiceHour: Record "Service Hour"; OrderDate: Date): Boolean
    var
        Date: Record System.Utilities.Date;
    begin
        // Finds the Service Hour related to the Date and returns a Boolean.
        Date.Get(Date."Period Type"::Date, OrderDate);
        ServiceHour.SetRange("Service Contract Type", ServiceHour."Service Contract Type"::" ");
        ServiceHour.SetRange("Service Contract No.", '');
        ServiceHour.SetFilter(Day, Date."Period Name");
        exit(ServiceHour.FindFirst())
    end;

    procedure GetServiceOrderReportGrossAmount(ServiceLine: Record "Service Line"): Decimal
    var
        CustInvDisc: Record "Cust. Invoice Disc.";
    begin
        CustInvDisc.Get(ServiceLine."Customer No.", ServiceLine."Currency Code", 0);
        exit(ServiceLine."Amount Including VAT" - (ServiceLine."Amount Including VAT" * CustInvDisc."Discount %" / 100));
    end;

    procedure GetShipmentLines(var ServiceLine: Record "Service Line")
    var
        ServiceGetShipment: Codeunit "Service-Get Shipment";
    begin
        ServiceGetShipment.Run(ServiceLine);
    end;

    procedure IsWorking(DateToCheck: Date): Boolean
    var
        CustomizedCalendarChange: Record "Customized Calendar Change";
        ServiceMgtSetup: Record "Service Mgt. Setup";
        CalendarManagement: Codeunit "Calendar Management";
    begin
        // Checks if the day is a working day.
        ServiceMgtSetup.Get();
        CalendarManagement.SetSource(ServiceMgtSetup, CustomizedCalendarChange);
        CustomizedCalendarChange.Date := DateToCheck;
        CalendarManagement.CheckDateStatus(CustomizedCalendarChange);
        exit(not CustomizedCalendarChange.Nonworking);
    end;

    procedure IsValidOnHolidays(DateToCheck: Date): Boolean
    var
        ServiceHour: Record "Service Hour";
    begin
        // Checks if the Service Hour for the date has Valid on Holidays checked.
        if GetServiceHourForDate(ServiceHour, DateToCheck) then
            exit(ServiceHour."Valid on Holidays");
        exit(false);
    end;

    procedure SignContract(ServiceContractHeader: Record "Service Contract Header")
    var
        SignServContractDoc: Codeunit SignServContractDoc;
    begin
        SignServContractDoc.SignContract(ServiceContractHeader);
    end;

    procedure SignContract(ServiceContractHeader: Record "Service Contract Header"; HideDialog: Boolean)
    var
        SignServContractDoc: Codeunit SignServContractDoc;
    begin
        SignServContractDoc.SetHideDialog(HideDialog);
        SignServContractDoc.SignContract(ServiceContractHeader);
    end;

    local procedure UpdatePaymentChannelContract(var ServiceContractHeader: Record "Service Contract Header")
    var
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if LibraryUtility.CheckFieldExistenceInTable(DATABASE::"Service Contract Header", PaymentChannelTxt) then begin
            RecRef.GetTable(ServiceContractHeader);
            FieldRef := RecRef.Field(LibraryUtility.FindFieldNoInTable(DATABASE::"Service Contract Header", PaymentChannelTxt));
            FieldRef.Validate(2);  // Input Option as Account Transfer.
            RecRef.SetTable(ServiceContractHeader);
        end;
    end;

    procedure AutoReserveServiceLine(ServiceLine: Record "Service Line")
    begin
        ServiceLine.AutoReserve();
    end;

    procedure UndoShipmentLinesByServiceOrderNo(ServiceOrderNo: Code[20])
    var
        ServiceShipmentLine: Record "Service Shipment Line";
    begin
        ServiceShipmentLine.SetRange("Order No.", ServiceOrderNo);
        CODEUNIT.Run(CODEUNIT::"Undo Service Shipment Line", ServiceShipmentLine);
    end;

    procedure UndoShipmentLinesByServiceDocNo(ServiceDocumentNo: Code[20])
    var
        ServiceShipmentLine: Record "Service Shipment Line";
    begin
        ServiceShipmentLine.SetRange("Document No.", ServiceDocumentNo);
        CODEUNIT.Run(CODEUNIT::"Undo Service Shipment Line", ServiceShipmentLine);
    end;

    procedure UndoConsumptionLinesByServiceOrderNo(ServiceOrderNo: Code[20])
    var
        ServiceShipmentLine: Record "Service Shipment Line";
    begin
        ServiceShipmentLine.SetRange("Order No.", ServiceOrderNo);
        CODEUNIT.Run(CODEUNIT::"Undo Service Consumption Line", ServiceShipmentLine);
    end;

    procedure UndoConsumptionLinesByServiceDocNo(ServiceDocumentNo: Code[20])
    var
        ServiceShipmentLine: Record "Service Shipment Line";
    begin
        ServiceShipmentLine.SetRange("Document No.", ServiceDocumentNo);
        CODEUNIT.Run(CODEUNIT::"Undo Service Consumption Line", ServiceShipmentLine);
    end;

    procedure CreateDefaultYellowLocation(var Location: Record Location): Code[10]
    var
        WarehouseEmployee: Record "Warehouse Employee";
        LibraryWarehouse: Codeunit "Library - Warehouse";
    begin
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        Location.Validate("Require Receive", true);
        Location.Validate("Require Shipment", true);
        Location.Validate("Require Put-away", true);
        Location.Validate("Require Pick", true);

        Location.Validate("Bin Mandatory", false);
        Location.Validate("Use Put-away Worksheet", false);
        Location.Validate("Directed Put-away and Pick", false);
        Location.Validate("Use ADCS", false);

        Location.Modify(true);

        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, Location.Code, false);

        exit(Location.Code);
    end;

    procedure CreateFullWarehouseLocation(var Location: Record Location; NumberOfBinsPerZone: Integer)
    var
        WarehouseEmployee: Record "Warehouse Employee";
        LibraryWarehouse: Codeunit "Library - Warehouse";
    begin
        LibraryWarehouse.CreateFullWMSLocation(Location, NumberOfBinsPerZone);  // Value used for number of bin per zone.
        LibraryWarehouse.CreateWarehouseEmployee(WarehouseEmployee, Location.Code, false);
    end;

    procedure CreateCustomizedCalendarChange(BaseCalendarCode: Code[10]; var CustomizedCalendarChange: Record "Customized Calendar Change"; SourceType: Option; SourceCode: Code[10]; AdditionalSourceCode: Code[10]; RecurringSystem: Option; WeekDay: Option; IsNonWorking: Boolean)
    begin
        CustomizedCalendarChange.Init();
        CustomizedCalendarChange.Validate("Source Type", SourceType);
        CustomizedCalendarChange.Validate("Source Code", SourceCode);
        CustomizedCalendarChange.Validate("Additional Source Code", AdditionalSourceCode);
        CustomizedCalendarChange.Validate("Base Calendar Code", BaseCalendarCode);
        CustomizedCalendarChange.Validate("Recurring System", RecurringSystem);
        CustomizedCalendarChange.Validate(Day, WeekDay);
        CustomizedCalendarChange.Validate(Nonworking, IsNonWorking);
        CustomizedCalendarChange.Insert(true);
    end;

    procedure CombineShipments(var ServiceHeader: Record "Service Header"; var ServiceShipmentHeader: Record "Service Shipment Header"; PostingDate: Date; DocumentDate: Date; CalcInvDisc: Boolean; PostInvoices: Boolean; OnlyStdPmtTerms: Boolean; CopyTextLines: Boolean)
    var
        TmpServiceHeader: Record "Service Header";
        TmpServiceShipmentHeader: Record "Service Shipment Header";
        CombineShipmentsReport: Report "Combine Service Shipments";
    begin
        CombineShipmentsReport.InitializeRequest(PostingDate, DocumentDate, CalcInvDisc, PostInvoices, OnlyStdPmtTerms, CopyTextLines);
        if ServiceHeader.HasFilter then
            TmpServiceHeader.CopyFilters(ServiceHeader)
        else begin
            ServiceHeader.Get(ServiceHeader."Document Type", ServiceHeader."No.");
            TmpServiceHeader.SetRange("Document Type", ServiceHeader."Document Type");
            TmpServiceHeader.SetRange("No.", ServiceHeader."No.");
        end;
        CombineShipmentsReport.SetTableView(TmpServiceHeader);
        if ServiceShipmentHeader.HasFilter then
            TmpServiceShipmentHeader.CopyFilters(ServiceShipmentHeader)
        else begin
            ServiceShipmentHeader.Get(ServiceShipmentHeader."No.");
            TmpServiceShipmentHeader.SetRange("No.", ServiceShipmentHeader."No.");
        end;
        CombineShipmentsReport.SetTableView(TmpServiceShipmentHeader);
        CombineShipmentsReport.UseRequestPage(false);
        CombineShipmentsReport.RunModal();
    end;

    procedure Job2ServiceConsumableType(Type: Enum "Job Planning Line Type"): Enum "Service Line Type"
    var
        ServiceLine: Record "Service Line";
    begin
        case Type of
            "Job Planning Line Type"::Resource:
                exit(ServiceLine.Type::Resource);
            "Job Planning Line Type"::Item:
                exit(ServiceLine.Type::Item);
            "Job Planning Line Type"::"G/L Account":
                exit(ServiceLine.Type::"G/L Account");
            else
                Assert.Fail('Unsupported consumable type');
        end
    end;

    procedure InitScenarioWTForServiceOrder(var TimeSheetHeader: Record "Time Sheet Header"; var ServiceHeader: Record "Service Header")
    var
        TimeSheetLine: Record "Time Sheet Line";
        Resource: Record Resource;
    begin
        // create time sheet
        LibraryTimesheet.CreateTimeSheet(TimeSheetHeader, false);

        // create work type
        Resource.Get(TimeSheetHeader."Resource No.");

        CreateServiceOrder(ServiceHeader, CalcDate('<+3D>', TimeSheetHeader."Starting Date"));

        // create time sheets' lines with type Resource, some kind of Work Type and different chargeables
        LibraryTimesheet.CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, TimeSheetLine.Type::Service, '', '', ServiceHeader."No.", '');
        TimeSheetLine.Validate("Service Order No.", ServiceHeader."No.");
        TimeSheetLine.Modify();
        // set quantities for lines
        LibraryTimesheet.CreateTimeSheetDetail(TimeSheetLine, TimeSheetHeader."Starting Date", LibraryTimesheet.GetRandomDecimal());
        LibraryTimesheet.SubmitTimeSheetLine(TimeSheetLine);
    end;

    procedure InitServiceScenario(var TimeSheetHeader: Record "Time Sheet Header"; var TimeSheetLine: Record "Time Sheet Line"; var ServiceHeader: Record "Service Header")
    begin
        // create time sheet
        LibraryTimesheet.CreateTimeSheet(TimeSheetHeader, false);

        // create service order
        if ServiceHeader."No." = '' then
            CreateServiceOrder(ServiceHeader, CalcDate('<+3D>', TimeSheetHeader."Starting Date"));

        // create time sheet line with type Service
        LibraryTimesheet.CreateTimeSheetLine(TimeSheetHeader, TimeSheetLine, TimeSheetLine.Type::Service, '', '', ServiceHeader."No.", '');
        TimeSheetLine.Validate("Service Order No.", ServiceHeader."No.");
        LibraryTimesheet.CreateTimeSheetDetail(TimeSheetLine, TimeSheetHeader."Starting Date", LibraryTimesheet.GetRandomDecimal());
        LibraryTimesheet.SubmitAndApproveTimeSheetLine(TimeSheetLine);
    end;

    procedure InitBackwayScenario(var TimeSheetHeader: Record "Time Sheet Header"; var ServiceHeader: Record "Service Header"; var ServiceLine: Record "Service Line")
    begin
        // create time sheet
        LibraryTimesheet.CreateTimeSheet(TimeSheetHeader, false);

        // create service order
        CreateServiceOrder(ServiceHeader, CalcDate('<+3D>', TimeSheetHeader."Starting Date"));
        // create service line
        CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Resource, TimeSheetHeader."Resource No.");
        ServiceLine.Validate("Service Item Line No.", 10000);
        ServiceLine.Validate(Quantity, LibraryRandom.RandInt(9999) / 100);
        ServiceLine.Modify();
    end;

    procedure CreateSpecificServiceOrder(var ServiceHeader: Record "Service Header"; PaymentTermsCode: Code[10]; CFPaymentTermsCode: Code[10])
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        LibraryCashFlowHelper.AssignCFPaymentTermToCustomer(Customer, PaymentTermsCode);
        LibraryCashFlowHelper.AssignCFPaymentTermToCustomer(Customer, CFPaymentTermsCode);

        CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Order, Customer."No.");

        CreateServiceLines(ServiceHeader);
        CreateServiceLines(ServiceHeader);
        CreateServiceLines(ServiceHeader);
    end;

    procedure CreateDefaultServiceOrder(var ServiceHeader: Record "Service Header")
    begin
        CreateSpecificServiceOrder(ServiceHeader, '', '');
    end;

    procedure CreateServiceLines(ServiceHeader: Record "Service Header")
    var
        ServiceLine: Record "Service Line";
        ServiceItemLine: Record "Service Item Line";
        Item: Record Item;
    begin
        // simple wrapper for LibraryPurchase.CreateServiceLine
        LibrarySales.FindItem(Item);
        CreateServiceItemLine(ServiceItemLine, ServiceHeader, '');
        CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, Item."No.");
        ServiceLine.Validate("Service Item Line No.", ServiceItemLine."Line No.");
        ServiceLine.Validate(Quantity, LibraryRandom.RandInt(50));
        ServiceLine.Modify(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCustomerModifyCreateServiceLine(var Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostServiceOrder(var ServiceHeader: Record "Service Header")
    begin
    end;
}

