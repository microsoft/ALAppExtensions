namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using Microsoft.Foundation.NoSeries;

table 8051 "Service Contract Setup"
{
    Caption = 'Service Contract Setup';
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Customer Contract Nos."; Code[20])
        {
            Caption = 'Customer Contract Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Vendor Contract Nos."; Code[20])
        {
            Caption = 'Vendor Contract Nos.';
            TableRelation = "No. Series";
        }
        field(4; "Service Object Nos."; Code[20])
        {
            Caption = 'Service Object Nos.';
            TableRelation = "No. Series";
        }
        field(5; "Aut. Insert C. Contr. DimValue"; Boolean)
        {
            Caption = 'Autom. Insert Cust. Contr. Dimension Value';
        }
        field(6; "Serv. Start Date for Inv. Pick"; Enum "Serv. Start Date For Inv. Pick")
        {
            Caption = 'Service Start Date for Inventory Pick';
        }
        field(7; "Overdue Date Formula"; DateFormula)
        {
            Caption = 'Overdue Date Formula';
        }
        field(10; "Contract Invoice Description"; Enum "Contract Invoice Text Type")
        {
            Caption = 'Description';
        }
        field(11; "Contract Invoice Add. Line 1"; Enum "Contract Invoice Text Type")
        {
            Caption = 'Additional Line 1';
        }
        field(12; "Contract Invoice Add. Line 2"; Enum "Contract Invoice Text Type")
        {
            Caption = 'Additional Line 2';
        }
        field(13; "Contract Invoice Add. Line 3"; Enum "Contract Invoice Text Type")
        {
            Caption = 'Additional Line 3';
        }
        field(14; "Contract Invoice Add. Line 4"; Enum "Contract Invoice Text Type")
        {
            Caption = 'Additional Line 4';
        }
        field(15; "Contract Invoice Add. Line 5"; Enum "Contract Invoice Text Type")
        {
            Caption = 'Additional Line 5';
        }
        field(20; "Origin Name collective Invoice"; Enum "Contract Origin Name Type")
        {
            Caption = 'Origin Name for collective Sales Invoice';
        }
        field(59; "Default Period Calculation"; enum "Period Calculation")
        {
            Caption = 'Default Period Calculation';
            trigger OnValidate()
            begin
                if xRec."Default Period Calculation" <> Rec."Default Period Calculation" then
                    if ConfirmManagement.GetResponse(UpdatePeriodCalculationQst, true) then
                        PropagatePeriodCalculationUpdate();
            end;
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        ContractTextsCreateDefaults();
    end;

    var
        ConfirmManagement: Codeunit "Confirm Management";
        UpdatePeriodCalculationQst: Label 'Do you want to update existing Service Commitments, Sales Service Commitments and Service Commitment Package lines? Choose Yes to change existing records. Choose No to change the default value but not update existing records.';

    procedure ContractTextsCreateDefaults()
    begin
        Rec.Validate("Contract Invoice Description", Enum::"Contract Invoice Text Type"::"Service Object");
        Rec.Validate("Contract Invoice Add. Line 1", Enum::"Contract Invoice Text Type"::"Service Commitment");
        Rec.Validate("Contract Invoice Add. Line 2", Enum::"Contract Invoice Text Type"::"Billing Period");
        Rec.Validate("Contract Invoice Add. Line 3", Enum::"Contract Invoice Text Type"::"Serial No.");
        Rec.Validate("Contract Invoice Add. Line 4", Enum::"Contract Invoice Text Type"::"Customer Reference");
        Rec.Validate("Contract Invoice Add. Line 5", Enum::"Contract Invoice Text Type"::"Primary attribute");
    end;

    procedure VerifyContractTextsSetup()
    var
        BillingPeriodSetupMissingErr: Label 'The %1 is incomplete. You have to set up a value for "%2" as a description line.';
    begin
        if (Rec."Contract Invoice Description" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
           (Rec."Contract Invoice Add. Line 1" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
           (Rec."Contract Invoice Add. Line 2" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
           (Rec."Contract Invoice Add. Line 3" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
           (Rec."Contract Invoice Add. Line 4" <> Enum::"Contract Invoice Text Type"::"Billing Period") and
           (Rec."Contract Invoice Add. Line 5" <> Enum::"Contract Invoice Text Type"::"Billing Period")
        then
            Error(BillingPeriodSetupMissingErr, Rec.TableCaption(), Enum::"Contract Invoice Text Type"::"Billing Period");
    end;

    local procedure PropagatePeriodCalculationUpdate()
    var
        ServiceCommPackageLine: Record "Service Comm. Package Line";
        SalesServiceCommitment: Record "Sales Service Commitment";
        ServiceCommitment: Record "Service Commitment";
    begin
        ServiceCommPackageLine.ModifyAll("Period Calculation", Rec."Default Period Calculation", false);
        SalesServiceCommitment.ModifyAll("Period Calculation", Rec."Default Period Calculation", false);
        ServiceCommitment.ModifyAll("Period Calculation", Rec."Default Period Calculation", false);
    end;
}