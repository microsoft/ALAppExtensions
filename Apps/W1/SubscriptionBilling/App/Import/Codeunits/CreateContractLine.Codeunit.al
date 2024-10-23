namespace Microsoft.SubscriptionBilling;

codeunit 8007 "Create Contract Line"
{
    Access = Internal;
    TableNo = "Imported Service Commitment";

    trigger OnRun()
    begin
        ImportedServiceCommitment := Rec;
        if SkipRun() then
            exit;
        TestImportedServiceCommitment();
        CreateContractLine();
        Rec := ImportedServiceCommitment;
        Rec.Modify(true);
    end;

    local procedure SkipRun(): Boolean
    begin
        if ImportedServiceCommitment."Contract Line created" then
            exit(true);
    end;

    local procedure TestImportedServiceCommitment()
    begin
        if ImportedServiceCommitment."Contract No." = '' then
            Error(EmptyContractNoErr);

        ImportedServiceCommitment.TestField("Invoicing via", ImportedServiceCommitment."Invoicing via"::Contract);
        if ImportedServiceCommitment.IsContractCommentLine() then
            case ImportedServiceCommitment.Partner of
                "Service Partner"::Customer:
                    CustomerContract.Get(ImportedServiceCommitment."Contract No.");
                "Service Partner"::Vendor:
                    VendorContract.Get(ImportedServiceCommitment."Contract No.");
            end
        else begin
            ServiceObject.Get(ImportedServiceCommitment."Service Object No.");
            ServiceCommitment.Get(ImportedServiceCommitment."Service Commitment Entry No.");

            case ImportedServiceCommitment.Partner of
                "Service Partner"::Customer:
                    begin
                        CustomerContract.Get(ImportedServiceCommitment."Contract No.");
                        CustomerContract.TestField("Sell-to Customer No.", ServiceObject."End-User Customer No.");
                        CustomerContract.TestField("Currency Code", ImportedServiceCommitment."Currency Code");
                    end;
                "Service Partner"::Vendor:
                    begin
                        VendorContract.Get(ImportedServiceCommitment."Contract No.");
                        VendorContract.TestField("Currency Code", ImportedServiceCommitment."Currency Code");
                    end;
            end;
        end;
    end;

    local procedure CreateContractLine()
    begin
        case ImportedServiceCommitment.Partner of
            "Service Partner"::Customer:
                CreateCustomerContractLine();
            "Service Partner"::Vendor:
                CreateVendorContractLine();
        end;

        ImportedServiceCommitment."Contract Line created" := true;
        ImportedServiceCommitment.ClearErrorTextAndSetProcessedFields();
    end;

    local procedure CreateCustomerContractLine()
    var
        CustomerContractLine: Record "Customer Contract Line";
        OldDimSetID: Integer;
    begin
        OnBeforeCreateCustomerContractLine(ServiceCommitment, ImportedServiceCommitment);
        if ImportedServiceCommitment.IsContractCommentLine() then
            CreateCustomerContractCommentLine()
        else begin
            CustomerContractLine.InitFromServiceCommitment(ServiceCommitment, ImportedServiceCommitment."Contract No.");
            if ImportedServiceCommitment."Contract Line No." <> 0 then
                CustomerContractLine."Line No." := ImportedServiceCommitment."Contract Line No."
            else
                ImportedServiceCommitment."Contract Line No." := CustomerContractLine."Line No.";
            CustomerContractLine.Insert(false);

            OldDimSetID := ServiceCommitment."Dimension Set ID";
            ServiceCommitment."Contract No." := CustomerContractLine."Contract No.";
            ServiceCommitment."Contract Line No." := CustomerContractLine."Line No.";
            ServiceCommitment.GetCombinedDimensionSetID(ServiceCommitment."Dimension Set ID", CustomerContract."Dimension Set ID");
            ServiceCommitment.Modify(true);
            ServiceCommitment.UpdateRelatedVendorServiceCommDimensions(OldDimSetID, ServiceCommitment."Dimension Set ID");
        end;
        OnAfterCreateCustomerContractLine(CustomerContractLine, ServiceCommitment, ImportedServiceCommitment);
    end;

    local procedure CreateCustomerContractCommentLine()
    var
        CustomerContractLine: Record "Customer Contract Line";
    begin
        CustomerContractLine.Init();
        CustomerContractLine."Contract No." := ImportedServiceCommitment."Contract No.";
        SetCustomerContractLineLineNo(CustomerContractLine);
        CustomerContractLine."Service Object Description" := ImportedServiceCommitment.Description;
        CustomerContractLine.Insert(false);
        ImportedServiceCommitment."Service Commitment created" := true;
    end;

    local procedure SetCustomerContractLineLineNo(var CustomerContractLine: Record "Customer Contract Line")
    begin
        if ImportedServiceCommitment."Contract Line No." = 0 then begin
            CustomerContractLine."Line No." := CustomerContractLine.GetNextLineNo(ImportedServiceCommitment."Contract No.");
            ImportedServiceCommitment."Contract Line No." := CustomerContractLine."Line No.";
        end else
            CustomerContractLine."Line No." := ImportedServiceCommitment."Contract Line No.";
    end;

    local procedure CreateVendorContractLine()
    var
        VendorContractLine: Record "Vendor Contract Line";
    begin
        OnBeforeCreateVendorContractLine(ServiceCommitment, ImportedServiceCommitment);
        if ImportedServiceCommitment.IsContractCommentLine() then
            CreateVendorContractCommentLine()
        else begin
            VendorContractLine.InitFromServiceCommitment(ServiceCommitment, ImportedServiceCommitment."Contract No.");
            if ImportedServiceCommitment."Contract Line No." <> 0 then
                VendorContractLine."Line No." := ImportedServiceCommitment."Contract Line No."
            else
                ImportedServiceCommitment."Contract Line No." := VendorContractLine."Line No.";
            VendorContractLine.Insert(false);

            ServiceCommitment."Contract No." := VendorContractLine."Contract No.";
            ServiceCommitment."Contract Line No." := VendorContractLine."Line No.";

            ServiceCommitment.GetCombinedDimensionSetID(ServiceCommitment."Dimension Set ID", VendorContract."Dimension Set ID");
            ServiceCommitment.Modify(false);
            VendorContractLine.UpdateServiceCommitmentDimensions();
        end;
        OnAfterCreateVendorContractLine(VendorContractLine, ServiceCommitment, ImportedServiceCommitment);
    end;

    local procedure CreateVendorContractCommentLine()
    var
        VendorContractLine: Record "Vendor Contract Line";
    begin
        VendorContractLine.Init();
        VendorContractLine."Contract No." := ImportedServiceCommitment."Contract No.";
        SetVendorContractLineLineNo(VendorContractLine);
        VendorContractLine."Service Object Description" := ImportedServiceCommitment.Description;
        VendorContractLine.Insert(false);
        ImportedServiceCommitment."Service Commitment created" := true;
    end;

    local procedure SetVendorContractLineLineNo(var VendorContractLine: Record "Vendor Contract Line")
    begin
        if ImportedServiceCommitment."Contract Line No." = 0 then begin
            VendorContractLine."Line No." := VendorContractLine.GetNextLineNo(ImportedServiceCommitment."Contract No.");
            ImportedServiceCommitment."Contract Line No." := VendorContractLine."Line No.";
        end else
            VendorContractLine."Line No." := ImportedServiceCommitment."Contract Line No.";
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCreateCustomerContractLine(var ServiceCommitment: Record "Service Commitment"; var ImportedServiceCommitment: Record "Imported Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCreateCustomerContractLine(var CustomerContractLine: Record "Customer Contract Line"; var ServiceCommitment: Record "Service Commitment"; var ImportedServiceCommitment: Record "Imported Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCreateVendorContractLine(var ServiceCommitment: Record "Service Commitment"; var ImportedServiceCommitment: Record "Imported Service Commitment")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCreateVendorContractLine(var VendorContractLine: Record "Vendor Contract Line"; var ServiceCommitment: Record "Service Commitment"; var ImportedServiceCommitment: Record "Imported Service Commitment")
    begin
    end;

    var
        ImportedServiceCommitment: Record "Imported Service Commitment";
        CustomerContract: Record "Customer Contract";
        VendorContract: Record "Vendor Contract";
        ServiceObject: Record "Service Object";
        ServiceCommitment: Record "Service Commitment";
        EmptyContractNoErr: Label 'The Contract No. must not be empty. No contract line was created.';
}