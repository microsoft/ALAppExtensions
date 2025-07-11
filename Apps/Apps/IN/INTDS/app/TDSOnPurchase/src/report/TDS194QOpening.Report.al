// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSOnPurchase;

using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

report 18716 "TDS 194Q Opening"
{
    Caption = 'TDS 194Q Opening';
    UsageCategory = Administration;
    ApplicationArea = All;
    Permissions = tabledata "TDS Entry" = rim;
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(General)
                {
                    field(VendorNo; VendorNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor No.';
                        TableRelation = Vendor;
                        ToolTip = 'Specifies the vendor number for which 194Q opening is to be posted.';

                        trigger OnValidate()
                        var
                        begin
                            if VendorNo = '' then begin
                                ResetVar();
                                exit;
                            end;

                            Vendor.Get(VendorNo);
                            Vendor.Testfield("Assessee Code");
                            AssesseeCode := Vendor."Assessee Code";
                        end;
                    }
                    field(AssesseeCode; AssesseeCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Assessee Code';
                        Editable = false;
                        ToolTip = 'Specifies the assessee code that is defined on the vendor master.';
                    }
                    field(TDSSectionCode; TDSSectionCode)
                    {
                        ApplicationArea = All;
                        Caption = 'TDS Section Code';
                        TableRelation = Vendor;
                        ToolTip = 'Specifies the TDS section code for which opening entry is to be posted.';

                        trigger OnValidate()
                        var
                            AllowedSections: Record "Allowed Sections";
                        begin
                            if TDSSectionCode = '' then
                                exit;

                            AllowedSections.Reset();
                            AllowedSections.SetRange("Vendor No", VendorNo);
                            AllowedSections.SetRange("TDS Section", TDSSectionCode);
                            if AllowedSections.IsEmpty then
                                Error(AllowedSectionErr, VendorNo);

                            GetTaxRateValues();
                        end;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            TDSSection: Record "TDS Section";
                            AllowedSections: Record "Allowed Sections";
                        begin
                            AllowedSections.Reset();
                            AllowedSections.SetRange("Vendor No", VendorNo);
                            if AllowedSections.FindSet() then
                                repeat
                                    TDSSection.setrange(code, AllowedSections."TDS Section");
                                    if TDSSection.FindFirst() then
                                        TDSSection.Mark(true);
                                until AllowedSections.Next() = 0;

                            TDSSection.setrange(code);
                            TDSSection.MarkedOnly(true);
                            if page.RunModal(Page::"TDS Sections", TDSSection) = Action::LookupOK then begin
                                TDSSectionCode := TDSSection.Code;
                                GetTaxRateValues();
                            end;
                        end;
                    }
                    field(DocumentNo; DocumentNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the document number that will appear on the TDS ledger entries.';
                    }
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the date on which the TDS ledger entries are to be posted.';

                        trigger OnValidate()
                        var
                        begin
                            if PostingDate = 0D then
                                exit;

                            if TDSSectionCode = '' then
                                Error(TDSSectionCodeErr);
                        end;
                    }
                    field(PurchaseAmount; PurchaseAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'Purchase Amount';
                        ToolTip = 'Specifies the purchase amount that needs to be posted as vendor opening entry for 194Q.';
                    }
                    field(TDSThresholdAmount; TDSThresholdAmount)
                    {
                        ApplicationArea = All;
                        Caption = 'TDS Threshold Amount';
                        Editable = false;
                        ToolTip = 'Specifies the TDS threshold amount that is defined on the TDS rate for TDS section code.';
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    var
        CompanyInformation: Record "Company Information";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        CheckValues();

        CompanyInformation.Get();
        Vendor.Get(VendorNo);
        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("TDS Above Threshold Opening");

        TDSEntry.Init();
        TDSEntry."Entry No." := 0;
        TDSEntry."Vendor No." := VendorNo;
        TDSEntry."T.A.N. No." := CompanyInformation."T.A.N. No.";
        TDSEntry."User ID" := CopyStr(UserId(), 1, 50);
        TDSEntry."Source Code" := SourceCodeSetup."TDS Above Threshold Opening";
        TDSEntry.Section := TDSSectionCode;
        TDSEntry."Assessee Code" := AssesseeCode;
        TDSEntry."Deductee PAN No." := Vendor."P.A.N. No.";
        TDSEntry."Account Type" := TDSEntry."Account Type"::Vendor;
        TDSEntry."Account No." := VendorNo;
        TDSEntry."Document Type" := TDSEntry."Document Type"::Invoice;
        TDSEntry."Document No." := DocumentNo;
        TDSEntry."Posting Date" := PostingDate;
        TDSEntry."TDS Base Amount" := PurchaseAmount;
        if PurchaseAmount > TDSThresholdAmount then
            TDSEntry."Invoice Amount" := TDSThresholdAmount
        else
            TDSEntry."Invoice Amount" := PurchaseAmount;
        TDSEntry."Over & Above Threshold Opening" := true;
        TDSEntry.Insert();
    end;

    procedure InitializeRequest(
        VendNo: Code[20];
        AsCode: Code[10];
        SectionCode: Code[10];
        DocNo: Code[20];
        PostDate: Date;
        PurchAmount: Decimal;
        ThresholdAmount: Decimal)
    begin
        VendorNo := VendNo;
        AssesseeCode := AsCode;
        TDSSectionCode := SectionCode;
        DocumentNo := DocNo;
        PostingDate := PostDate;
        PurchaseAmount := PurchAmount;
        TDSThresholdAmount := ThresholdAmount;
    end;

    local procedure ResetVar()
    begin
        AssesseeCode := '';
        TDSSectionCode := '';
        EffectiveDate := 0D;
        DocumentNo := '';
        PostingDate := 0D;
        PurchaseAmount := 0;
        TDSThresholdAmount := 0;
        CalcOverThreshold := false;
    end;

    local procedure CheckValues()
    begin
        If VendorNo = '' then
            Error(VendorNoErr);

        if TDSSectionCode = '' then
            Error(TDSSectionCodeErr);

        if DocumentNo = '' then
            Error(DocumentNoErr);

        if PostingDate = 0D then
            Error(PostingDateErr, EffectiveDate);

        if PurchaseAmount = 0 then
            Error(PurchaseAmountErr);
    end;

    local procedure GetTaxRateValues()
    var
        RateID: Text;
        RowID: Guid;
    begin
        if not TDSSetup.Get() then
            exit;

        RateID := GetTaxRateID();
        RowID := GetTaxRateRowID(RateID);

        CheckTaxRateValues(RowID);
    end;

    local procedure GetTaxRateID(): Text
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        Value: Text;
        RateID: Text;
    begin
        TaxRateColumnSetup.SetCurrentKey(Sequence);
        TaxRateColumnSetup.SetRange("Tax Type", TDSSetup."Tax Type");
        TaxRateColumnSetup.SetFilter("Column Type", '%1|%2', TaxRateColumnSetup."Column Type"::Value, TaxRateColumnSetup."Column Type"::"Tax Attributes");
        TaxRateColumnSetup.SetRange("Allow Blank", false);
        if TaxRateColumnSetup.FindSet() then
            repeat
                Value := '';
                Case TaxRateColumnSetup.Sequence of
                    1:
                        Value := TDSSectionCode;
                    2:
                        Value := AssesseeCode;
                End;

                RateID += Value + '|';
            until TaxRateColumnSetup.Next() = 0;

        exit(RateID);
    end;

    local procedure GetTaxRateRowID(RateID: Text): Guid
    var
        TaxRate: Record "Tax Rate";
        TempTaxRate: Record "Tax Rate" Temporary;
        Rank: Text;
    begin
        TaxRate.SetRange("Tax Type", TDSSetup."Tax Type");
        TaxRate.SetRange("Tax Rate ID", RateID);
        if TaxRate.findSet() then
            repeat
                Rank := '';
                if QualifyTaxRateRow(TaxRate, Rank) then begin
                    TempTaxRate := TaxRate;
                    TempTaxRate."Tax Rate ID" := Rank;
                    TempTaxRate.Insert();
                end;
            until TaxRate.Next() = 0;

        TempTaxRate.Reset();
        TempTaxRate.SetCurrentKey("Tax Rate ID");
        if TempTaxRate.FindLast() then
            exit(TempTaxRate.ID);
    end;

    local procedure QualifyTaxRateRow(var TaxRate: Record "Tax Rate"; var Rank: Text): Boolean
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
        RHSValue: Variant;
        ColumnScore: Integer;
        ColumnRank: Text;
    begin
        ColumnScore := 0;
        TaxRateColumnSetup.SetCurrentKey(Sequence);
        TaxRateColumnSetup.SetRange("Tax Type", TaxRate."Tax Type");
        if TaxRateColumnSetup.FindSet() then
            repeat
                if TaxRateColumnSetup."Column Type" in [
                    TaxRateColumnSetup."Column Type"::"Range From and Range To",
                    TaxRateColumnSetup."Column Type"::"Range From",
                    TaxRateColumnSetup."Column Type"::"Range To"]
                then begin
                    RHSValue := WorkDate();
                    if not QualifyRangeColumn(TaxRate, TaxRateColumnSetup, RHSValue, ColumnScore) then
                        exit(false);

                    ColumnRank := PadStr(Format(ColumnScore, 0, 2), 10, '0');
                    Rank += ColumnRank;
                end;

            until TaxRateColumnSetup.Next() = 0;

        exit(true);
    end;

    local procedure QualifyRangeColumn(var TaxRate: Record "Tax Rate"; var TaxRateColumnSetup: Record "Tax Rate Column Setup"; RHSValue: Variant; var Score: Integer): Boolean
    var
        TaxRateValue: Record "Tax Rate Value";
        CompareDate: Date;
    begin
        TaxRateValue.SetRange("Tax Type", TaxRateColumnSetup."Tax Type");
        TaxRateValue.SetRange("Config ID", TaxRate.ID);
        TaxRateValue.SetRange("Column ID", TaxRateColumnSetup."Column ID");
        if TaxRateValue.FindSet() then
            repeat
                if not ParamterInRange(TaxRateColumnSetup, TaxRateValue."Config ID", RHSValue) then
                    exit(false);

                case TaxRateColumnSetup.Type of
                    TaxRateColumnSetup.Type::Date:
                        begin
                            CompareDate := RHSValue;
                            if TaxRateValue."Date Value" <> 0D then
                                Score := CompareDate - TaxRateValue."Date Value"
                            else
                                Score := CompareDate - 17530101D;

                            Score := 10000 - Score;
                        end;
                    TaxRateColumnSetup.Type::Decimal:
                        Score := RHSValue;
                end;
            until TaxRateValue.Next() = 0;
        exit(true);
    end;

    local procedure ParamterInRange(TaxRateColumnSetup: Record "Tax Rate Column Setup"; ConfigID: Guid; var RHSValue: Variant): Boolean
    var
        TaxRateValue: Record "Tax Rate Value";
    begin
        TaxRateValue.Reset();
        TaxRateValue.SetRange("Tax Type", TaxRateColumnSetup."Tax Type");
        TaxRateValue.SetRange("Config ID", ConfigID);
        TaxRateValue.SetRange("Column ID", TaxRateColumnSetup."Column ID");

        case TaxRateColumnSetup."Column Type" of
            TaxRateColumnSetup."Column Type"::"Range From and Range To":
                FilterBasedOnFromAndToRange(TaxRateValue, TaxRateColumnSetup, RHSValue);
            TaxRateColumnSetup."Column Type"::"Range From":
                FilterBasedOnFromRange(TaxRateValue, TaxRateColumnSetup, RHSValue);
            TaxRateColumnSetup."Column Type"::"Range To":
                FilterBasedOnToRange(TaxRateValue, TaxRateColumnSetup, RHSValue);
        end;

        if Not TaxRateValue.IsEmpty() then
            exit(true);
    end;

    local procedure FilterBasedOnFromAndToRange(var TaxRateValue: Record "Tax Rate Value"; TaxRateColumnSetup: Record "Tax Rate Column Setup"; RHSValue: Variant)
    var
        CompareDecimal: Decimal;
        CompareDate: Date;
    begin
        if TaxRateColumnSetup.Type = TaxRateColumnSetup.Type::Date then begin
            CompareDate := RHSValue;
            TaxRateValue.SetFilter("Date Value", '<=%1', CompareDate);
            TaxRateValue.SetFilter("Date Value To", '>=%1', CompareDate);
        end else
            if TaxRateColumnSetup.Type = TaxRateColumnSetup.Type::Decimal then begin
                CompareDecimal := RHSValue;
                TaxRateValue.SetFilter("Decimal Value", '<=%1', CompareDecimal);
                TaxRateValue.SetFilter("Decimal Value To", '>=%1', CompareDecimal);
            end;
    end;

    local procedure FilterBasedOnFromRange(var TaxRateValue: Record "Tax Rate Value"; TaxRateColumnSetup: Record "Tax Rate Column Setup"; RHSValue: Variant)
    var
        CompareDecimal: Decimal;
        CompareDate: Date;
    begin
        case TaxRateColumnSetup.Type of
            TaxRateColumnSetup.Type::Date:
                begin
                    CompareDate := RHSValue;
                    TaxRateValue.SetFilter("Date Value", '<=%1', CompareDate);
                end;
            TaxRateColumnSetup.Type::Decimal:
                begin
                    CompareDecimal := RHSValue;
                    TaxRateValue.SetFilter("Decimal Value", '<=%1', CompareDecimal);
                end;
        end;
    end;

    local procedure FilterBasedOnToRange(var TaxRateValue: Record "Tax Rate Value"; TaxRateColumnSetup: Record "Tax Rate Column Setup"; RHSValue: Variant)
    var
        CompareDecimal: Decimal;
        CompareDate: Date;
    begin
        case TaxRateColumnSetup.Type of
            TaxRateColumnSetup.Type::Date:
                begin
                    CompareDate := RHSValue;
                    TaxRateValue.SetFilter("Date Value", '>=%1', CompareDate);
                end;
            TaxRateColumnSetup.Type::Decimal:
                begin
                    CompareDecimal := RHSValue;
                    TaxRateValue.SetFilter("Decimal Value", '>=%1', CompareDecimal);
                end;
        end;
    end;

    local procedure CheckTaxRateValues(RowID: Guid)
    var
        TaxRateValue: Record "Tax Rate Value";
    begin
        // Get Efective Date
        TaxRateValue.SetRange("Config ID", RowID);
        TaxRateValue.SetRange("Column Type", TaxRateValue."Column Type"::"Range From");
        TaxRateValue.SetRange("Column ID", GetColumnID(EffectiveDateLbl));
        if TaxRateValue.FindFirst() then
            Evaluate(EffectiveDate, TaxRateValue.Value);

        // Get Threshold Amount
        TaxRateValue.SetRange("Config ID", RowID);
        TaxRateValue.SetRange("Column Type", TaxRateValue."Column Type"::"Output Information");
        TaxRateValue.SetRange("Column ID", GetColumnID(TDSThresholdAmountLbl));
        if TaxRateValue.FindFirst() then
            Evaluate(TDSThresholdAmount, TaxRateValue.Value);

        // Get Calc. Over & Above Threshold
        TaxRateValue.SetRange("Config ID", RowID);
        TaxRateValue.SetRange("Column Type", TaxRateValue."Column Type"::"Output Information");
        TaxRateValue.SetRange("Column ID", GetColumnID(CalcOverThresholdLbl));
        if TaxRateValue.FindFirst() then
            Evaluate(CalcOverThreshold, TaxRateValue.Value);

        if not CalcOverThreshold then
            Error(CalcOverThresholdErr);
    end;

    local procedure GetColumnID(ColumnName: Text): Integer
    var
        TaxRateColumnSetup: Record "Tax Rate Column Setup";
    begin
        TaxRateColumnSetup.SetRange("Tax Type", TDSSetup."Tax Type");
        TaxRateColumnSetup.SetRange("Column Name", ColumnName);
        if TaxRateColumnSetup.FindFirst() then
            exit(TaxRateColumnSetup."Column ID");
    end;

    var
        TDSSetup: Record "TDS Setup";
        Vendor: Record Vendor;
        TDSEntry: Record "TDS Entry";
        VendorNo: Code[20];
        TDSSectionCode: Code[10];
        AssesseeCode: Code[10];
        DocumentNo: Code[20];
        PostingDate: Date;
        PurchaseAmount: Decimal;
        EffectiveDate: Date;
        TDSThresholdAmount: Decimal;
        CalcOverThreshold: Boolean;
        EffectiveDateLbl: Label 'Effective Date', Locked = true;
        TDSThresholdAmountLbl: Label 'TDS Threshold Amount', Locked = true;
        CalcOverThresholdLbl: Label 'Calc. Over & Above Threshold', Locked = true;
        CalcOverThresholdErr: Label 'Calc. Over & Above Threshold must be true in TDS Rates.', Locked = true;
        PostingDateErr: Label 'Posting Date must be earlier than effective date in TDS Rates %1.', Comment = '%1 = Effective Date';
        TDSSectionCodeErr: Label 'TDS Section code must be specified.', Locked = true;
        VendorNoErr: Label 'Vendor No. must be specified.', Locked = true;
        DocumentNoErr: Label 'Document No. must be specified.', Locked = true;
        PurchaseAmountErr: Label 'Purchase Amount must be specified.', Locked = true;
        AllowedSectionErr: Label 'TDS Section Code must have a value in Allowed Section for Vendor No. %1', Comment = '%1 = Vendor No';
}
