namespace Microsoft.SubscriptionBilling;

codeunit 8007 "Create Sub. Contract Line"
{
    TableNo = "Imported Subscription Line";

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
        if ImportedServiceCommitment."Sub. Contract Line created" then
            exit(true);
    end;

    local procedure TestImportedServiceCommitment()
    begin
        if ImportedServiceCommitment."Subscription Contract No." = '' then
            Error(EmptyContractNoErr);

        ImportedServiceCommitment.TestField("Invoicing via", ImportedServiceCommitment."Invoicing via"::Contract);
        if ImportedServiceCommitment.IsContractCommentLine() then
            case ImportedServiceCommitment.Partner of
                "Service Partner"::Customer:
                    CustomerContract.Get(ImportedServiceCommitment."Subscription Contract No.");
                "Service Partner"::Vendor:
                    VendorContract.Get(ImportedServiceCommitment."Subscription Contract No.");
            end
        else begin
            ServiceObject.Get(ImportedServiceCommitment."Subscription Header No.");
            ServiceCommitment.Get(ImportedServiceCommitment."Subscription Line Entry No.");

            case ImportedServiceCommitment.Partner of
                "Service Partner"::Customer:
                    begin
                        CustomerContract.Get(ImportedServiceCommitment."Subscription Contract No.");
                        CustomerContract.TestField("Sell-to Customer No.", ServiceObject."End-User Customer No.");
                        CustomerContract.TestField("Currency Code", ImportedServiceCommitment."Currency Code");
                    end;
                "Service Partner"::Vendor:
                    begin
                        VendorContract.Get(ImportedServiceCommitment."Subscription Contract No.");
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

        ImportedServiceCommitment."Sub. Contract Line created" := true;
        ImportedServiceCommitment.ClearErrorTextAndSetProcessedFields();
    end;

    local procedure CreateCustomerContractLine()
    var
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        OldDimSetID: Integer;
    begin
        OnBeforeCreateCustomerContractLine(ServiceCommitment, ImportedServiceCommitment);
        if ImportedServiceCommitment.IsContractCommentLine() then
            CreateCustomerContractCommentLine()
        else begin
            CustomerContractLine.InitFromServiceCommitment(ServiceCommitment, ImportedServiceCommitment."Subscription Contract No.");
            if ImportedServiceCommitment."Subscription Contract Line No." <> 0 then
                CustomerContractLine."Line No." := ImportedServiceCommitment."Subscription Contract Line No."
            else
                ImportedServiceCommitment."Subscription Contract Line No." := CustomerContractLine."Line No.";
            CustomerContractLine.Insert(false);

            OldDimSetID := ServiceCommitment."Dimension Set ID";
            ServiceCommitment."Subscription Contract No." := CustomerContractLine."Subscription Contract No.";
            ServiceCommitment."Subscription Contract Line No." := CustomerContractLine."Line No.";
            ServiceCommitment.GetCombinedDimensionSetID(ServiceCommitment."Dimension Set ID", CustomerContract."Dimension Set ID");
            ServiceCommitment.Modify(true);
            ServiceCommitment.UpdateRelatedVendorServiceCommDimensions(OldDimSetID, ServiceCommitment."Dimension Set ID");
        end;
        OnAfterCreateCustomerContractLine(CustomerContractLine, ServiceCommitment, ImportedServiceCommitment);
    end;

    local procedure CreateCustomerContractCommentLine()
    var
        CustomerContractLine: Record "Cust. Sub. Contract Line";
    begin
        CustomerContractLine.Init();
        CustomerContractLine."Subscription Contract No." := ImportedServiceCommitment."Subscription Contract No.";
        SetCustomerContractLineLineNo(CustomerContractLine);
        CustomerContractLine."Subscription Description" := ImportedServiceCommitment.Description;
        CustomerContractLine.Insert(false);
        ImportedServiceCommitment."Subscription Line created" := true;
    end;

    local procedure SetCustomerContractLineLineNo(var CustomerContractLine: Record "Cust. Sub. Contract Line")
    begin
        if ImportedServiceCommitment."Subscription Contract Line No." = 0 then begin
            CustomerContractLine."Line No." := CustomerContractLine.GetNextLineNo(ImportedServiceCommitment."Subscription Contract No.");
            ImportedServiceCommitment."Subscription Contract Line No." := CustomerContractLine."Line No.";
        end else
            CustomerContractLine."Line No." := ImportedServiceCommitment."Subscription Contract Line No.";
    end;

    local procedure CreateVendorContractLine()
    var
        VendorContractLine: Record "Vend. Sub. Contract Line";
    begin
        OnBeforeCreateVendorContractLine(ServiceCommitment, ImportedServiceCommitment);
        if ImportedServiceCommitment.IsContractCommentLine() then
            CreateVendorContractCommentLine()
        else begin
            VendorContractLine.InitFromServiceCommitment(ServiceCommitment, ImportedServiceCommitment."Subscription Contract No.");
            if ImportedServiceCommitment."Subscription Contract Line No." <> 0 then
                VendorContractLine."Line No." := ImportedServiceCommitment."Subscription Contract Line No."
            else
                ImportedServiceCommitment."Subscription Contract Line No." := VendorContractLine."Line No.";
            VendorContractLine.Insert(false);

            ServiceCommitment."Subscription Contract No." := VendorContractLine."Subscription Contract No.";
            ServiceCommitment."Subscription Contract Line No." := VendorContractLine."Line No.";

            ServiceCommitment.GetCombinedDimensionSetID(ServiceCommitment."Dimension Set ID", VendorContract."Dimension Set ID");
            ServiceCommitment.Modify(false);
            VendorContractLine.UpdateServiceCommitmentDimensions();
        end;
        OnAfterCreateVendorContractLine(VendorContractLine, ServiceCommitment, ImportedServiceCommitment);
    end;

    local procedure CreateVendorContractCommentLine()
    var
        VendorContractLine: Record "Vend. Sub. Contract Line";
    begin
        VendorContractLine.Init();
        VendorContractLine."Subscription Contract No." := ImportedServiceCommitment."Subscription Contract No.";
        SetVendorContractLineLineNo(VendorContractLine);
        VendorContractLine."Subscription Description" := ImportedServiceCommitment.Description;
        VendorContractLine.Insert(false);
        ImportedServiceCommitment."Subscription Line created" := true;
    end;

    local procedure SetVendorContractLineLineNo(var VendorContractLine: Record "Vend. Sub. Contract Line")
    begin
        if ImportedServiceCommitment."Subscription Contract Line No." = 0 then begin
            VendorContractLine."Line No." := VendorContractLine.GetNextLineNo(ImportedServiceCommitment."Subscription Contract No.");
            ImportedServiceCommitment."Subscription Contract Line No." := VendorContractLine."Line No.";
        end else
            VendorContractLine."Line No." := ImportedServiceCommitment."Subscription Contract Line No.";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateCustomerContractLine(var SubscriptionLine: Record "Subscription Line"; var ImportedSubscriptionLine: Record "Imported Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateCustomerContractLine(var CustSubContractLine: Record "Cust. Sub. Contract Line"; var SubscriptionLine: Record "Subscription Line"; var ImportedSubscriptionLine: Record "Imported Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateVendorContractLine(var SubscriptionLine: Record "Subscription Line"; var ImportedSubscriptionLine: Record "Imported Subscription Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateVendorContractLine(var VendSubContractLine: Record "Vend. Sub. Contract Line"; var SubscriptionLine: Record "Subscription Line"; var ImportedSubscriptionLine: Record "Imported Subscription Line")
    begin
    end;

    var
        ImportedServiceCommitment: Record "Imported Subscription Line";
        CustomerContract: Record "Customer Subscription Contract";
        VendorContract: Record "Vendor Subscription Contract";
        ServiceObject: Record "Subscription Header";
        ServiceCommitment: Record "Subscription Line";
        EmptyContractNoErr: Label 'The Contract No. must not be empty. No contract line was created.';
}