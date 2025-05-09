namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Inventory.Item;

table 8065 "Vend. Sub. Contract Line"
{
    Caption = 'Vendor Subscription Contract Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Subscription Contract No."; Code[20])
        {
            Caption = 'Subscription Contract No.';
            TableRelation = "Vendor Subscription Contract";
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
                TempVendorContractLine: Record "Vend. Sub. Contract Line" temporary;
            begin
                CheckAndDisconnectContractLine();
                TempVendorContractLine := Rec;
                Init();
                "Contract Line Type" := TempVendorContractLine."Contract Line Type";
            end;
        }
        field(4; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = if ("Contract Line Type" = const(Item)) Item where("Subscription Option" = filter("Sales with Service Commitment" | "Service Commitment Item"), Blocked = const(false))
            else if ("Contract Line Type" = const("G/L Account")) "G/L Account" where("Direct Posting" = const(true), "Account Type" = const(Posting), Blocked = const(false));
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                Item: Record Item;
                GLAccount: Record "G/L Account";
                TempVendorContractLine: Record "Vend. Sub. Contract Line" temporary;
            begin
                case "Contract Line Type" of
                    "Contract Line Type"::Item:
                        begin
                            if not Item.Get("No.") then
                                Error(EntityDoesNotExistErr, Item.TableCaption, "No.");
                            if Item.Blocked or Item."Subscription Option" in ["Item Service Commitment Type"::"Sales without Service Commitment", "Item Service Commitment Type"::"Sales without Service Commitment"] then
                                Error(ItemBlockedOrWithoutServiceCommitmentsErr, "No.");
                        end;
                    "Contract Line Type"::"G/L Account":
                        begin
                            if not GLAccount.Get("No.") then
                                Error(EntityDoesNotExistErr, GLAccount.TableCaption, "No.");
                            if GLAccount.Blocked or not GLAccount."Direct Posting" or (GLAccount."Account Type" <> GLAccount."Account Type"::Posting) then
                                Error(GLAccountBlockedOrNotForDirectPostingErr, "No.");
                        end;
                end;

                TempVendorContractLine := Rec;
                Init();
                SystemId := TempVendorContractLine.SystemId;
                "Contract Line Type" := TempVendorContractLine."Contract Line Type";
                "No." := TempVendorContractLine."No.";
                CreateServiceObjectWithServiceCommitment();
            end;
        }
        field(100; "Subscription Header No."; Code[20])
        {
            Caption = 'Subscription No.';
            TableRelation = "Subscription Header";
            Editable = false;
        }
        field(101; "Subscription Line Entry No."; Integer)
        {
            Caption = 'Subscription Line Entry No.';
            TableRelation = "Subscription Line"."Entry No.";
            Editable = false;
        }
        field(102; "Subscription Description"; Text[100])
        {
            Caption = 'Subscription Description';

            trigger OnValidate()
            begin
                UpdateServiceObjectDescription();
            end;
        }
        field(106; "Subscription Line Description"; Text[100])
        {
            Caption = 'Subscription Line Description';

            trigger OnValidate()
            begin
                UpdateServiceCommitmentDescription();
            end;
        }
        field(107; "Closed"; Boolean)
        {
            Caption = 'Closed';
        }
        field(109; "Service Object Quantity"; Decimal)
        {
            Caption = 'Quantity';
            FieldClass = FlowField;
            CalcFormula = lookup("Subscription Header".Quantity where("No." = field("Subscription Header No.")));
            Editable = false;
        }
        field(200; "Planned Sub. Line exists"; Boolean)
        {
            Caption = 'Planned Subscription Line exists';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("Planned Subscription Line" where("Subscription Header No." = field("Subscription Header No."), "Subscription Contract No." = field("Subscription Contract No."), "Subscription Contract Line No." = field("Line No.")));
        }
    }

    keys
    {
        key(PK; "Subscription Contract No.", "Line No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
    begin
        AskIfClosedContractLineCanBeDeleted();
        UpdateServiceCommitmentDimensions();
        ErrorIfUsageDataBillingIsLinkedToContractLine();
        CheckAndDisconnectContractLine();
    end;

    var
        TextManagement: Codeunit "Text Management";
        ContractsGeneralMgt: Codeunit "Sub. Contracts General Mgt.";
        DeletionNotAllowedErr: Label 'Deletion is not allowed because the line is linked to a contract billing line. Please delete the billing proposal first.';
        ClosedContractLinesDeletionQst: Label 'Closed contract lines may represent the archive for deleted Subscription Lines. If you delete terminated contract lines, you can no longer access the history. Do you want to continue?';
        OneContractLineSelectedErr: Label 'Please select the lines you want to combine.';
        BillingLinesForSelectedContractLinesExistsErr: Label 'Billing Lines for exists for at least one of the selected contract lines. Delete the Billing Lines before merging the Contract Lines.';
        ContractLinesWithDifferentDimensionSelectedErr: Label 'There are different dimension values for the Contract Lines. Complete the dimensions before merging the Contract Lines.';
        ContractLinesWithDifferentNextBillingDateSelectedErr: Label 'There is a different Next Billing Date for the Contract Lines. The Contract Lines must be billed so that the Next Billing Date is the same before they can be combined.';
        NotAllowedMergingTextLinesErr: Label 'Merging with text lines is not allowed.';
        ContractLinesMergedMsg: Label 'Vendor contract lines have been merged.';
        ContractLineCannotBeDeletedErr: Label 'You cannot delete the contract line because usage data exist for it. Please delete all related data in Usage Data Billing first.';
        EntityDoesNotExistErr: Label '%1 with the No. %2 does not exist.', Comment = '%1 = Item or GL Account, %2 = Entity No.';
        ItemBlockedOrWithoutServiceCommitmentsErr: Label 'The item %1 cannot be blocked and must be of type "Non-Inventory" with the Subscription Option set to "Sales with Subscription" or "Subscription Item".', Comment = '%1=Item No.';
        GLAccountBlockedOrNotForDirectPostingErr: Label 'The G/L Account %1 cannot be blocked and must allow direct posting to it.', Comment = '%1=G/L Account No.';

    local procedure CreateServiceObjectWithServiceCommitment()
    var
        VendorContract: Record "Vendor Subscription Contract";
        ServiceObject: Record "Subscription Header";
        ServiceCommitment: Record "Subscription Line";
    begin
        VendorContract.Get("Subscription Contract No.");
        ServiceObject.InitForSourceNo("Contract Line Type", "No.");
        ServiceObject."Created in Contract line" := true;
        ServiceObject.Insert(true);
        "Subscription Header No." := ServiceObject."No.";
        "Subscription Description" := ServiceObject.Description;

        ServiceCommitment.InitForServiceObject(ServiceObject, "Service Partner"::Vendor);
        ServiceCommitment.UpdateFromVendorContract(VendorContract);
        ServiceCommitment."Created in Contract line" := true;
        ServiceCommitment."Subscription Contract No." := Rec."Subscription Contract No.";
        ServiceCommitment."Subscription Contract Line No." := Rec."Line No.";
        ServiceCommitment.Insert(false);
        "Subscription Line Entry No." := ServiceCommitment."Entry No.";
        "Subscription Line Description" := ServiceCommitment.Description;
    end;

    local procedure ErrorIfUsageDataBillingIsLinkedToContractLine()
    var
        UsageDataBilling: Record "Usage Data Billing";
    begin
        UsageDataBilling.SetRange(Partner, "Service Partner"::Vendor);
        UsageDataBilling.SetRange("Subscription Contract No.", "Subscription Contract No.");
        UsageDataBilling.SetRange("Subscription Contract Line No.", "Line No.");
        if not UsageDataBilling.IsEmpty() then
            Error(ContractLineCannotBeDeletedErr);
    end;

    internal procedure OpenServiceObjectCard()
    var
        ServiceObject: Record "Subscription Header";
    begin
        ServiceObject.OpenServiceObjectCard("Subscription Header No.");
    end;

    local procedure CheckAndDisconnectContractLine()
    var
        ServiceCommitment: Record "Subscription Line";
        BillingLineArchive: Record "Billing Line Archive";
    begin
        if ContractsGeneralMgt.BillingLineExists(Enum::"Service Partner"::Vendor, "Subscription Contract No.", "Line No.") then
            Error(DeletionNotAllowedErr);

        BillingLineArchive.FilterBillingLineArchiveOnContractLine(Enum::"Service Partner"::Vendor, "Subscription Contract No.", "Line No.");
        if BillingLineArchive.FindSet() then begin
            repeat
                if not BillingLineArchive.PostedPurchaseDocumentExist() then
                    BillingLineArchive.Delete(false);
            until BillingLineArchive.Next() = 0;
            ServiceCommitment.DisconnectContractLine("Subscription Line Entry No.");
        end else
            ServiceCommitment.DeleteOrDisconnectServiceCommitment("Subscription Line Entry No.");
    end;

    internal procedure GetNextLineNo(VendorContractNo: Code[20]) LineNo: Integer
    var
        VendorContractLine: Record "Vend. Sub. Contract Line";
    begin
        VendorContractLine.SetRange("Subscription Contract No.", VendorContractNo);
        if VendorContractLine.FindLast() then
            LineNo := VendorContractLine."Line No.";
        LineNo += 10000;
    end;

    local procedure UpdateServiceObjectDescription()
    var
        ServiceObject: Record "Subscription Header";
    begin
        case Rec."Contract Line Type" of
            Enum::"Contract Line Type"::Item,
            Enum::"Contract Line Type"::"G/L Account":
                begin
                    ServiceObject.Get(Rec."Subscription Header No.");
                    ServiceObject.Validate(Description, Rec."Subscription Description");
                    ServiceObject.Modify(true);
                end;
        end;
    end;

    local procedure UpdateServiceCommitmentDescription()
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        case Rec."Contract Line Type" of
            Enum::"Contract Line Type"::Item,
            Enum::"Contract Line Type"::"G/L Account":
                begin
                    ServiceCommitment.Get(Rec."Subscription Line Entry No.");
                    ServiceCommitment.Validate(Description, Rec."Subscription Line Description");
                    ServiceCommitment.Modify(true);
                end;
        end;
    end;

    internal procedure LoadServiceCommitmentForContractLine(var ServiceCommitment: Record "Subscription Line")
    var
        LocalServiceCommitment: Record "Subscription Line"; //in case the parameter is passed as temporary table
    begin
        ServiceCommitment.Init();
        if "Subscription Contract No." = '' then
            exit;
        case "Contract Line Type" of
            Enum::"Contract Line Type"::Item,
            Enum::"Contract Line Type"::"G/L Account":
                begin
                    GetServiceCommitment(LocalServiceCommitment);
                    LocalServiceCommitment.CalcFields(Quantity);
                    ServiceCommitment.TransferFields(LocalServiceCommitment);
                end;
        end
    end;

    internal procedure GetServiceCommitment(var ServiceCommitment: Record "Subscription Line"): Boolean
    var
    begin
        ServiceCommitment.Init();
        exit(ServiceCommitment.Get(Rec."Subscription Line Entry No."));
    end;

    internal procedure GetServiceObject(var ServiceObject: Record "Subscription Header"): Boolean
    begin
        ServiceObject.Init();
        exit(ServiceObject.Get(Rec."Subscription Header No."));
    end;

    internal procedure UpdateServiceCommitmentDimensions()
    var
        ServiceCommitment: Record "Subscription Line";
        CustomerServiceCommitment: Record "Subscription Line";
        CustomerContract: Record "Customer Subscription Contract";
    begin
        if Rec."Subscription Header No." = '' then
            exit;
        if not ServiceCommitment.Get(Rec."Subscription Line Entry No.") then
            exit;

        ServiceCommitment.SetDefaultDimensions(true);
        CustomerServiceCommitment.FilterOnServiceObjectAndPackage(Rec."Subscription Header No.", ServiceCommitment.Template, ServiceCommitment."Subscription Package Code", Enum::"Service Partner"::Customer);
        if CustomerServiceCommitment.FindFirst() then
            if CustomerContract.Get(CustomerServiceCommitment."Subscription Contract No.") then
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

    internal procedure FilterOnServiceCommitment(ServiceCommitment: Record "Subscription Line")
    begin
        Rec.SetRange("Subscription Line Entry No.", ServiceCommitment."Entry No.");
        Rec.SetRange("Subscription Contract No.", ServiceCommitment."Subscription Contract No.");
    end;

    internal procedure FilterOnServiceObjectContractLineType()
    begin
        SetRange("Contract Line Type", "Contract Line Type"::Item, "Contract Line Type"::"G/L Account");
    end;

    internal procedure MergeContractLines(var VendorContractLine: Record "Vend. Sub. Contract Line")
    var
        RefVendorContractLine: Record "Vend. Sub. Contract Line";
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

    local procedure CheckSelectedContractLines(var VendorContractLine: Record "Vend. Sub. Contract Line")
    begin
        ErrorIfTextLineIsSelected(VendorContractLine);
        ErrorIfOneVendorContractLineIsSelected(VendorContractLine);
        TestAndCompareSelectedVendorContractLines(VendorContractLine);
    end;

    local procedure ErrorIfTextLineIsSelected(var VendorContractLine: Record "Vend. Sub. Contract Line")
    begin
        VendorContractLine.SetRange("Contract Line Type", Enum::"Contract Line Type"::Comment);
        if not VendorContractLine.IsEmpty() then
            Error(NotAllowedMergingTextLinesErr);
        VendorContractLine.SetRange("Contract Line Type");
    end;

    local procedure ErrorIfOneVendorContractLineIsSelected(var VendorContractLine: Record "Vend. Sub. Contract Line")
    begin
        if VendorContractLine.Count < 2 then
            Error(OneContractLineSelectedErr);
    end;

    local procedure TestAndCompareSelectedVendorContractLines(var VendorContractLine: Record "Vend. Sub. Contract Line")
    var
        ServiceCommitment: Record "Subscription Line";
        PrevServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
        PrevServiceObject: Record "Subscription Header";
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
                ServiceObject.Get(VendorContractLine."Subscription Header No.");
                if not FirstLine then
                    case true of
                        PrevDimensionSetID <> ServiceCommitment."Dimension Set ID":
                            Error(ContractLinesWithDifferentDimensionSelectedErr);
                        ContractsGeneralMgt.BillingLineExists(Enum::"Service Partner"::Vendor, VendorContractLine."Subscription Contract No.", VendorContractLine."Line No."):
                            Error(BillingLinesForSelectedContractLinesExistsErr);
                        PrevNextBillingDate <> ServiceCommitment."Next Billing Date":
                            Error(ContractLinesWithDifferentNextBillingDateSelectedErr);
                        ((ServiceCommitment."Subscription Header No." <> PrevServiceCommitment."Subscription Header No.") or
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

    local procedure MergeVendorContractLine(var VendorContractLine: Record "Vend. Sub. Contract Line"; RefVendorContractLine: Record "Vend. Sub. Contract Line"): Boolean
    var
        ServiceObject: Record "Subscription Header";
        ServiceCommitment: Record "Subscription Line";
    begin
        CreateDuplicateServiceObject(ServiceObject, RefVendorContractLine."Subscription Header No.", VendorContractLine);
        CreateMergedServiceCommitment(ServiceCommitment, ServiceObject, RefVendorContractLine);
        CloseVendorContractLines(VendorContractLine);
        if not AssignNewServiceCommitmentToVendorContract(VendorContractLine."Subscription Contract No.", ServiceCommitment) then
            exit(false);
        exit(true);
    end;

    local procedure CreateDuplicateServiceObject(var ServiceObject: Record "Subscription Header"; ServiceObjectNo: Code[20]; var VendorContractLine: Record "Vend. Sub. Contract Line")
    begin
        ServiceObject.Get(ServiceObjectNo);
        ServiceObject."No." := '';
        ServiceObject.Quantity := GetNewServiceObjectQuantity(VendorContractLine);
        ServiceObject.Insert(true);
    end;

    local procedure CreateMergedServiceCommitment(var ServiceCommitment: Record "Subscription Line"; ServiceObject: Record "Subscription Header"; RefVendorContractLine: Record "Vend. Sub. Contract Line")
    begin
        ServiceCommitment.Get(RefVendorContractLine."Subscription Line Entry No.");
        ServiceCommitment."Entry No." := 0;
        ServiceCommitment."Subscription Header No." := ServiceObject."No.";
        ServiceCommitment.Validate(Amount, ServiceCommitment.Price * ServiceObject.Quantity);
        ServiceCommitment.Validate("Subscription Line Start Date", ServiceCommitment."Next Billing Date");
        ServiceCommitment.Insert(true);
    end;

    local procedure AssignNewServiceCommitmentToVendorContract(ContractNo: Code[20]; NewServiceCommitment: Record "Subscription Line"): Boolean
    var
        VendorContract: Record "Vendor Subscription Contract";
    begin
        if ContractNo = '' then
            exit(false);
        VendorContract.Get(ContractNo);
        VendorContract.CreateVendorContractLineFromServiceCommitment(NewServiceCommitment);
        exit(true);
    end;

    local procedure CloseVendorContractLines(var VendorContractLine: Record "Vend. Sub. Contract Line")
    var
        ServiceCommitment: Record "Subscription Line";
        ServiceObject: Record "Subscription Header";
    begin
        if VendorContractLine.FindSet() then
            repeat
                ServiceCommitment.Get(VendorContractLine."Subscription Line Entry No.");
                UpdateServiceCommitmentAndCloseVendorContractLine(ServiceCommitment, VendorContractLine);
                ServiceObject.Get(VendorContractLine."Subscription Header No.");
                ServiceObject.UpdateServicesDates();
                ServiceObject.Modify(false);
            until VendorContractLine.Next() = 0;
    end;

    local procedure GetNewServiceObjectQuantity(var VendorContractLine: Record "Vend. Sub. Contract Line") NewQuantity: Decimal
    var
        ServiceObject: Record "Subscription Header";
    begin
        if VendorContractLine.FindSet() then
            repeat
                ServiceObject.Get(VendorContractLine."Subscription Header No.");
                NewQuantity += ServiceObject.Quantity;
            until VendorContractLine.Next() = 0;
    end;

    local procedure UpdateServiceCommitmentAndCloseVendorContractLine(var ServiceCommitment: Record "Subscription Line"; var VendorContractLine: Record "Vend. Sub. Contract Line")
    begin
        ServiceCommitment."Subscription Line End Date" := ServiceCommitment."Next Billing Date";
        ServiceCommitment."Next Billing Date" := 0D;
        ServiceCommitment.Validate("Subscription Line End Date");
        ServiceCommitment.Closed := true;
        ServiceCommitment.Modify(false);

        VendorContractLine.Closed := true;
        VendorContractLine.Modify(false);
    end;

    internal procedure InitFromServiceCommitment(ServiceCommitment: Record "Subscription Line"; ContractNo: Code[20])
    var
        ServiceObject: Record "Subscription Header";
    begin
        Rec.Init();
        Rec."Subscription Contract No." := ContractNo;
        Rec."Line No." := GetNextLineNo(ContractNo);
        ServiceObject.Get(ServiceCommitment."Subscription Header No.");
        Rec."Contract Line Type" := ServiceObject.GetContractLineTypeFromServiceObject();
        Rec."No." := ServiceObject."Source No.";
        Rec."Subscription Header No." := ServiceObject."No.";
        Rec."Subscription Description" := ServiceObject.Description;
        Rec."Subscription Line Entry No." := ServiceCommitment."Entry No.";
        Rec."Subscription Line Description" := ServiceCommitment.Description;
    end;

    internal procedure IsCommentLine(): Boolean
    begin
        exit("Contract Line Type" = "Contract Line Type"::Comment);
    end;
}