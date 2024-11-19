namespace Microsoft.SubscriptionBilling;

using System.Utilities;

table 8062 "Customer Contract Line"
{
    Caption = 'Customer Contract Line';
    DataClassification = CustomerContent;
    DrillDownPageId = "Customer Contract Lines";
    LookupPageId = "Customer Contract Lines";
    Access = Internal;

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "Customer Contract";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Contract Line Type"; Enum "Contract Line Type")
        {
            Caption = 'Type';

            trigger OnValidate()
            var
                TempCustomerContractLine: Record "Customer Contract Line" temporary;
            begin
                CheckTypeChangeAllowed();
                CheckAndDisconnectContractLine();
                TempCustomerContractLine := Rec;
                Init();
                "Contract Line Type" := TempCustomerContractLine."Contract Line Type";
            end;
        }
        field(100; "Service Object No."; Code[20])
        {
            Caption = 'Service Object No.';
            TableRelation = "Service Object";
            Editable = false;
        }
        field(101; "Service Commitment Entry No."; Integer)
        {
            Caption = 'Service Commitment Entry No.';
            TableRelation = "Service Commitment"."Entry No.";
            Editable = false;
        }
        field(102; "Service Object Description"; Text[100])
        {
            Caption = 'Service Object Description';

            trigger OnValidate()
            begin
                UpdateServiceObjectDescription();
            end;
        }
        field(106; "Service Commitment Description"; Text[100])
        {
            Caption = 'Service Commitment Description';

            trigger OnValidate()
            begin
                UpdateServiceCommitmentDescription();
            end;
        }

        field(107; "Closed"; Boolean)
        {
            Caption = 'Closed';
        }
        field(109; "Service Obj. Quantity Decimal"; Decimal)
        {
            Caption = 'Quantity';
            FieldClass = FlowField;
            CalcFormula = lookup("Service Object"."Quantity Decimal" where("No." = field("Service Object No.")));
            Editable = false;
        }

        field(200; "Planned Serv. Comm. exists"; Boolean)
        {
            Caption = 'Planned Service Commitment exists';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Planned Service Commitment" where("Service Object No." = field("Service Object No."), "Contract No." = field("Contract No."), "Contract Line No." = field("Line No.")));
        }
    }

    keys
    {
        key(PK; "Contract No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    begin
        if not CalledFromDeleteServiceCommitment then begin
            AskIfClosedContractLineCanBeDeleted();
            CheckAndDisconnectContractLine();
            UpdateServiceCommitmentDimensions();
        end;
        RecalculateHarmonizedBillingFieldsOnCustomerContract(Rec."Line No.");
        ErrorIfUsageDataBillingIsLinkedToContractLine();
    end;

    var
        TextManagement: Codeunit "Text Management";
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
        ConfirmManagement: Codeunit "Confirm Management";
        CalledFromDeleteServiceCommitment: Boolean;
        HideValidationDialog: Boolean;
        DeletionNotAllowedErr: Label 'Deletion is not allowed because the line is linked to a contract billing line. Please delete the billing proposal first.';
        ClosedContractLinesDeletionQst: Label 'Deleting the contract line breaks the link to the service in the service object. Do you want to continue?';
        OneContractLineSelectedErr: Label 'Please select the lines you want to combine.';
        BillingLinesForSelectedContractLinesExistsErr: Label 'Billing Lines for exists for at least one of the selected contract lines. Delete the Billing Lines before merging the Contract Lines.';
        ContractLinesWithDifferentDimensionSelectedErr: Label 'There are different dimension values for the Contract Lines. Complete the dimensions before merging the Contract Lines.';
        ContractLinesWithDifferentNextBillingDateSelectedErr: Label 'There is a different Next Billing Date for the Contract Lines. The Contract Lines must be billed so that the Next Billing Date is the same before they can be combined.';
        NotAllowdMergingTextLinesErr: Label 'Merging with text lines is not allowed.';
        ContractLinesMergedMsg: Label 'Customer contract lines have been merged.';
        ContractLineWithDifferentCustRefCannotBeMergedErr: Label 'Service Commitments from Service Objects with different Customer References cannot be merged.';
        LinesWithSerialNoCannotBeMergedErr: Label 'Contract lines cannot be merged if Serial No. is entered into Service Object.';
        ContractLineCannotBeDeletedErr: Label 'You cannot delete the contract line because usage data exist for it. Please delete all related data in Usage Data Billing first.';

    local procedure ErrorIfUsageDataBillingIsLinkedToContractLine()
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UsageDataBilling.SetRange(Partner, "Service Partner"::Customer);
        UsageDataBilling.SetRange("Contract No.", "Contract No.");
        UsageDataBilling.SetRange("Contract Line No.", "Line No.");
        if not UsageDataBilling.IsEmpty() then
            Error(ContractLineCannotBeDeletedErr);
    end;

    local procedure CheckAndDisconnectContractLine()
    var
        ServiceCommitment: Record "Service Commitment";
        BillingLineArchive: Record "Billing Line Archive";
    begin
        if Rec."Service Commitment Entry No." <> 0 then
            if ServiceCommitment.Get(Rec."Service Commitment Entry No.") then begin
                ServiceCommitment."Contract No." := '';
                ServiceCommitment."Contract Line No." := 0;
                ServiceCommitment.Modify(false);
            end;

        if ContractsGeneralMgt.BillingLineExists(Enum::"Service Partner"::Customer, Rec."Contract No.", Rec."Line No.") then
            Error(DeletionNotAllowedErr);

        BillingLineArchive.FilterBillingLineArchiveOnContractLine(Enum::"Service Partner"::Customer, "Contract No.", "Line No.");
        if BillingLineArchive.FindSet() then
            repeat
                if not BillingLineArchive.PostedDocumentExist() then
                    BillingLineArchive.Delete(false);
            until BillingLineArchive.Next() = 0;
        OnAfterCheckAndDisconnectContractLine(Rec, xRec);
    end;

    local procedure CheckTypeChangeAllowed()
    var
        ServiceCommitment: Record "Service Commitment";
        TypeChangeNotAllowedErr: Label '%1 cannot be changed to %2 as long as the line is connected to a %3 (%4 %5, %6 %7)';
    begin
        if Rec."Service Commitment Entry No." <> 0 then
            if ServiceCommitment.Get(Rec."Service Commitment Entry No.") then
                Error(
                    TypeChangeNotAllowedErr,
                    Rec.FieldCaption("Contract Line Type"),
                    Rec."Contract Line Type",
                    ServiceCommitment.TableCaption,
                    Rec.FieldCaption("Service Object No."),
                    Rec."Service Object No.",
                    Rec.FieldCaption("Service Commitment Entry No."),
                    Rec."Service Commitment Entry No.");
    end;

    internal procedure OpenServiceObjectCard()
    var
        ServiceObject: Record "Service Object";
    begin
        ServiceObject.OpenServiceObjectCard("Service Object No.");
    end;

    internal procedure GetNextLineNo(CustomerContractNo: Code[20]) LineNo: Integer
    var
        CustomerContractLine: Record "Customer Contract Line";
    begin
        CustomerContractLine.SetRange("Contract No.", CustomerContractNo);
        if CustomerContractLine.FindLast() then
            LineNo := CustomerContractLine."Line No.";
        LineNo += 10000;
    end;

    local procedure UpdateServiceObjectDescription()
    var
        ServiceObject: Record "Service Object";
    begin
        case Rec."Contract Line Type" of
            Enum::"Contract Line Type"::"Service Commitment":
                begin
                    ServiceObject.Get(Rec."Service Object No.");
                    ServiceObject.Validate(Description, Rec."Service Object Description");
                    ServiceObject.Modify(true);
                end;
        end;
        OnAfterUpdateServiceObjectDescription(Rec);
    end;

    local procedure UpdateServiceCommitmentDescription()
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        case Rec."Contract Line Type" of
            Enum::"Contract Line Type"::"Service Commitment":
                begin
                    ServiceCommitment.Get(Rec."Service Commitment Entry No.");
                    ServiceCommitment.Validate(Description, Rec."Service Commitment Description");
                    ServiceCommitment.Modify(true);
                end;
        end;
        OnAfterUpdateServiceCommitmentDescription(Rec);
    end;

    internal procedure LoadAmountsForContractLine(var Price: Decimal; var DiscountPerc: Decimal; var DiscountAmount: Decimal; var ServiceAmount: Decimal; var CalculationBaseAmount: Decimal; var CalculationBasePercent: Decimal)
    begin
        ResetAmountsForContractLine(Price, DiscountPerc, DiscountAmount, ServiceAmount, CalculationBaseAmount, CalculationBasePercent);
        if "Contract No." = '' then
            exit;
        case "Contract Line Type" of
            Enum::"Contract Line Type"::"Service Commitment":
                SetAmountsForContractLineFromServiceCommitment(Price, DiscountPerc, DiscountAmount, ServiceAmount, CalculationBaseAmount, CalculationBasePercent);
        end;
        OnAfterLoadAmountsForContractLine(Rec);
    end;

    internal procedure UpdateFormatingOnServiceCommitment(FieldNo: Integer)
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        GetServiceCommitment(ServiceCommitment);
        ServiceCommitment.Modify(false);
    end;

    procedure GetServiceCommitment(var ServiceCommitment: Record "Service Commitment")
    var
    begin
        if not ServiceCommitment.Get(Rec."Service Commitment Entry No.") then
            ServiceCommitment.Init();
    end;

    procedure GetServiceObject(var ServiceObject: Record "Service Object")
    begin
        if not ServiceObject.Get(Rec."Service Object No.") then
            ServiceObject.Init();
    end;

    local procedure UpdateServiceCommitmentDimensions()
    var
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
    begin
        if Rec."Service Object No." = '' then
            exit;

        if not ServiceCommitment.Get(Rec."Service Commitment Entry No.") then
            exit;

        ServiceObject.Get(Rec."Service Object No.");
        ServiceCommitment.SetDefaultDimensionFromItem(ServiceObject."Item No.");
        ServiceCommitment.Modify(false);
        DeleteRelatedVendorServiceCommDimensions(ServiceCommitment);
    end;

    local procedure DeleteRelatedVendorServiceCommDimensions(ServiceCommitment: Record "Service Commitment")
    var
        VendorServiceCommitment: Record "Service Commitment";
        VendorContract: Record "Vendor Contract";
        ServiceObject: Record "Service Object";
    begin
        VendorServiceCommitment.FilterOnServiceObjectAndPackage(ServiceCommitment."Service Object No.", ServiceCommitment.Template, ServiceCommitment."Package Code", Enum::"Service Partner"::Vendor);
        if VendorServiceCommitment.FindSet() then
            repeat
                ServiceObject.Get(VendorServiceCommitment."Service Object No.");
                VendorServiceCommitment.SetDefaultDimensionFromItem(ServiceObject."Item No.");
                if VendorContract.Get(VendorServiceCommitment."Contract No.") then
                    VendorServiceCommitment.GetCombinedDimensionSetID(VendorServiceCommitment."Dimension Set ID", VendorContract."Dimension Set ID");
                VendorServiceCommitment.Modify(false);
            until VendorServiceCommitment.Next() = 0;
    end;

    local procedure AskIfClosedContractLineCanBeDeleted()
    begin
        if not Rec.Closed then
            exit;
        if not GetConfirmResponse(ClosedContractLinesDeletionQst, true) then
            Error(TextManagement.GetProcessingAbortedErr());
    end;

    local procedure ErrorIfTextLineIsSelected(var CustomerContractLine: Record "Customer Contract Line")
    begin
        CustomerContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Comment);
        if not CustomerContractLine.IsEmpty() then
            Error(NotAllowdMergingTextLinesErr);
        CustomerContractLine.SetRange("Contract Line Type");
    end;

    local procedure CheckSelectedContractLines(var CustomerContractLine: Record "Customer Contract Line")
    begin
        ErrorIfTextLineIsSelected(CustomerContractLine);
        ErrorIfOneCustomerContractLineIsSelected(CustomerContractLine);
        TestAndCompareSelectedCustomerContractLines(CustomerContractLine);
        OnAfterCheckSelectedContractLinesOnMergeContractLines(CustomerContractLine);
    end;

    local procedure ErrorIfOneCustomerContractLineIsSelected(var CustomerContractLine: Record "Customer Contract Line")
    begin
        if CustomerContractLine.Count < 2 then
            Error(OneContractLineSelectedErr);
    end;

    local procedure TestAndCompareSelectedCustomerContractLines(var CustomerContractLine: Record "Customer Contract Line")
    var
        ServiceCommitment: Record "Service Commitment";
        PrevServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        PrevServiceObject: Record "Service Object";
        PrevNextBillingDate: Date;
        FirstLine: Boolean;
        PrevDimensionSetID: Integer;
    begin
        FirstLine := true;
        PrevDimensionSetID := 0;
        PrevNextBillingDate := 0D;
        if CustomerContractLine.FindSet() then
            repeat
                CustomerContractLine.GetServiceCommitment(ServiceCommitment);
                ServiceObject.Get(CustomerContractLine."Service Object No.");

                if not FirstLine then
                    case true of
                        ServiceObject."Customer Reference" <> PrevServiceObject."Customer Reference":
                            Error(ContractLineWithDifferentCustRefCannotBeMergedErr);
                        ServiceObject."Serial No." <> PrevServiceObject."Serial No.":
                            Error(LinesWithSerialNoCannotBeMergedErr);
                        PrevDimensionSetID <> ServiceCommitment."Dimension Set ID":
                            Error(ContractLinesWithDifferentDimensionSelectedErr);
                        ContractsGeneralMgt.BillingLineExists(Enum::"Service Partner"::Customer, CustomerContractLine."Contract No.", CustomerContractLine."Line No."):
                            Error(BillingLinesForSelectedContractLinesExistsErr);
                        PrevNextBillingDate <> ServiceCommitment."Next Billing Date":
                            Error(ContractLinesWithDifferentNextBillingDateSelectedErr);
                        ((ServiceCommitment."Service Object No." <> PrevServiceCommitment."Service Object No.") or
                         (ServiceCommitment."Entry No." <> PrevServiceCommitment."Entry No.")):
                            begin
                                if ServiceObject."No." <> PrevServiceObject."No." then
                                    ContractsGeneralMgt.TestMergingServiceObjects(ServiceObject, PrevServiceObject);
                                ContractsGeneralMgt.TestMergingServiceCommitments(ServiceCommitment, PrevServiceCommitment);
                            end;
                    end;
                PrevDimensionSetID := ServiceCommitment."Dimension Set ID";
                PrevNextBillingDate := ServiceCommitment."Next Billing Date";
                PrevServiceCommitment := ServiceCommitment;
                PrevServiceObject := ServiceObject;
                FirstLine := false;
            until CustomerContractLine.Next() = 0;
    end;

    local procedure RecalculateHarmonizedBillingFieldsOnCustomerContract(DeletedCustContractLineNo: Integer)
    var
        CustomerContract: Record "Customer Contract";
        ServiceCommitment: Record "Service Commitment";
    begin
        CustomerContract.Get(Rec."Contract No.");
        Rec.GetServiceCommitment(ServiceCommitment);
        CustomerContract.RecalculateHarmonizedBillingFieldsBasedOnNextBillingDate(DeletedCustContractLineNo);
    end;

    internal procedure FilterOnServiceCommitment(ServiceCommitment: Record "Service Commitment")
    begin
        Rec.SetRange("Service Commitment Entry No.", ServiceCommitment."Entry No.");
        Rec.SetRange("Contract No.", ServiceCommitment."Contract No.");
    end;

    internal procedure MergeContractLines(var CustomerContractLine: Record "Customer Contract Line")
    var
        RefCustomerContractLine: Record "Customer Contract Line";
        SelectCustContractLines: Page "Select Cust. Contract Lines";
    begin
        CheckSelectedContractLines(CustomerContractLine);
        SelectCustContractLines.SetTableView(CustomerContractLine);
        if SelectCustContractLines.RunModal() = Action::OK then begin
            SelectCustContractLines.GetRecord(RefCustomerContractLine);
            if MergeCustomerContractLine(CustomerContractLine, RefCustomerContractLine) then
                Message(ContractLinesMergedMsg);
        end;
    end;

    internal procedure InitFromServiceCommitment(ServiceCommitment: Record "Service Commitment"; ContractNo: Code[20])
    var
        ServiceObject: Record "Service Object";
    begin
        Rec.Init();
        Rec."Contract No." := ContractNo;
        Rec."Line No." := GetNextLineNo(Rec."Contract No.");
        Rec."Contract Line Type" := Enum::"Contract Line Type"::"Service Commitment";
        Rec."Service Object No." := ServiceCommitment."Service Object No.";
        ServiceObject.Get(ServiceCommitment."Service Object No.");
        Rec."Service Object Description" := ServiceObject.Description;
        Rec."Service Commitment Entry No." := ServiceCommitment."Entry No.";
        Rec."Service Commitment Description" := ServiceCommitment.Description;
        OnAfterInitFromServiceCommitment(Rec, ServiceCommitment, ServiceObject);
    end;

    local procedure MergeCustomerContractLine(var CustomerContractLine: Record "Customer Contract Line"; RefCustomerContractLine: Record "Customer Contract Line"): Boolean
    var
        ServiceObject: Record "Service Object";
        ServiceCommitment: Record "Service Commitment";
    begin
        CreateServiceObject(ServiceObject, RefCustomerContractLine."Service Object No.", CustomerContractLine);
        CreateMergedServiceCommitment(ServiceCommitment, ServiceObject, RefCustomerContractLine);
        CloseCustomerContractLines(CustomerContractLine);
        if not AssignNewServiceCommitmentToCustomerContract(CustomerContractLine."Contract No.", ServiceCommitment) then
            exit(false);
        exit(true);
    end;

    local procedure GetNewServiceObjectQuantity(var CustomerContractLine: Record "Customer Contract Line") NewQuantity: Decimal
    var
        ServiceObject: Record "Service Object";
    begin
        if CustomerContractLine.FindSet() then
            repeat
                ServiceObject.Get(CustomerContractLine."Service Object No.");
                NewQuantity += ServiceObject."Quantity Decimal";
            until CustomerContractLine.Next() = 0;
    end;

    local procedure CreateServiceObject(var ServiceObject: Record "Service Object"; ServiceObjectNo: Code[20]; var CustomerContractLine: Record "Customer Contract Line")
    begin
        ServiceObject.Get(ServiceObjectNo);
        ServiceObject."No." := '';
        ServiceObject."Quantity Decimal" := GetNewServiceObjectQuantity(CustomerContractLine);
        ServiceObject.Insert(true);
    end;

    local procedure CreateMergedServiceCommitment(var ServiceCommitment: Record "Service Commitment"; ServiceObject: Record "Service Object"; RefCustomerContractLine: Record "Customer Contract Line")
    begin
        RefCustomerContractLine.GetServiceCommitment(ServiceCommitment);
        ServiceCommitment."Entry No." := 0;
        ServiceCommitment."Service Object No." := ServiceObject."No.";
        ServiceCommitment.Validate("Service Amount", ServiceCommitment.Price * ServiceObject."Quantity Decimal");
        ServiceCommitment.Validate("Service Start Date", ServiceCommitment."Next Billing Date");
        ServiceCommitment.Insert(true);
    end;

    local procedure AssignNewServiceCommitmentToCustomerContract(ContractNo: Code[20]; NewServiceCommitment: Record "Service Commitment"): Boolean
    var
        CustomerContract: Record "Customer Contract";
    begin
        if ContractNo = '' then
            exit(false);
        CustomerContract.Get(ContractNo);
        CustomerContract.CreateCustomerContractLineFromServiceCommitment(NewServiceCommitment, ContractNo);
        exit(true);
    end;

    local procedure CloseCustomerContractLines(var CustomerContractLine: Record "Customer Contract Line")
    var
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
    begin
        if CustomerContractLine.FindSet() then
            repeat
                CustomerContractLine.GetServiceCommitment(ServiceCommitment);
                UpdateServiceCommitmentAndCloseCustomerContractLine(ServiceCommitment, CustomerContractLine);
                ServiceObject.Get(CustomerContractLine."Service Object No.");
                ServiceObject.UpdateServicesDates();
                ServiceObject.Modify(false);
            until CustomerContractLine.Next() = 0;
    end;

    local procedure UpdateServiceCommitmentAndCloseCustomerContractLine(var ServiceCommitment: Record "Service Commitment"; var CustomerContractLine: Record "Customer Contract Line")
    begin
        ServiceCommitment."Service End Date" := ServiceCommitment."Next Billing Date";
        ServiceCommitment."Next Billing Date" := 0D;
        ServiceCommitment.Validate("Service End Date");
        ServiceCommitment.Closed := true;
        ServiceCommitment.Modify(false);

        CustomerContractLine.Closed := true;
        CustomerContractLine.Modify(false);
    end;

    local procedure SetAmountsForContractLineFromServiceCommitment(var Price: Decimal; var DiscountPerc: Decimal; var DiscountAmount: Decimal; var ServiceAmount: Decimal; var CalculationBaseAmount: Decimal; var CalculationBasePercent: Decimal)
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        GetServiceCommitment(ServiceCommitment);
        Price := ServiceCommitment.Price;
        DiscountPerc := ServiceCommitment."Discount %";
        DiscountAmount := ServiceCommitment."Discount Amount";
        ServiceAmount := ServiceCommitment."Service Amount";
        CalculationBaseAmount := ServiceCommitment."Calculation Base Amount";
        CalculationBasePercent := ServiceCommitment."Calculation Base %";
    end;

    local procedure ResetAmountsForContractLine(var Price: Decimal; var DiscountPerc: Decimal; var DiscountAmount: Decimal; var ServiceAmount: Decimal; var CalculationBaseAmount: Decimal; var CalculationBasePercent: Decimal)
    begin
        Price := 0;
        DiscountPerc := 0;
        DiscountAmount := 0;
        ServiceAmount := 0;
        CalculationBasePercent := 0;
        CalculationBaseAmount := 0;
    end;

    procedure SetHideValidationDialog(NewHideValidationDialog: Boolean)
    begin
        HideValidationDialog := NewHideValidationDialog;
    end;

    procedure GetHideValidationDialog(): Boolean
    begin
        exit(HideValidationDialog);
    end;

    local procedure GetConfirmResponse(ConfirmQuestion: Text; DefaultButton: Boolean): Boolean
    begin
        if HideValidationDialog then
            exit(true);
        exit(ConfirmManagement.GetResponse(ConfirmQuestion, DefaultButton));
    end;

    internal procedure SetCalledFromDeleteServiceCommitment(NewCalledFromDeleteServiceCommitment: Boolean)
    begin
        CalledFromDeleteServiceCommitment := NewCalledFromDeleteServiceCommitment;
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCheckSelectedContractLinesOnMergeContractLines(var SelectedCustomerContractLines: Record "Customer Contract Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCheckAndDisconnectContractLine(var Rec: Record "Customer Contract Line"; xRec: Record "Customer Contract Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateServiceObjectDescription(var Rec: Record "Customer Contract Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterUpdateServiceCommitmentDescription(var Rec: Record "Customer Contract Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterLoadAmountsForContractLine(var Rec: Record "Customer Contract Line")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterInitFromServiceCommitment(var CustomerContractLine: Record "Customer Contract Line"; ServiceCommitment: Record "Service Commitment"; ServiceObject: Record "Service Object")
    begin
    end;
}