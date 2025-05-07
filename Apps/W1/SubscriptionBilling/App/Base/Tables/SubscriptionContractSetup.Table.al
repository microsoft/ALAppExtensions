namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using Microsoft.Foundation.NoSeries;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.Dimension;

table 8051 "Subscription Contract Setup"
{
    Caption = 'Subscription Contract Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Cust. Sub. Contract Nos."; Code[20])
        {
            Caption = 'Customer Subscription Contract Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Vend. Sub. Contract Nos."; Code[20])
        {
            Caption = 'Vendor Subscription Contract Nos.';
            TableRelation = "No. Series";
        }
        field(4; "Subscription Header No."; Code[20])
        {
            Caption = 'Subscription Nos.';
            TableRelation = "No. Series";
        }
        field(5; "Aut. Insert C. Contr. DimValue"; Boolean)
        {
            Caption = 'Autom. Insert Cust. Contr. Dimension Value';
        }
        field(6; "Sub. Line Start Date Inv. Pick"; Enum "Serv. Start Date For Inv. Pick")
        {
            Caption = 'Subscription Line Start Date for Inventory Pick';
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
        field(21; "Dimension Code Cust. Contr."; Code[20])
        {
            Caption = 'Dimension Code for Customer Subscription Contract';
            TableRelation = Dimension;
        }
        field(59; "Default Period Calculation"; enum "Period Calculation")
        {
            Caption = 'Default Period Calculation';
            InitValue = "Align to End of Month";
            trigger OnValidate()
            begin
                if xRec."Default Period Calculation" <> Rec."Default Period Calculation" then
                    if ConfirmManagement.GetResponse(UpdatePeriodCalculationQst, true) then
                        PropagatePeriodCalculationUpdate();
            end;
        }
        field(60; "Default Billing Base Period"; DateFormula)
        {
            Caption = 'Default Billing Base Period';
            InitValue = '1M';
            trigger OnValidate()
            begin
                if Format(Rec."Default Billing Base Period") = '' then
                    Message(ManualCreationOfContractLinesNotPossibleMsg, FieldCaption("Default Billing Base Period"))
                else
                    DateFormulaManagement.ErrorIfDateFormulaNegative("Default Billing Base Period");
            end;
        }
        field(61; "Default Billing Rhythm"; DateFormula)
        {
            Caption = 'Default Billing Rhythm';
            InitValue = '1M';
            trigger OnValidate()
            begin
                if Format(Rec."Default Billing Rhythm") = '' then
                    Message(ManualCreationOfContractLinesNotPossibleMsg, FieldCaption("Default Billing Rhythm"))
                else
                    DateFormulaManagement.ErrorIfDateFormulaNegative("Default Billing Rhythm");
            end;
        }
        field(180; "Def. Rel. Jnl. Template Name"; Code[10])
        {
            Caption = 'Deferrals Release Jnl. Template Name';
            TableRelation = "Gen. Journal Template";

            trigger OnValidate()
            begin
                if "Def. Rel. Jnl. Template Name" = '' then
                    "Def. Rel. Jnl. Batch Name" := '';
            end;
        }
        field(181; "Def. Rel. Jnl. Batch Name"; Code[10])
        {
            Caption = 'Deferrals Release Jnl. Batch Name';
            TableRelation = if ("Def. Rel. Jnl. Template Name" = filter(<> '')) "Gen. Journal Batch".Name where("Journal Template Name" = field("Def. Rel. Jnl. Template Name"));

            trigger OnValidate()
            begin
                TestField("Def. Rel. Jnl. Template Name");
            end;
        }
        field(182; "Create Contract Deferrals"; Enum "Create Contract Deferrals")
        {
            Caption = 'Create Contract Deferrals';
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        ConfirmManagement: Codeunit "Confirm Management";
        DateFormulaManagement: Codeunit "Date Formula Management";
        UpdatePeriodCalculationQst: Label 'Do you want to update existing Subscription Lines, Sales Subscription Lines and Subscription Package Lines? Choose Yes to change existing records. Choose No to change the default value but not update existing records.';
        IsEmptyTxt: Label '%1 or %2 is empty.', Comment = '%1 = FieldCaption, %2 = FieldCaption';
        EnterValuesInFieldsMsg: Label 'In order to continue please enter a values for fields ''%1'' and ''%2''.', Comment = '%1 = FieldCaption, %2 = FieldCaption';
        OpenServiceContractSetupTok: Label 'Open Subscription Contract Setup.';
        ManualCreationOfContractLinesNotPossibleMsg: Label 'No manual contract lines can be created without %1. Do you want to delete the value?', Comment = '%1 = FieldCaption';

    internal procedure ContractTextsCreateDefaults()
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
        BillingPeriodSetupMissingErr: Label 'The %1 is incomplete. You have to set up a value for "%2" as a description line.', Comment = '%1 = TableCaption, %2 = Specific text type value"';
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
        ServiceCommPackageLine: Record "Subscription Package Line";
        SalesServiceCommitment: Record "Sales Subscription Line";
        ServiceCommitment: Record "Subscription Line";
    begin
        ServiceCommPackageLine.ModifyAll("Period Calculation", Rec."Default Period Calculation", false);
        SalesServiceCommitment.ModifyAll("Period Calculation", Rec."Default Period Calculation", false);
        ServiceCommitment.ModifyAll("Period Calculation", Rec."Default Period Calculation", false);
    end;

    procedure CheckPrerequisitesForCreatingManualContractLine()
    var
        FieldEmptyErrorInfo: ErrorInfo;
    begin
        Get();
        if (Format("Default Billing Base Period") <> '') and (Format("Default Billing Rhythm") <> '') then
            exit;

        FieldEmptyErrorInfo.Title(StrSubstNo(IsEmptyTxt, FieldCaption("Default Billing Base Period"), FieldCaption("Default Billing Rhythm")));
        FieldEmptyErrorInfo.Message(StrSubstNo(EnterValuesInFieldsMsg, FieldCaption("Default Billing Base Period"), FieldCaption("Default Billing Rhythm")));
        FieldEmptyErrorInfo.PageNo := Page::"Service Contract Setup";
        FieldEmptyErrorInfo.AddNavigationAction(OpenServiceContractSetupTok);

        Error(FieldEmptyErrorInfo);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"Subscription Contract Setup", 'I')]
    internal procedure InitRecord()
    begin
        if not Get() then begin
            ContractTextsCreateDefaults();
            Insert();
        end;
    end;
}