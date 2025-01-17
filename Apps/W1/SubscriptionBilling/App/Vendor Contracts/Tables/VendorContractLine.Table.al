namespace Microsoft.SubscriptionBilling;

using System.Utilities;

table 8065 "Vendor Contract Line"
{
    Caption = 'Vendor Contract Line';
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Contract No."; Code[20])
        {
            Caption = 'Contract No.';
            TableRelation = "Vendor Contract";
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
                TempVendorContractLine: Record "Vendor Contract Line" temporary;
            begin
                CheckTypeChangeAllowed();
                CheckAndDisconnectContractLine();
                TempVendorContractLine := Rec;
                Init();
                "Contract Line Type" := TempVendorContractLine."Contract Line Type";
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
    var
    begin
        if not CalledFromDeleteServiceCommitment then begin
            AskIfClosedContractLineCanBeDeleted();
            CheckAndDisconnectContractLine();
            UpdateServiceCommitmentDimensions();
        end;
        ErrorIfUsageDataBillingIsLinkedToContractLine();
    end;

    var
        TextManagement: Codeunit "Text Management";
        ContractsGeneralMgt: Codeunit "Contracts General Mgt.";
        CalledFromDeleteServiceCommitment: Boolean;
        DeletionNotAllowedErr: Label 'Deletion is not allowed because the line is linked to a contract billing line. Please delete the billing proposal first.';
        ClosedContractLinesDeletionQst: Label 'Closed contract lines may represent the archive for deleted services. If you delete terminated contract lines, you can no longer access the history. Do you want to continue?';
        OneContractLineSelectedErr: Label 'Please select the lines you want to combine.';
        BillingLinesForSelectedContractLinesExistsErr: Label 'Billing Lines for exists for at least one of the selected contract lines. Delete the Billing Lines before merging the Contract Lines.';
        ContractLinesWithDifferentDimensionSelectedErr: Label 'There are different dimension values for the Contract Lines. Complete the dimensions before merging the Contract Lines.';
        ContractLinesWithDifferentNextBillingDateSelectedErr: Label 'There is a different Next Billing Date for the Contract Lines. The Contract Lines must be billed so that the Next Billing Date is the same before they can be combined.';
        NotAllowdMergingTextLinesErr: Label 'Merging with text lines is not allowed.';
        ContractLinesMergedMsg: Label 'Vendor contract lines have been merged.';
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

    internal procedure OpenServiceObjectCard()
    var
        ServiceObject: Record "Service Object";
    begin
        ServiceObject.OpenServiceObjectCard("Service Object No.");
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

        if ContractsGeneralMgt.BillingLineExists(Enum::"Service Partner"::Vendor, "Contract No.", "Line No.") then
            Error(DeletionNotAllowedErr);

        BillingLineArchive.FilterBillingLineArchiveOnContractLine(Enum::"Service Partner"::Vendor, "Contract No.", "Line No.");
        if BillingLineArchive.FindSet() then
            repeat
                if not BillingLineArchive.PostedPurchaseDocumentExist() then
                    BillingLineArchive.Delete(false);
            until BillingLineArchive.Next() = 0;
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

    internal procedure GetNextLineNo(VendorContractNo: Code[20]) LineNo: Integer
    var
        VendorContractLine: Record "Vendor Contract Line";
    begin
        VendorContractLine.SetRange("Contract No.", VendorContractNo);
        if VendorContractLine.FindLast() then
            LineNo := VendorContractLine."Line No.";
        LineNo += 10000;
    end;

    local procedure UpdateServiceObjectDescription()
    var
        ServiceObject: Record "Service Object";
    begin
        if Rec."Contract Line Type" <> Rec."Contract Line Type"::"Service Commitment" then
            exit;
        ServiceObject.Get(Rec."Service Object No.");
        ServiceObject.Validate(Description, Rec."Service Object Description");
        ServiceObject.Modify(true);
    end;

    local procedure UpdateServiceCommitmentDescription()
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        if Rec."Contract Line Type" <> Rec."Contract Line Type"::"Service Commitment" then
            exit;
        ServiceCommitment.Get(Rec."Service Commitment Entry No.");
        ServiceCommitment.Validate(Description, Rec."Service Commitment Description");
        ServiceCommitment.Modify(true);
    end;

    internal procedure LoadAmountsForContractLine(var Price: Decimal; var DiscountPerc: Decimal; var DiscountAmount: Decimal; var ServiceAmount: Decimal)
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        Price := 0;
        DiscountPerc := 0;
        DiscountAmount := 0;
        ServiceAmount := 0;
        if "Contract No." = '' then
            exit;
        case "Contract Line Type" of
            Enum::"Contract Line Type"::"Service Commitment":
                begin
                    GetServiceCommitment(ServiceCommitment);
                    Price := ServiceCommitment.Price;
                    DiscountPerc := ServiceCommitment."Discount %";
                    DiscountAmount := ServiceCommitment."Discount Amount";
                    ServiceAmount := ServiceCommitment."Service Amount";
                end;
        end
    end;

    internal procedure GetServiceCommitment(var ServiceCommitment: Record "Service Commitment")
    var
    begin
        if not ServiceCommitment.Get(Rec."Service Commitment Entry No.") then
            ServiceCommitment.Init();
    end;

    internal procedure GetServiceObject(var ServiceObject: Record "Service Object")
    begin
        if not ServiceObject.Get(Rec."Service Object No.") then
            ServiceObject.Init();
    end;

    internal procedure UpdateServiceCommitmentDimensions()
    var
        ServiceCommitment: Record "Service Commitment";
        CustomerServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
        CustomerContract: Record "Customer Contract";
    begin
        if Rec."Service Object No." = '' then
            exit;
        if not ServiceCommitment.Get(Rec."Service Commitment Entry No.") then
            exit;

        ServiceObject.Get(Rec."Service Object No.");
        ServiceCommitment.SetDefaultDimensionFromItem(ServiceObject."Item No.");
        CustomerServiceCommitment.FilterOnServiceObjectAndPackage(Rec."Service Object No.", ServiceCommitment.Template, ServiceCommitment."Package Code", Enum::"Service Partner"::Customer);
        if CustomerServiceCommitment.FindFirst() then
            if CustomerContract.Get(CustomerServiceCommitment."Contract No.") then
                ServiceCommitment.GetCombinedDimensionSetID(ServiceCommitment."Dimension Set ID", CustomerContract."Dimension Set ID");
        ServiceCommitment.Modify(false);

    end;

    local procedure AskIfClosedContractLineCanBeDeleted()
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if not Rec.Closed then
            exit;
        if not ConfirmManagement.GetResponse(ClosedContractLinesDeletionQst, true) then
            Error(TextManagement.GetProcessingAbortedErr());
    end;

    internal procedure FilterOnServiceCommitment(ServiceCommitment: Record "Service Commitment")
    begin
        Rec.SetRange("Service Commitment Entry No.", ServiceCommitment."Entry No.");
        Rec.SetRange("Contract No.", ServiceCommitment."Contract No.");
    end;

    internal procedure MergeContractLines(var VendorContractLine: Record "Vendor Contract Line")
    var
        RefVendorContractLine: Record "Vendor Contract Line";
        SelectVendContractLines: Page "Select Vend. Contract Lines";
    begin
        CheckSelectedContractLines(VendorContractLine);
        SelectVendContractLines.SetTableView(VendorContractLine);
        if SelectVendContractLines.RunModal() = Action::OK then begin
            SelectVendContractLines.GetRecord(RefVendorContractLine);
            if MergeVendorContractLine(VendorContractLine, RefVendorContractLine) then
                Message(ContractLinesMergedMsg);
        end;
    end;

    local procedure CheckSelectedContractLines(var VendorContractLine: Record "Vendor Contract Line")
    begin
        ErrorIfTextLineIsSelected(VendorContractLine);
        ErrorIfOneVendorContractLineIsSelected(VendorContractLine);
        TestAndCompareSelectedVendorContractLines(VendorContractLine);
    end;

    local procedure ErrorIfTextLineIsSelected(var VendorContractLine: Record "Vendor Contract Line")
    begin
        VendorContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Comment);
        if not VendorContractLine.IsEmpty() then
            Error(NotAllowdMergingTextLinesErr);
        VendorContractLine.SetRange("Contract Line Type");
    end;

    local procedure ErrorIfOneVendorContractLineIsSelected(var VendorContractLine: Record "Vendor Contract Line")
    begin
        if VendorContractLine.Count < 2 then
            Error(OneContractLineSelectedErr);
    end;

    local procedure TestAndCompareSelectedVendorContractLines(var VendorContractLine: Record "Vendor Contract Line")
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
        if VendorContractLine.FindSet() then
            repeat
                VendorContractLine.GetServiceCommitment(ServiceCommitment);
                ServiceObject.Get(VendorContractLine."Service Object No.");
                if not FirstLine then
                    case true of
                        PrevDimensionSetID <> ServiceCommitment."Dimension Set ID":
                            Error(ContractLinesWithDifferentDimensionSelectedErr);
                        ContractsGeneralMgt.BillingLineExists(Enum::"Service Partner"::Vendor, VendorContractLine."Contract No.", VendorContractLine."Line No."):
                            Error(BillingLinesForSelectedContractLinesExistsErr);
                        PrevNextBillingDate <> ServiceCommitment."Next Billing Date":
                            Error(ContractLinesWithDifferentNextBillingDateSelectedErr);
                        ServiceObject."No." <> PrevServiceObject."No.":
                            ContractsGeneralMgt.TestMergingServiceObjects(ServiceObject, PrevServiceObject);
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
            until VendorContractLine.Next() = 0;
    end;

    local procedure MergeVendorContractLine(var VendorContractLine: Record "Vendor Contract Line"; RefVendorContractLine: Record "Vendor Contract Line"): Boolean
    var
        ServiceObject: Record "Service Object";
        ServiceCommitment: Record "Service Commitment";
    begin
        CreateServiceObject(ServiceObject, RefVendorContractLine."Service Object No.", VendorContractLine);
        CreateMergedServiceCommitment(ServiceCommitment, ServiceObject, RefVendorContractLine);
        CloseVendorContractLines(VendorContractLine);
        if not AssignNewServiceCommitmentToVendorContract(VendorContractLine."Contract No.", ServiceCommitment) then
            exit(false);
        exit(true);
    end;

    local procedure CreateServiceObject(var ServiceObject: Record "Service Object"; ServiceObjectNo: Code[20]; var VendorContractLine: Record "Vendor Contract Line")
    begin
        ServiceObject.Get(ServiceObjectNo);
        ServiceObject."No." := '';
        ServiceObject."Quantity Decimal" := GetNewServiceObjectQuantity(VendorContractLine);
        ServiceObject.Insert(true);
    end;

    local procedure CreateMergedServiceCommitment(var ServiceCommitment: Record "Service Commitment"; ServiceObject: Record "Service Object"; RefVendorContractLine: Record "Vendor Contract Line")
    begin
        ServiceCommitment.Get(RefVendorContractLine."Service Commitment Entry No.");
        ServiceCommitment."Entry No." := 0;
        ServiceCommitment."Service Object No." := ServiceObject."No.";
        ServiceCommitment.Validate("Service Amount", ServiceCommitment.Price * ServiceObject."Quantity Decimal");
        ServiceCommitment.Validate("Service Start Date", ServiceCommitment."Next Billing Date");
        ServiceCommitment.Insert(true);
    end;

    local procedure AssignNewServiceCommitmentToVendorContract(ContractNo: Code[20]; NewServiceCommitment: Record "Service Commitment"): Boolean
    var
        VendorContract: Record "Vendor Contract";
    begin
        if ContractNo = '' then
            exit(false);
        VendorContract.Get(ContractNo);
        VendorContract.CreateVendorContractLineFromServiceCommitment(NewServiceCommitment);
        exit(true);
    end;

    local procedure CloseVendorContractLines(var VendorContractLine: Record "Vendor Contract Line")
    var
        ServiceCommitment: Record "Service Commitment";
        ServiceObject: Record "Service Object";
    begin
        if VendorContractLine.FindSet() then
            repeat
                ServiceCommitment.Get(VendorContractLine."Service Commitment Entry No.");
                UpdateServiceCommitmentAndCloseVendorContractLine(ServiceCommitment, VendorContractLine);
                ServiceObject.Get(VendorContractLine."Service Object No.");
                ServiceObject.UpdateServicesDates();
                ServiceObject.Modify(false);
            until VendorContractLine.Next() = 0;
    end;

    local procedure GetNewServiceObjectQuantity(var VendorContractLine: Record "Vendor Contract Line") NewQuantity: Decimal
    var
        ServiceObject: Record "Service Object";
    begin
        if VendorContractLine.FindSet() then
            repeat
                ServiceObject.Get(VendorContractLine."Service Object No.");
                NewQuantity += ServiceObject."Quantity Decimal";
            until VendorContractLine.Next() = 0;
    end;

    local procedure UpdateServiceCommitmentAndCloseVendorContractLine(var ServiceCommitment: Record "Service Commitment"; var VendorContractLine: Record "Vendor Contract Line")
    begin
        ServiceCommitment."Service End Date" := ServiceCommitment."Next Billing Date";
        ServiceCommitment."Next Billing Date" := 0D;
        ServiceCommitment.Validate("Service End Date");
        ServiceCommitment.Closed := true;
        ServiceCommitment.Modify(false);

        VendorContractLine.Closed := true;
        VendorContractLine.Modify(false);
    end;

    internal procedure InitFromServiceCommitment(ServiceCommitment: Record "Service Commitment"; ContractNo: Code[20])
    var
        ServiceObject: Record "Service Object";
    begin
        Rec.Init();
        Rec."Contract No." := ContractNo;
        Rec."Line No." := GetNextLineNo(ContractNo);
        Rec."Contract Line Type" := Enum::"Contract Line Type"::"Service Commitment";
        Rec."Service Object No." := ServiceCommitment."Service Object No.";
        ServiceObject.Get(ServiceCommitment."Service Object No.");
        Rec."Service Object Description" := ServiceObject.Description;
        Rec."Service Commitment Entry No." := ServiceCommitment."Entry No.";
        Rec."Service Commitment Description" := ServiceCommitment.Description;
    end;
}